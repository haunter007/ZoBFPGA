CXX      ?= g++
CXXFLAGS ?= -O2 -std=c++14 -Wall -I../../include

SRCS = main.cpp fpga_kernels.cpp zonotope_operations.cpp dump.cpp
BIN  = zonotope_cpp
REPLAY_BIN = replay_fixed_input

.PHONY: all run replay-fixed clean

all: $(BIN) $(REPLAY_BIN)

$(BIN): $(SRCS)
	$(CXX) $(CXXFLAGS) -o $@ $^

$(REPLAY_BIN): replay_fixed_input.cpp fpga_kernels.cpp zonotope_operations.cpp dump.cpp
	$(CXX) $(CXXFLAGS) -o $@ $^

# 从 repo 根目录运行（保证相对路径 data/output/cpp 正确）
# Run from repo root so that data/output/cpp relative path is correct
run: $(BIN)
	cd ../.. && src/cpp/$(BIN)

replay-fixed: $(REPLAY_BIN)
	cd ../.. && src/cpp/$(REPLAY_BIN)

clean:
	rm -f $(BIN) $(REPLAY_BIN)
