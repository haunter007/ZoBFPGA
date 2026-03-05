# ====== User config ======
VITIS_HLS ?= ./vitis_hls_wrap.sh

# 工程名与顶层函数（你需要按你的 top function 名字改）
PROJ      ?= ../../data/output/HLS_Report
TOP       ?= predict_kernel

# 目标器件/板卡（KR260 等导师给 part/board 后再改）
# 你可以先留空，用 part:
PART      ?= xck26-sfvc784-2LV-c   # 占位！！拿到KR260准确part后替换
# 或者用 BOARD：
# BOARD   ?= xilinx.com:kr260_som:part0:1.1

CLK_MHZ   ?= 100

# 源码（HLS顶层kernel文件 + tb）
KERNEL_SRC = fpga_kernels.cpp
TB_SRC     = testbench.cpp

INC       = -I../../include
HLS_CFLAGS ?=

# ====== Targets ======
.PHONY: help csim synth cosim export clean distclean

help:
	@echo "make csim      - C simulation"
	@echo "make synth     - C synthesis"
	@echo "make cosim     - C/RTL co-sim (needs RTL)"
	@echo "make export    - export IP"
	@echo "make clean     - remove HLS project"
	@echo ""
	@echo "Variables:"
	@echo "  TOP=... PART=... CLK_MHZ=... VITIS_HLS=..."

csim:
	HLS_SIM_MODE=csim HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl csim $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode csim

synth:
	HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl synth $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

cosim:
	HLS_SIM_MODE=cosim HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl cosim $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode cosim

export:
	HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl export $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

clean:
	rm -rf $(PROJ)

distclean: clean
	rm -rf *.log *.jou .Xil
