#include "kernels.hpp"
#include <stdio.h>
#include <math.h>
#include <assert.h>

extern "C" {

static constexpr int STATE_PAR = 8;
static constexpr int STATE_BLOCKS = N_STATE / STATE_PAR;
static constexpr int OSC_BLOCK_SIZE = 4;
static constexpr int OSC_BLOCKS = N_STATE / OSC_BLOCK_SIZE;

static inline int meas_state_index(int meas) {
#pragma HLS INLINE
    return (meas / 2) * OSC_BLOCK_SIZE + (meas % 2);
}

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
#pragma HLS INLINE
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
#pragma HLS INLINE
    int i, j;

    // Ensure we always have room to append one generator.
    assert(m >= 0 && m < MAX_GEN);

    /* residual r = y - c^T p */
    data_t residual = 0.0;
    for (i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        residual += c[i] * p[i];
    }
    data_t r = y - residual;

    /* p_hat = p + lambda * r */
    for (i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        p_hat[i] = p[i] + lambda[i] * r;
    }

    /* H_hat = H - lambda * (c^T H) */
    for (j = 0; j < m; ++j) {
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        #pragma HLS PIPELINE II=1
        data_t t = 0.0;
        for (i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            t += c[i] * H[i][j];
        }
        for (i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            H_hat[i][j] = H[i][j] - lambda[i] * t;
        }
    }

    /* append phi * lambda */
    for (i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
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
    #pragma HLS ARRAY_PARTITION variable=H_drop complete dim=1
    #pragma HLS ARRAY_PARTITION variable=row_sum complete dim=1

    const int ACCUM_LANES = 4;
    data_t acc[ACCUM_LANES][N_STATE];
    #pragma HLS ARRAY_PARTITION variable=acc complete dim=1
    #pragma HLS ARRAY_PARTITION variable=acc complete dim=2
    for (int l = 0; l < ACCUM_LANES; ++l) {
        #pragma HLS UNROLL
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            acc[l][i] = 0.0;
        }
    }

    for (int j = 0; j < m_drop; ++j) {
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        #pragma HLS PIPELINE II=1
        const int lane = j & (ACCUM_LANES - 1);
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            data_t v = H_drop[i][j];
            acc[lane][i] += (v >= 0.0) ? v : -v;  // abs without <cmath>
        }
    }

    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        data_t sum = 0.0;
        for (int l = 0; l < ACCUM_LANES; ++l) {
            #pragma HLS UNROLL
            sum += acc[l][i];
        }
        row_sum[i] = sum;
    }
}

