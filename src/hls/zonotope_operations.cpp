#include "zonotope.hpp"
#include "kernels.hpp"
#include <cmath>

// ------------------------------
// Lambda: Segment (闭式解)
// ------------------------------
void compute_lambda_segment(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    int c_idx,
    data_t phi
) {
    #pragma HLS INLINE
    #pragma HLS ARRAY_PARTITION variable=H complete dim=1
    #pragma HLS ARRAY_PARTITION variable=lambda complete dim=1

    static constexpr int OSC_BLOCK_SIZE = 4;
    const int ACCUM_LANES = 4;
    data_t HHT_c_acc[ACCUM_LANES][OSC_BLOCK_SIZE];
    #pragma HLS ARRAY_PARTITION variable=HHT_c_acc complete dim=1
    #pragma HLS ARRAY_PARTITION variable=HHT_c_acc complete dim=2
    const int block_base = (c_idx / OSC_BLOCK_SIZE) * OSC_BLOCK_SIZE;
    const int c_local = c_idx - block_base;

    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        lambda[i] = 0.0f;
    }

    for (int l = 0; l < ACCUM_LANES; ++l) {
        #pragma HLS UNROLL
        for (int i = 0; i < OSC_BLOCK_SIZE; ++i) {
            #pragma HLS UNROLL
            HHT_c_acc[l][i] = 0.0f;
        }
    }

    for (int j = 0; j < m; ++j) {
        #pragma HLS PIPELINE II=1
        #pragma HLS LOOP_TRIPCOUNT min=0 max=STEP_MEAS_MAX_GEN
        const int lane = j & (ACCUM_LANES - 1);
        const data_t h_dot_c = H[c_idx][j];
        for (int i = 0; i < OSC_BLOCK_SIZE; ++i) {
            #pragma HLS UNROLL
            HHT_c_acc[lane][i] += H[block_base + i][j] * h_dot_c;
        }
    }

    data_t HHT_c[OSC_BLOCK_SIZE];
    #pragma HLS ARRAY_PARTITION variable=HHT_c complete dim=1
    for (int i = 0; i < OSC_BLOCK_SIZE; ++i) {
        #pragma HLS UNROLL
        data_t sum = 0.0f;
        for (int l = 0; l < ACCUM_LANES; ++l) {
            #pragma HLS UNROLL
            sum += HHT_c_acc[l][i];
        }
        HHT_c[i] = sum;
    }

    const data_t denom = phi * phi + HHT_c[c_local];
    if (std::fabs(denom) < 1e-12f) {
        return;
    }

    const data_t inv_denom = 1.0f / denom;
    for (int i = 0; i < OSC_BLOCK_SIZE; ++i) {
        #pragma HLS UNROLL
        lambda[block_base + i] = HHT_c[i] * inv_denom;
    }
}

// LAMBDA_P_RADIUS disabled for now.
#if 0
// ------------------------------
// Lambda: P-radius
// 说明：Python里用了矩阵求逆 P=inv(HHT+epsI)
// HLS里不建议做矩阵逆，这里先用 segment 作为可综合近似
// ------------------------------
static void mat4_mul(const data_t A[4][4], const data_t x[4], data_t y[4]) {
    for (int i = 0; i < 4; ++i) {
        data_t s = 0.0;
        for (int j = 0; j < 4; ++j) {
            #pragma HLS UNROLL
            s += A[i][j] * x[j];
        }
        y[i] = s;
    }
}

static data_t vec4_dot(const data_t a[4], const data_t b[4]) {
    data_t s = 0.0;
    for (int i = 0; i < 4; ++i) {
        #pragma HLS UNROLL
        s += a[i] * b[i];
    }
    return s;
}

static void mat4_add_epsI(data_t A[4][4], data_t eps) {
    for (int i = 0; i < 4; ++i) A[i][i] += eps;
}

