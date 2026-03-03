#pragma once
#include "zonotope.hpp"

// 每步追加一行到 center.csv / x_true.csv
void dump_center_append(const char* filename, const data_t x[N_STATE]);
void dump_true_append(const char* filename, const data_t x[N_STATE]);

// 每一步输出一个 zonotope_XXX.csv 到 folder
void dump_zonotope_csv(const Zonotope& Z, int step, const char* folder);

// 可选：清空输出文件（程序启动时调用一次）
void dump_reset_file(const char* filename);

// #pragma once
// #include <vector>
// #include <array>
// #include <string>
// #include "zonotope.hpp"

// void dump_centers_csv(
//     const std::vector<std::array<double, N_STATE>>& centers,
//     const std::string& filename
// );

// void dump_zonotope_csv(
//     const Zonotope& Z,
//     int step,
//     const std::string& folder
// );
