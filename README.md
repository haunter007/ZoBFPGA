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

# Cross-platform numerical consistency check (fast: Python + C++ only,
# reuses whatever HLS csim output is on disk)
make crosscheck

# Same, but also re-runs HLS csim first (slow, needs Vitis HLS) -
# use after touching src/hls/*.cpp
make crosscheck-full
```

**Run `make crosscheck` every time you change core estimator logic**
(`src/python/zonotope.py`, `src/cpp/zonotope_operations.cpp`, or the HLS
kernels) and commit the refreshed `results/thesis/cross_platform_consistency.csv`
along with the code change. It replays the same fixed input bundle
(`data/input/shared_linear_24d_200`) through Python, C++, and HLS and
regenerates the consistency table, so the committed numbers never go stale.

## Phase 1 software experiments

Run `make phase1` (NumPy, SciPy, Matplotlib and g++ required), or use
`python3 src/compare/phase1_sweep.py --seeds 20 --steps 100 --output results/phase1`.
The sweep runs Fixed-gain, Segment and Volume on the original block oscillator
and a second, nearest-neighbour coupled linear oscillator. Each method sees the
same noise realization for a given seed within each implementation.

`results/phase1/per_step.csv` records center L2 error, mean and maximum full
interval width, generator count, a log ellipsoid shape proxy, and strict
zonotope membership. Membership solves `min ||xi||_inf` subject to
`H xi = x_true - p`; values at most `1 + 1e-6` count as contained and boundary
cases are flagged. The shape proxy is `0.5 log det(H H^T)`, not exact zonotope
volume. `per_seed.csv`, `summary.csv` (mean and sample standard deviation across
seeds) and `comparison_boxplots.png` provide the method comparison. Time is
estimator time per step on the host; the C++ timing excludes CSV export.

Python and C++ currently use different initial truth states and noise RNGs.
Compare methods within each implementation; use `make crosscheck` for paired
input cross-platform numerical comparisons. These software timings are not
KR260 measurements. The C++ runner accepts `ZONO_RANDOM_SEED`,
`ZONO_BENCHMARK=oscillator|dense`, `ZONO_OUTPUT_BASE` and
`ZONO_EXPORT_ZONOTOPES=1` as environment overrides.

### Shared seeded replay inputs

Run `make seeded-inputs` to generate one shared input bundle per seed for both
the block oscillator and the nearest-neighbour coupled oscillator. The default
is 20 seeds (0–19), 100 steps, with bundles under `data/input/seeded_replay/`.
`data/input/seeded_replay/manifest.csv` records each bundle path, seed, shape,
validated process/measurement residuals and a SHA-256 digest of its CSV inputs.
For a different range use, for example,
`python3 tools/generate_seeded_replay_bundles.py --seed-start 20 --n-seeds 10`.
The generator reads structural dimensions and noise bounds from
`config/zonotope_params.json`; its oscillator frequency, damping and coupling
match the current software benchmark definitions.

Each bundle contains the same float32 input values in CSV and NPY form. Python
and C++ can replay both benchmarks without generating their own random
trajectories. The current accelerated HLS step kernel assumes independent 4x4
blocks; its replay runner accepts the `oscillator` bundles and rejects the
cross-block coupled `dense` bundles. The dense case is a software benchmark
until a general-matrix FPGA prediction kernel is implemented and measured.
Pass one compatible bundle directory to
`replay_fixed_input_python.py --bundle-dir`, to `src/cpp/replay_fixed_input` as
its first argument, or to `make -C src/hls csim-replay REPLAY_INPUT_DIR=...`.
Save replay outputs separately for each seed because the default replay output
directories are reused. The existing `results/phase1` sweep was generated by
the independent Python/C++ simulators and has not been regenerated from these
shared bundles.

## HLS Notes

- The default HLS flow targets the batch kernel in `src/hls/Makefile`.
- Current placeholder part is `xck26-sfvc784-2LV-c`; replace it if your KR260 platform config differs.
- After HLS simulation, `src/hls/plot_fpga_results.py` writes plots under `data/output/hls/<mode>/...`.
- Default batch C-sim keeps the lightweight accelerator-style output: only `zonotope_000.csv` and the final `zonotope_<last>.csv` are dumped, so timing remains aligned with the batch-kernel path.
- To export every intermediate batch zonotope for phase-plot inspection, run `HLS_BATCH_DUMP_ALL=1 make -C src/hls csim-batch`. This adds a host-side replay in the testbench, so it is intended for debugging/visualization rather than timing runs.

## Comparison Outputs

`python3 src/compare/plot_comparison.py` produces:

- `data/output/comparison/Fixed-gain/{trajectory,error}.png`
- `data/output/comparison/LAMBDA_SEGMENT/{trajectory,error}.png`
- `data/output/comparison/LAMBDA_VOLUME/{trajectory,error}.png`
- `data/output/comparison/timing/{timing_bar,timing_table}.png`
- `data/output/comparison/python_hls/*` for Python-vs-HLS analysis plots
