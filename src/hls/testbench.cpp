#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <dirent.h>
#include <errno.h>
#include <fstream>
#include <limits.h>
#include <sstream>
#include <string>
#include <sys/stat.h>
#include <unistd.h>
#include <vector>

#include "dump.hpp"
#include "kernels.hpp"
#include "zonotope.hpp"

// ------------------------------
// Simple RNG (portable / HLS-friendly)
// ------------------------------
static unsigned int g_seed = RANDOM_SEED;

static inline data_t rand01() {
    g_seed = 1664525u * g_seed + 1013904223u;
    unsigned int v = (g_seed >> 8) & 0x00FFFFFFu;
    return (data_t)v / (data_t)0x01000000u;
}

static inline data_t uniform_noise(data_t r) { return (2.0 * rand01() - 1.0) * r; }

static bool str_eq(const char* a, const char* b) {
    return a && b && std::strcmp(a, b) == 0;
}

static std::string dirname_of(const std::string& path) {
    const std::string::size_type pos = path.find_last_of('/');
    if (pos == std::string::npos) return ".";
    if (pos == 0) return "/";
    return path.substr(0, pos);
}

static std::string find_repo_root() {
    char resolved[PATH_MAX];
    if (realpath(__FILE__, resolved)) {
        // .../src/hls/testbench.cpp -> repo root
        return dirname_of(dirname_of(dirname_of(std::string(resolved))));
    }

    char cwd[PATH_MAX];
    if (!getcwd(cwd, sizeof(cwd))) return ".";

    std::string dir = cwd;
    for (int i = 0; i < 10; ++i) {
        const std::string src_dir = dir + "/src";
        const std::string data_dir = dir + "/data";
        if (access(src_dir.c_str(), F_OK) == 0 && access(data_dir.c_str(), F_OK) == 0) return dir;
        const std::string parent = dirname_of(dir);
        if (parent == dir) break;
        dir = parent;
    }
    return ".";
}

static void mkdir_p(const std::string& path) {
    if (path.empty()) return;
    std::string tmp;
    tmp.reserve(path.size());

    for (size_t i = 0; i < path.size(); ++i) {
        tmp.push_back(path[i]);
        if (path[i] == '/' || i + 1 == path.size()) {
            if (tmp.size() == 1 && tmp[0] == '/') continue;
            if (mkdir(tmp.c_str(), 0755) != 0 && errno != EEXIST) {
                // best-effort; file IO will fail later if truly fatal
            }
        }
    }
}

static void csv_reset(const std::string& path) { dump_reset_file(path.c_str()); }

static void csv_append_row(const std::string& path, const data_t* x, int n) {
    FILE* f = std::fopen(path.c_str(), "a");
    if (!f) return;
    for (int i = 0; i < n; ++i) {
        std::fprintf(f, "%.17g", x[i]);
        if (i + 1 < n) std::fprintf(f, ",");
    }
    std::fprintf(f, "\n");
    std::fclose(f);
}

static bool all_finite_vec(const data_t* x, int n, int* bad_idx) {
    for (int i = 0; i < n; ++i) {
        if (!std::isfinite(x[i])) {
            if (bad_idx) *bad_idx = i;
            return false;
        }
    }
    return true;
}

static bool all_finite_mat(const data_t H[N_STATE][MAX_GEN], int rows, int cols, int* bad_r, int* bad_c) {
    for (int r = 0; r < rows; ++r) {
        for (int c = 0; c < cols; ++c) {
            if (!std::isfinite(H[r][c])) {
                if (bad_r) *bad_r = r;
                if (bad_c) *bad_c = c;
                return false;
            }
        }
    }
    return true;
}

static void print_finite_status(const char* label, const data_t* p, const data_t H[N_STATE][MAX_GEN], int m) {
    int bad_idx = -1;
    int bad_r = -1;
    int bad_c = -1;
    const bool p_ok = all_finite_vec(p, N_STATE, &bad_idx);
    const bool H_ok = all_finite_mat(H, N_STATE, MAX_GEN, &bad_r, &bad_c);
    std::printf("[debug] %-24s p=%s", label, p_ok ? "finite" : "NONFINITE");
    if (!p_ok) std::printf("(idx=%d val=%g)", bad_idx, (double)p[bad_idx]);
    std::printf(" H=%s", H_ok ? "finite" : "NONFINITE");
    if (!H_ok) std::printf("(r=%d c=%d val=%g)", bad_r, bad_c, (double)H[bad_r][bad_c]);
    std::printf(" m=%d\n", m);
}

static bool load_csv_values(const std::string& path, std::vector<data_t>* out) {
    std::ifstream f(path.c_str());
    if (!f) return false;
    out->clear();
    std::string line;
    while (std::getline(f, line)) {
        for (char& ch : line) {
            if (ch == ',') ch = ' ';
        }
        std::istringstream iss(line);
        double v = 0.0;
        while (iss >> v) out->push_back((data_t)v);
    }
    return true;
}

static int run_file_input_debug(const char* input_dir) {
    const std::string base = input_dir ? input_dir : "";
    if (base.empty()) {
        std::fprintf(stderr, "[filedbg] missing input dir\n");
        return 70;
    }

    std::vector<data_t> A_flat, y_flat, phi_flat, p_input_flat, H_input_flat, p_w_flat, H_w_flat;
    if (!load_csv_values(base + "/A.csv", &A_flat) ||
        !load_csv_values(base + "/y_all.csv", &y_flat) ||
        !load_csv_values(base + "/phi_all.csv", &phi_flat) ||
        !load_csv_values(base + "/p_input.csv", &p_input_flat) ||
        !load_csv_values(base + "/H_input.csv", &H_input_flat) ||
        !load_csv_values(base + "/p_w.csv", &p_w_flat) ||
        !load_csv_values(base + "/H_w.csv", &H_w_flat)) {
        std::fprintf(stderr, "[filedbg] failed to load CSV bundle from %s\n", base.c_str());
        return 71;
    }

    if ((int)A_flat.size() != N_STATE * N_STATE ||
        (int)p_input_flat.size() != N_STATE ||
        (int)H_input_flat.size() != N_STATE * MAX_GEN ||
        (int)p_w_flat.size() != N_STATE ||
        (int)H_w_flat.size() != N_STATE * MAX_GEN ||
        y_flat.size() != phi_flat.size() ||
        (y_flat.size() % N_MEAS) != 0) {
        std::fprintf(stderr, "[filedbg] CSV size mismatch\n");
        return 72;
    }

    int compare_steps = (int)(y_flat.size() / N_MEAS);
    if (const char* env_steps = std::getenv("HLS_DEBUG_COMPARE_STEPS")) {
        const int parsed = std::atoi(env_steps);
        if (parsed > 0 && parsed <= compare_steps) compare_steps = parsed;
    }

    data_t A[N_STATE][N_STATE] = {};
    data_t p_seq[N_STATE] = {};
    data_t H_seq[N_STATE][MAX_GEN] = {};
    data_t p_batch[N_STATE] = {};
    data_t H_batch[N_STATE][MAX_GEN] = {};
    data_t p_w[N_STATE] = {};
    data_t H_w[N_STATE][MAX_GEN] = {};
    int m_seq = N_STATE;
    int m_batch = N_STATE;

    for (int r = 0; r < N_STATE; ++r) {
        p_seq[r] = p_input_flat[r];
        p_batch[r] = p_input_flat[r];
        p_w[r] = p_w_flat[r];
        for (int c = 0; c < N_STATE; ++c) A[r][c] = A_flat[r * N_STATE + c];
        for (int c = 0; c < MAX_GEN; ++c) {
            H_seq[r][c] = H_input_flat[r * MAX_GEN + c];
            H_batch[r][c] = H_input_flat[r * MAX_GEN + c];
            H_w[r][c] = H_w_flat[r * MAX_GEN + c];
        }
    }

    std::printf("[filedbg] sequential trace from %s\n", base.c_str());
    for (int k = 0; k < compare_steps; ++k) {
        data_t y_step[N_MEAS];
        data_t phi_step[N_MEAS];
        for (int j = 0; j < N_MEAS; ++j) {
            y_step[j] = y_flat[k * N_MEAS + j];
            phi_step[j] = phi_flat[k * N_MEAS + j];
        }
        zonotope_step_kernel(p_seq, H_seq, &m_seq, A, p_w, H_w, N_STATE, y_step, phi_step, REDUCTION_BUDGET);
        const bool p_ok = all_finite_vec(p_seq, N_STATE, nullptr);
        const bool H_ok = all_finite_mat(H_seq, N_STATE, MAX_GEN, nullptr, nullptr);
        std::printf("[filedbg] seq step=%d p=%s H=%s m=%d\n", k + 1, p_ok ? "finite" : "NONFINITE",
                    H_ok ? "finite" : "NONFINITE", m_seq);
        if (!p_ok || !H_ok) return 80 + k;
    }

    std::printf("[filedbg] batch trace from %s\n", base.c_str());
    zonotope_batch_kernel_axi(p_batch, &H_batch[0][0], &m_batch, &A[0][0], p_w, &H_w[0][0], N_STATE,
                              y_flat.data(), phi_flat.data(), REDUCTION_BUDGET, compare_steps, 1);
    print_finite_status("file batch", p_batch, H_batch, m_batch);
    if (!all_finite_vec(p_batch, N_STATE, nullptr) || !all_finite_mat(H_batch, N_STATE, MAX_GEN, nullptr, nullptr)) {
        return 180;
    }
    return 0;
}

