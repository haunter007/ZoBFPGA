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
    #pragma HLS ARRAY_PARTITION variable=H complete dim=1
    #pragma HLS ARRAY_PARTITION variable=lambda complete dim=1

    const int ACCUM_LANES = 4;
    data_t HHT_c_acc[ACCUM_LANES][N_STATE];
    #pragma HLS ARRAY_PARTITION variable=HHT_c_acc complete dim=1
    #pragma HLS ARRAY_PARTITION variable=HHT_c_acc complete dim=2

    for (int l = 0; l < ACCUM_LANES; ++l) {
        #pragma HLS UNROLL
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            HHT_c_acc[l][i] = 0.0f;
        }
    }

    for (int j = 0; j < m; ++j) {
        #pragma HLS PIPELINE II=1
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        const int lane = j & (ACCUM_LANES - 1);
        const data_t h_dot_c = H[c_idx][j];
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            HHT_c_acc[lane][i] += H[i][j] * h_dot_c;
        }
    }

    data_t HHT_c[N_STATE];
    #pragma HLS ARRAY_PARTITION variable=HHT_c complete dim=1
    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        data_t sum = 0.0f;
        for (int l = 0; l < ACCUM_LANES; ++l) {
            #pragma HLS UNROLL
            sum += HHT_c_acc[l][i];
        }
        HHT_c[i] = sum;
    }

    const data_t denom = phi * phi + HHT_c[c_idx];
    if (std::fabs(denom) < 1e-12f) {
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            lambda[i] = 0.0f;
        }
        return;
    }

    const data_t inv_denom = 1.0f / denom;
    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        lambda[i] = HHT_c[i] * inv_denom;
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


