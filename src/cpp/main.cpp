#include <chrono>
#include <cmath>
#include <cstdio>
#include <cstdlib>
#include <cstring>
#include <dirent.h>
#include <errno.h>
#include <string>
#include <sys/stat.h>
#include <vector>

#include "dump.hpp"
#include "kernels.hpp"
#include "zonotope.hpp"

static unsigned int g_seed = RANDOM_SEED;
static inline double rand01() {
    g_seed = 1664525u * g_seed + 1013904223u;
    return (double)((g_seed >> 8) & 0x00FFFFFFu) / 16777216.0;
}
static inline data_t uniform_noise(data_t r) {
    return (data_t)((2.0 * rand01() - 1.0) * r);
}

static void mkdir_p(const std::string& path) {
    std::string tmp;
    for (size_t i = 0; i < (int)path.size(); ++i) {
        tmp += path[i];
        if (path[i] == '/' || i + 1 == (int)path.size()) {
            if (tmp != "/") mkdir(tmp.c_str(), 0755);
        }
    }
}

static void csv_append_row(const std::string& path, const data_t* x, int n) {
    FILE* f = std::fopen(path.c_str(), "a");
    if (!f) return;
    for (int i = 0; i < n; ++i) {
        std::fprintf(f, "%.17g%c", (double)x[i], (i == n - 1) ? '\n' : ',');
    }
    std::fclose(f);
}

// Global buffers to avoid stack overflow and simplify management
static data_t g_A[N_STATE][N_STATE];
static data_t g_C[N_MEAS][N_STATE];
static data_t g_H_w[N_STATE][MAX_GEN];
static data_t g_H_tmp1[N_STATE][MAX_GEN];
static data_t g_H_tmp2[N_STATE][MAX_GEN];
static data_t g_H_tmp3[N_STATE][MAX_GEN];
static Zonotope g_X;

static void prepare_synthetic_batch_inputs(
    std::vector<std::vector<data_t>>& x_true_seq,
    std::vector<std::vector<data_t>>& y_seq
) {
    x_true_seq.assign(NUM_STEPS, std::vector<data_t>(N_STATE, 0.0f));
    y_seq.assign(NUM_STEPS, std::vector<data_t>(N_MEAS, 0.0f));

    std::vector<data_t> x_true(N_STATE, 0.0f);
    for (int b = 0; b < N_STATE / 4; ++b) x_true[b * 4] = 1.0f;

    for (int k = 0; k < NUM_STEPS; ++k) {
        std::vector<data_t> x_next(N_STATE, 0.0f);
        for (int i = 0; i < N_STATE; ++i) {
            for (int j = 0; j < N_STATE; ++j) x_next[i] += g_A[i][j] * x_true[j];
            x_next[i] += uniform_noise(PROC_NOISE_RADIUS);
        }
        x_true = x_next;
        x_true_seq[k] = x_true;

        for (int i = 0; i < N_MEAS; ++i) {
            data_t tmp = 0.0f;
            for (int j = 0; j < N_STATE; ++j) tmp += g_C[i][j] * x_true[j];
            y_seq[k][i] = tmp + uniform_noise(MEAS_NOISE_RADIUS);
        }
    }
}