static inline int debug_meas_state_index(int meas) {
    return (meas / 2) * 4 + (meas % 2);
}

static void mat_mul_square(const data_t A[N_STATE][N_STATE], const data_t B[N_STATE][N_STATE], data_t out[N_STATE][N_STATE]) {
    for (int i = 0; i < N_STATE; ++i) {
        for (int j = 0; j < N_STATE; ++j) {
            data_t s = 0.0;
            for (int k = 0; k < N_STATE; ++k) s += A[i][k] * B[k][j];
            out[i][j] = s;
        }
    }
}

static int observability_rank(const data_t A[N_STATE][N_STATE], const data_t C[N_MEAS][N_STATE], data_t tol) {
    data_t O[N_STATE * N_MEAS][N_STATE] = {0.0};
    data_t A_pow[N_STATE][N_STATE] = {0.0};

    for (int i = 0; i < N_STATE; ++i) A_pow[i][i] = 1.0;

    for (int p = 0; p < N_STATE; ++p) {
        for (int r = 0; r < N_MEAS; ++r) {
            for (int c = 0; c < N_STATE; ++c) {
                data_t v = 0.0;
                for (int j = 0; j < N_STATE; ++j) v += C[r][j] * A_pow[j][c];
                O[p * N_MEAS + r][c] = v;
            }
        }
        if (p + 1 < N_STATE) {
            data_t next_pow[N_STATE][N_STATE] = {0.0};
            mat_mul_square(A_pow, A, next_pow);
            for (int i = 0; i < N_STATE; ++i) {
                for (int j = 0; j < N_STATE; ++j) A_pow[i][j] = next_pow[i][j];
            }
        }
    }

    data_t M[N_STATE * N_MEAS][N_STATE] = {0.0};
    for (int r = 0; r < N_STATE * N_MEAS; ++r) {
        for (int c = 0; c < N_STATE; ++c) M[r][c] = O[r][c];
    }

    int rank = 0;
    const int rows = N_STATE * N_MEAS;
    const int cols = N_STATE;
    for (int col = 0; col < cols && rank < rows; ++col) {
        int pivot = -1;
        data_t pivot_abs = tol;
        for (int r = rank; r < rows; ++r) {
            const data_t a = std::fabs(M[r][col]);
            if (a > pivot_abs) {
                pivot_abs = a;
                pivot = r;
            }
        }
        if (pivot < 0) continue;

        if (pivot != rank) {
            for (int c = col; c < cols; ++c) {
                const data_t tmp = M[rank][c];
                M[rank][c] = M[pivot][c];
                M[pivot][c] = tmp;
            }
        }

        const data_t pv = M[rank][col];
        for (int c = col; c < cols; ++c) M[rank][c] /= pv;

        for (int r = rank + 1; r < rows; ++r) {
            const data_t factor = M[r][col];
            if (std::fabs(factor) <= tol) continue;
            for (int c = col; c < cols; ++c) M[r][c] -= factor * M[rank][c];
        }
        rank++;
    }
    return rank;
}

// Copy of zonotope_reduce(), but returns (and times) only the row_sum_abs_kernel() part.
static double zonotope_reduce_row_sum_us(Zonotope* Z, int max_gens) {
    const int n = Z->n;
    const int m = Z->m;
    if (m <= max_gens) return 0.0;

    double col_norm[MAX_GEN];
    for (int j = 0; j < m; ++j) {
        double s = 0.0;
        for (int i = 0; i < n; ++i) s += Z->H[i][j] * Z->H[i][j];
        col_norm[j] = std::sqrt(s);
    }

    int idx[MAX_GEN];
    for (int j = 0; j < m; ++j) idx[j] = j;

    for (int a = 0; a < m - 1; ++a) {
        int best = a;
        for (int b = a + 1; b < m; ++b) {
            if (col_norm[idx[b]] > col_norm[idx[best]]) best = b;
        }
        const int tmp = idx[a];
        idx[a] = idx[best];
        idx[best] = tmp;
    }

    const int keep = max_gens;
    if (keep < 0) return 0.0;
    if (keep > MAX_GEN) return 0.0;

    data_t H_new[N_STATE][MAX_GEN] = {0.0};
    for (int j = 0; j < keep; ++j) {
        const int old_j = idx[j];
        for (int i = 0; i < n; ++i) H_new[i][j] = Z->H[i][old_j];
    }

    data_t H_drop[N_STATE][MAX_GEN] = {0.0};
    int m_drop = 0;
    for (int k = keep; k < Z->m; ++k) {
        const int old_idx = idx[k];
        for (int i = 0; i < Z->n; ++i) H_drop[i][m_drop] = Z->H[i][old_idx];
        m_drop++;
    }

    data_t d[N_STATE] = {0.0};
    const auto t0 = std::chrono::high_resolution_clock::now();
    row_sum_abs_kernel(H_drop, m_drop, d);
    const auto t1 = std::chrono::high_resolution_clock::now();
    const data_t row_sum_us =
        (data_t)std::chrono::duration_cast<std::chrono::nanoseconds>(t1 - t0).count() / 1000.0;

    for (int i = 0; i < n; ++i) H_new[i][keep + i] = d[i];

    const int m_new = keep + n;
    Z->m = m_new;

    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m_new; ++j) Z->H[i][j] = H_new[i][j];
        for (int j = m_new; j < MAX_GEN; ++j) Z->H[i][j] = 0.0;
    }

    return row_sum_us;
}