/* ================= Top Level Step Kernel ================= */
// Fully in-place: all predict/update/reduce operations work directly on
// (p_inout, H_inout).  No H_pred / H_upd / H_next2 / Z.H intermediate arrays.
// Only scratch buffers are: p_tmp[N_STATE] and col_tmp[N_STATE] (tiny).
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
) {
#pragma HLS ARRAY_PARTITION variable=p_inout complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_inout cyclic factor=STATE_PAR dim=1
#pragma HLS ARRAY_PARTITION variable=A       complete dim=2
#pragma HLS ARRAY_PARTITION variable=p_w     complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_w     cyclic factor=STATE_PAR dim=1
#pragma HLS ARRAY_PARTITION variable=y       complete dim=1
#pragma HLS ARRAY_PARTITION variable=phi     complete dim=1

    int m = *m_inout;

    // 1. Predict IN-PLACE on (p_inout, H_inout)

    // 1a. p_inout = A*p_inout + p_w  (tiny 24-float scratch)
    data_t p_tmp[N_STATE];
#pragma HLS ARRAY_PARTITION variable=p_tmp complete dim=1
    for (int b = 0; b < OSC_BLOCKS; ++b) {
#pragma HLS PIPELINE II=1
        const int base = b * OSC_BLOCK_SIZE;
        const data_t x0 = p_inout[base + 0];
        const data_t x1 = p_inout[base + 1];
        const data_t x2 = p_inout[base + 2];
        const data_t x3 = p_inout[base + 3];

        p_tmp[base + 0] = p_w[base + 0]
                        + A[base + 0][base + 0] * x0
                        + A[base + 0][base + 1] * x1
                        + A[base + 0][base + 2] * x2
                        + A[base + 0][base + 3] * x3;
        p_tmp[base + 1] = p_w[base + 1]
                        + A[base + 1][base + 0] * x0
                        + A[base + 1][base + 1] * x1
                        + A[base + 1][base + 2] * x2
                        + A[base + 1][base + 3] * x3;
        p_tmp[base + 2] = p_w[base + 2]
                        + A[base + 2][base + 0] * x0
                        + A[base + 2][base + 1] * x1
                        + A[base + 2][base + 2] * x2
                        + A[base + 2][base + 3] * x3;
        p_tmp[base + 3] = p_w[base + 3]
                        + A[base + 3][base + 0] * x0
                        + A[base + 3][base + 1] * x1
                        + A[base + 3][base + 2] * x2
                        + A[base + 3][base + 3] * x3;
    }
    for (int i = 0; i < N_STATE; ++i) {
#pragma HLS UNROLL
        p_inout[i] = p_tmp[i];
    }

    // 1b. H_inout[:,0:m] = A * H_inout[:,0:m]  (in-place, column-by-column)
    //     Each column k is computed atomically: read old H[:,k] → col_tmp → write new H[:,k].
    //     Columns k' ≠ k are never touched in the same k iteration → no alias hazard.
    data_t col_tmp[N_STATE];
#pragma HLS ARRAY_PARTITION variable=col_tmp complete dim=1
    for (int k = 0; k < m; ++k) {
#pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
#pragma HLS DEPENDENCE variable=H_inout inter false
        for (int b = 0; b < OSC_BLOCKS; ++b) {
#pragma HLS PIPELINE II=1
            const int base = b * OSC_BLOCK_SIZE;
            const data_t h0 = H_inout[base + 0][k];
            const data_t h1 = H_inout[base + 1][k];
            const data_t h2 = H_inout[base + 2][k];
            const data_t h3 = H_inout[base + 3][k];

            col_tmp[base + 0] = A[base + 0][base + 0] * h0
                              + A[base + 0][base + 1] * h1
                              + A[base + 0][base + 2] * h2
                              + A[base + 0][base + 3] * h3;
            col_tmp[base + 1] = A[base + 1][base + 0] * h0
                              + A[base + 1][base + 1] * h1
                              + A[base + 1][base + 2] * h2
                              + A[base + 1][base + 3] * h3;
            col_tmp[base + 2] = A[base + 2][base + 0] * h0
                              + A[base + 2][base + 1] * h1
                              + A[base + 2][base + 2] * h2
                              + A[base + 2][base + 3] * h3;
            col_tmp[base + 3] = A[base + 3][base + 0] * h0
                              + A[base + 3][base + 1] * h1
                              + A[base + 3][base + 2] * h2
                              + A[base + 3][base + 3] * h3;
        }
        for (int i = 0; i < N_STATE; ++i) {
#pragma HLS UNROLL factor=STATE_PAR
            H_inout[i][k] = col_tmp[i];
        }
    }

    // 1c. Append process-noise generators H_w
    for (int k = 0; k < m_w; ++k) {
#pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
#pragma HLS DEPENDENCE variable=H_inout inter false
        for (int i = 0; i < N_STATE; ++i) {
#pragma HLS UNROLL factor=STATE_PAR
            H_inout[i][m + k] = H_w[i][k];
        }
    }
    m += m_w;

    // 2. Early reduce if prediction exceeds budget
    if (m > REDUCTION_BUDGET) {
        zonotope_reduce(H_inout, &m);
    }

    // 3. Strip updates — fully IN-PLACE on p_inout / H_inout
    for (int meas = 0; meas < N_MEAS; ++meas) {
        const int meas_state = meas_state_index(meas);
        data_t lambda[N_STATE];
#pragma HLS ARRAY_PARTITION variable=lambda complete dim=1
        for (int i = 0; i < N_STATE; ++i) {
#pragma HLS UNROLL
            lambda[i] = 0.0f;
        }

        compute_lambda_segment(lambda, H_inout, m, meas_state, phi[meas]);

        // For the current model, each measurement row is a one-hot selector
        // of the first two states in its 4x4 oscillator block.
        const data_t residual = p_inout[meas_state];
        const data_t r = y[meas] - residual;

        // p += lambda * r  (in-place)
        for (int i = 0; i < N_STATE; ++i) {
#pragma HLS UNROLL factor=STATE_PAR
            p_inout[i] += lambda[i] * r;
        }

        // Update H a bank-aligned block at a time. Keep only half a bank
        // active per cycle here; the recovered fast lambda path already
        // pushes timing hard, and the full 8-lane update becomes the
        // dominant critical path at fpga_kernels.cpp:344.
        for (int j = 0; j < m; ++j) {
#pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
#pragma HLS PIPELINE II=1
#pragma HLS DEPENDENCE variable=H_inout inter false
            const data_t t = H_inout[meas_state][j];
            for (int i = 0; i < N_STATE; ++i) {
#pragma HLS UNROLL factor=STATE_PAR
                H_inout[i][j] -= lambda[i] * t;
            }
        }

        // Append phi*lambda as new generator
        for (int i = 0; i < N_STATE; ++i) {
#pragma HLS UNROLL factor=STATE_PAR
            H_inout[i][m] = phi[meas] * lambda[i];
        }
        m += 1;
    }

    // 4. Final reduce
    zonotope_reduce(H_inout, &m);

    // 5. Write back only m (p_inout and H_inout modified in-place above)
    *m_inout = m;
}