// Adjugate matrix invert 4x4 (return false if singular)
static bool mat4_inv(const data_t A[4][4], data_t Ainv[4][4]) {
    #pragma HLS INLINE
    data_t m00 = A[0][0], m01 = A[0][1], m02 = A[0][2], m03 = A[0][3];
    data_t m10 = A[1][0], m11 = A[1][1], m12 = A[1][2], m13 = A[1][3];
    data_t m20 = A[2][0], m21 = A[2][1], m22 = A[2][2], m23 = A[2][3];
    data_t m30 = A[3][0], m31 = A[3][1], m32 = A[3][2], m33 = A[3][3];

    data_t c00 = m22 * m33 - m23 * m32;
    data_t c01 = m21 * m33 - m23 * m31;
    data_t c02 = m21 * m32 - m22 * m31;
    data_t c03 = m20 * m33 - m23 * m30;
    data_t c04 = m20 * m32 - m22 * m30;
    data_t c05 = m20 * m31 - m21 * m30;

    data_t c06 = m12 * m33 - m13 * m32;
    data_t c07 = m11 * m33 - m13 * m31;
    data_t c08 = m11 * m32 - m12 * m31;
    data_t c09 = m10 * m33 - m13 * m30;
    data_t c10 = m10 * m32 - m12 * m30;
    data_t c11 = m10 * m31 - m11 * m30;

    data_t c12 = m12 * m23 - m13 * m22;
    data_t c13 = m11 * m23 - m13 * m21;
    data_t c14 = m11 * m22 - m12 * m21;
    data_t c15 = m10 * m23 - m13 * m20;
    data_t c16 = m10 * m22 - m12 * m20;
    data_t c17 = m10 * m21 - m11 * m20;

    Ainv[0][0] =  (m11 * c00 - m12 * c01 + m13 * c02);
    Ainv[0][1] = -(m01 * c00 - m02 * c01 + m03 * c02);
    Ainv[0][2] =  (m01 * c06 - m02 * c07 + m03 * c08);
    Ainv[0][3] = -(m01 * c12 - m02 * c13 + m03 * c14);

    Ainv[1][0] = -(m10 * c00 - m12 * c03 + m13 * c04);
    Ainv[1][1] =  (m00 * c00 - m02 * c03 + m03 * c04);
    Ainv[1][2] = -(m00 * c06 - m02 * c09 + m03 * c10);
    Ainv[1][3] =  (m00 * c12 - m02 * c15 + m03 * c16);

    Ainv[2][0] =  (m10 * c01 - m11 * c03 + m13 * c05);
    Ainv[2][1] = -(m00 * c01 - m01 * c03 + m03 * c05);
    Ainv[2][2] =  (m00 * c07 - m01 * c09 + m03 * c11);
    Ainv[2][3] = -(m00 * c13 - m01 * c15 + m03 * c17);

    Ainv[3][0] = -(m10 * c02 - m11 * c04 + m12 * c05);
    Ainv[3][1] =  (m00 * c02 - m01 * c04 + m02 * c05);
    Ainv[3][2] = -(m00 * c08 - m01 * c10 + m02 * c11);
    Ainv[3][3] =  (m00 * c14 - m01 * c16 + m02 * c17);

    data_t det = m00 * Ainv[0][0] + m01 * Ainv[1][0] + m02 * Ainv[2][0] + m03 * Ainv[3][0];

    if (std::fabs(det) < 1e-18) return false;

    data_t invDet = 1.0 / det;
    for (int i = 0; i < 4; ++i) {
        #pragma HLS UNROLL
        for (int j = 0; j < 4; ++j) {
            #pragma HLS UNROLL
            Ainv[i][j] *= invDet;
        }
    }

    return true;
}

void compute_lambda_p_radius(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    // 1) HHT = H*H^T
    // data_t HHT[4][4] = {0};
    // for (int i = 0; i < 4; ++i) {
    //     #pragma HLS UNROLL
    //     for (int j = 0; j < 4; ++j) {
    //         #pragma HLS UNROLL
    //         data_t s = 0.0;
    //         for (int k = 0; k < m; ++k) {
    //             #pragma HLS PIPELINE II=1
    //             s += H[i][k] * H[j][k];
    //         }
    //         HHT[i][j] = s;
    //     }
    // }
    // 1. 初始化
    data_t HHT[4][4];
    for (int i = 0; i < 4; ++i) {
        #pragma HLS UNROLL
        for (int j = 0; j < 4; ++j) {
            #pragma HLS UNROLL
            HHT[i][j] = 0.0;
        }
    }
     // 2. 累加计算 (把 k 放到外层)
    for (int k = 0; k < m; ++k) {
        // 放宽 II 限制，让工具根据浮点加法延迟自动推导 (通常为 II=4)
        #pragma HLS PIPELINE 
        for (int i = 0; i < 4; ++i) {
            #pragma HLS UNROLL
            for (int j = 0; j < 4; ++j) {
                #pragma HLS UNROLL
                // 16个乘加器并行工作，且循环依赖距离变成跨 k 的迭代
                HHT[i][j] += H[i][k] * H[j][k];
            }
        }
    }

    // 2) P = inv(HHT + eps I)
    data_t A[4][4];
    for (int i = 0; i < 4; ++i) {
        #pragma HLS UNROLL
        for (int j = 0; j < 4; ++j) {
            #pragma HLS UNROLL
            A[i][j] = HHT[i][j];
        }
    }

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

    for (int i = 0; i < 4; ++i) {
        #pragma HLS UNROLL
        lambda[i] = num[i] / denom;
    }
}
#endif


