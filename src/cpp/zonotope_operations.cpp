#include "zonotope.hpp"
#include "kernels.hpp"
#include <cmath>
#include <vector>
#include <cstring>
#include <algorithm>
#include <memory>

// ------------------------------
// Lambda: Segment (闭式解)
// ------------------------------
void compute_lambda_segment(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    std::vector<data_t> HHT_c(N_STATE, 0.0);

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
// Lambda: Volume
// ------------------------------
void compute_lambda_volume(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    data_t t_sq = 0.0;
    data_t c_sq = 0.0;
    for (int i = 0; i < N_STATE; ++i) c_sq += c[i] * c[i];

    for (int j = 0; j < m; ++j) {
        data_t h_dot_c = 0.0;
        for (int i = 0; i < N_STATE; ++i) h_dot_c += H[i][j] * c[i];
        t_sq += h_dot_c * h_dot_c;
    }

    data_t denom = c_sq * (t_sq + phi * phi);
    data_t alpha = (denom > 1e-12) ? (t_sq / denom) : 0.0;

    for (int i = 0; i < N_STATE; ++i) lambda[i] = alpha * c[i];
}

// ------------------------------
// Lambda: P-radius (Simplified for high dims)
// ------------------------------
void compute_lambda_p_radius(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    // For high dimensions (N_STATE=64), matrix inversion is expensive.
    // Falling back to Segment method as a stable alternative.
    compute_lambda_segment(lambda, H, m, c, phi);
}

// ------------------------------
// Zonotope Reduction
// ------------------------------
void zonotope_reduce(Zonotope* Z, int max_gens) {
    int n = Z->n;
    int m = Z->m;
    if (m <= max_gens) return;

    // 1) 计算 L2 norm 并排序 // 1) Compute L2 norms and sort
    std::vector<data_t> norms(m);
    std::vector<int> idx(m);
    for (int j = 0; j < m; ++j) {
        data_t sum_sq = 0.0;
        for (int i = 0; i < n; ++i) sum_sq += Z->H[i][j] * Z->H[i][j];
        norms[j] = sum_sq;
        idx[j] = j;
    }

    std::sort(idx.begin(), idx.end(), [&](int a, int b) {
        return norms[a] > norms[b];
    });

    int keep = max_gens - n;
    if (keep < 0) keep = 0;

    // 使用堆分配的大型数组 // Use heap-allocated large arrays
    auto H_new = std::unique_ptr<data_t[][MAX_GEN]>(new data_t[N_STATE][MAX_GEN]());
    
    // 3) 拷贝保留列 // 3) Copy kept columns
    for (int j = 0; j < keep; ++j) {
        int old_j = idx[j];
        for (int i = 0; i < n; ++i) H_new[i][j] = Z->H[i][old_j];
    }

    // 4) row-sum(abs) 聚合剩余列 // 4) row-sum(abs) of remaining columns
    std::vector<data_t> d(n, 0.0);
    for (int k = keep; k < m; ++k) {
        int old_idx = idx[k];
        for (int i = 0; i < n; ++i) {
            data_t v = Z->H[i][old_idx];
            d[i] += (v >= 0.0) ? v : -v;
        }
    }

    for (int i = 0; i < n; ++i) {
        H_new[i][keep + i] = d[i];
    }

    int m_new = keep + n;
    Z->m = m_new;

    // 写回 // Write back
    for (int i = 0; i < n; ++i) {
        for (int j = 0; j < m_new; ++j) Z->H[i][j] = H_new[i][j];
        for (int j = m_new; j < MAX_GEN; ++j) Z->H[i][j] = 0.0;
    }
}
