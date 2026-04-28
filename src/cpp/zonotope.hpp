#ifndef ZONOTOPE_H
#define ZONOTOPE_H

#define N_STATE               24
#define MAX_GEN               64
#define N_INPUT               1
#define N_MEAS                12
#ifndef NUM_STEPS
#define NUM_STEPS             100
#endif
#define DT                    0.1
#define PROC_NOISE_RADIUS     0.05
#define MEAS_NOISE_RADIUS     0.1
#define INIT_RADIUS           0.2
#define REDUCTION_BUDGET      32
#define RANDOM_SEED          42

using data_t = float;

struct Zonotope {
    int n;
    int m;
    data_t p[N_STATE];
    data_t H[N_STATE][MAX_GEN];
};

enum LambdaMethod {
    LAMBDA_NONE = 0,
    LAMBDA_SEGMENT,
    LAMBDA_VOLUME,
    LAMBDA_P_RADIUS
};

void compute_lambda_segment(data_t lambda[N_STATE], const data_t H[N_STATE][MAX_GEN], int m, const data_t c[N_STATE], data_t phi);
void compute_lambda_volume(data_t lambda[N_STATE], const data_t H[N_STATE][MAX_GEN], int m, const data_t c[N_STATE], data_t phi);
void compute_lambda_p_radius(data_t lambda[N_STATE], const data_t H[N_STATE][MAX_GEN], int m, const data_t c[N_STATE], data_t phi);
void zonotope_reduce(Zonotope* Z, int max_gens);

#endif