// AXI-friendly wrapper: flattened pointers + explicit interfaces.中文：AXI友好包装器：扁平化指针 + 显式接口。
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
) {
#pragma HLS INTERFACE m_axi     port=p_inout offset=slave bundle=state_port depth=N_STATE    // AXI接口，port指定端口，offset=slave表示从外部主机访问，bundle=state_port表示这个接口属于state_port组，depth=N_STATE表示这个接口可以访问N_STATE个数据元素。
#pragma HLS INTERFACE m_axi     port=H_inout offset=slave bundle=state_port depth=(N_STATE*MAX_GEN)
#pragma HLS INTERFACE m_axi     port=m_inout offset=slave bundle=state_port depth=1
#pragma HLS INTERFACE m_axi     port=A       offset=slave bundle=param_port depth=(N_STATE*N_STATE)
#pragma HLS INTERFACE m_axi     port=p_w     offset=slave bundle=param_port depth=N_STATE
#pragma HLS INTERFACE m_axi     port=H_w     offset=slave bundle=param_port depth=(N_STATE*MAX_GEN)
#pragma HLS INTERFACE m_axi     port=y       offset=slave bundle=param_port depth=N_MEAS
#pragma HLS INTERFACE m_axi     port=phi     offset=slave bundle=param_port depth=N_MEAS
#pragma HLS INTERFACE s_axilite port=p_inout bundle=control   // AXI Lite接口，port指定端口，bundle=control表示这个接口属于control组，AXI Lite接口适合访问少量控制寄存器，这里p_inout是一个输入输出参数，所以需要AXI Lite接口来读写它。
#pragma HLS INTERFACE s_axilite port=H_inout bundle=control
#pragma HLS INTERFACE s_axilite port=m_inout bundle=control
#pragma HLS INTERFACE s_axilite port=A       bundle=control
#pragma HLS INTERFACE s_axilite port=p_w     bundle=control
#pragma HLS INTERFACE s_axilite port=H_w     bundle=control
#pragma HLS INTERFACE s_axilite port=y       bundle=control
#pragma HLS INTERFACE s_axilite port=phi     bundle=control
#pragma HLS INTERFACE s_axilite port=m_w     bundle=control
#pragma HLS INTERFACE s_axilite port=max_gens bundle=control
#pragma HLS INTERFACE s_axilite port=return  bundle=control

    data_t p_local[N_STATE];
    data_t H_local[N_STATE][MAX_GEN];
    data_t A_local[N_STATE][N_STATE];
    data_t p_w_local[N_STATE];
    data_t H_w_local[N_STATE][MAX_GEN];
    data_t y_local[N_MEAS];
    data_t phi_local[N_MEAS];
    int m_local = *m_inout;

#pragma HLS ARRAY_PARTITION variable=p_local complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_local complete dim=1
#pragma HLS ARRAY_PARTITION variable=A_local complete dim=2
#pragma HLS ARRAY_PARTITION variable=p_w_local complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_w_local complete dim=1
#pragma HLS ARRAY_PARTITION variable=y_local complete dim=1
#pragma HLS ARRAY_PARTITION variable=phi_local complete dim=1

    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS PIPELINE II=1
        p_local[i] = p_inout[i];
    }
    
    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS PIPELINE II=1
        p_w_local[i] = p_w[i];
    }
    
    for (int i = 0; i < N_STATE; ++i) {
        for (int j = 0; j < N_STATE; ++j) {
            #pragma HLS PIPELINE II=1
            A_local[i][j] = A[i * N_STATE + j];
        }
    }

    // Read full H_inout (constant MAX_GEN bound keeps H_local in registers,
    // not RAM — critical for ARRAY_PARTITION complete to take effect).
    for (int r = 0; r < N_STATE; ++r) {
        for (int c = 0; c < MAX_GEN; ++c) {
            #pragma HLS PIPELINE II=1
            H_local[r][c] = H_inout[r * MAX_GEN + c];
        }
    }

    // Read full H_w (same reason).
    for (int r = 0; r < N_STATE; ++r) {
        for (int c = 0; c < MAX_GEN; ++c) {
            #pragma HLS PIPELINE II=1
            H_w_local[r][c] = H_w[r * MAX_GEN + c];
        }
    }

    for (int r = 0; r < N_MEAS; ++r) {
        #pragma HLS PIPELINE II=1
        y_local[r] = y[r];
    }
    
    for (int r = 0; r < N_MEAS; ++r) {
        #pragma HLS PIPELINE II=1
        phi_local[r] = phi[r];
    }
    
    zonotope_step_kernel(
        p_local,
        H_local,
        &m_local,
        A_local,
        p_w_local,
        H_w_local,
        m_w,
        y_local,
        phi_local,
        max_gens
    );

    *m_inout = m_local;
    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS PIPELINE II=1
        p_inout[i] = p_local[i];
    }
    // Write back full MAX_GEN (constant bound → H_local stays in registers).
    for (int r = 0; r < N_STATE; ++r) {
        #pragma HLS UNROLL
        for (int c = 0; c < MAX_GEN; ++c) {
            #pragma HLS PIPELINE II=1
            H_inout[r * MAX_GEN + c] = H_local[r][c];
        }
    }
}