// -----------------------------------------------------------------------
// run_batch_method: validates zonotope_batch_kernel_axi.
//
// The true system is simulated on the host to collect all measurements,
// then a single FPGA call processes all NUM_STEPS steps at once.
// This is the pattern used in actual board deployment: measurements are
// pre-collected (e.g. from a sensor buffer) and handed to the FPGA in
// one batch, eliminating per-step AXI overhead.
// -----------------------------------------------------------------------
static void run_batch_method(LambdaMethod method, const char* method_name,
                             const std::string& out_base_dir) {
    g_seed = RANDOM_SEED;
    const char* dump_all_env = std::getenv("HLS_BATCH_DUMP_ALL");
    const bool dump_all_zonotopes =
        (dump_all_env && dump_all_env[0] != '\0' && !str_eq(dump_all_env, "0"));

    const std::string out_dir = out_base_dir + "/" + method_name;
    mkdir_p(out_dir);

    const std::string center_csv   = out_dir + "/center.csv";
    const std::string x_true_csv   = out_dir + "/x_true.csv";
    const std::string meas_csv     = out_dir + "/meas.csv";
    const std::string error_csv    = out_dir + "/error.csv";
    const std::string ktime_step_csv = out_dir + "/kernel_time_step_us.csv";
    const std::string ktime_sum_csv  = out_dir + "/kernel_time_summary_us.csv";

    csv_reset(center_csv);
    csv_reset(x_true_csv);
    csv_reset(meas_csv);
    csv_reset(error_csv);
    csv_reset(ktime_step_csv);
    csv_reset(ktime_sum_csv);
    {
        DIR* d = opendir(out_dir.c_str());
        if (d) {
            struct dirent* entry;
            while ((entry = readdir(d)) != nullptr) {
                const char* name = entry->d_name;
                if (std::strncmp(name, "zonotope_", 9) == 0) {
                    std::remove((out_dir + "/" + name).c_str());
                }
            }
            closedir(d);
        }
    }

    // Build system matrices (time-invariant, same as single-step TB)
    const data_t omega = 0.5;
    const data_t zeta  = 0.05;
    const data_t dt    = DT;
    const data_t decay = std::exp(-zeta * dt);
    const data_t c_cos = std::cos(omega * dt) * decay;
    const data_t c_sin = std::sin(omega * dt) * decay;
    const data_t eps   = 0.1;

    // Build block-diagonal A (N_STATE/4 coupled oscillator blocks)
    data_t A[N_STATE][N_STATE] = {};
    {
        const data_t A_block[4][4] = {
            {  c_cos, -c_sin,  eps,  0.0 },
            {  c_sin,  c_cos,  0.0,  eps },
            { -eps,    0.0,   c_cos, -c_sin },
            {  0.0,   -eps,   c_sin,  c_cos }
        };
        for (int b = 0; b < N_STATE/4; ++b)
            for (int i = 0; i < 4; ++i)
                for (int j = 0; j < 4; ++j)
                    A[b*4+i][b*4+j] = A_block[i][j];
    }
    // C_mat: each 4x4 oscillator block exposes its first two states.
    data_t C_mat[N_MEAS][N_STATE] = {};
    for (int block = 0; block < N_STATE / 4; ++block) {
        const int meas_base = block * 2;
        const int state_base = block * 4;
        if (meas_base + 1 < N_MEAS) {
            C_mat[meas_base + 0][state_base + 0] = 1.0;
            C_mat[meas_base + 1][state_base + 1] = 1.0;
        }
    }

    // Process noise
    data_t p_w[N_STATE] = {0};
    data_t H_w[N_STATE][MAX_GEN] = {};
    for (int i = 0; i < N_STATE; ++i) H_w[i][i] = PROC_NOISE_RADIUS;

    // Simulate true system and collect ALL measurements first
    data_t x_true[N_STATE] = {0};
    for (int b = 0; b < N_STATE/4; ++b) x_true[b*4] = 1.0;
    data_t phi_vec[N_MEAS];
    for (int i = 0; i < N_MEAS; ++i) phi_vec[i] = MEAS_NOISE_RADIUS;

    // Store measurements and true states
    data_t y_all  [N_BATCH * N_MEAS];
    data_t phi_all[N_BATCH * N_MEAS];
    data_t x_true_seq[NUM_STEPS + 1][N_STATE];

    for (int i = 0; i < N_STATE; ++i) x_true_seq[0][i] = x_true[i];

    for (int k = 0; k < NUM_STEPS; ++k) {
        // Propagate true state
        data_t w_k[N_STATE];
        for (int i = 0; i < N_STATE; ++i) w_k[i] = uniform_noise(PROC_NOISE_RADIUS);
        data_t x_next[N_STATE];
        for (int i = 0; i < N_STATE; ++i) {
            data_t tmp = 0.0;
            for (int j = 0; j < N_STATE; ++j) tmp += A[i][j] * x_true[j];
            x_next[i] = tmp + w_k[i];
        }
        for (int i = 0; i < N_STATE; ++i) x_true[i] = x_next[i];
        for (int i = 0; i < N_STATE; ++i) x_true_seq[k + 1][i] = x_true[i];

        // Generate measurement
        for (int j = 0; j < N_MEAS; ++j) {
            const data_t v = uniform_noise(MEAS_NOISE_RADIUS);
            data_t tmp = 0.0;
            for (int l = 0; l < N_STATE; ++l) tmp += C_mat[j][l] * x_true[l];
            y_all  [k * N_MEAS + j] = tmp + v;
            phi_all[k * N_MEAS + j] = phi_vec[j];
        }
    }

    // Initial zonotope
    data_t p_init[N_STATE];
    data_t H_init_flat[N_STATE * MAX_GEN];
    for (int i = 0; i < N_STATE; ++i) {
        p_init[i] = ((i % 4 == 0)) ? 1.0 : 0.0;
        for (int j = 0; j < MAX_GEN; ++j) H_init_flat[i * MAX_GEN + j] = 0.0;
        H_init_flat[i * MAX_GEN + i] = INIT_RADIUS;
    }
    int m_init = N_STATE;

    data_t p_batch[N_STATE];
    data_t H_batch_flat[N_STATE * MAX_GEN];
    int m_batch = m_init;
    for (int i = 0; i < N_STATE; ++i) p_batch[i] = p_init[i];
    for (int i = 0; i < N_STATE * MAX_GEN; ++i) H_batch_flat[i] = H_init_flat[i];

    // Flatten static matrices for AXI interface
    data_t A_flat[N_STATE * N_STATE];
    data_t H_w_flat[N_STATE * MAX_GEN];
    for (int i = 0; i < N_STATE; ++i)
        for (int j = 0; j < N_STATE; ++j)
            A_flat[i * N_STATE + j] = A[i][j];
    for (int r = 0; r < N_STATE; ++r)
        for (int c = 0; c < MAX_GEN; ++c)
            H_w_flat[r * MAX_GEN + c] = H_w[r][c];

    // Dump step0
    dump_true_append(x_true_csv.c_str(), x_true_seq[0]);
    dump_center_append(center_csv.c_str(), p_init);
    {
        Zonotope Ztmp;
        Ztmp.n = N_STATE; Ztmp.m = m_init;
        for (int i = 0; i < N_STATE; ++i) Ztmp.p[i] = p_init[i];
        for (int r = 0; r < N_STATE; ++r)
            for (int c = 0; c < MAX_GEN; ++c)
                Ztmp.H[r][c] = H_init_flat[r * MAX_GEN + c];
        dump_zonotope_csv(Ztmp, 0, out_dir.c_str());
    }

    // ---- Single FPGA call for ALL steps ----
    const auto t0 = std::chrono::high_resolution_clock::now();

    zonotope_batch_kernel_axi(
        p_batch,
        H_batch_flat,
        &m_batch,
        A_flat,
        p_w,
        H_w_flat, N_STATE,
        y_all,
        phi_all,
        REDUCTION_BUDGET,
        NUM_STEPS,
        1
    );

    const auto t1 = std::chrono::high_resolution_clock::now();
    const data_t total_us = (data_t)std::chrono::duration_cast<std::chrono::nanoseconds>(
                                t1 - t0).count() / 1000.0;

    data_t final_center_diff_l2 = 0.0;
    data_t final_h_diff_l2 = 0.0;
    int m_replay = -1;
    if (dump_all_zonotopes) {
        // Replay the same batch one step at a time to export every intermediate
        // zonotope so batch-mode plots can match the single-step visualization.
        data_t p_replay[N_STATE];
        data_t H_replay[N_STATE][MAX_GEN];
        m_replay = m_init;
        for (int i = 0; i < N_STATE; ++i) {
            p_replay[i] = p_init[i];
            for (int j = 0; j < MAX_GEN; ++j) {
                H_replay[i][j] = H_init_flat[i * MAX_GEN + j];
            }
        }

        // Error at step0
        {
            data_t err_row[N_STATE + 1] = {0};
            data_t l2 = 0.0;
            for (int i = 0; i < N_STATE; ++i) {
                const data_t e = p_replay[i] - x_true_seq[0][i];
                err_row[i] = e;
                l2 += e * e;
            }
            err_row[N_STATE] = std::sqrt(l2);
            csv_append_row(error_csv, err_row, N_STATE + 1);
        }

        for (int k = 0; k < NUM_STEPS; ++k) {
            zonotope_step_kernel(
                p_replay,
                H_replay,
                &m_replay,
                A,
                p_w,
                H_w,
                N_STATE,
                &y_all[k * N_MEAS],
                &phi_all[k * N_MEAS],
                REDUCTION_BUDGET
            );

            dump_true_append(x_true_csv.c_str(), x_true_seq[k + 1]);
            dump_center_append(center_csv.c_str(), p_replay);

            Zonotope Zstep;
            Zstep.n = N_STATE;
            Zstep.m = m_replay;
            for (int i = 0; i < N_STATE; ++i) {
                Zstep.p[i] = p_replay[i];
                for (int j = 0; j < MAX_GEN; ++j) {
                    Zstep.H[i][j] = H_replay[i][j];
                }
            }
            dump_zonotope_csv(Zstep, k + 1, out_dir.c_str());

            data_t err_row[N_STATE + 1] = {0};
            data_t l2 = 0.0;
            for (int i = 0; i < N_STATE; ++i) {
                const data_t e = p_replay[i] - x_true_seq[k + 1][i];
                err_row[i] = e;
                l2 += e * e;
            }
            err_row[N_STATE] = std::sqrt(l2);
            csv_append_row(error_csv, err_row, N_STATE + 1);
        }

        for (int i = 0; i < N_STATE; ++i) {
            const data_t dc = p_batch[i] - p_replay[i];
            final_center_diff_l2 += dc * dc;
            for (int j = 0; j < MAX_GEN; ++j) {
                const data_t dh = H_batch_flat[i * MAX_GEN + j] - H_replay[i][j];
                final_h_diff_l2 += dh * dh;
            }
        }
        final_center_diff_l2 = std::sqrt(final_center_diff_l2);
        final_h_diff_l2 = std::sqrt(final_h_diff_l2);
    } else {
        // Keep the original lightweight batch output for fair timing runs.
        dump_true_append(x_true_csv.c_str(), x_true_seq[NUM_STEPS]);
        dump_center_append(center_csv.c_str(), p_batch);
        {
            Zonotope Zfinal;
            Zfinal.n = N_STATE;
            Zfinal.m = m_batch;
            for (int i = 0; i < N_STATE; ++i) Zfinal.p[i] = p_batch[i];
            for (int r = 0; r < N_STATE; ++r)
                for (int c = 0; c < MAX_GEN; ++c)
                    Zfinal.H[r][c] = H_batch_flat[r * MAX_GEN + c];
            dump_zonotope_csv(Zfinal, NUM_STEPS, out_dir.c_str());
        }
        {
            data_t err_row[N_STATE + 1] = {0};
            data_t l2 = 0.0;
            for (int i = 0; i < N_STATE; ++i) {
                const data_t e = p_batch[i] - x_true_seq[NUM_STEPS][i];
                err_row[i] = e;
                l2 += e * e;
            }
            err_row[N_STATE] = std::sqrt(l2);
            csv_append_row(error_csv, err_row, N_STATE + 1);
        }
    }

    const data_t avg_us = total_us / (data_t)NUM_STEPS;
    const data_t ktime_row[3]  = {avg_us, 0.0, 0.0};
    const data_t summary_row[9] = {total_us, 0.0, 0.0,
                                    (data_t)NUM_STEPS, 0.0, 0.0,
                                    avg_us, 0.0, 0.0};
    csv_append_row(ktime_step_csv, ktime_row, 3);
    csv_append_row(ktime_sum_csv, summary_row, 9);

    if (dump_all_zonotopes) {
        std::printf("[BATCH:%s] total=%.1fus (%d steps), avg=%.2fus/step, m_final=%d, replay_m=%d, center_diff_l2=%.3e, H_diff_l2=%.3e, dump_all=1, out=%s\n",
                    method_name, total_us, NUM_STEPS, avg_us, m_batch, m_replay,
                    final_center_diff_l2, final_h_diff_l2, out_dir.c_str());
    } else {
        std::printf("[BATCH:%s] total=%.1fus (%d steps), avg=%.2fus/step, m_final=%d, dump_all=0, out=%s\n",
                    method_name, total_us, NUM_STEPS, avg_us, m_batch, out_dir.c_str());
    }
}

