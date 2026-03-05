#include "kernels.hpp"
#include <stdio.h>
#include <math.h>
#include <assert.h>

extern "C" {

void predict_kernel(
    const data_t p_x[N_STATE],
    const data_t H_x[N_STATE][MAX_GEN], int m_x,
    const data_t A[N_STATE][N_STATE],
    const data_t p_w[N_STATE],
    const data_t H_w[N_STATE][MAX_GEN], int m_w,
    data_t p_pred[N_STATE],
    data_t H_pred[N_STATE][MAX_GEN],
    int* m_pred
) {
    // ----------- Hard bounds (VERY important for correctness + analysis) ----------
    // m_x/m_w are generator counts, bounded by MAX_GEN.
    assert(m_x >= 0 && m_x <= MAX_GEN);
    assert(m_w >= 0 && m_w <= MAX_GEN);
    assert(m_x + m_w <= MAX_GEN);
    // ----------- Memory banking for N_STATE=4 (cheap and effective) --------------
#pragma HLS ARRAY_PARTITION variable=A      complete dim=2
#pragma HLS ARRAY_PARTITION variable=p_x    complete dim=1
#pragma HLS ARRAY_PARTITION variable=p_w    complete dim=1
#pragma HLS ARRAY_PARTITION variable=p_pred complete dim=1

#pragma HLS ARRAY_PARTITION variable=H_x    complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_w    complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_pred complete dim=1
    int i, j, k;

    /* p_pred = A * p_x + p_w */
    for (i = 0; i < N_STATE; ++i) {
        #pragma HLS PIPELINE II=1
        p_pred[i] = p_w[i];
        for (j = 0; j < N_STATE; ++j) {
            #pragma HLS UNROLL
            p_pred[i] += A[i][j] * p_x[j];
        }
    }

    /* H_pred[:, 0:m_x] = A * H_x */
    for (k = 0; k < m_x; ++k) {                        
        // tripcount = 循环会执行多少次（迭代次数）就是m_x的值，m_x的值在调用这个函数的时候是根据实际情况传入的，m_x的值越大，循环迭代次数越多，性能开销也就越大，所以需要给出一个合理的范围来指导HLS工具进行优化。
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        for (i = 0; i < N_STATE; ++i) {
            #pragma HLS PIPELINE II=1
            H_pred[i][k] = 0.0;
            for (j = 0; j < N_STATE; ++j) {
                #pragma HLS UNROLL
                H_pred[i][k] += A[i][j] * H_x[j][k];
            }
        }
    }

    /* append H_w */
    for (k = 0; k < m_w; ++k) {
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        for (i = 0; i < N_STATE; ++i) {
            #pragma HLS PIPELINE II=1
            H_pred[i][m_x + k] = H_w[i][k];
        }
    }

    *m_pred = m_x + m_w;
}

/* ================= Strip Update ================= */

void strip_update_kernel(
    const data_t p[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t y, data_t phi,
    const data_t lambda[N_STATE],
    data_t p_hat[N_STATE],
    data_t H_hat[N_STATE][MAX_GEN],
    int* m_hat  
) {
    int i, j;

    /* residual r = y - c^T p */
    data_t residual = 0.0;
    for (i = 0; i < N_STATE; ++i) {
        residual += c[i] * p[i];
    }
    data_t r = y - residual;

    /* p_hat = p + lambda * r */
    for (i = 0; i < N_STATE; ++i) {
        p_hat[i] = p[i] + lambda[i] * r;
    }

    /* H_hat = H - lambda * (c^T H) */
    for (j = 0; j < m; ++j) {
        data_t t = 0.0;
        for (i = 0; i < N_STATE; ++i) {
            t += c[i] * H[i][j];
        }
        for (i = 0; i < N_STATE; ++i) {
            H_hat[i][j] = H[i][j] - lambda[i] * t;
        }
    }

    /* append phi * lambda */
    for (i = 0; i < N_STATE; ++i) {
        H_hat[i][m] = phi * lambda[i];
    }

    *m_hat = m + 1;
}

/* ================= Row Sum abs ================= */

void row_sum_abs_kernel(
    const data_t H_drop[N_STATE][MAX_GEN],
    int m_drop,
    data_t row_sum[N_STATE]
) {
    for (int i = 0; i < N_STATE; ++i) row_sum[i] = 0.0;

    for (int j = 0; j < m_drop; ++j) {
        for (int i = 0; i < N_STATE; ++i) {
            data_t v = H_drop[i][j];
            row_sum[i] += (v >= 0.0) ? v : -v;  // abs without <cmath>
        }
    }
}
}