// ------------------------------
// Lambda: Volume（同样先给可综合近似）
// ------------------------------
void compute_lambda_volume(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
) {
    #pragma HLS ARRAY_PARTITION variable=H complete dim=1
    #pragma HLS ARRAY_PARTITION variable=c complete dim=1
    #pragma HLS ARRAY_PARTITION variable=lambda complete dim=1

    // 预计算 t = c^T H  (1xm)
    // ARRAY_PARTITION keeps t[] in registers (not BRAM), enabling II=1 readout
    data_t t[MAX_GEN];
    #pragma HLS ARRAY_PARTITION variable=t complete dim=1
    for (int j = 0; j < MAX_GEN; ++j) {
        #pragma HLS UNROLL
        t[j] = 0.0f;
    }
    for (int j = 0; j < m; ++j) {
        #pragma HLS PIPELINE II=1
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        data_t s = 0.0;
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            s += c[i] * H[i][j];
        }
        t[j] = s;
    }

    // Interleaved accumulators (ACCUM_LANES=4) break the fadd loop-carried
    // dependency (latency=4 cycles) so that II=1 is achievable.
    const int ACCUM_LANES = 4;
    data_t t_sq_acc[ACCUM_LANES];
    #pragma HLS ARRAY_PARTITION variable=t_sq_acc complete dim=1
    for (int l = 0; l < ACCUM_LANES; ++l) {
        #pragma HLS UNROLL
        t_sq_acc[l] = 0.0f;
    }
    for (int j = 0; j < m; ++j) {
        #pragma HLS PIPELINE II=1
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        const int lane = j & (ACCUM_LANES - 1);
        t_sq_acc[lane] += t[j] * t[j];
    }
    data_t t_sq = 0.0f;
    for (int l = 0; l < ACCUM_LANES; ++l) {
        #pragma HLS UNROLL
        t_sq += t_sq_acc[l];
    }

    data_t c_sq = 0.0;
    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        c_sq += c[i] * c[i];
    }

    data_t denom = c_sq * (t_sq + phi * phi);
    data_t best_alpha = (denom > 1e-12f) ? (t_sq / denom) : 0.0f;

    // 输出最优 lambda
    for (int i = 0; i < N_STATE; ++i) lambda[i] = best_alpha * c[i];
}


