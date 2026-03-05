#include "zonotope.hpp"
#include "kernels.hpp"
#include <cmath>

// ------------------------------
// Lambda: Segment (闭式解)
// ------------------------------
void compute_lambda_segment(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    // HHT_c = H * (H^T * c)
    data_t HHT_c[N_STATE] = {0.0};

    for (int j = 0; j < m; ++j) {
        data_t h_dot_c = 0.0;
        for (int i = 0; i < N_STATE; ++i) {
            h_dot_c += H[i][j] * c[i];
        }
        for (int i = 0; i < N_STATE; ++i) {
            HHT_c[i] += H[i][j] * h_dot_c;
        }
    }

    data_t denom = phi * phi;
    for (int i = 0; i < N_STATE; ++i) {
        denom += c[i] * HHT_c[i];
    }

    if (std::fabs(denom) < 1e-12) {
        for (int i = 0; i < N_STATE; ++i) lambda[i] = 0.0;
    } else {
        for (int i = 0; i < N_STATE; ++i) lambda[i] = HHT_c[i] / denom;
    }
}

// ------------------------------
// Lambda: P-radius
// 说明：Python里用了矩阵求逆 P=inv(HHT+epsI)
// HLS里不建议做矩阵逆，这里先用 segment 作为可综合近似
// ------------------------------
static void mat4_mul(const data_t A[4][4], const data_t x[4], data_t y[4]) {
    for (int i = 0; i < 4; ++i) {
        data_t s = 0.0;
        for (int j = 0; j < 4; ++j) s += A[i][j] * x[j];
        y[i] = s;
    }
}

static data_t vec4_dot(const data_t a[4], const data_t b[4]) {
    data_t s = 0.0;
    for (int i = 0; i < 4; ++i) s += a[i] * b[i];
    return s;
}

static void mat4_add_epsI(data_t A[4][4], data_t eps) {
    for (int i = 0; i < 4; ++i) A[i][i] += eps;
}

// Gauss-Jordan invert 4x4 (return false if singular)
static bool mat4_inv(const data_t A_in[4][4], data_t Ainv[4][4]) {
    data_t A[4][8];
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) A[i][j] = A_in[i][j];
        for (int j = 0; j < 4; ++j) A[i][4 + j] = (i == j) ? 1.0 : 0.0;
    }

    for (int col = 0; col < 4; ++col) {
        // pivot
        int piv = col;
        data_t best = std::fabs(A[col][col]);
        for (int r = col + 1; r < 4; ++r) {
            data_t v = std::fabs(A[r][col]);
            if (v > best) { best = v; piv = r; }
        }
        if (best < 1e-18) return false;

        if (piv != col) {
            for (int j = 0; j < 8; ++j) {
                data_t tmp = A[col][j];
                A[col][j] = A[piv][j];
                A[piv][j] = tmp;
            }
        }

        data_t diag = A[col][col];
        for (int j = 0; j < 8; ++j) A[col][j] /= diag;

        for (int r = 0; r < 4; ++r) {
            if (r == col) continue;
            data_t f = A[r][col];
            for (int j = 0; j < 8; ++j) A[r][j] -= f * A[col][j];
        }
    }

    for (int i = 0; i < 4; ++i)
        for (int j = 0; j < 4; ++j)
            Ainv[i][j] = A[i][4 + j];

    return true;
}