struct MethodItem {
    LambdaMethod method;
    const char* name;
};

static const MethodItem kMethods[] = {
    {LAMBDA_SEGMENT, "LAMBDA_SEGMENT"},
};

static void run_one_method(LambdaMethod method, const char* method_name, const std::string& out_base_dir) {
    // Reset RNG so every method sees the same noise sequence (for fair comparison)
    g_seed = RANDOM_SEED;

    const std::string out_dir = out_base_dir + "/" + method_name;
    mkdir_p(out_dir);

    const std::string center_csv = out_dir + "/center.csv";
    const std::string x_true_csv = out_dir + "/x_true.csv";
    const std::string meas_csv = out_dir + "/meas.csv";                 // y_k[0], y_k[1]
    const std::string error_csv = out_dir + "/error.csv";               // err[0..3], l2
    const std::string ktime_step_csv = out_dir + "/kernel_time_step_us.csv";  // step_axi, reserved, reserved
    const std::string ktime_sum_csv = out_dir + "/kernel_time_summary_us.csv";
    const std::string obs_csv = out_dir + "/obs_rank.csv";              // k, rank, pass

    csv_reset(center_csv);
    csv_reset(x_true_csv);
    csv_reset(meas_csv);
    csv_reset(error_csv);
    csv_reset(ktime_step_csv);
    csv_reset(ktime_sum_csv);
    csv_reset(obs_csv);

    // Remove stale zonotope files from previous runs with different NUM_STEPS
    {
        DIR* d = opendir(out_dir.c_str());
        if (d) {
            struct dirent* entry;
            while ((entry = readdir(d)) != nullptr) {
                const char* name = entry->d_name;
                if (std::strncmp(name, "zonotope_", 9) == 0) {
                    const std::string fpath = out_dir + "/" + name;
                    std::remove(fpath.c_str());
                }
            }
            closedir(d);
        }
    }

    // True state (first state of each 4-state block = 1.0)
    data_t x_true[N_STATE] = {0.0};
    for (int b = 0; b < N_STATE/4; ++b) x_true[b*4] = 1.0;

    data_t phi_vec[N_MEAS];
    for (int i = 0; i < N_MEAS; ++i) phi_vec[i] = MEAS_NOISE_RADIUS;

    // Initial zonotope X
    Zonotope X;
    X.n = N_STATE;
    X.m = N_STATE;
    for (int i = 0; i < N_STATE; ++i) {
        X.p[i] = (i == 0) ? 1.0 : 0.0;
        for (int j = 0; j < MAX_GEN; ++j) X.H[i][j] = 0.0;
        X.H[i][i] = INIT_RADIUS;
    }

    // Process noise W: p_w=0, H_w=diag(PROC_NOISE_RADIUS)
    data_t p_w[N_STATE] = {0};
    data_t H_w[N_STATE][MAX_GEN] = {0};
    for (int i = 0; i < N_STATE; ++i) H_w[i][i] = PROC_NOISE_RADIUS;

    // Dump step0
    dump_true_append(x_true_csv.c_str(), x_true);
    dump_center_append(center_csv.c_str(), X.p);
    dump_zonotope_csv(X, 0, out_dir.c_str());

    // Error at step0
    {
        data_t err_row[N_STATE + 1] = {0};
        data_t l2 = 0.0;
        for (int i = 0; i < N_STATE; ++i) {
            const data_t e = X.p[i] - x_true[i];
            err_row[i] = e;
            l2 += e * e;
        }
        err_row[N_STATE] = std::sqrt(l2);
        csv_append_row(error_csv, err_row, N_STATE + 1);
    }

    data_t total_step_us = 0.0;
    data_t total_reserved1_us = 0.0;
    data_t total_reserved2_us = 0.0;
    long long count_step = 0;
    long long count_reserved1 = 0;
    long long count_reserved2 = 0;
    int min_obs_rank = N_STATE;

    for (int k = 0; k < NUM_STEPS; ++k) {
        // system matrices (match src/main.cpp)
        // const data_t theta = 0.05 * k * DT;
        // const data_t cth = std::cos(theta);
        // const data_t sth = std::sin(theta);
        // data_t eps = 0.1;
        // data_t delta = 0.05;

        // const data_t A[N_STATE][N_STATE] = {
        //     {cth, -1.5 * sth, eps, 0},
        //     {1.5 * sth, cth, 0, eps},
        //     {-delta, 0, 1, 0},
        //     {0, -delta, 0, 1},
        // };
        // 定义参数 (建议将 DT, omega, zeta 定义为常量或从外部传入)
        const data_t omega = 0.5;   // 振荡频率
        const data_t zeta = 0.05;   // 阻尼比
        const data_t dt = DT;       // 采样时间步长

        // 计算旋转分量 c 和 s (包含阻尼衰减)
        const data_t decay = std::exp(-zeta * dt);
        const data_t c = std::cos(omega * dt) * decay;
        const data_t s = std::sin(omega * dt) * decay;

        // 耦合系数 (对应 Python 中的 0.1)
        const data_t eps = 0.1;

        // Build block-diagonal A (N_STATE/4 coupled oscillator blocks)
        data_t A[N_STATE][N_STATE] = {};
        {
            const data_t A_block[4][4] = {
                {  c,  -s,  eps,  0.0 },
                {  s,   c,  0.0,  eps },
                {-eps, 0.0,   c,   -s },
                { 0.0, -eps,  s,    c }
            };
            for (int b = 0; b < N_STATE/4; ++b)
                for (int i = 0; i < 4; ++i)
                    for (int j = 0; j < 4; ++j)
                        A[b*4+i][b*4+j] = A_block[i][j];
        }
        // C: each 4x4 oscillator block exposes its first two states.
        data_t C[N_MEAS][N_STATE] = {};
        for (int block = 0; block < N_STATE / 4; ++block) {
            const int meas_base = block * 2;
            const int state_base = block * 4;
            if (meas_base + 1 < N_MEAS) {
                C[meas_base + 0][state_base + 0] = 1.0;
                C[meas_base + 1][state_base + 1] = 1.0;
            }
        }

        const int obs_rank = observability_rank(A, C, 1e-6);
        if (obs_rank < min_obs_rank) min_obs_rank = obs_rank;
        const data_t obs_row[3] = {(data_t)k, (data_t)obs_rank, (obs_rank == N_STATE) ? (data_t)1.0 : (data_t)0.0};
        csv_append_row(obs_csv, obs_row, 3);

        // TRUE SYSTEM: x_{k+1} = A x_k + w
        data_t w_k[N_STATE];
        for (int i = 0; i < N_STATE; ++i) w_k[i] = uniform_noise(PROC_NOISE_RADIUS);

        data_t x_next[N_STATE];
        for (int i = 0; i < N_STATE; ++i) {
            data_t tmp = 0.0;
            for (int j = 0; j < N_STATE; ++j) tmp += A[i][j] * x_true[j];
            x_next[i] = tmp + w_k[i];
        }
        for (int i = 0; i < N_STATE; ++i) x_true[i] = x_next[i];

        // measurement y_k = C x_true + v
        data_t y_k[N_MEAS];
        for (int i = 0; i < N_MEAS; ++i) {
            const data_t v = uniform_noise(MEAS_NOISE_RADIUS);
            data_t tmp = 0.0;
            for (int j = 0; j < N_STATE; ++j) tmp += C[i][j] * x_true[j];
            y_k[i] = tmp + v;
        }
        csv_append_row(meas_csv, y_k, N_MEAS);

        // -------- One Complete AXI-top Step --------
        const auto t_step0 = std::chrono::high_resolution_clock::now();

        zonotope_step_kernel_axi(
            X.p,
            &X.H[0][0],
            &X.m,
            &A[0][0],
            p_w,
            &H_w[0][0], N_STATE,
            y_k,
            phi_vec,
            REDUCTION_BUDGET
        );

        const auto t_step1 = std::chrono::high_resolution_clock::now();
        const data_t step_axi_us =
            (data_t)std::chrono::duration_cast<std::chrono::nanoseconds>(t_step1 - t_step0).count() / 1000.0;

        total_step_us += step_axi_us;
        count_step += 1;

        data_t reserved1_us = 0.0;
        data_t reserved2_us = 0.0;

        // dump: x_true/center/zonotope
        dump_true_append(x_true_csv.c_str(), x_true);
        dump_center_append(center_csv.c_str(), X.p);
        dump_zonotope_csv(X, k + 1, out_dir.c_str());

        // error at this step
        data_t err_row[N_STATE + 1] = {0};
        data_t l2 = 0.0;
        for (int i = 0; i < N_STATE; ++i) {
            const data_t e = X.p[i] - x_true[i];
            err_row[i] = e;
            l2 += e * e;
        }
        err_row[N_STATE] = std::sqrt(l2);
        csv_append_row(error_csv, err_row, N_STATE + 1);

        // kernel timing per step (AXI top / reserved / reserved)
        const data_t ktime_row[3] = {step_axi_us, reserved1_us, reserved2_us};
        csv_append_row(ktime_step_csv, ktime_row, 3);

        if (k % 50 == 0) {
            std::printf("[%s] k=%d done (m=%d, step_axi=%.1fus)\n",
                        method_name, k, X.m, step_axi_us);
        }
    }

    const data_t avg_step_us = (count_step > 0) ? (total_step_us / (data_t)count_step) : 0.0;
    const data_t avg_reserved1_us =
        (count_reserved1 > 0) ? (total_reserved1_us / (data_t)count_reserved1) : 0.0;
    const data_t avg_reserved2_us =
        (count_reserved2 > 0) ? (total_reserved2_us / (data_t)count_reserved2) : 0.0;

    const data_t summary_row[9] = {
        total_step_us, total_reserved1_us, total_reserved2_us,
        (data_t)count_step, (data_t)count_reserved1, (data_t)count_reserved2,
        avg_step_us, avg_reserved1_us, avg_reserved2_us,
    };
    csv_append_row(ktime_sum_csv, summary_row, 9);

    std::printf("[%s] outputs: %s\n", method_name, out_dir.c_str());
    std::printf("[%s] observability: min_rank=%d/%d => %s (%s)\n", method_name, min_obs_rank, N_STATE,
                (min_obs_rank == N_STATE) ? "PASS" : "FAIL", obs_csv.c_str());
    std::printf("[%s] kernel_time_summary_us.csv: total_step_axi=%.1fus (n=%lld, avg=%.1fus)\n",
                method_name, total_step_us, count_step, avg_step_us);
}

