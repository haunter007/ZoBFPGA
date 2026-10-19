.PHONY: python cpp-build cpp compare phase1 seeded-inputs hls-csim hls-csim-step hls-cosim hls-cosim-step \
        crosscheck crosscheck-cpp-python crosscheck-full params

# Single source of truth for N_STATE/N_MEAS/MAX_GEN/REDUCTION_BUDGET/... :
# edit config/zonotope_params.json, then `make params` (or just build
# anything -- src/cpp/Makefile and src/hls/Makefile regenerate it
# automatically). Python reads the JSON directly, no generation needed.
params:
	python3 tools/gen_zonotope_params.py

python:
	python3 src/python/zonotope.py

cpp-build:
	$(MAKE) -C src/cpp

cpp: cpp-build
	$(MAKE) -C src/cpp run

compare:
	python3 src/compare/plot_comparison.py

phase1:
	python3 src/compare/phase1_sweep.py --seeds 20 --steps 100

seeded-inputs:
	python3 tools/generate_seeded_replay_bundles.py --n-seeds 20 --n-steps 100

hls-csim:
	$(MAKE) -C src/hls csim

hls-csim-step:
	$(MAKE) -C src/hls csim-step

hls-cosim:
	$(MAKE) -C src/hls cosim

hls-cosim-step:
	$(MAKE) -C src/hls cosim-step

# ---------------------------------------------------------------------------
# Cross-platform numerical consistency check.
#
# Replays the SAME fixed input bundle (data/input/shared_linear_24d_200)
# through Python, C++, and (existing) HLS csim outputs, then regenerates
# results/thesis/cross_platform_consistency.csv. Run this every time core
# estimator logic changes (zonotope.py, zonotope_operations.cpp, or the HLS
# kernels) so the committed consistency table never goes stale.
#
# crosscheck-cpp-python: fast path (~seconds), refreshes Python+C++ sides
#   only and reuses whatever HLS csim output is currently on disk.
# crosscheck-full: also re-runs HLS csim (slow, needs Vitis HLS) before
#   comparing. Use this after touching src/hls/*.cpp.
# ---------------------------------------------------------------------------
crosscheck-cpp-python: cpp-build
	$(MAKE) -C src/cpp replay-fixed
	python3 src/compare/replay_fixed_input_python.py
	python3 src/compare/analyze_cross_platform_consistency.py

crosscheck: crosscheck-cpp-python

crosscheck-full:
	$(MAKE) -C src/hls csim-replay METHOD=fixed_gain PROJ=../../data/output/hls/HLS_Report_batch_Fixed-gain
	$(MAKE) -C src/hls csim-replay METHOD=segment PROJ=../../data/output/hls/HLS_Report_batch_segment
	$(MAKE) -C src/hls csim-replay METHOD=volume PROJ=../../data/output/hls/HLS_Report_batch_volume
	$(MAKE) crosscheck-cpp-python
