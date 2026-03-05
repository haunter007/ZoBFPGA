#include <cstdio>
#include <cmath>

#include "zonotope.hpp"
#include "kernels.hpp"
// #include "kernels.hpp"
#include "dump.hpp"

// ------------------------------
// 简单 RNG（HLS/可移植友好）
// LCG: x = a*x + c
// ------------------------------
static unsigned int g_seed = RANDOM_SEED;

static inline double rand01() {
    g_seed = 1664525u * g_seed + 1013904223u;
    // 取高位做 [0,1) // Use high bits for [0,1)
    unsigned int v = (g_seed >> 8) & 0x00FFFFFFu;
    return (double)v / (double)0x01000000u;
}

static inline double uniform_noise(double r) {
    // [-r, r]
    return (2.0 * rand01() - 1.0) * r;
}

int main() {
    // 输出文件：程序开始先清空 // Output files: clear at program start
    dump_reset_file("data/output/center.csv");
    dump_reset_file("data/output/x_true.csv");

    // --- 真实状态 x_true ---
    double x_true[N_STATE] = {0.0};
    x_true[0] = 1.0;
    x_true[1] = 0.0;

    // phi_vec：Python 里 phi = l1 norm of row of H_v
    // H_v = diag(MEAS_NOISE_RADIUS) => phi_i = MEAS_NOISE_RADIUS
    double phi_vec[N_MEAS];
    for (int i = 0; i < N_MEAS; ++i) phi_vec[i] = MEAS_NOISE_RADIUS;

    // --- 初始 Zonotope X ---
    Zonotope X;
    X.n = N_STATE;
    X.m = N_STATE;
    for (int i = 0; i < N_STATE; ++i) {
        X.p[i] = (i == 0) ? 1.0 : 0.0;
        for (int j = 0; j < MAX_GEN; ++j) X.H[i][j] = 0.0;
        X.H[i][i] = INIT_RADIUS;
    }

    // --- 过程噪声 W: p_w=0, H_w=diag(PROC_NOISE_RADIUS) ---
    double p_w[N_STATE] = {0};
    double H_w[N_STATE][MAX_GEN] = {0};
    for (int i = 0; i < N_STATE; ++i) H_w[i][i] = PROC_NOISE_RADIUS;

    // 初始写一条（可选） // Write an initial record (optional)
    dump_true_append("data/output/x_true.csv", x_true);
    dump_center_append("data/output/center.csv", X.p);
    dump_zonotope_csv(X, 0, "data/output");

    for (int k = 0; k < NUM_STEPS; ++k) {
        // -------- system matrices (对齐 Python system_matrices) --------
        double theta = 0.05 * k * DT;
        double cth = std::cos(theta);
        double sth = std::sin(theta);

        double A[N_STATE][N_STATE] = {
            {cth, -1.5*sth, 0, 0},
            {1.5*sth,  cth, 0, 0},
            {0, 0, 1, 0},
            {0, 0, 0, 1}
        };

        double C[N_MEAS][N_STATE] = {
            {1, 0, 0, 0},
            {0, 1, 0, 0}
        };

        // -------- TRUE SYSTEM --------
        double w_k[N_STATE];
        for (int i = 0; i < N_STATE; ++i) w_k[i] = uniform_noise(PROC_NOISE_RADIUS);

        double x_next[N_STATE];
        for (int i = 0; i < N_STATE; ++i) {
            double tmp = 0.0;
            for (int j = 0; j < N_STATE; ++j) tmp += A[i][j] * x_true[j];
            x_next[i] = tmp + w_k[i];
        }
        for (int i = 0; i < N_STATE; ++i) x_true[i] = x_next[i];

        // measurement y_k = C x_true + v
        double y_k[N_MEAS];
        for (int i = 0; i < N_MEAS; ++i) {
            double v = uniform_noise(MEAS_NOISE_RADIUS);
            double tmp = 0.0;
            for (int j = 0; j < N_STATE; ++j) tmp += C[i][j] * x_true[j];
            y_k[i] = tmp + v;
        }

        // -------- ESTIMATOR: Prediction --------
        double p_pred[N_STATE];
        double H_pred[N_STATE][MAX_GEN];
        int m_pred = 0;

        predict_kernel(
            X.p, X.H, X.m,
            A,
            p_w,
            H_w, N_STATE,
            p_pred,
            H_pred,
            &m_pred
        );

        // -------- ESTIMATOR: Correction (strip 串联，严格对齐 Python) --------
        double p_upd[N_STATE];
        double H_upd[N_STATE][MAX_GEN];
        int m_upd = m_pred;

        for (int i = 0; i < N_STATE; ++i) p_upd[i] = p_pred[i];
        for (int r = 0; r < N_STATE; ++r)
            for (int c = 0; c < m_pred; ++c)
                H_upd[r][c] = H_pred[r][c];

        LambdaMethod method = LAMBDA_SEGMENT; 
        // 你可以改成 LAMBDA_NONE/LAMBDA_SEGMENT/LAMBDA_VOLUME/LAMBDA_P_RADIUS

        for (int meas = 0; meas < N_MEAS; ++meas) {
            double lambda[N_STATE];
            double phi = phi_vec[meas];

            if (method == LAMBDA_NONE) {
                for (int j = 0; j < N_STATE; ++j) lambda[j] = C[meas][j];
            } else if (method == LAMBDA_SEGMENT) {
                compute_lambda_segment(lambda, H_upd, m_upd, C[meas], phi);
            } else if (method == LAMBDA_VOLUME) {
                compute_lambda_volume(lambda, H_upd, m_upd, C[meas], phi);
            } else { // LAMBDA_P_RADIUS
                compute_lambda_p_radius(lambda, H_upd, m_upd, C[meas], phi);
            }

            double p_next2[N_STATE];
            double H_next2[N_STATE][MAX_GEN];
            int m_next2 = 0;

            strip_update_kernel(
                p_upd, H_upd, m_upd,
                C[meas],
                y_k[meas],
                phi,
                lambda,
                p_next2,
                H_next2,
                &m_next2
            );

            // 写回，继续串联下一个 strip
            for (int i = 0; i < N_STATE; ++i) p_upd[i] = p_next2[i];
            for (int r = 0; r < N_STATE; ++r)
                for (int c = 0; c < m_next2; ++c)
                    H_upd[r][c] = H_next2[r][c];
            m_upd = m_next2;
        }

        // -------- 写回 X --------
        X.m = m_upd;
        for (int i = 0; i < N_STATE; ++i) X.p[i] = p_upd[i];
        for (int r = 0; r < N_STATE; ++r) {
            for (int c = 0; c < m_upd; ++c) X.H[r][c] = H_upd[r][c];
            for (int c = m_upd; c < MAX_GEN; ++c) X.H[r][c] = 0.0; // 清零 // Zero out
        }

        // -------- Reduction（对齐 Python：所有 strip 串联完后 reduce 一次）--------
        zonotope_reduce(&X, REDUCTION_BUDGET);

        std::printf("k=%d, center=[%.3f %.3f %.3f %.3f], m=%d\n",
                    k, X.p[0], X.p[1], X.p[2], X.p[3], X.m);

        // dump: 每步都写（append 一条 center/true + 一个 zonotope 文件）
        dump_true_append("data/output/x_true.csv", x_true);
        dump_center_append("data/output/center.csv", X.p);
        dump_zonotope_csv(X, k+1, "data/output"); // k+1: 因为 step0 已经写过一次
    }

    return 0;
}