static void reduce_compute_l1_col_norms(
    const data_t H[N_STATE][MAX_GEN],
    int m,
    data_t col_norm[MAX_GEN]
) {
    #pragma HLS INLINE off
    #pragma HLS ARRAY_PARTITION variable=H complete dim=1
    #pragma HLS ARRAY_PARTITION variable=col_norm complete dim=1

    for (int j = 0; j < m; j += 2) {
        #pragma HLS LOOP_TRIPCOUNT min=0 max=32
        #pragma HLS PIPELINE II=1
        const bool has_j1 = (j + 1) < m;

        const data_t j0_0  = (H[0][j]  < 0.0f) ? -H[0][j]  : H[0][j];
        const data_t j0_1  = (H[1][j]  < 0.0f) ? -H[1][j]  : H[1][j];
        const data_t j0_2  = (H[2][j]  < 0.0f) ? -H[2][j]  : H[2][j];
        const data_t j0_3  = (H[3][j]  < 0.0f) ? -H[3][j]  : H[3][j];
        const data_t j0_4  = (H[4][j]  < 0.0f) ? -H[4][j]  : H[4][j];
        const data_t j0_5  = (H[5][j]  < 0.0f) ? -H[5][j]  : H[5][j];
        const data_t j0_6  = (H[6][j]  < 0.0f) ? -H[6][j]  : H[6][j];
        const data_t j0_7  = (H[7][j]  < 0.0f) ? -H[7][j]  : H[7][j];
        const data_t j0_8  = (H[8][j]  < 0.0f) ? -H[8][j]  : H[8][j];
        const data_t j0_9  = (H[9][j]  < 0.0f) ? -H[9][j]  : H[9][j];
        const data_t j0_10 = (H[10][j] < 0.0f) ? -H[10][j] : H[10][j];
        const data_t j0_11 = (H[11][j] < 0.0f) ? -H[11][j] : H[11][j];
        const data_t j0_12 = (H[12][j] < 0.0f) ? -H[12][j] : H[12][j];
        const data_t j0_13 = (H[13][j] < 0.0f) ? -H[13][j] : H[13][j];
        const data_t j0_14 = (H[14][j] < 0.0f) ? -H[14][j] : H[14][j];
        const data_t j0_15 = (H[15][j] < 0.0f) ? -H[15][j] : H[15][j];
        const data_t j0_16 = (H[16][j] < 0.0f) ? -H[16][j] : H[16][j];
        const data_t j0_17 = (H[17][j] < 0.0f) ? -H[17][j] : H[17][j];
        const data_t j0_18 = (H[18][j] < 0.0f) ? -H[18][j] : H[18][j];
        const data_t j0_19 = (H[19][j] < 0.0f) ? -H[19][j] : H[19][j];
        const data_t j0_20 = (H[20][j] < 0.0f) ? -H[20][j] : H[20][j];
        const data_t j0_21 = (H[21][j] < 0.0f) ? -H[21][j] : H[21][j];
        const data_t j0_22 = (H[22][j] < 0.0f) ? -H[22][j] : H[22][j];
        const data_t j0_23 = (H[23][j] < 0.0f) ? -H[23][j] : H[23][j];
        col_norm[j] =
            j0_0 + j0_1 + j0_2 + j0_3 + j0_4 + j0_5 + j0_6 + j0_7 +
            j0_8 + j0_9 + j0_10 + j0_11 + j0_12 + j0_13 + j0_14 + j0_15 +
            j0_16 + j0_17 + j0_18 + j0_19 + j0_20 + j0_21 + j0_22 + j0_23;

        if (has_j1) {
            const data_t j1_0  = (H[0][j + 1]  < 0.0f) ? -H[0][j + 1]  : H[0][j + 1];
            const data_t j1_1  = (H[1][j + 1]  < 0.0f) ? -H[1][j + 1]  : H[1][j + 1];
            const data_t j1_2  = (H[2][j + 1]  < 0.0f) ? -H[2][j + 1]  : H[2][j + 1];
            const data_t j1_3  = (H[3][j + 1]  < 0.0f) ? -H[3][j + 1]  : H[3][j + 1];
            const data_t j1_4  = (H[4][j + 1]  < 0.0f) ? -H[4][j + 1]  : H[4][j + 1];
            const data_t j1_5  = (H[5][j + 1]  < 0.0f) ? -H[5][j + 1]  : H[5][j + 1];
            const data_t j1_6  = (H[6][j + 1]  < 0.0f) ? -H[6][j + 1]  : H[6][j + 1];
            const data_t j1_7  = (H[7][j + 1]  < 0.0f) ? -H[7][j + 1]  : H[7][j + 1];
            const data_t j1_8  = (H[8][j + 1]  < 0.0f) ? -H[8][j + 1]  : H[8][j + 1];
            const data_t j1_9  = (H[9][j + 1]  < 0.0f) ? -H[9][j + 1]  : H[9][j + 1];
            const data_t j1_10 = (H[10][j + 1] < 0.0f) ? -H[10][j + 1] : H[10][j + 1];
            const data_t j1_11 = (H[11][j + 1] < 0.0f) ? -H[11][j + 1] : H[11][j + 1];
            const data_t j1_12 = (H[12][j + 1] < 0.0f) ? -H[12][j + 1] : H[12][j + 1];
            const data_t j1_13 = (H[13][j + 1] < 0.0f) ? -H[13][j + 1] : H[13][j + 1];
            const data_t j1_14 = (H[14][j + 1] < 0.0f) ? -H[14][j + 1] : H[14][j + 1];
            const data_t j1_15 = (H[15][j + 1] < 0.0f) ? -H[15][j + 1] : H[15][j + 1];
            const data_t j1_16 = (H[16][j + 1] < 0.0f) ? -H[16][j + 1] : H[16][j + 1];
            const data_t j1_17 = (H[17][j + 1] < 0.0f) ? -H[17][j + 1] : H[17][j + 1];
            const data_t j1_18 = (H[18][j + 1] < 0.0f) ? -H[18][j + 1] : H[18][j + 1];
            const data_t j1_19 = (H[19][j + 1] < 0.0f) ? -H[19][j + 1] : H[19][j + 1];
            const data_t j1_20 = (H[20][j + 1] < 0.0f) ? -H[20][j + 1] : H[20][j + 1];
            const data_t j1_21 = (H[21][j + 1] < 0.0f) ? -H[21][j + 1] : H[21][j + 1];
            const data_t j1_22 = (H[22][j + 1] < 0.0f) ? -H[22][j + 1] : H[22][j + 1];
            const data_t j1_23 = (H[23][j + 1] < 0.0f) ? -H[23][j + 1] : H[23][j + 1];
            col_norm[j + 1] =
                j1_0 + j1_1 + j1_2 + j1_3 + j1_4 + j1_5 + j1_6 + j1_7 +
                j1_8 + j1_9 + j1_10 + j1_11 + j1_12 + j1_13 + j1_14 + j1_15 +
                j1_16 + j1_17 + j1_18 + j1_19 + j1_20 + j1_21 + j1_22 + j1_23;
        }
    }
}

