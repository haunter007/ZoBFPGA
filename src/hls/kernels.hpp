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

void compute_lambda_segment(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    int c_idx,
    data_t phi
);

// Top-level kernel encapsulating one complete time step
void zonotope_step_kernel(
    data_t p_inout[N_STATE],
    data_t H_inout[N_STATE][MAX_GEN],
    int* m_inout,
    const data_t A[N_STATE][N_STATE],
    const data_t p_w[N_STATE],
    const data_t H_w[N_STATE][MAX_GEN], int m_w,
    const data_t y[N_MEAS],
    const data_t phi[N_MEAS],
    int max_gens
);

// AXI-friendly wrapper (flattened pointers).
void zonotope_step_kernel_axi(
    data_t* p_inout,
    data_t* H_inout,
    int* m_inout,
    const data_t* A,
    const data_t* p_w,
    const data_t* H_w, int m_w,
    const data_t* y,
    const data_t* phi,
    int max_gens
);

// Batch AXI kernel: processes n_steps steps in a single FPGA call.
// Static params (A, p_w, H_w, C) can be cached on-chip across invocations.
// Set reload_params=1 to refresh the cache from AXI; set reload_params=0 to
// reuse the previously loaded static matrices and only stream new state/meas.
// Measurements y_all/phi_all are read through separate AXI channels and
// consumed step-by-step without a batch-sized on-chip preload buffer.
// y_all  layout: y_all[k * N_MEAS + j]   (k=step, j=measurement index)
// phi_all layout: phi_all[k * N_MEAS + j]
void zonotope_batch_kernel_axi(
    data_t* p_inout,
    data_t* H_inout,
    int* m_inout,
    const data_t* A,
    const data_t* p_w,
    const data_t* H_w, int m_w,
    const data_t* y_all,
    const data_t* phi_all,
    int max_gens,
    int n_steps,
    int reload_params
);

#ifdef __cplusplus
}  // extern "C"
#endif

#endif