// #include <cstdio>
// #include <cmath>
// #include <vector>
// #include <random>
// #include <array>
// #include <algorithm>

// #include "../include/dump.hpp"
// #include "../include/zonotope.hpp"
// #include "../include/kernels.hpp"

// // ---------------------------------------------------------
// // 1. 随机数生成器 (解决 identifier undefined 报错)
// // ---------------------------------------------------------
// // 建议将 rng 定义为全局或静态，确保序列是连续的
// std::mt19937 rng(42); 

// double uniform_noise(double r) {
//     // 产生 [-r, r] 之间的均匀分布
//     std::uniform_real_distribution<double> dist(-r, r);
//     return dist(rng);
// }

// int main() {
//     std::vector<std::array<double, N_STATE>> estimated_center_hist;
//     std::vector<std::array<double, N_STATE>> x_true_hist;

//     // --- 初始化真实状态 x_true ---
//     double x_true[N_STATE] = {0.0};
//     x_true[0] = 1.0;
//     x_true[1] = 0.0;

//     double phi_vec[N_MEAS];
//     for (int i = 0; i < N_MEAS; ++i) {
//         phi_vec[i] = MEAS_NOISE_RADIUS;  // 因为 H_v = diag(radius)
//     }

//     Zonotope X;
//     X.n = N_STATE;
//     X.m = N_STATE;

//     /* Initial zonotope */
//     for (int i = 0; i < N_STATE; ++i) {
//         X.p[i] = (i == 0) ? 1.0 : 0.0;
//         for (int j = 0; j < N_STATE; ++j) {
//             X.H[i][j] = (i == j) ? INIT_RADIUS : 0.0;
//         }
//     }

//     /* Process noise */
//     double p_w[N_STATE] = {0};
//     double H_w[N_STATE][MAX_GEN] = {0};
//     for (int i = 0; i < N_STATE; ++i)
//         H_w[i][i] = PROC_NOISE_RADIUS;

//     for (int k = 0; k < NUM_STEPS; ++k) {
//         double theta = 0.05 * k * DT;
//         double cth = std::cos(theta);
//         double sth = std::sin(theta);

//         double A[N_STATE][N_STATE] = {
//             {cth, -1.5*sth, 0, 0},
//             {1.5*sth,  cth, 0, 0},
//             {0, 0, 1, 0},
//             {0, 0, 0, 1}
//         };

//         double C[N_MEAS][N_STATE] = {
//             {1, 0, 0, 0},
//             {0, 1, 0, 0}
//         };