// ===================================================================
// Batch AXI Kernel
// ===================================================================
// Processes n_steps filter steps in a single FPGA invocation.
//
// Key idea: static matrices (A, p_w, H_w) are loaded from AXI ONCE.
// Measurements are then pulled step-by-step from AXI directly into tiny
// N_MEAS-local registers, so the kernel avoids a batch-sized y/phi buffer.
//
// y_all  layout: y_all  [k * N_MEAS + j]
// phi_all layout: phi_all[k * N_MEAS + j]
// ===================================================================
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
) {
    // ---- AXI memory interfaces ----
    // state_port: carries the zonotope state (in/out, small, updated once)
#pragma HLS INTERFACE m_axi port=p_inout  offset=slave bundle=state_port depth=N_STATE
#pragma HLS INTERFACE m_axi port=H_inout  offset=slave bundle=state_port depth=(N_STATE*MAX_GEN)
#pragma HLS INTERFACE m_axi port=m_inout  offset=slave bundle=state_port depth=1
    // param_port: carries static system matrices (read once, never written)
#pragma HLS INTERFACE m_axi port=A        offset=slave bundle=param_port depth=(N_STATE*N_STATE)
#pragma HLS INTERFACE m_axi port=p_w      offset=slave bundle=param_port depth=N_STATE
#pragma HLS INTERFACE m_axi port=H_w      offset=slave bundle=param_port depth=(N_STATE*MAX_GEN)
    // Split measurement payload across two AXI channels so preload can read
    // y and phi in the same pipeline iteration without contending on one port.
#pragma HLS INTERFACE m_axi port=y_all    offset=slave bundle=meas_y_port   depth=(N_BATCH*N_MEAS)
#pragma HLS INTERFACE m_axi port=phi_all  offset=slave bundle=meas_phi_port depth=(N_BATCH*N_MEAS)

    // ---- AXI-Lite control register interface ----
#pragma HLS INTERFACE s_axilite port=p_inout       bundle=control
#pragma HLS INTERFACE s_axilite port=H_inout       bundle=control
#pragma HLS INTERFACE s_axilite port=m_inout       bundle=control
#pragma HLS INTERFACE s_axilite port=A             bundle=control
#pragma HLS INTERFACE s_axilite port=p_w           bundle=control
#pragma HLS INTERFACE s_axilite port=H_w           bundle=control
#pragma HLS INTERFACE s_axilite port=y_all         bundle=control
#pragma HLS INTERFACE s_axilite port=phi_all       bundle=control
#pragma HLS INTERFACE s_axilite port=m_w           bundle=control
#pragma HLS INTERFACE s_axilite port=max_gens      bundle=control
#pragma HLS INTERFACE s_axilite port=n_steps       bundle=control
#pragma HLS INTERFACE s_axilite port=reload_params bundle=control
#pragma HLS INTERFACE s_axilite port=return        bundle=control

    // Static parameter cache persists across accelerator invocations.
    static data_t A_cache[N_STATE][N_STATE];
    static data_t p_w_cache[N_STATE];
    static data_t H_w_cache[N_STATE][MAX_GEN];
    static int cached_m_w = 0;
    static int params_valid = 0;

    // ---- On-chip local buffers (registers / BRAM) ----
    data_t p_local[N_STATE];
    data_t H_local[N_STATE][MAX_GEN];

#pragma HLS ARRAY_PARTITION variable=A_cache    complete dim=2
#pragma HLS ARRAY_PARTITION variable=p_w_cache  complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_w_cache  cyclic factor=STATE_PAR dim=1
#pragma HLS ARRAY_PARTITION variable=p_local    complete dim=1
#pragma HLS ARRAY_PARTITION variable=H_local    cyclic factor=STATE_PAR dim=1

    int m_local = *m_inout;
    assert(n_steps >= 0 && n_steps <= N_BATCH);
    const int need_reload = reload_params || !params_valid;

    // ---- 1. Load current zonotope state ----
    for (int i = 0; i < N_STATE; ++i) {
#pragma HLS PIPELINE II=1
        p_local[i] = p_inout[i];
    }
    for (int r = 0; r < N_STATE; ++r) {
        for (int c = 0; c < MAX_GEN; ++c) {
#pragma HLS PIPELINE II=1
            H_local[r][c] = H_inout[r * MAX_GEN + c];
        }
    }

    // ---- 2. Load STATIC system matrices only when requested ----
    if (need_reload) {
        for (int i = 0; i < N_STATE; ++i) {
#pragma HLS PIPELINE II=1
            p_w_cache[i] = p_w[i];
        }
        for (int i = 0; i < N_STATE; ++i) {
            for (int j = 0; j < N_STATE; ++j) {
#pragma HLS PIPELINE II=1
                A_cache[i][j] = A[i * N_STATE + j];
            }
        }
        for (int r = 0; r < N_STATE; ++r) {
            for (int c = 0; c < MAX_GEN; ++c) {
#pragma HLS PIPELINE II=1
                H_w_cache[r][c] = H_w[r * MAX_GEN + c];
            }
        }
        cached_m_w = m_w;
        params_valid = 1;
    }

    // ---- 3. Pull measurements step-by-step and update the state in place ----
    for (int k = 0; k < n_steps; ++k) {
#pragma HLS LOOP_TRIPCOUNT min=1 max=N_BATCH
        data_t y_k[N_MEAS];
        data_t phi_k[N_MEAS];
#pragma HLS ARRAY_PARTITION variable=y_k complete dim=1
#pragma HLS ARRAY_PARTITION variable=phi_k complete dim=1

        for (int j = 0; j < N_MEAS; ++j) {
#pragma HLS PIPELINE II=1
            y_k[j] = y_all[k * N_MEAS + j];
            phi_k[j] = phi_all[k * N_MEAS + j];
        }

        zonotope_step_kernel(
            p_local,
            H_local,
            &m_local,
            A_cache,
            p_w_cache,
            H_w_cache,
            cached_m_w,
            y_k,
            phi_k,
            max_gens
        );
    }

    // ---- 4. Write back updated zonotope state ----
    *m_inout = m_local;
    for (int i = 0; i < N_STATE; ++i) {
#pragma HLS PIPELINE II=1
        p_inout[i] = p_local[i];
    }
    for (int r = 0; r < N_STATE; ++r) {
#pragma HLS UNROLL
        for (int c = 0; c < MAX_GEN; ++c) {
#pragma HLS PIPELINE II=1
            H_inout[r * MAX_GEN + c] = H_local[r][c];
        }
    }
}

}