static void reduce_select_topk(
    const data_t col_norm[MAX_GEN],
    int m,
    int top_idx[TOPK]
) {
    #pragma HLS INLINE off
    #pragma HLS ARRAY_PARTITION variable=col_norm complete dim=1
    #pragma HLS ARRAY_PARTITION variable=top_idx complete dim=1

    data_t top_vals[TOPK];
    #pragma HLS ARRAY_PARTITION variable=top_vals complete dim=1

    for (int k = 0; k < TOPK; ++k) {
        #pragma HLS UNROLL
        top_vals[k] = col_norm[k];
        top_idx[k] = k;
    }

    for (int j = TOPK; j < m; ++j) {
        #pragma HLS PIPELINE off
        #pragma HLS LOOP_TRIPCOUNT min=0 max=REDUCE_INPUT_MAX_GEN
        const data_t v = col_norm[j];
        const bool c01 = top_vals[0] < top_vals[1];
        const data_t m01_v = c01 ? top_vals[0] : top_vals[1];
        const int m01_k = c01 ? 0 : 1;
        const bool c23 = top_vals[2] < top_vals[3];
        const data_t m23_v = c23 ? top_vals[2] : top_vals[3];
        const int m23_k = c23 ? 2 : 3;
        const bool c45 = top_vals[4] < top_vals[5];
        const data_t m45_v = c45 ? top_vals[4] : top_vals[5];
        const int m45_k = c45 ? 4 : 5;
        const bool c67 = top_vals[6] < top_vals[7];
        const data_t m67_v = c67 ? top_vals[6] : top_vals[7];
        const int m67_k = c67 ? 6 : 7;

        const bool c03 = m01_v < m23_v;
        const data_t m03_v = c03 ? m01_v : m23_v;
        const int m03_k = c03 ? m01_k : m23_k;
        const bool c47 = m45_v < m67_v;
        const data_t m47_v = c47 ? m45_v : m67_v;
        const int m47_k = c47 ? m45_k : m67_k;

        const bool c07 = m03_v < m47_v;
        const data_t min_v = c07 ? m03_v : m47_v;
        const int min_k = c07 ? m03_k : m47_k;
        if (v > min_v) {
            top_vals[min_k] = v;
            top_idx[min_k] = j;
        }
    }
}