static void run_one_method(LambdaMethod method, const char* method_name, const std::string& out_base) {
    g_seed = RANDOM_SEED;
    const std::string out_dir = out_base + "/" + method_name;
    mkdir_p(out_dir);

    const std::string center_csv = out_dir + "/center.csv";
    const std::string x_true_csv = out_dir + "/x_true.csv";
    const std::string meas_csv   = out_dir + "/meas.csv";
    const std::string error_csv  = out_dir + "/error.csv";
    const std::string ktime_csv  = out_dir + "/kernel_time_step_us.csv";
    const std::string ksum_csv   = out_dir + "/kernel_time_summary_us.csv";

    dump_reset_file(center_csv.c_str()); dump_reset_file(x_true_csv.c_str());
    dump_reset_file(meas_csv.c_str()); dump_reset_file(error_csv.c_str());
    dump_reset_file(ktime_csv.c_str()); dump_reset_file(ksum_csv.c_str());

    const data_t omega = 0.5f, zeta = 0.05f, dt = DT, decay = std::exp(-zeta * dt);
    const data_t c_val = std::cos(omega * dt) * decay, s_val = std::sin(omega * dt) * decay, eps = 0.1f;

    std::memset(g_A, 0, sizeof(g_A));
    data_t A_block[4][4] = {{c_val,-s_val,eps,0},{s_val,c_val,0,eps},{-eps,0,c_val,-s_val},{0,-eps,s_val,c_val}};
    for (int b = 0; b < N_STATE/4; ++b)
        for (int i = 0; i < 4; ++i)
            for (int j = 0; j < 4; ++j)
                g_A[b*4+i][b*4+j] = A_block[i][j];

    std::memset(g_C, 0, sizeof(g_C));
    for (int block = 0; block < N_STATE / 4; ++block) {
        const int meas_base = block * 2;
        const int state_base = block * 4;
        if (meas_base + 1 < N_MEAS) {
            g_C[meas_base + 0][state_base + 0] = 1.0f;
            g_C[meas_base + 1][state_base + 1] = 1.0f;
        }
    }

    std::vector<std::vector<data_t>> x_true_seq;
    std::vector<std::vector<data_t>> y_seq;
    prepare_synthetic_batch_inputs(x_true_seq, y_seq);

    g_X.n = N_STATE; g_X.m = N_STATE;
    for (int i = 0; i < N_STATE; ++i) {
        g_X.p[i] = 0.0f;
        for (int j = 0; j < MAX_GEN; ++j) g_X.H[i][j] = 0.0f;
    }
    for (int b = 0; b < N_STATE / 4; ++b) {
        g_X.p[b * 4] = 1.0f;
    }
    for (int i = 0; i < N_STATE; ++i) {
        g_X.H[i][i] = INIT_RADIUS;
    }

    std::memset(g_H_w, 0, sizeof(g_H_w));
    for (int i = 0; i < N_STATE; ++i) g_H_w[i][i] = PROC_NOISE_RADIUS;

    std::vector<data_t> p_w(N_STATE, 0.0f);
    std::vector<data_t> p_pred(N_STATE, 0.0f);
    std::vector<data_t> p_upd(N_STATE, 0.0f);
    std::vector<data_t> p_next2(N_STATE, 0.0f);
    std::vector<data_t> err(N_STATE + 1, 0.0f);
    data_t total_us = 0.0f;
    auto t0 = std::chrono::high_resolution_clock::now();
    for (int k = 0; k < NUM_STEPS; ++k) {
        const std::vector<data_t>& x_true = x_true_seq[k];
        const std::vector<data_t>& y_k = y_seq[k];
        csv_append_row(meas_csv, y_k.data(), N_MEAS);

        int m_pred = 0;
        predict_kernel(g_X.p, g_X.H, g_X.m, g_A, p_w.data(), g_H_w, N_STATE, p_pred.data(), g_H_tmp1, &m_pred);

        std::memcpy(p_upd.data(), p_pred.data(), sizeof(data_t) * N_STATE);
        int m_upd = m_pred;
        std::memcpy(g_H_tmp2, g_H_tmp1, sizeof(g_H_tmp2));

        for (int meas = 0; meas < N_MEAS; ++meas) {
            data_t lambda[N_STATE];
            if (method == LAMBDA_NONE) { for (int j=0; j<N_STATE; ++j) lambda[j] = g_C[meas][j]; }
            else if (method == LAMBDA_SEGMENT) compute_lambda_segment(lambda, g_H_tmp2, m_upd, g_C[meas], MEAS_NOISE_RADIUS);
            else if (method == LAMBDA_VOLUME) compute_lambda_volume(lambda, g_H_tmp2, m_upd, g_C[meas], MEAS_NOISE_RADIUS);
            else compute_lambda_p_radius(lambda, g_H_tmp2, m_upd, g_C[meas], MEAS_NOISE_RADIUS);

            int m_next2 = 0;
            strip_update_kernel(p_upd.data(), g_H_tmp2, m_upd, g_C[meas], y_k[meas], MEAS_NOISE_RADIUS, lambda, p_next2.data(), g_H_tmp3, &m_next2);
            std::memcpy(p_upd.data(), p_next2.data(), sizeof(data_t) * N_STATE);
            m_upd = m_next2;
            std::memcpy(g_H_tmp2, g_H_tmp3, sizeof(g_H_tmp2));
        }

        g_X.m = m_upd; for (int i = 0; i < N_STATE; ++i) g_X.p[i] = p_upd[i];
        std::memcpy(g_X.H, g_H_tmp2, sizeof(g_X.H));
        zonotope_reduce(&g_X, REDUCTION_BUDGET);

        dump_true_append(x_true_csv.c_str(), x_true.data());
        dump_center_append(center_csv.c_str(), g_X.p);
        data_t l2 = 0.0f;
        for(int i=0; i<N_STATE; ++i){ err[i]=g_X.p[i]-x_true[i]; l2+=err[i]*err[i]; }
        err[N_STATE]=std::sqrt(l2);
        csv_append_row(error_csv, err.data(), N_STATE+1);
        if (k % 50 == 0) std::printf("[%s] k=%d done (m=%d)\n", method_name, k, g_X.m);
    }
    auto t1 = std::chrono::high_resolution_clock::now();
    total_us = (data_t)std::chrono::duration_cast<std::chrono::nanoseconds>(t1 - t0).count() / 1000.0f;
    data_t summary[3] = {total_us, total_us / NUM_STEPS, (data_t)NUM_STEPS};
    data_t timing_row[3] = {total_us / NUM_STEPS, 0.0f, 0.0f};
    csv_append_row(ktime_csv, timing_row, 3);
    csv_append_row(ksum_csv, summary, 3);
    std::printf("[%s] total=%.2fus (%d steps), avg=%.2fus/step\n",
                method_name, (double)total_us, NUM_STEPS, (double)(total_us / NUM_STEPS));
}

int main() {
    mkdir_p("data/output/cpp");
    run_one_method(LAMBDA_NONE, "LAMBDA_NONE", "data/output/cpp");
    run_one_method(LAMBDA_SEGMENT, "LAMBDA_SEGMENT", "data/output/cpp");
    run_one_method(LAMBDA_VOLUME, "LAMBDA_VOLUME", "data/output/cpp");
    return 0;
}