static int run_first_step_debug() {
    data_t A[N_STATE][N_STATE] = {};
    data_t p_w[N_STATE] = {0};
    data_t H_w[N_STATE][MAX_GEN] = {};
    data_t phi[N_MEAS];
    data_t y[N_MEAS];

    const data_t omega = 0.5;
    const data_t zeta = 0.05;
    const data_t dt = DT;
    const data_t decay = std::exp(-zeta * dt);
    const data_t c = std::cos(omega * dt) * decay;
    const data_t s = std::sin(omega * dt) * decay;
    const data_t eps = 0.1;
    const data_t A_block[4][4] = {
        {c, -s, eps, 0.0},
        {s, c, 0.0, eps},
        {-eps, 0.0, c, -s},
        {0.0, -eps, s, c},
    };
    for (int b = 0; b < N_STATE / 4; ++b) {
        for (int i = 0; i < 4; ++i) {
            for (int j = 0; j < 4; ++j) {
                A[b * 4 + i][b * 4 + j] = A_block[i][j];
            }
        }
    }
    for (int i = 0; i < N_STATE; ++i) {
        H_w[i][i] = PROC_NOISE_RADIUS;
    }
    for (int i = 0; i < N_MEAS; ++i) {
        y[i] = 0.0f;
        phi[i] = 1.0f;
    }

    Zonotope Z = {};
    Z.n = N_STATE;
    Z.m = N_STATE;
    for (int b = 0; b < N_STATE / 4; ++b) Z.p[b * 4] = 1.0f;
    for (int i = 0; i < N_STATE; ++i) Z.H[i][i] = INIT_RADIUS;

    std::printf("[debug] first-step constant-input trace\n");
    print_finite_status("initial", Z.p, Z.H, Z.m);

    data_t p_tmp[N_STATE];
    data_t col_tmp[N_STATE];
    for (int b = 0; b < N_STATE / 4; ++b) {
        const int base = b * 4;
        const data_t x0 = Z.p[base + 0];
        const data_t x1 = Z.p[base + 1];
        const data_t x2 = Z.p[base + 2];
        const data_t x3 = Z.p[base + 3];
        p_tmp[base + 0] = p_w[base + 0] + A[base + 0][base + 0] * x0 + A[base + 0][base + 1] * x1
                        + A[base + 0][base + 2] * x2 + A[base + 0][base + 3] * x3;
        p_tmp[base + 1] = p_w[base + 1] + A[base + 1][base + 0] * x0 + A[base + 1][base + 1] * x1
                        + A[base + 1][base + 2] * x2 + A[base + 1][base + 3] * x3;
        p_tmp[base + 2] = p_w[base + 2] + A[base + 2][base + 0] * x0 + A[base + 2][base + 1] * x1
                        + A[base + 2][base + 2] * x2 + A[base + 2][base + 3] * x3;
        p_tmp[base + 3] = p_w[base + 3] + A[base + 3][base + 0] * x0 + A[base + 3][base + 1] * x1
                        + A[base + 3][base + 2] * x2 + A[base + 3][base + 3] * x3;
    }
    for (int i = 0; i < N_STATE; ++i) Z.p[i] = p_tmp[i];
    for (int k = 0; k < Z.m; ++k) {
        for (int b = 0; b < N_STATE / 4; ++b) {
            const int base = b * 4;
            const data_t h0 = Z.H[base + 0][k];
            const data_t h1 = Z.H[base + 1][k];
            const data_t h2 = Z.H[base + 2][k];
            const data_t h3 = Z.H[base + 3][k];
            col_tmp[base + 0] = A[base + 0][base + 0] * h0 + A[base + 0][base + 1] * h1
                              + A[base + 0][base + 2] * h2 + A[base + 0][base + 3] * h3;
            col_tmp[base + 1] = A[base + 1][base + 0] * h0 + A[base + 1][base + 1] * h1
                              + A[base + 1][base + 2] * h2 + A[base + 1][base + 3] * h3;
            col_tmp[base + 2] = A[base + 2][base + 0] * h0 + A[base + 2][base + 1] * h1
                              + A[base + 2][base + 2] * h2 + A[base + 2][base + 3] * h3;
            col_tmp[base + 3] = A[base + 3][base + 0] * h0 + A[base + 3][base + 1] * h1
                              + A[base + 3][base + 2] * h2 + A[base + 3][base + 3] * h3;
        }
        for (int i = 0; i < N_STATE; ++i) Z.H[i][k] = col_tmp[i];
    }
    for (int k = 0; k < N_STATE; ++k) {
        for (int i = 0; i < N_STATE; ++i) Z.H[i][Z.m + k] = H_w[i][k];
    }
    Z.m += N_STATE;
    print_finite_status("after predict+append", Z.p, Z.H, Z.m);

    zonotope_reduce(Z.H, &Z.m);
    print_finite_status("after early reduce", Z.p, Z.H, Z.m);

    for (int meas = 0; meas < N_MEAS; ++meas) {
        const int meas_state = debug_meas_state_index(meas);
        data_t lambda[N_STATE];
        for (int i = 0; i < N_STATE; ++i) lambda[i] = 0.0f;
        compute_lambda_segment(lambda, Z.H, Z.m, meas_state, phi[meas]);

        int bad_idx = -1;
        if (!all_finite_vec(lambda, N_STATE, &bad_idx)) {
            std::printf("[debug] lambda NONFINITE at meas=%d idx=%d val=%g\n",
                        meas, bad_idx, (double)lambda[bad_idx]);
            return 10 + meas;
        }

        data_t denom = phi[meas] * phi[meas];
        for (int j = 0; j < Z.m; ++j) {
            denom += Z.H[meas_state][j] * Z.H[meas_state][j];
        }
        std::printf("[debug] meas=%d state=%d denom=%g lambda0=%g\n",
                    meas, meas_state, (double)denom, (double)lambda[0]);

        const data_t residual = Z.p[meas_state];
        const data_t r = y[meas] - residual;
        for (int i = 0; i < N_STATE; ++i) Z.p[i] += lambda[i] * r;
        for (int j = 0; j < Z.m; ++j) {
            const data_t t = Z.H[meas_state][j];
            for (int i = 0; i < N_STATE; ++i) Z.H[i][j] -= lambda[i] * t;
        }
        for (int i = 0; i < N_STATE; ++i) Z.H[i][Z.m] = phi[meas] * lambda[i];
        Z.m += 1;

        char label[64];
        std::snprintf(label, sizeof(label), "after meas %d", meas);
        print_finite_status(label, Z.p, Z.H, Z.m);
        if (!all_finite_vec(Z.p, N_STATE, nullptr) || !all_finite_mat(Z.H, N_STATE, MAX_GEN, nullptr, nullptr)) {
            return 100 + meas;
        }
    }

    zonotope_reduce(Z.H, &Z.m);
    print_finite_status("after final reduce", Z.p, Z.H, Z.m);

    data_t p_step[N_STATE];
    data_t H_step[N_STATE][MAX_GEN] = {};
    int m_step = N_STATE;
    for (int b = 0; b < N_STATE / 4; ++b) p_step[b * 4] = 1.0f;
    for (int i = 0; i < N_STATE; ++i) H_step[i][i] = INIT_RADIUS;
    zonotope_step_kernel(p_step, H_step, &m_step, A, p_w, H_w, N_STATE, y, phi, REDUCTION_BUDGET);
    print_finite_status("direct step kernel", p_step, H_step, m_step);

    data_t p_axi[N_STATE];
    data_t H_axi[N_STATE][MAX_GEN] = {};
    int m_axi = N_STATE;
    for (int b = 0; b < N_STATE / 4; ++b) p_axi[b * 4] = 1.0f;
    for (int i = 0; i < N_STATE; ++i) H_axi[i][i] = INIT_RADIUS;
    zonotope_step_kernel_axi(p_axi, &H_axi[0][0], &m_axi, &A[0][0], p_w, &H_w[0][0], N_STATE, y, phi, REDUCTION_BUDGET);
    print_finite_status("axi step kernel", p_axi, H_axi, m_axi);

    data_t p_batch[N_STATE];
    data_t H_batch[N_STATE][MAX_GEN] = {};
    int m_batch = N_STATE;
    data_t y_all[N_MEAS];
    data_t phi_all[N_MEAS];
    for (int i = 0; i < N_MEAS; ++i) {
        y_all[i] = y[i];
        phi_all[i] = phi[i];
    }
    for (int b = 0; b < N_STATE / 4; ++b) p_batch[b * 4] = 1.0f;
    for (int i = 0; i < N_STATE; ++i) H_batch[i][i] = INIT_RADIUS;
    zonotope_batch_kernel_axi(p_batch, &H_batch[0][0], &m_batch, &A[0][0], p_w, &H_w[0][0], N_STATE,
                              y_all, phi_all, REDUCTION_BUDGET, 1, 1);
    print_finite_status("batch kernel 1-step", p_batch, H_batch, m_batch);
    return 0;
}

