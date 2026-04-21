# ====== User config ======
VITIS_HLS ?= ./vitis_hls_wrap.sh

# 工程名与顶层函数
# Default to the batch kernel, which is the accelerator-oriented path.
STEP_PROJ  ?= ../../data/output/hls/HLS_Report
STEP_TOP   ?= zonotope_step_kernel_axi
BATCH_PROJ ?= ../../data/output/hls/HLS_Report_batch
BATCH_TOP  ?= zonotope_batch_kernel_axi
PROJ       ?= $(BATCH_PROJ)
TOP        ?= $(BATCH_TOP)

# 目标器件/板卡（KR260 等导师给 part/board 后再改）
# 你可以先留空，用 part:
PART      ?= xck26-sfvc784-2LV-c   # 占位！！拿到KR260准确part后替换
# 或者用 BOARD：
# BOARD   ?= xilinx.com:kr260_som:part0:1.1

CLK_MHZ   ?= 95   

# 源码（HLS顶层kernel文件 + tb）
KERNEL_SRC = fpga_kernels.cpp
TB_SRC     = testbench.cpp

INC       = -I../../include
HLS_CFLAGS ?=

# ====== Targets ======
.PHONY: help csim synth cosim export csim-step synth-step cosim-step export-step csim-batch synth-batch clean distclean

help:
	@echo "=== Batch kernel (default / recommended) ==="
	@echo "make csim      - C simulation"
	@echo "make synth     - C synthesis"
	@echo "make cosim     - C/RTL co-sim (needs RTL)"
	@echo "make export    - export IP"
	@echo ""
	@echo "=== Single-step kernel (debug / reference) ==="
	@echo "make csim-step   - C simulation with single-step AXI wrapper"
	@echo "make synth-step  - Synthesis of single-step AXI wrapper"
	@echo "make cosim-step  - C/RTL co-sim with single-step AXI wrapper"
	@echo "make export-step - export single-step IP"
	@echo ""
	@echo "Variables:"
	@echo "  TOP=... PART=... CLK_MHZ=... VITIS_HLS=..."

csim:
	HLS_SIM_MODE=csim HLS_TB_MODE=batch HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl csim $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode csim_batch

synth:
	HLS_TB_MODE=batch HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl synth $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

cosim:
	HLS_SIM_MODE=cosim HLS_TB_MODE=batch HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl cosim $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode cosim_batch

export:
	HLS_TB_MODE=batch HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl export $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

csim-step:
	HLS_SIM_MODE=csim HLS_TB_MODE=step HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl csim $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode csim

synth-step:
	HLS_TB_MODE=step HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl synth $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

cosim-step:
	HLS_SIM_MODE=cosim HLS_TB_MODE=step HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl cosim $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode cosim

export-step:
	HLS_TB_MODE=step HLS_CFLAGS="$(HLS_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl export $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

csim-batch:
	$(MAKE) csim

synth-batch:
	$(MAKE) synth

clean:
	rm -rf $(PROJ)

distclean: clean
	rm -rf *.log *.jou .Xil
