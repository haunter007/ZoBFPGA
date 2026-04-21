CXX      ?= g++
CXXFLAGS ?= -O2 -std=c++14 -Wall -I../../include

SRCS = main.cpp fpga_kernels.cpp zonotope_operations.cpp dump.cpp
BIN  = zonotope_cpp

.PHONY: all run clean

all: $(BIN)

$(BIN): $(SRCS)
	$(CXX) $(CXXFLAGS) -o $@ $^

# 从 repo 根目录运行（保证相对路径 data/output/cpp 正确）
# Run from repo root so that data/output/cpp relative path is correct
run: $(BIN)
	cd ../.. && src/cpp/$(BIN)

clean:
	rm -f $(BIN)