static int run_batch_compare_debug() {
    int compare_steps = 103;
    if (const char* env_steps = std::getenv("HLS_DEBUG_COMPARE_STEPS")) {
        const int parsed = std::atoi(env_steps);
        if (parsed > 0 && parsed <= NUM_STEPS) {
            compare_steps = parsed;
        }
    }

    data_t A[N_STATE][N_STATE] = {};
    data_t p_w[N_STATE] = {0};
    data_t H_w[N_STATE][MAX_GEN] = {};
    data_t y_all[compare_steps][N_MEAS];
    data_t phi_all[compare_steps][N_MEAS];
    data_t x_true[N_STATE] = {0};

    const data_t omega = 0.5;
    const data_t zeta = 0.05;
    const data_t dt = DT;
    const data_t decay = std::exp(-zeta * dt);
    const data_t c_cos = std::cos(omega * dt) * decay;
    const data_t c_sin = std::sin(omega * dt) * decay;
    const data_t eps = 0.1;
    const data_t A_block[4][4] = {
        {c_cos, -c_sin, eps, 0.0},
        {c_sin, c_cos, 0.0, eps},
        {-eps, 0.0, c_cos, -c_sin},
        {0.0, -eps, c_sin, c_cos},
    };
    data_t C[N_MEAS][N_STATE] = {};

    for (int b = 0; b < N_STATE / 4; ++b) {
        for (int i = 0; i < 4; ++i) {
            for (int j = 0; j < 4; ++j) {
                A[b * 4 + i][b * 4 + j] = A_block[i][j];
            }
        }
        x_true[b * 4] = 1.0f;
    }
    for (int i = 0; i < N_STATE; ++i) H_w[i][i] = PROC_NOISE_RADIUS;
    for (int block = 0; block < N_STATE / 4; ++block) {
        const int meas_base = block * 2;
        const int state_base = block * 4;
        C[meas_base + 0][state_base + 0] = 1.0f;
        C[meas_base + 1][state_base + 1] = 1.0f;
    }

    g_seed = RANDOM_SEED;
    for (int k = 0; k < compare_steps; ++k) {
        data_t w_k[N_STATE];
        for (int i = 0; i < N_STATE; ++i) w_k[i] = uniform_noise(PROC_NOISE_RADIUS);
        data_t x_next[N_STATE];
        for (int i = 0; i < N_STATE; ++i) {
            data_t tmp = 0.0f;
            for (int j = 0; j < N_STATE; ++j) tmp += A[i][j] * x_true[j];
            x_next[i] = tmp + w_k[i];
        }
        for (int i = 0; i < N_STATE; ++i) x_true[i] = x_next[i];

        for (int j = 0; j < N_MEAS; ++j) {
            const data_t v = uniform_noise(MEAS_NOISE_RADIUS);
            data_t tmp = 0.0f;
            for (int l = 0; l < N_STATE; ++l) tmp += C[j][l] * x_true[l];
            y_all[k][j] = tmp + v;
            phi_all[k][j] = MEAS_NOISE_RADIUS;
        }
    }

    data_t p_seq[N_STATE] = {0};
    data_t H_seq[N_STATE][MAX_GEN] = {};
    int m_seq = N_STATE;
    data_t p_batch[N_STATE] = {0};
    data_t H_batch[N_STATE][MAX_GEN] = {};
    int m_batch = N_STATE;
    data_t y_flat[compare_steps * N_MEAS];
    data_t phi_flat[compare_steps * N_MEAS];

    for (int b = 0; b < N_STATE / 4; ++b) {
        p_seq[b * 4] = 1.0f;
        p_batch[b * 4] = 1.0f;
    }
    for (int i = 0; i < N_STATE; ++i) {
        H_seq[i][i] = INIT_RADIUS;
        H_batch[i][i] = INIT_RADIUS;
    }
    for (int k = 0; k < compare_steps; ++k) {
        for (int j = 0; j < N_MEAS; ++j) {
            y_flat[k * N_MEAS + j] = y_all[k][j];
            phi_flat[k * N_MEAS + j] = phi_all[k][j];
        }
    }

    std::printf("[debug103] sequential single-step trace\n");
    for (int k = 0; k < compare_steps; ++k) {
        if (k == 101) {
            Zonotope Z = {};
            Z.n = N_STATE;
            Z.m = m_seq;
            for (int i = 0; i < N_STATE; ++i) {
                Z.p[i] = p_seq[i];
                for (int j = 0; j < MAX_GEN; ++j) Z.H[i][j] = H_seq[i][j];
            }
            print_finite_status("step102 entry", Z.p, Z.H, Z.m);

            data_t p_tmp[N_STATE];
            data_t col_tmp[N_STATE];
            for (int b = 0; b < N_STATE / 4; ++b) {
                const int base = b * 4;
                const data_t x0 = Z.p[base + 0];
                const data_t x1 = Z.p[base + 1];
                const data_t x2 = Z.p[base + 2];
                const data_t x3 = Z.p[base + 3];
                p_tmp[base + 0] = p_w[base + 0] + A[base + 0][base + 0] * x0 + A[base + 0][base + 1] * x1
                                + A[base + 0][base + 2] * x2 + A[base + 0][base + 3] * x3;
                p_tmp[base + 1] = p_w[base + 1] + A[base + 1][base + 0] * x0 + A[base + 1][base + 1] * x1
                                + A[base + 1][base + 2] * x2 + A[base + 1][base + 3] * x3;
                p_tmp[base + 2] = p_w[base + 2] + A[base + 2][base + 0] * x0 + A[base + 2][base + 1] * x1
                                + A[base + 2][base + 2] * x2 + A[base + 2][base + 3] * x3;
                p_tmp[base + 3] = p_w[base + 3] + A[base + 3][base + 0] * x0 + A[base + 3][base + 1] * x1
                                + A[base + 3][base + 2] * x2 + A[base + 3][base + 3] * x3;
            }
            for (int i = 0; i < N_STATE; ++i) Z.p[i] = p_tmp[i];
            for (int gen = 0; gen < Z.m; ++gen) {
                for (int b = 0; b < N_STATE / 4; ++b) {
                    const int base = b * 4;
                    const data_t h0 = Z.H[base + 0][gen];
                    const data_t h1 = Z.H[base + 1][gen];
                    const data_t h2 = Z.H[base + 2][gen];
                    const data_t h3 = Z.H[base + 3][gen];
                    col_tmp[base + 0] = A[base + 0][base + 0] * h0 + A[base + 0][base + 1] * h1
                                      + A[base + 0][base + 2] * h2 + A[base + 0][base + 3] * h3;
                    col_tmp[base + 1] = A[base + 1][base + 0] * h0 + A[base + 1][base + 1] * h1
                                      + A[base + 1][base + 2] * h2 + A[base + 1][base + 3] * h3;
                    col_tmp[base + 2] = A[base + 2][base + 0] * h0 + A[base + 2][base + 1] * h1
                                      + A[base + 2][base + 2] * h2 + A[base + 2][base + 3] * h3;
                    col_tmp[base + 3] = A[base + 3][base + 0] * h0 + A[base + 3][base + 1] * h1
                                      + A[base + 3][base + 2] * h2 + A[base + 3][base + 3] * h3;
                }
                for (int i = 0; i < N_STATE; ++i) Z.H[i][gen] = col_tmp[i];
            }
            for (int gen = 0; gen < N_STATE; ++gen) {
                for (int i = 0; i < N_STATE; ++i) Z.H[i][Z.m + gen] = H_w[i][gen];
            }
            Z.m += N_STATE;
            print_finite_status("step102 after predict", Z.p, Z.H, Z.m);

            zonotope_reduce(Z.H, &Z.m);
            print_finite_status("step102 after early reduce", Z.p, Z.H, Z.m);

            for (int meas = 0; meas < N_MEAS; ++meas) {
                const int meas_state = debug_meas_state_index(meas);
                data_t lambda[N_STATE];
                for (int i = 0; i < N_STATE; ++i) lambda[i] = 0.0f;
                compute_lambda_segment(lambda, Z.H, Z.m, meas_state, phi_all[k][meas]);
                int bad_idx = -1;
                if (!all_finite_vec(lambda, N_STATE, &bad_idx)) {
                    std::printf("[debug103] step102 meas=%d lambda bad idx=%d val=%g\n",
                                meas, bad_idx, (double)lambda[bad_idx]);
                    return 300 + meas;
                }
                const data_t residual = Z.p[meas_state];
                const data_t r = y_all[k][meas] - residual;
                for (int i = 0; i < N_STATE; ++i) Z.p[i] += lambda[i] * r;
                for (int j = 0; j < Z.m; ++j) {
                    const data_t t = Z.H[meas_state][j];
                    for (int i = 0; i < N_STATE; ++i) Z.H[i][j] -= lambda[i] * t;
                }
                for (int i = 0; i < N_STATE; ++i) Z.H[i][Z.m] = phi_all[k][meas] * lambda[i];
                Z.m += 1;
                char label[64];
                std::snprintf(label, sizeof(label), "step102 after meas %d", meas);
                print_finite_status(label, Z.p, Z.H, Z.m);
                if (!all_finite_vec(Z.p, N_STATE, nullptr) || !all_finite_mat(Z.H, N_STATE, MAX_GEN, nullptr, nullptr)) {
                    return 400 + meas;
                }
            }

            zonotope_reduce(Z.H, &Z.m);
            print_finite_status("step102 after final reduce", Z.p, Z.H, Z.m);
        }

        zonotope_step_kernel(p_seq, H_seq, &m_seq, A, p_w, H_w, N_STATE, y_all[k], phi_all[k], REDUCTION_BUDGET);
        const bool p_ok = all_finite_vec(p_seq, N_STATE, nullptr);
        const bool H_ok = all_finite_mat(H_seq, N_STATE, MAX_GEN, nullptr, nullptr);
        std::printf("[debug103] seq step=%d p=%s H=%s m=%d\n", k + 1, p_ok ? "finite" : "NONFINITE",
                    H_ok ? "finite" : "NONFINITE", m_seq);
        if (!p_ok || !H_ok) return 200 + k;
    }

    std::printf("[debug103] batch trace\n");
    zonotope_batch_kernel_axi(p_batch, &H_batch[0][0], &m_batch, &A[0][0], p_w, &H_w[0][0], N_STATE,
                              y_flat, phi_flat, REDUCTION_BUDGET, compare_steps, 1);
    print_finite_status("batch 103-step", p_batch, H_batch, m_batch);

    int first_bad_col = -1;
    for (int c = 0; c < MAX_GEN; ++c) {
        bool col_ok = true;
        for (int r = 0; r < N_STATE; ++r) {
            if (!std::isfinite(H_batch[r][c])) {
                col_ok = false;
                break;
            }
        }
        if (!col_ok) {
            first_bad_col = c;
            break;
        }
    }

    data_t max_abs = 0.0f;
    for (int r = 0; r < N_STATE; ++r) {
        for (int c = 0; c < MAX_GEN; ++c) {
            const data_t v = H_batch[r][c];
            if (std::isfinite(v)) {
                const data_t a = (v < 0.0f) ? -v : v;
                if (a > max_abs) max_abs = a;
            }
        }
    }
    std::printf("[debug103] batch first_bad_col=%d max_abs_finite_H=%g\n",
                first_bad_col, (double)max_abs);
    return 0;
}

