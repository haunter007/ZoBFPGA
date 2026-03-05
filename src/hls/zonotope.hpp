#ifndef ZONOTOPE_H
#define ZONOTOPE_H

#define N_STATE               4     // 状态维度 // State dimension
#define MAX_GEN               32    // 最大生成器数量 // Maximum number of generators
#define N_INPUT               1     // 输入维度 // Input dimension
#define N_MEAS                2     // 测量维度 // Measurement dimension
#define NUM_STEPS             15    // 仿真步数 // Number of simulation steps
#define DT                    0.1   // 采样时间 // Sampling time
#define PROC_NOISE_RADIUS     0.05  // 过程噪声半径 // Process noise radius
#define MEAS_NOISE_RADIUS     0.1   // 测量噪声半径 0.1 // Measurement noise radius 0.1
#define INIT_RADIUS           0.2   // 初始状态半径 // Initial state radius
#define REDUCTION_BUDGET      8     // 降阶预算 // Reduction budget
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

void zonotope_reduce(
    Zonotope* Z,  
    int max_gens   
);

#endif