// ------------------------------
// Reduce: box-preserving, in-place on H[N_STATE][MAX_GEN].
//
// Always reduces to REDUCTION_BUDGET = TOPK + N_STATE generators.
// Layout after reduce:
//   H[:,0..TOPK-1]              : top-TOPK kept generators (sorted by norm)
//   H[:,TOPK..TOPK+N_STATE-1]   : diagonal overapproximation of dropped generators
//   H[:,TOPK+N_STATE..MAX_GEN-1]: zeros
//
// H_kept[N_STATE][TOPK] replaces the old H_new[N_STATE][MAX_GEN] to stay in
// LUT-affordable register storage (24×8 = 192 vs 24×64 = 1536 elements).
// ------------------------------
void zonotope_reduce(data_t H[N_STATE][MAX_GEN], int* m_ptr) {
    static constexpr int REDUCE_STATE_PAR = 8;
    static constexpr int REDUCE_STATE_BLOCKS = N_STATE / REDUCE_STATE_PAR;

    const int m = *m_ptr;
    if (m <= REDUCTION_BUDGET) return;

    // 1) Compute L1 column norms.
    //    The old fast branch behaved more like a cheap magnitude ranking than
    //    a numerically careful Euclidean norm. Using L1 here removes the
    //    sqrt/scale machinery while preserving a monotone "large column first"
    //    ordering for reduction.
    data_t col_norm[MAX_GEN];
    #pragma HLS ARRAY_PARTITION variable=col_norm complete dim=1
    for (int j = 0; j < m; ++j) {
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        data_t sum_abs_blk[REDUCE_STATE_BLOCKS];
        #pragma HLS ARRAY_PARTITION variable=sum_abs_blk complete dim=1
        for (int blk = 0; blk < REDUCE_STATE_BLOCKS; ++blk) {
            #pragma HLS PIPELINE II=1
            const int base = blk * REDUCE_STATE_PAR;
            const data_t a0 = (H[base + 0][j] < 0.0f) ? -H[base + 0][j] : H[base + 0][j];
            const data_t a1 = (H[base + 1][j] < 0.0f) ? -H[base + 1][j] : H[base + 1][j];
            const data_t a2 = (H[base + 2][j] < 0.0f) ? -H[base + 2][j] : H[base + 2][j];
            const data_t a3 = (H[base + 3][j] < 0.0f) ? -H[base + 3][j] : H[base + 3][j];
            const data_t a4 = (H[base + 4][j] < 0.0f) ? -H[base + 4][j] : H[base + 4][j];
            const data_t a5 = (H[base + 5][j] < 0.0f) ? -H[base + 5][j] : H[base + 5][j];
            const data_t a6 = (H[base + 6][j] < 0.0f) ? -H[base + 6][j] : H[base + 6][j];
            const data_t a7 = (H[base + 7][j] < 0.0f) ? -H[base + 7][j] : H[base + 7][j];
            sum_abs_blk[blk] = a0 + a1 + a2 + a3 + a4 + a5 + a6 + a7;
        }
        col_norm[j] = sum_abs_blk[0] + sum_abs_blk[1] + sum_abs_blk[2];
    }

    // 2) Single-pass top-TOPK selection.
    //    We only keep TOPK candidates. Guard slots (inf) are unnecessary because
    //    min selection never needs to consider indices outside [0..TOPK-1].
    data_t top_vals[TOPK];
    int    top_idx[TOPK];
    #pragma HLS ARRAY_PARTITION variable=top_vals complete dim=1
    #pragma HLS ARRAY_PARTITION variable=top_idx  complete dim=1

    for (int k = 0; k < TOPK; ++k) {
        #pragma HLS UNROLL
        top_vals[k] = col_norm[k];
        top_idx[k]  = k;
    }

    // Auto-pipelining this loop was landing at II=8 because the compare/update
    // chain carries state across iterations. TOPK is only 8, so keeping this
    // loop sequential is a better tradeoff while we reduce LUT pressure.
    for (int j = TOPK; j < m; ++j) {
        #pragma HLS PIPELINE off
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        const data_t v = col_norm[j];
        int min_k = 0;
        data_t min_v = top_vals[0];
        for (int k = 1; k < TOPK; ++k) {
            #pragma HLS UNROLL
            if (top_vals[k] < min_v) {
                min_v = top_vals[k];
                min_k = k;
            }
        }
        if (v > min_v) {
            top_vals[min_k] = v;
            top_idx[min_k] = j;
        }
    }

    // 3) Save top-TOPK columns into compact H_kept[N_STATE][TOPK].
    //    TOPK = 8 → only 192 registers vs 1536 for H_new[N_STATE][MAX_GEN].
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

    // 4) Build kept_flag and row-sum dropped columns.
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

    const int ACCUM_LANES = 4;
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
        #pragma HLS LOOP_TRIPCOUNT min=0 max=MAX_GEN
        const int lane = j & (ACCUM_LANES - 1);
        const data_t w = kept_flag[j] ? 0.0f : 1.0f;
        for (int blk = 0; blk < REDUCE_STATE_BLOCKS; ++blk) {
            #pragma HLS PIPELINE II=1
            const int base = blk * REDUCE_STATE_PAR;
            for (int i = 0; i < REDUCE_STATE_PAR; ++i) {
                #pragma HLS UNROLL
                const data_t v = H[base + i][j];
                d_acc[lane][base + i] += w * (v < 0.0f ? -v : v);
            }
        }
    }
    data_t d[N_STATE];
    #pragma HLS ARRAY_PARTITION variable=d complete dim=1
    for (int i = 0; i < N_STATE; ++i) {
        #pragma HLS UNROLL
        data_t s = 0.0f;
        for (int l = 0; l < ACCUM_LANES; ++l) {
            #pragma HLS UNROLL
            s += d_acc[l][i];
        }
        d[i] = s;
    }

    // 5) Write result directly into H (no H_new copy needed):
    //    Columns 0..TOPK-1         : H_kept (kept generators) — static addressing
    //    Columns TOPK..TOPK+N_STATE-1 : diagonal d[] — static addressing (TOPK is const)
    //    Columns TOPK+N_STATE..MAX_GEN-1 : zeros — static addressing
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
        H[i][TOPK + i] = d[i];           // TOPK is compile-time → static column address
    }
    for (int j = REDUCTION_BUDGET; j < MAX_GEN; ++j) {
        #pragma HLS UNROLL
        for (int i = 0; i < N_STATE; ++i) {
            #pragma HLS UNROLL
            H[i][j] = 0.0f;
        }
    }

    *m_ptr = REDUCTION_BUDGET;            // = TOPK + N_STATE, compile-time constant
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
