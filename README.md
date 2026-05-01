# minkowski_fpga

Python / C++ / Vitis HLS implementations of a zonotopic state estimator, plus scripts to compare trajectory, error, and total runtime across implementations.

## Repo Layout

- `src/python/zonotope.py`: Python reference implementation.
- `src/cpp/`: native C++ implementation and runner.
- `src/hls/`: Vitis HLS kernels, testbench, and FPGA-result plotting.
- `src/compare/plot_comparison.py`: unified Python/C++/HLS comparison plots.
- `data/output/`: generated outputs for Python, C++, HLS sim, board runs, comparison figures, and board input bundles.

Recommended `data/output/` layout:

```text
data/output/
  hls/
  python/
  cpp/
  comparison/
  board_inputs_rebuilt_max32/
```

- `data/output/hls/`: HLS reports, `csim`, `cosim`, and board-side FPGA outputs.
- `data/output/python/` and `data/output/cpp/`: baseline outputs by method; `fixed/` stores fixed-input replays.
- `data/output/comparison/`: cross-implementation figures; `python_hls/` stores Python-vs-HLS analysis plots and `fixed/` stores fixed-input comparison figures.
- `data/output/board_inputs_rebuilt_max32/`: rebuilt board input bundle used for replay/debug runs.

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
- `data/output/comparison/python_hls/*` for Python-vs-HLS analysis plots
