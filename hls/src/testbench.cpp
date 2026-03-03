#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <errno.h>
#include <limits.h>
#include <string>
#include <sys/stat.h>
#include <unistd.h>

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

static std::string dirname_of(const std::string& path) {
    const std::string::size_type pos = path.find_last_of('/');
    if (pos == std::string::npos) return ".";
    if (pos == 0) return "/";
    return path.substr(0, pos);
}

static std::string find_repo_root() {
    char resolved[PATH_MAX];
    if (realpath(__FILE__, resolved)) {
        // .../hls/src/testbench.cpp -> .../hls
        return dirname_of(dirname_of(std::string(resolved)));
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

struct MethodItem {
    LambdaMethod method;
    const char* name;
};

static const MethodItem kMethods[] = {
    {LAMBDA_NONE, "LAMBDA_NONE"},
    {LAMBDA_SEGMENT, "LAMBDA_SEGMENT"},
    {LAMBDA_VOLUME, "LAMBDA_VOLUME"},
    {LAMBDA_P_RADIUS, "LAMBDA_P_RADIUS"},
};

static bool str_eq(const char* a, const char* b) { return a && b && std::strcmp(a, b) == 0; }

static void run_one_method(LambdaMethod method, const char* method_name, const std::string& out_base_dir) {
    // Reset RNG so every method sees the same noise sequence (for fair comparison)
    g_seed = RANDOM_SEED;

    const std::string out_dir = out_base_dir + "/" + method_name;
    mkdir_p(out_dir);

    const std::string center_csv = out_dir + "/center.csv";
    const std::string x_true_csv = out_dir + "/x_true.csv";
    const std::string meas_csv = out_dir + "/meas.csv";                 // y_k[0], y_k[1]
    const std::string error_csv = out_dir + "/error.csv";               // err[0..3], l2
    const std::string ktime_step_csv = out_dir + "/kernel_time_step_us.csv";  // predict, strip(total), row_sum
    const std::string ktime_sum_csv = out_dir + "/kernel_time_summary_us.csv";

    csv_reset(center_csv);
    csv_reset(x_true_csv);
    csv_reset(meas_csv);
    csv_reset(error_csv);
    csv_reset(ktime_step_csv);
    csv_reset(ktime_sum_csv);

    // True state
    data_t x_true[N_STATE] = {0.0};
    x_true[0] = 1.0;
    x_true[1] = 0.0;

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

    data_t total_predict_us = 0.0;
    data_t total_strip_us = 0.0;
    data_t total_row_sum_us = 0.0;
    long long count_predict = 0;
    long long count_strip = 0;
    long long count_row_sum = 0;

    for (int k = 0; k < NUM_STEPS; ++k) {
        // system matrices (match src/main.cpp)
        const data_t theta = 0.05 * k * DT;
        const data_t cth = std::cos(theta);
        const data_t sth = std::sin(theta);

        const data_t A[N_STATE][N_STATE] = {
            {cth, -1.5 * sth, 0, 0},
            {1.5 * sth, cth, 0, 0},
            {0, 0, 1, 0},
            {0, 0, 0, 1},
        };

        const data_t C[N_MEAS][N_STATE] = {
            {1, 0, 0, 0},
            {0, 1, 0, 0},
            {0, 0, 1, 0},
            {0, 0, 0, 1},
        };

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

        // -------- Prediction --------
        data_t p_pred[N_STATE];
        data_t H_pred[N_STATE][MAX_GEN] = {0};
        int m_pred = 0;

        const auto t_pred0 = std::chrono::high_resolution_clock::now();
        predict_kernel(X.p, X.H, X.m, A, p_w, H_w, N_STATE, p_pred, H_pred, &m_pred);
        const auto t_pred1 = std::chrono::high_resolution_clock::now();
        const data_t predict_us =
            (data_t)std::chrono::duration_cast<std::chrono::nanoseconds>(t_pred1 - t_pred0).count() / 1000.0;
        total_predict_us += predict_us;
        count_predict += 1;

        // -------- Correction (strip updates) --------
        data_t p_upd[N_STATE];
        data_t H_upd[N_STATE][MAX_GEN] = {0};
        int m_upd = m_pred;

        for (int i = 0; i < N_STATE; ++i) p_upd[i] = p_pred[i];
        for (int r = 0; r < N_STATE; ++r) {
            for (int c = 0; c < m_pred; ++c) H_upd[r][c] = H_pred[r][c];
        }

        data_t strip_us_total = 0.0;
        for (int meas = 0; meas < N_MEAS; ++meas) {
            data_t lambda[N_STATE] = {0};
            const data_t phi = phi_vec[meas];

            if (method == LAMBDA_NONE) {
                for (int j = 0; j < N_STATE; ++j) lambda[j] = C[meas][j];
            } else if (method == LAMBDA_SEGMENT) {
                compute_lambda_segment(lambda, H_upd, m_upd, C[meas], phi);
            } else if (method == LAMBDA_VOLUME) {
                compute_lambda_volume(lambda, H_upd, m_upd, C[meas], phi);
            } else {  // LAMBDA_P_RADIUS
                compute_lambda_p_radius(lambda, H_upd, m_upd, C[meas], phi);
            }

            data_t p_next2[N_STATE];
            data_t H_next2[N_STATE][MAX_GEN] = {0};
            int m_next2 = 0;

            const auto t_s0 = std::chrono::high_resolution_clock::now();
            strip_update_kernel(p_upd, H_upd, m_upd, C[meas], y_k[meas], phi, lambda, p_next2, H_next2, &m_next2);
            const auto t_s1 = std::chrono::high_resolution_clock::now();
            const data_t strip_us =
                (data_t)std::chrono::duration_cast<std::chrono::nanoseconds>(t_s1 - t_s0).count() / 1000.0;
            strip_us_total += strip_us;
            total_strip_us += strip_us;
            count_strip += 1;

            // write back for chaining next measurement strip
            for (int i = 0; i < N_STATE; ++i) p_upd[i] = p_next2[i];
            for (int r = 0; r < N_STATE; ++r) {
                for (int c = 0; c < m_next2; ++c) H_upd[r][c] = H_next2[r][c];
                for (int c = m_next2; c < MAX_GEN; ++c) H_upd[r][c] = 0.0;
            }
            m_upd = m_next2;
        }

        // -------- Write back X --------
        X.m = m_upd;
        for (int i = 0; i < N_STATE; ++i) X.p[i] = p_upd[i];
        for (int r = 0; r < N_STATE; ++r) {
            for (int c = 0; c < m_upd; ++c) X.H[r][c] = H_upd[r][c];
            for (int c = m_upd; c < MAX_GEN; ++c) X.H[r][c] = 0.0;
        }

        // -------- Reduction (time only row_sum_abs_kernel inside) --------
        const data_t row_sum_us = zonotope_reduce_row_sum_us(&X, REDUCTION_BUDGET);
        if (row_sum_us > 0.0) {
            total_row_sum_us += row_sum_us;
            count_row_sum += 1;
        }

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

        // kernel timing per step (predict / total strip / row_sum)
        const data_t ktime_row[3] = {predict_us, strip_us_total, row_sum_us};
        csv_append_row(ktime_step_csv, ktime_row, 3);

        std::printf("[%s] k=%d done (m=%d, predict=%.1fus, strip=%.1fus, row_sum=%.1fus)\n", method_name, k, X.m,
                    predict_us, strip_us_total, row_sum_us);
    }

    const data_t avg_predict_us = (count_predict > 0) ? (total_predict_us / (data_t)count_predict) : 0.0;
    const data_t avg_strip_us = (count_strip > 0) ? (total_strip_us / (data_t)count_strip) : 0.0;
    const data_t avg_row_sum_us = (count_row_sum > 0) ? (total_row_sum_us / (data_t)count_row_sum) : 0.0;

    const data_t summary_row[9] = {
        total_predict_us, total_strip_us, total_row_sum_us,
        (data_t)count_predict, (data_t)count_strip, (data_t)count_row_sum,
        avg_predict_us, avg_strip_us, avg_row_sum_us,
    };
    csv_append_row(ktime_sum_csv, summary_row, 9);

    std::printf("[%s] outputs: %s\n", method_name, out_dir.c_str());
    std::printf("[%s] kernel_time_summary_us.csv: total_predict=%.1fus (n=%lld, avg=%.1fus), total_strip=%.1fus (n=%lld, avg=%.1fus), total_row_sum=%.1fus (n=%lld, avg=%.1fus)\n",
                method_name, total_predict_us, count_predict, avg_predict_us, total_strip_us, count_strip, avg_strip_us,
                total_row_sum_us, count_row_sum, avg_row_sum_us);
}

int main() {
    const std::string repo_root = find_repo_root();
    const char* sim_mode = std::getenv("HLS_SIM_MODE");
    if (!sim_mode || sim_mode[0] == '\0') sim_mode = "unknown";

    const std::string out_base_dir = repo_root + "/data/output/fpga/" + sim_mode;
    mkdir_p(out_base_dir);

    const char* only_method = std::getenv("HLS_LAMBDA_METHOD");  // optional filter

    std::printf("FPGA TB repo_root=%s\n", repo_root.c_str());
    std::printf("FPGA TB out_base=%s\n", out_base_dir.c_str());
    if (only_method && only_method[0] != '\0') std::printf("FPGA TB method filter: %s\n", only_method);

    bool ran_any = false;
    for (const auto& it : kMethods) {
        if (only_method && only_method[0] != '\0' && !str_eq(only_method, it.name)) continue;
        run_one_method(it.method, it.name, out_base_dir);
        ran_any = true;
    }

    if (!ran_any) {
        std::printf("No method matched HLS_LAMBDA_METHOD=%s\n", (only_method && only_method[0]) ? only_method : "(unset)");
        std::printf("Valid: LAMBDA_NONE/LAMBDA_SEGMENT/LAMBDA_VOLUME/LAMBDA_P_RADIUS\n");
        return 2;
    }

    std::printf("All done. Results under: %s\n", out_base_dir.c_str());
    return 0;
}
