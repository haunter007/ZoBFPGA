# minkowski_fpga

Python / C++ / Vitis HLS implementations of a zonotopic state estimator, plus scripts to compare trajectory, error, and total runtime across implementations.

## Repo Layout

- `src/python/zonotope.py`: Python reference implementation.
- `src/cpp/`: native C++ implementation and runner.
- `src/hls/`: Vitis HLS kernels, testbench, and FPGA-result plotting.
- `src/compare/plot_comparison.py`: unified Python/C++/HLS comparison plots.
- `data/output/`: generated outputs for Python, C++, HLS sim, board runs, and comparison figures.

## Quick Start

From the repo root:

```bash
make python
make cpp
make compare
```

Generated comparison figures are written to `data/output/comparison/`.

## Common Commands

```bash
# Python reference
make python

# Native C++ baseline
make cpp

# Rebuild C++ binary only
make cpp-build

# Generate cross-implementation comparison figures
make compare

# HLS batch-kernel C simulation (default HLS path)
make hls-csim

# HLS single-step C simulation
make hls-csim-step
```

## HLS Notes

- The default HLS flow targets the batch kernel in `src/hls/Makefile`.
- Current placeholder part is `xck26-sfvc784-2LV-c`; replace it if your KR260 platform config differs.
- After HLS simulation, `src/hls/plot_fpga_results.py` writes plots under `data/output/hls/<mode>/...`.
- Default batch C-sim keeps the lightweight accelerator-style output: only `zonotope_000.csv` and the final `zonotope_<last>.csv` are dumped, so timing remains aligned with the batch-kernel path.
- To export every intermediate batch zonotope for phase-plot inspection, run `HLS_BATCH_DUMP_ALL=1 make -C src/hls csim-batch`. This adds a host-side replay in the testbench, so it is intended for debugging/visualization rather than timing runs.

## Comparison Outputs

`python3 src/compare/plot_comparison.py` produces:

- `data/output/comparison/LAMBDA_NONE/{trajectory,error}.png`
- `data/output/comparison/LAMBDA_SEGMENT/{trajectory,error}.png`
- `data/output/comparison/LAMBDA_VOLUME/{trajectory,error}.png`
- `data/output/comparison/timing/{timing_bar,timing_table}.png`
