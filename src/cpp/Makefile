CXX      ?= g++
# EXTRA_DEFS lets a parameter sweep override the single-source config, e.g.
#   make -C src/cpp EXTRA_DEFS="-DN_STATE=48 -DN_MEAS=24 -DREDUCTION_BUDGET=64 -DMAX_GEN=136"
EXTRA_DEFS ?=
CXXFLAGS ?= -O2 -std=c++14 -Wall -I../../include $(EXTRA_DEFS)

SRCS = main.cpp fpga_kernels.cpp zonotope_operations.cpp dump.cpp
BIN  = zonotope_cpp
REPLAY_BIN = replay_fixed_input

# Single source of truth for N_STATE/N_MEAS/MAX_GEN/REDUCTION_BUDGET/... :
# config/zonotope_params.json -> include/zonotope_params.hpp (regenerated
# automatically whenever the JSON changes).
PARAMS_HPP  = ../../include/zonotope_params.hpp
PARAMS_JSON = ../../config/zonotope_params.json
PARAMS_GEN  = ../../tools/gen_zonotope_params.py

.PHONY: all run replay-fixed clean

all: $(BIN) $(REPLAY_BIN)

$(PARAMS_HPP): $(PARAMS_JSON) $(PARAMS_GEN)
	python3 $(PARAMS_GEN)

$(BIN): $(SRCS) $(PARAMS_HPP)
	$(CXX) $(CXXFLAGS) -o $@ $(SRCS)

$(REPLAY_BIN): replay_fixed_input.cpp fpga_kernels.cpp zonotope_operations.cpp dump.cpp $(PARAMS_HPP)
	$(CXX) $(CXXFLAGS) -o $@ replay_fixed_input.cpp fpga_kernels.cpp zonotope_operations.cpp dump.cpp

# 从 repo 根目录运行（保证相对路径 data/output/cpp 正确）
# Run from repo root so that data/output/cpp relative path is correct
run: $(BIN)
	cd ../.. && src/cpp/$(BIN)

replay-fixed: $(REPLAY_BIN)
	cd ../.. && src/cpp/$(REPLAY_BIN)

clean:
	rm -f $(BIN) $(REPLAY_BIN)
