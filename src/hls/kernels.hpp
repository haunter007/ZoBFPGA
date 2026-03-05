#ifndef KERNELS_HLS_HPP
#define KERNELS_HLS_HPP

#include "zonotope.hpp"

// Plain C-style kernels (HLS-friendly)
#ifdef __cplusplus
extern "C" {
#endif

void predict_kernel(
    const data_t p_x[N_STATE],
    const data_t H_x[N_STATE][MAX_GEN], int m_x,
    const data_t A[N_STATE][N_STATE],
    const data_t p_w[N_STATE],
    const data_t H_w[N_STATE][MAX_GEN], int m_w,
    data_t p_pred[N_STATE],
    data_t H_pred[N_STATE][MAX_GEN],
    int* m_pred
);

void strip_update_kernel(
    const data_t p[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t y, data_t phi,
    const data_t lambda[N_STATE],
    data_t p_hat[N_STATE],
    data_t H_hat[N_STATE][MAX_GEN],
    int* m_hat
);

void row_sum_abs_kernel(
    const data_t H[N_STATE][MAX_GEN], int m,
    data_t row_sum[N_STATE]
);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif
