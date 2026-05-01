#include <cmath>
#include <cstdio>
#include <cstring>
#include <fstream>
#include <sstream>
#include <string>
#include <sys/stat.h>
#include <vector>

#include "dump.hpp"
#include "kernels.hpp"
#include "zonotope.hpp"

static void mkdir_p(const std::string& path) {
    std::string tmp;
    for (size_t i = 0; i < path.size(); ++i) {
        tmp += path[i];
        if (path[i] == '/' || i + 1 == path.size()) {
            if (tmp != "/") mkdir(tmp.c_str(), 0755);
        }
    }
}

static bool load_csv_matrix(const std::string& path, std::vector<std::vector<data_t>>& rows) {
    std::ifstream f(path);
    if (!f) return false;
    rows.clear();
    std::string line;
    while (std::getline(f, line)) {
        if (line.empty()) continue;
        std::stringstream ss(line);
        std::string cell;
        std::vector<data_t> row;
        while (std::getline(ss, cell, ',')) {
            row.push_back(static_cast<data_t>(std::strtof(cell.c_str(), nullptr)));
        }
        rows.push_back(row);
    }
    return !rows.empty();
}

static bool load_csv_row(const std::string& path, std::vector<data_t>& row) {
    std::vector<std::vector<data_t>> rows;
    if (!load_csv_matrix(path, rows) || rows.empty()) return false;
    row = rows[0];
    return true;
}

static int infer_generator_count(const std::vector<std::vector<data_t>>& H) {
    int cols = H.empty() ? 0 : static_cast<int>(H[0].size());
    int count = 0;
    for (int j = 0; j < cols; ++j) {
        bool nonzero = false;
        for (int i = 0; i < static_cast<int>(H.size()); ++i) {
            if (std::fabs(H[i][j]) > 1e-12f) {
                nonzero = true;
                break;
            }
        }
        if (nonzero) count++;
    }
    return count;
}

static void csv_append_row(const std::string& path, const data_t* x, int n) {
    FILE* f = std::fopen(path.c_str(), "a");
    if (!f) return;
    for (int i = 0; i < n; ++i) {
        std::fprintf(f, "%.17g%c", static_cast<double>(x[i]), (i == n - 1) ? '\n' : ',');
    }
    std::fclose(f);
}