void compute_lambda_p_radius(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    // 1) HHT = H*H^T
    data_t HHT[4][4] = {0};
    for (int i = 0; i < 4; ++i) {
        for (int j = 0; j < 4; ++j) {
            data_t s = 0.0;
            for (int k = 0; k < m; ++k) s += H[i][k] * H[j][k];
            HHT[i][j] = s;
        }
    }

    // 2) P = inv(HHT + eps I)
    data_t A[4][4];
    for (int i = 0; i < 4; ++i)
        for (int j = 0; j < 4; ++j)
            A[i][j] = HHT[i][j];

    mat4_add_epsI(A, 1e-6);

    data_t P[4][4];
    if (!mat4_inv(A, P)) {
        // fallback: segment
        compute_lambda_segment(lambda, H, m, c, phi);
        return;
    }

    // 3) numerator = P * HHT * c
    data_t HHTc[4];
    mat4_mul(HHT, c, HHTc);

    data_t num[4];
    mat4_mul(P, HHTc, num);

    // 4) denom = c^T HHT P HHT c + phi^2 c^T P c
    data_t PHHTc[4];
    mat4_mul(P, HHTc, PHHTc);

    data_t term1 = vec4_dot(HHTc, PHHTc); // (HHTc)^T (P HHTc) = c^T HHT P HHT c

    data_t Pc[4];
    mat4_mul(P, c, Pc);
    data_t term2 = (phi * phi) * vec4_dot(c, Pc); // phi^2 c^T P c

    data_t denom = term1 + term2;
    if (std::fabs(denom) < 1e-18) {
        compute_lambda_segment(lambda, H, m, c, phi);
        return;
    }

    for (int i = 0; i < 4; ++i) lambda[i] = num[i] / denom;
}


// ------------------------------
// Lambda: Volume（同样先给可综合近似）
// ------------------------------
void compute_lambda_volume(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    // 扫描参数 // Scan parameters
    const int N_SCAN = 21;
    const data_t A_MIN = -3.0;
    const data_t A_MAX =  3.0;

    data_t best_alpha = 0.0;
    data_t best_cost = 1e300;

    // 预计算 t = c^T H  (1xm)
    data_t t[MAX_GEN];
    for (int j = 0; j < m; ++j) {
        data_t s = 0.0;
        for (int i = 0; i < N_STATE; ++i) s += c[i] * H[i][j];
        t[j] = s;
    }

    // 扫描 alpha
    for (int s = 0; s < N_SCAN; ++s) {
        data_t alpha = A_MIN + (A_MAX - A_MIN) * (data_t)s / (data_t)(N_SCAN - 1);

        // lam = alpha * c
        data_t lam[N_STATE];
        for (int i = 0; i < N_STATE; ++i) lam[i] = alpha * c[i];

        // 构造 H_hat = H - lam * t  (n x m)
        // 并追加一列 phi*lam
        data_t cost = 0.0;

        // cost = trace(H_hat H_hat^T) = sum_{i,j} H_hat[i][j]^2  + sum_i (phi*lam[i])^2
        for (int j = 0; j < m; ++j) {
            for (int i = 0; i < N_STATE; ++i) {
                data_t Hij = H[i][j] - lam[i] * t[j];
                cost += Hij * Hij;
            }
        }
        for (int i = 0; i < N_STATE; ++i) {
            data_t g = phi * lam[i];
            cost += g * g;
        }

        if (cost < best_cost) {
            best_cost = cost;
            best_alpha = alpha;
        }
    }

    // 输出最优 lambda
    for (int i = 0; i < N_STATE; ++i) lambda[i] = best_alpha * c[i];
}