static void reduce_accumulate_diag(
    const data_t H[N_STATE][MAX_GEN],
    int m,
    const int top_idx[TOPK],
    data_t d[N_STATE]
) {
    #pragma HLS INLINE off
    #pragma HLS ARRAY_PARTITION variable=H complete dim=1
    #pragma HLS ARRAY_PARTITION variable=top_idx complete dim=1
    #pragma HLS ARRAY_PARTITION variable=d complete dim=1

    static constexpr int REDUCE_STATE_PAR = N_STATE;
    static constexpr int REDUCE_STATE_BLOCKS = N_STATE / REDUCE_STATE_PAR;
    const int ACCUM_LANES = 4;

    bool kept_flag[MAX_GEN];
    #pragma HLS ARRAY_PARTITION variable=kept_flag complete dim=1
    for (int j = 0; j < MAX_GEN; ++j) {
        #pragma HLS UNROLL
        kept_flag[j] = false;
    }
    for (int k = 0; k < TOPK; ++k) {
        #pragma HLS UNROLL
        kept_flag[top_idx[k]] = true;
    }

    data_t d_acc[ACCUM_LANES][N_STATE];
    #pragma HLS ARRAY_PARTITION variable=d_acc complete dim=1
    #pragma HLS ARRAY_PARTITION variable=d_acc complete dim=2
    for (int l = 0; l < ACCUM_LANES; ++l) {
        #pragma HLS UNROLL
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            d_acc[l][i] = 0.0f;
        }
    }

    for (int j = 0; j < m; ++j) {
        #pragma HLS LOOP_TRIPCOUNT min=0 max=REDUCE_INPUT_MAX_GEN
        const int lane = j & (ACCUM_LANES - 1);
        if (!kept_flag[j]) {
            for (int blk = 0; blk < REDUCE_STATE_BLOCKS; ++blk) {
                #pragma HLS PIPELINE II=1
                const int base = blk * REDUCE_STATE_PAR;
                for (int i = 0; i < REDUCE_STATE_PAR; ++i) {
                    #pragma HLS UNROLL
                    const data_t v = H[base + i][j];
                    d_acc[lane][base + i] += (v < 0.0f ? -v : v);
                }
            }
        }
    }

    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        data_t s = 0.0f;
        for (int l = 0; l < ACCUM_LANES; ++l) {
            #pragma HLS UNROLL
            s += d_acc[l][i];
        }
        d[i] = s;
    }
}

static void reduce_writeback(
    data_t H[N_STATE][MAX_GEN],
    const int top_idx[TOPK],
    const data_t d[N_STATE]
) {
    #pragma HLS INLINE off
    #pragma HLS ARRAY_PARTITION variable=H complete dim=1
    #pragma HLS ARRAY_PARTITION variable=top_idx complete dim=1
    #pragma HLS ARRAY_PARTITION variable=d complete dim=1

    data_t H_kept[N_STATE][TOPK];
    #pragma HLS ARRAY_PARTITION variable=H_kept complete dim=1
    #pragma HLS ARRAY_PARTITION variable=H_kept complete dim=2

    for (int k = 0; k < TOPK; ++k) {
        #pragma HLS UNROLL
        const int old_j = top_idx[k];
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            H_kept[i][k] = H[i][old_j];
        }
    }

    for (int k = 0; k < TOPK; ++k) {
        #pragma HLS UNROLL
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            H[i][k] = H_kept[i][k];
        }
    }
    for (int j = TOPK; j < REDUCTION_BUDGET; ++j) {
        #pragma HLS UNROLL
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            H[i][j] = 0.0f;
        }
    }
    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        H[i][TOPK + i] = d[i];
    }
    for (int j = REDUCTION_BUDGET; j < MAX_GEN; ++j) {
        #pragma HLS UNROLL
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            H[i][j] = 0.0f;
        }
    }
}

// ------------------------------
// Reduce: box-preserving, in-place on H[N_STATE][MAX_GEN].
// ------------------------------
void zonotope_reduce(data_t H[N_STATE][MAX_GEN], int* m_ptr) {
    #pragma HLS ARRAY_PARTITION variable=H complete dim=1

    const int m = *m_ptr;
    if (m <= REDUCTION_BUDGET) return;

    data_t col_norm[MAX_GEN];
    int top_idx[TOPK];
    data_t d[N_STATE];
    #pragma HLS ARRAY_PARTITION variable=col_norm complete dim=1
    #pragma HLS ARRAY_PARTITION variable=top_idx complete dim=1
    #pragma HLS ARRAY_PARTITION variable=d complete dim=1

    reduce_compute_l1_col_norms(H, m, col_norm);
    reduce_select_topk(col_norm, m, top_idx);
    reduce_accumulate_diag(H, m, top_idx, d);
    reduce_writeback(H, top_idx, d);

    *m_ptr = REDUCTION_BUDGET;
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