int main(int argc, char** argv) {
    std::string bundle_dir = "data/output/board_inputs_rebuilt_max32";
    std::string out_dir = "data/output/cpp/fixed/LAMBDA_SEGMENT";
    if (argc >= 2) bundle_dir = argv[1];
    if (argc >= 3) out_dir = argv[2];

    std::vector<std::vector<data_t>> A_rows, y_rows, phi_rows, H_input_rows, H_w_rows, x_true_rows;
    std::vector<data_t> p_input_row, p_w_row;
    if (!load_csv_matrix(bundle_dir + "/A.csv", A_rows) ||
        !load_csv_matrix(bundle_dir + "/y_all.csv", y_rows) ||
        !load_csv_matrix(bundle_dir + "/phi_all.csv", phi_rows) ||
        !load_csv_matrix(bundle_dir + "/H_input.csv", H_input_rows) ||
        !load_csv_matrix(bundle_dir + "/H_w.csv", H_w_rows) ||
        !load_csv_matrix(bundle_dir + "/x_true.csv", x_true_rows) ||
        !load_csv_row(bundle_dir + "/p_input.csv", p_input_row) ||
        !load_csv_row(bundle_dir + "/p_w.csv", p_w_row)) {
        std::fprintf(stderr, "Failed to load fixed input bundle from %s\n", bundle_dir.c_str());
        return 1;
    }

    mkdir_p(out_dir);
    const std::string center_csv = out_dir + "/center.csv";
    const std::string x_true_csv = out_dir + "/x_true.csv";
    const std::string meas_csv = out_dir + "/meas.csv";
    const std::string error_csv = out_dir + "/error.csv";
    dump_reset_file(center_csv.c_str());
    dump_reset_file(x_true_csv.c_str());
    dump_reset_file(meas_csv.c_str());
    dump_reset_file(error_csv.c_str());

    data_t A[N_STATE][N_STATE] = {};
    data_t C[N_MEAS][N_STATE] = {};
    data_t H_w[N_STATE][MAX_GEN] = {};
    data_t H_cur[N_STATE][MAX_GEN] = {};
    data_t H_pred[N_STATE][MAX_GEN] = {};
    data_t H_upd[N_STATE][MAX_GEN] = {};
    data_t p_cur[N_STATE] = {};
    data_t p_pred[N_STATE] = {};
    data_t p_upd[N_STATE] = {};
    data_t p_w[N_STATE] = {};

    for (int i = 0; i < N_STATE; ++i) {
        p_cur[i] = p_input_row[i];
        p_w[i] = p_w_row[i];
        for (int j = 0; j < N_STATE; ++j) A[i][j] = A_rows[i][j];
    }
    for (int block = 0; block < N_STATE / 4; ++block) {
        const int meas_base = block * 2;
        const int state_base = block * 4;
        if (meas_base + 1 < N_MEAS) {
            C[meas_base + 0][state_base + 0] = 1.0f;
            C[meas_base + 1][state_base + 1] = 1.0f;
        }
    }

    for (int i = 0; i < N_STATE; ++i) {
        for (int j = 0; j < MAX_GEN; ++j) {
            H_cur[i][j] = 0.0f;
            H_w[i][j] = 0.0f;
        }
    }

    const int m_x_init = infer_generator_count(H_input_rows);
    const int m_w = infer_generator_count(H_w_rows);
    for (int i = 0; i < N_STATE; ++i) {
        for (int j = 0; j < m_x_init; ++j) H_cur[i][j] = H_input_rows[i][j];
        for (int j = 0; j < m_w; ++j) H_w[i][j] = H_w_rows[i][j];
    }

    Zonotope Z{};
    Z.n = N_STATE;
    Z.m = m_x_init;
    for (int i = 0; i < N_STATE; ++i) {
        Z.p[i] = p_cur[i];
        for (int j = 0; j < MAX_GEN; ++j) Z.H[i][j] = H_cur[i][j];
    }

    const int n_steps = static_cast<int>(y_rows.size());
    for (int k = 0; k < n_steps; ++k) {
        csv_append_row(meas_csv, y_rows[k].data(), N_MEAS);

        int m_pred = 0;
        predict_kernel(Z.p, Z.H, Z.m, A, p_w, H_w, m_w, p_pred, H_pred, &m_pred);

        Zonotope Z_pred{};
        Z_pred.n = N_STATE;
        Z_pred.m = m_pred;
        for (int i = 0; i < N_STATE; ++i) {
            Z_pred.p[i] = p_pred[i];
            for (int j = 0; j < MAX_GEN; ++j) Z_pred.H[i][j] = H_pred[i][j];
        }
        if (Z_pred.m > REDUCTION_BUDGET) {
            zonotope_reduce(&Z_pred, REDUCTION_BUDGET);
        }

        std::memcpy(p_upd, Z_pred.p, sizeof(p_upd));
        std::memcpy(H_upd, Z_pred.H, sizeof(H_upd));
        int m_upd = Z_pred.m;

        for (int meas = 0; meas < N_MEAS; ++meas) {
            data_t lambda[N_STATE];
            compute_lambda_segment(lambda, H_upd, m_upd, C[meas], phi_rows[k][meas]);
            data_t p_next[N_STATE];
            data_t H_next[N_STATE][MAX_GEN];
            int m_next = 0;
            strip_update_kernel(p_upd, H_upd, m_upd, C[meas], y_rows[k][meas], phi_rows[k][meas], lambda, p_next, H_next, &m_next);
            std::memcpy(p_upd, p_next, sizeof(p_upd));
            std::memcpy(H_upd, H_next, sizeof(H_upd));
            m_upd = m_next;
        }

        Z.m = m_upd;
        for (int i = 0; i < N_STATE; ++i) {
            Z.p[i] = p_upd[i];
            for (int j = 0; j < MAX_GEN; ++j) Z.H[i][j] = H_upd[i][j];
        }
        zonotope_reduce(&Z, REDUCTION_BUDGET);

        dump_true_append(x_true_csv.c_str(), x_true_rows[k].data());
        dump_center_append(center_csv.c_str(), Z.p);
        data_t err_row[N_STATE + 1];
        data_t l2 = 0.0f;
        for (int i = 0; i < N_STATE; ++i) {
            err_row[i] = Z.p[i] - x_true_rows[k][i];
            l2 += err_row[i] * err_row[i];
        }
        err_row[N_STATE] = std::sqrt(l2);
        csv_append_row(error_csv, err_row, N_STATE + 1);
    }

    std::printf("Replayed fixed input bundle from %s -> %s\n", bundle_dir.c_str(), out_dir.c_str());
    return 0;
}
