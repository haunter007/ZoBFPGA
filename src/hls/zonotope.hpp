#ifndef ZONOTOPE_H
#define ZONOTOPE_H

#define N_STATE               24    // 状态维度 // State dimension (6 coupled oscillator blocks × 4)
#define MAX_GEN               64    // 最大生成器数量 // Maximum generators (≥ REDUCTION_BUDGET+N_STATE)
#define N_INPUT               1     // 输入维度 // Input dimension
#define N_MEAS                12    // 测量维度 // Measurement dimension (2 per 4x4 block)
#define NUM_STEPS             200   // 仿真步数 // Number of simulation steps
#define N_BATCH               NUM_STEPS  // Steps per single FPGA kernel call (batch mode)
#define DT                    0.1   // 采样时间 // Sampling time
#define PROC_NOISE_RADIUS     0.05  // 过程噪声半径 // Process noise radius
#define MEAS_NOISE_RADIUS     0.1   // 测量噪声半径 0.1 // Measurement noise radius 0.1
#define INIT_RADIUS           0.2   // 初始状态半径 // Initial state radius
#define REDUCTION_BUDGET      32    // 降阶预算 (≥N_STATE, ≤MAX_GEN-N_MEAS) // Reduction budget
#define TOPK                  (REDUCTION_BUDGET - N_STATE)  // Generators kept by top-K (= 8)
#define RANDOM_SEED          42     // 随机种子[1](@ref)
// #include <ap_fixed.h>
// using data_t = ap_fixed<32, 8>;  // 例子：总32位，整数8位（含符号）
using data_t = float;  // double/float 都行，HLS工具会根据实际情况优化


struct Zonotope {
    int n;          // state dimension 状态维度
    int m;          // number of generators 生成器数量
    data_t p[N_STATE];  // center 中心向量
    data_t H[N_STATE][MAX_GEN]; // generator matrix 生成器矩阵
};

enum LambdaMethod {
    LAMBDA_NONE = 0,
    LAMBDA_SEGMENT,
    LAMBDA_VOLUME,
    LAMBDA_P_RADIUS
};

void compute_lambda_segment(
    data_t lambda[N_STATE],
    const data_t H[N_STATE][MAX_GEN], int m,
    const data_t c[N_STATE],
    data_t phi
);

void compute_lambda_volume(
    data_t lambda[N_STATE],   
    const data_t H[N_STATE][MAX_GEN], int m,  
    const data_t c[N_STATE],  
    data_t phi   
);

void compute_lambda_p_radius(
    data_t lambda[N_STATE],   
    const data_t H[N_STATE][MAX_GEN], int m,  
    const data_t c[N_STATE],  
    data_t phi   
);

// Reduce H in-place to REDUCTION_BUDGET generators (uses TOPK+N_STATE layout).
// Always reduces to REDUCTION_BUDGET columns; *m is set to REDUCTION_BUDGET.
void zonotope_reduce(data_t H[N_STATE][MAX_GEN], int* m);

#endif