int main() {
    const std::string repo_root = find_repo_root();
    const char* sim_mode = std::getenv("HLS_SIM_MODE");
    if (!sim_mode || sim_mode[0] == '\0') sim_mode = "unknown";

    // HLS_TB_MODE: "batch" (default) = accelerator-style path; "step" keeps
    // the original per-step wrapper for debugging/regression only.
    const char* tb_mode = std::getenv("HLS_TB_MODE");
    const bool use_batch = !(tb_mode && str_eq(tb_mode, "step"));

    const std::string out_base_dir = repo_root + "/data/output/hls/"
                                     + sim_mode
                                     + (use_batch ? "_batch" : "");
    mkdir_p(out_base_dir);

    const char* only_method = std::getenv("HLS_LAMBDA_METHOD");  // optional filter
    const char* debug_first_step = std::getenv("HLS_DEBUG_FIRST_STEP");
    const char* debug_batch_compare = std::getenv("HLS_DEBUG_BATCH_COMPARE");
    const char* debug_file_input_dir = std::getenv("HLS_DEBUG_FILE_INPUT_DIR");

    std::printf("FPGA TB repo_root=%s\n", repo_root.c_str());
    std::printf("FPGA TB out_base=%s\n", out_base_dir.c_str());
    std::printf("FPGA TB mode=%s\n", use_batch ? "batch" : "step");
    if (only_method && only_method[0] != '\0') std::printf("FPGA TB method filter: %s\n", only_method);
    if (debug_first_step && debug_first_step[0] != '\0') {
        return run_first_step_debug();
    }
    if (debug_batch_compare && debug_batch_compare[0] != '\0') {
        return run_batch_compare_debug();
    }
    if (debug_file_input_dir && debug_file_input_dir[0] != '\0') {
        return run_file_input_debug(debug_file_input_dir);
    }

    bool ran_any = false;
    for (const auto& it : kMethods) {
        if (only_method && only_method[0] != '\0' && !str_eq(only_method, it.name)) continue;
        if (use_batch)
            run_batch_method(it.method, it.name, out_base_dir);
        else
            run_one_method(it.method, it.name, out_base_dir);
        ran_any = true;
    }

    if (!ran_any) {
        std::printf("No method matched HLS_LAMBDA_METHOD=%s\n", (only_method && only_method[0]) ? only_method : "(unset)");
        std::printf("Valid: LAMBDA_SEGMENT\n");
        return 2;
    }

    std::printf("All done. Results under: %s\n", out_base_dir.c_str());
    return 0;
}