// ------------------------------
// Reduce: box-preserving (对齐Python)
// 逻辑：保留 max_gens 个里最“重要”的若干列，其余按行绝对值求和 -> 对角生成器
//
// Python版：
//   keep = max_gens
//   drop = m-keep
//   row_sum = sum(abs(H_drop), axis=1)
//   H_red = [H_keep, diag(row_sum)]
//
// 注意：diag(row_sum) 会新增 n 个生成器，所以最终 m = keep + n
// 因此这里我们保留 keep_count = max_gens - n 列，把剩余折叠成 diag，最终 m = keep_count + n <= max_gens
// ------------------------------
void zonotope_reduce(Zonotope* Z, int max_gens) {
    const int n = Z->n;
    const int m = Z->m;
    if (m <= max_gens) return;

    // 1) 计算每列 L2 范数
    data_t col_norm[MAX_GEN];
    for (int j = 0; j < m; ++j) {
        data_t s = 0.0;
        for (int i = 0; i < n; ++i) s += Z->H[i][j] * Z->H[i][j];
        col_norm[j] = std::sqrt(s);
    }

    // 2) 选择 top max_gens 的列索引（简单选择排序，避免 STL）
    int idx[MAX_GEN];
    for (int j = 0; j < m; ++j) idx[j] = j;

    // sort idx by col_norm desc (selection sort)
    for (int a = 0; a < m - 1; ++a) {
        int best = a;
        for (int b = a + 1; b < m; ++b) {
            if (col_norm[idx[b]] > col_norm[idx[best]]) best = b;
        }
        int tmp = idx[a]; idx[a] = idx[best]; idx[best] = tmp;
    }

    const int keep = max_gens;                 // 保留的列数 // Number of kept columns
    const int drop = m - keep;                 // 被聚合的列数 // Number of aggregated columns
    if (keep < 0) return;                      // 防御（一般不会发生） // Guard (normally should not happen)
    if (keep > MAX_GEN) return;                // 防御 // Guard

    // 3) 拷贝保留列 // 3) Copy kept columns
    data_t H_new[N_STATE][MAX_GEN] = {0.0};
    for (int j = 0; j < keep; ++j) {
        int old_j = idx[j];
        for (int i = 0; i < n; ++i) H_new[i][j] = Z->H[i][old_j];
    }

    // 4) row-sum(abs) 聚合剩余列，形成 diag(row_sum)
    // 2. 将剩余生成器合并为对角阵：d[i] = sum_j abs(H_drop[i][j])
    data_t H_drop[N_STATE][MAX_GEN] = {0.0};
    int m_drop = 0;

    for (int k = keep; k < Z->m; ++k) {
        int old_idx = idx[k];
        for (int i = 0; i < Z->n; ++i) {
            H_drop[i][m_drop] = Z->H[i][old_idx];
        }
        m_drop++;
    }

    data_t d[N_STATE] = {0.0};
    row_sum_abs_kernel(H_drop, m_drop, d);


    // 追加对角阵：占用 n 列
    // 结果列数 = keep + n
    for (int i = 0; i < n; ++i) {
        H_new[i][keep + i] = d[i];
    }

    const int m_new = keep + n;
    Z->m = m_new;

    // 5) 写回并清零剩余 // 5) Write back and zero remaining columns
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m_new; ++j) Z->H[i][j] = H_new[i][j];
        for (int j = m_new; j < MAX_GEN; ++j) Z->H[i][j] = 0.0;
    }
}


// #include "zonotope.hpp"
// #include <cmath>
// #include <algorithm>
// #include <vector>

// /**
//  * 计算增益 Lambda (Segment 策略)
//  * 公式: L = (H*H' * c') / (c * H*H' * c' + phi^2)
//  */
// void compute_lambda_segment(
//     double lambda[N_STATE],
//     const double H[N_STATE][MAX_GEN], int m,
//     const double c[N_STATE],
//     double phi
// ) {
//     double HHT_c[N_STATE] = {0.0};

//     // 1. 计算 H * H' * c
//     // 逻辑: H * (H' * c)
//     for (int j = 0; j < m; ++j) {
//         double h_dot_c = 0.0;
//         for (int i = 0; i < N_STATE; ++i) {
//             h_dot_c += H[i][j] * c[i];
//         }
//         for (int i = 0; i < N_STATE; ++i) {
//             HHT_c[i] += H[i][j] * h_dot_c;
//         }
//     }

//     // 2. 计算分母: c * (HHT_c) + phi^2
//     double denom = phi * phi;
//     for (int i = 0; i < N_STATE; ++i) {
//         denom += c[i] * HHT_c[i];
//     }

//     // 3. 计算 Lambda
//     // 增加一个小的 epsilon 防止除以 0
//     if (std::abs(denom) < 1e-12) {
//         for (int i = 0; i < N_STATE; ++i) lambda[i] = 0.0;
//     } else {
//         for (int i = 0; i < N_STATE; ++i) {
//             lambda[i] = HHT_c[i] / denom;
//         }
//     }
// }

// /**
//  * 改进后的降阶函数 (Zonotope Reduction)
//  * 必须将被剔除的生成元合并为对角阵，以保持包络特性 // Removed generators must be merged into a diagonal matrix to preserve enclosure properties
//  */
// void zonotope_reduce(Zonotope* Z, int max_gens) {
//     if (Z->m <= max_gens) return;