//         double p_pred[N_STATE];
//         double H_pred[N_STATE][MAX_GEN];
//         int m_pred;
//         //真实系统更新 // True system update
//         double w_k[N_STATE];
//         for (int i = 0; i < N_STATE; ++i)
//             w_k[i] = uniform_noise(PROC_NOISE_RADIUS);

//         for (int i = 0; i < N_STATE; ++i) {
//             double tmp = 0.0;
//             for (int j = 0; j < N_STATE; ++j)
//                 tmp += A[i][j] * x_true[j];
//             x_true[i] = tmp + w_k[i];
//         }

//         //生成测量 y_k
//         double y_k[N_MEAS];
//         for (int i = 0; i < N_MEAS; ++i) {
//             double v = uniform_noise(MEAS_NOISE_RADIUS);
//             y_k[i] = 0.0;
//             for (int j = 0; j < N_STATE; ++j)
//                 y_k[i] += C[i][j] * x_true[j];
//             y_k[i] += v;
//         }



//         /* Prediction */
//         FpgaKernels::predict(
//             X.p, X.H, X.m,
//             A,
//             p_w,
//             H_w, N_STATE,
//             p_pred,
//             H_pred,
//             &m_pred
//         );
        
//         // 初始化为 prediction
//         double p_upd[N_STATE];
//         double H_upd[N_STATE][MAX_GEN];
//         // 1. 拷贝中心点 p
//         std::copy(p_pred, p_pred + N_STATE, p_upd);
//         for (int i = 0; i < N_STATE; ++i) {
//             for (int j = 0; j < m_pred; ++j)
//                 H_upd[i][j] = H_pred[i][j];
//         }
//         // 3. 拷贝生成器数量 // 3. Copy generator count
//         int m_upd = m_pred;
  
//         /* Measurement update 方法选择*/
//         LambdaMethod method = LAMBDA_SEGMENT;  // 或 LAMBDA_SEGMENT / LAMBDA_NONE
//         for (int i = 0; i < N_MEAS; ++i) {
//             double lambda[N_STATE];
//             double phi = phi_vec[i];

//             if (method == LAMBDA_NONE) {
//                 for (int j = 0; j < N_STATE; ++j)
//                     lambda[j] = C[i][j];
//             }
//             else if (method == LAMBDA_SEGMENT) {
//                 compute_lambda_segment(lambda, H_upd, m_upd, C[i], phi); // C[i]一个[]默认传入第i行
//             }
//             else if (method == LAMBDA_VOLUME) {
//                 compute_lambda_volume(lambda, H_upd, m_upd, C[i], phi);
//             }
//             else if (method == LAMBDA_P_RADIUS) {
//                 compute_lambda_p_radius(lambda, H_upd, m_upd, C[i], phi);
//             }
//             else
//                 for (int j = 0; j < N_STATE; ++j) lambda[j] = C[i][j];
                
//             double p_next[N_STATE];
//             double H_next[N_STATE][MAX_GEN];
//             int m_next;

//             FpgaKernels::strip_update(
//                 p_upd,
//                 H_upd,
//                 m_upd,
//                 C[i],
//                 y_k[i],   // ★ 不再是 0
//                 phi,      // ★ 不再是 MEAS_NOISE_RADIUS
//                 lambda,
//                 p_next,//X.p,
//                 H_next,//X.H,
//                 &m_next//&X.m
//                 );

//             // === 写回，准备下一个 strip ===
//             std::copy(p_next, p_next + N_STATE, p_upd);
//             for (int r = 0; r < N_STATE; ++r)
//                 for (int c = 0; c < m_next; ++c)
//                     H_upd[r][c] = H_next[r][c];
//             m_upd = m_next;
//         }
        
//         // === 最终写回 X ===
//         X.m = m_upd;
//         std::copy(p_upd, p_upd + N_STATE, X.p);
//         for (int i = 0; i < N_STATE; ++i)
//             for (int j = 0; j < m_upd; ++j)
//                 X.H[i][j] = H_upd[i][j];

//         // // 如果 H 之前更大，需要清零剩余列（推荐，防脏数据）
//         // for (int i = 0; i < N_STATE; ++i) {
//         //     for (int j = m_upd; j < MAX_GEN; ++j) {
//         //         X.H[i][j] = 0.0;
//         //     }
//         // }

//         // ===== Reduction (对应 Python X = X_upd.reduce) =====
//         zonotope_reduce(&X, REDUCTION_BUDGET);



//         std::printf("k=%d, center=[%.3f %.3f %.3f %.3f]\n",
//                     k, X.p[0], X.p[1], X.p[2], X.p[3]);

//         // 每一步更新后添加的代码 // Code added after each update step
//         estimated_center_hist.push_back(
//             {X.p[0], X.p[1], X.p[2], X.p[3]}
//         );
//         dump_zonotope_csv(X, k, "output");

//         x_true_hist.push_back(
//             {x_true[0], x_true[1], x_true[2], x_true[3]}
//         );
//         dump_centers_csv(x_true_hist, "output/x_true.csv");
//     }
//     // 仿真结束后导出中心轨迹 // Export center trajectory after simulation
//     dump_centers_csv(estimated_center_hist, "output/center.csv");
//     return 0;
// }
