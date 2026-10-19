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

CLK_MHZ   ?= 113

# 源码（HLS顶层kernel文件 + tb）
KERNEL_SRC = fpga_kernels.cpp
TB_SRC     = testbench.cpp

INC       = -I../../include
HLS_CFLAGS ?=
# SIZE_CFLAGS lets a parameter sweep override the single-source config, e.g.
#   make csim-segment SIZE_CFLAGS="-DN_STATE=16 -DN_MEAS=8 -DREDUCTION_BUDGET=24 -DMAX_GEN=40"
SIZE_CFLAGS ?=
METHOD ?= segment
METHOD_ID_segment = 1
METHOD_ID_fixed_gain = 0
METHOD_ID_volume  = 2
METHOD_NAME_segment = LAMBDA_SEGMENT
METHOD_NAME_fixed_gain = Fixed-gain
METHOD_NAME_volume  = LAMBDA_VOLUME
METHOD_ID ?= $(METHOD_ID_$(METHOD))
METHOD_NAME ?= $(METHOD_NAME_$(METHOD))
METHOD_PROJ_SUFFIX ?= $(METHOD)
METHOD_CFLAGS = $(HLS_CFLAGS) $(SIZE_CFLAGS) -DHLS_LAMBDA_METHOD_ID=$(METHOD_ID)
REPLAY_INPUT_DIR ?= $(abspath ../../data/input/shared_linear_24d_200)

# Single source of truth for N_STATE/N_MEAS/MAX_GEN/REDUCTION_BUDGET/... :
# config/zonotope_params.json -> include/zonotope_params.hpp (regenerated
# automatically whenever the JSON changes). run_hls.tcl already adds
# -I../../include, so the generated header is picked up with no tcl changes.
PARAMS_HPP  = ../../include/zonotope_params.hpp
PARAMS_JSON = ../../config/zonotope_params.json
PARAMS_GEN  = ../../tools/gen_zonotope_params.py

# ====== Targets ======
.PHONY: help csim csim-replay synth cosim export csim-step synth-step cosim-step export-step csim-batch synth-batch clean distclean

$(PARAMS_HPP): $(PARAMS_JSON) $(PARAMS_GEN)
	python3 $(PARAMS_GEN)

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

csim: $(PARAMS_HPP)
	HLS_SIM_MODE=csim HLS_TB_MODE=batch HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl csim $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode csim_batch

csim-replay: $(PARAMS_HPP)
	HLS_SIM_MODE=csim HLS_TB_MODE=batch HLS_REPLAY_INPUT_DIR="$(REPLAY_INPUT_DIR)" HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl csim $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

synth: $(PARAMS_HPP)
	HLS_TB_MODE=batch HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl synth $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

cosim: $(PARAMS_HPP)
	HLS_SIM_MODE=cosim HLS_TB_MODE=batch HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl cosim $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode cosim_batch

export: $(PARAMS_HPP)
	HLS_TB_MODE=batch HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl export $(PROJ) $(TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

csim-step: $(PARAMS_HPP)
	HLS_SIM_MODE=csim HLS_TB_MODE=step HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl csim $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode csim

synth-step: $(PARAMS_HPP)
	HLS_TB_MODE=step HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl synth $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

cosim-step: $(PARAMS_HPP)
	HLS_SIM_MODE=cosim HLS_TB_MODE=step HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl cosim $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"
	python3 plot_fpga_results.py --mode cosim

export-step: $(PARAMS_HPP)
	HLS_TB_MODE=step HLS_CFLAGS="$(METHOD_CFLAGS)" $(VITIS_HLS) -f run_hls.tcl export $(STEP_PROJ) $(STEP_TOP) $(PART) $(CLK_MHZ) "$(KERNEL_SRC)" "$(TB_SRC)"

csim-batch:
	$(MAKE) csim

synth-batch:
	$(MAKE) synth

csim-segment:
	$(MAKE) csim METHOD=segment PROJ=../../data/output/hls/HLS_Report_batch_segment

csim-fixed-gain:
	$(MAKE) csim METHOD=fixed_gain PROJ=../../data/output/hls/HLS_Report_batch_Fixed-gain

csim-volume:
	$(MAKE) csim METHOD=volume PROJ=../../data/output/hls/HLS_Report_batch_volume

synth-segment:
	$(MAKE) synth METHOD=segment PROJ=../../data/output/hls/HLS_Report_batch_segment

synth-fixed-gain:
	$(MAKE) synth METHOD=fixed_gain PROJ=../../data/output/hls/HLS_Report_batch_Fixed-gain

synth-volume:
	$(MAKE) synth METHOD=volume PROJ=../../data/output/hls/HLS_Report_batch_volume

export-segment:
	$(MAKE) export METHOD=segment PROJ=../../data/output/hls/HLS_Report_batch_segment

export-fixed-gain:
	$(MAKE) export METHOD=fixed_gain PROJ=../../data/output/hls/HLS_Report_batch_Fixed-gain

export-volume:
	$(MAKE) export METHOD=volume PROJ=../../data/output/hls/HLS_Report_batch_volume

clean:
	rm -rf $(PROJ)

distclean: clean
	rm -rf *.log *.jou .Xil