//     // 计算每个生成元的 L1 范数 (FPGA 友好) 或 L2 范数
//     struct GenInfo {
//         int idx;
//         double score;
//     };
//     std::vector<GenInfo> gens(Z->m);
//     for (int j = 0; j < Z->m; ++j) {
//         double score = 0.0;
//         for (int i = 0; i < Z->n; ++i) {
//             score += std::abs(Z->H[i][j]);
//         }
//         gens[j] = {j, score};
//     }

//     // 按得分从大到小排序 // Sort by score in descending order
//     std::sort(gens.begin(), gens.end(), [](const GenInfo& a, const GenInfo& b) {
//         return a.score > b.score;
//     });

//     double H_new[N_STATE][MAX_GEN] = {0.0};
//     int keep_count = max_gens - Z->n; // 预留位置给合并后的对角阵
//     if (keep_count < 0) keep_count = 0;

//     // 1. 保留得分最高的生成元 // 1. Keep the highest-scoring generators
//     for (int k = 0; k < keep_count; ++k) {
//         int old_idx = gens[k].idx;
//         for (int i = 0; i < Z->n; ++i) {
//             H_new[i][k] = Z->H[i][old_idx];
//         }
//     }

//     // 2. 将剩余的生成元合并为一个对角阵 (Interval Box)
//     // d[i] = sum(abs(H[i, j])) 对于所有被剔除的 j
//     double d[N_STATE] = {0.0};
//     for (int k = keep_count; k < Z->m; ++k) {
//         int old_idx = gens[k].idx;
//         for (int i = 0; i < Z->n; ++i) {
//             d[i] += std::abs(Z->H[i][old_idx]);
//         }
//     }

//     // 3. 将对角阵添加到生成器矩阵末尾 // 3. Append the diagonal matrix to the end of the generator matrix
//     for (int i = 0; i < Z->n; ++i) {
//         H_new[i][keep_count + i] = d[i];
//     }

//     // 写回结果 // Write back results
//     Z->m = keep_count + Z->n;
//     for (int i = 0; i < Z->n; ++i) {
//         for (int j = 0; j < Z->m; ++j) {
//             Z->H[i][j] = H_new[i][j];
//         }
//         // 清理剩余列数据 // Clear remaining column data
//         for (int j = Z->m; j < MAX_GEN; ++j) {
//             Z->H[i][j] = 0.0;
//         }
//     }
// }

// /**
//  * P-Radius 策略的 Lambda 计算
//  */
// void compute_lambda_p_radius(
//     double lambda[N_STATE],
//     const double H[N_STATE][MAX_GEN], int m,
//     const double c[N_STATE],
//     double phi
// ) {
//     // 逻辑与 Segment 类似，但通常用于不同的代价函数优化
//     // 这里保持实现逻辑一致 // Keep implementation logic consistent here
//     compute_lambda_segment(lambda, H, m, c, phi);
// }
// void compute_lambda_volume(
//     double lambda[N_STATE],
//     const double H[N_STATE][MAX_GEN], int m,
//     const double c[N_STATE],
//     double phi
// ) {
//     // 体积最小化通常没有简单的闭式解， // Volume minimization usually has no simple closed-form solution,
//     // 在 Python 的实现中，常用的一种高效近似是基于对角占优的增益计算
//     // 这里实现一种鲁棒的加权增益 // Implement a robust weighted gain here
//     double HHT_c[N_STATE] = {0.0};
//     double h_c_norm = 0.0;

//     for (int j = 0; j < m; ++j) {
//         double dot = 0.0;
//         for (int i = 0; i < N_STATE; ++i) dot += H[i][j] * c[i];
//         h_c_norm += std::abs(dot); // 使用 L1 范数近似体积梯度
        
//         for (int i = 0; i < N_STATE; ++i) {
//             HHT_c[i] += H[i][j] * dot;
//         }
//     }

//     double denom = phi * phi;
//     for (int i = 0; i < N_STATE; ++i) denom += c[i] * HHT_c[i];

//     if (std::abs(denom) < 1e-12) {
//         for (int i = 0; i < N_STATE; ++i) lambda[i] = 0.0;
//     } else {
//         for (int i = 0; i < N_STATE; ++i) {
//             lambda[i] = HHT_c[i] / denom;
//         }
//     }
// }
