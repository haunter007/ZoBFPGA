#include "dump.hpp"
#include <cstdio>
#include <cstring>

static void make_path(char* out, int out_sz, const char* folder, const char* name) {
    // folder + "/" + name
    std::snprintf(out, out_sz, "%s/%s", folder, name);
}

void dump_reset_file(const char* filename) {
    FILE* f = std::fopen(filename, "w");
    if (f) std::fclose(f);
}

void dump_center_append(const char* filename, const data_t x[N_STATE]) {
    FILE* f = std::fopen(filename, "a");
    if (!f) return;
    for (int i = 0; i < N_STATE; ++i) {
        std::fprintf(f, "%.17g", x[i]);
        if (i + 1 < N_STATE) std::fprintf(f, ",");
    }
    std::fprintf(f, "\n");
    std::fclose(f);
}

void dump_true_append(const char* filename, const data_t x[N_STATE]) {
    dump_center_append(filename, x);
}

void dump_zonotope_csv(const Zonotope& Z, int step, const char* folder) {
    char fname[256];
    char name_only[64];
    std::snprintf(name_only, sizeof(name_only), "zonotope_%03d.csv", step);
    make_path(fname, (int)sizeof(fname), folder, name_only);

    FILE* f = std::fopen(fname, "w");
    if (!f) return;

    // p line: p,p0,p1,p2,p3
    std::fprintf(f, "p");
    for (int i = 0; i < N_STATE; ++i) {
        std::fprintf(f, ",%.17g", Z.p[i]);
    }
    std::fprintf(f, "\n");

    // H lines: 每一行表示一个 generator 列（与你的 Python loader 一致）
    // 形如: H,h0,h1,h2,h3   （这是一个 generator 列向量）
    for (int j = 0; j < Z.m; ++j) {
        std::fprintf(f, "H");
        for (int i = 0; i < N_STATE; ++i) {
            std::fprintf(f, ",%.17g", Z.H[i][j]);
        }
        std::fprintf(f, "\n");
    }

    std::fclose(f);
}

// #include "dump.hpp"
// #include <fstream>
// #include <iomanip>
// #include <filesystem>

// void dump_centers_csv(
//     const std::vector<std::array<double, N_STATE>>& centers,
//     const std::string& filename
// ) {
//     std::ofstream ofs(filename);
//     ofs << std::setprecision(10);

//     for (const auto& p : centers) {
//         for (int i = 0; i < N_STATE; ++i) {
//             ofs << p[i];
//             if (i + 1 < N_STATE) ofs << ",";
//         }
//         ofs << "\n";
//     }
// }

// void dump_zonotope_csv(
//     const Zonotope& Z,
//     int step,
//     const std::string& folder
// ) {
//     std::filesystem::create_directories(folder);

//     char fname[256];
//     std::snprintf(fname, sizeof(fname),
//                   "%s/zonotope_%03d.csv", folder.c_str(), step);

//     std::ofstream ofs(fname);
//     ofs << std::setprecision(10);

//     /* center */
//     ofs << "p";
//     for (int i = 0; i < N_STATE; ++i)
//         ofs << "," << Z.p[i];
//     ofs << "\n";

//     /* generators */
//     for (int j = 0; j < Z.m; ++j) {
//         ofs << "H";
//         for (int i = 0; i < N_STATE; ++i)
//             ofs << "," << Z.H[i][j];
//         ofs << "\n";
//     }
// }
