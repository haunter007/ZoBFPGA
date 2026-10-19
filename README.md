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

### Three linear systems in Python

Run `make python-linear-benchmarks` (or
`python3 src/compare/compare_python_linear_systems.py --seeds 20 --steps 100`).
This Python-only comparison retains the original 24-state independent-block
oscillator and the adjacent-block-coupled oscillator, then adds a 12-state
indoor-drone localization simulation. All three use the existing Python
zonotope estimator and the same Fixed-gain, Segment and Volume methods. Each
method receives the same simulated truth and measurements for a given seed.
The two oscillator simulations retain their existing behavior.

The indoor-drone model is defined in `src/python/indoor_drone_model.py`.
Its state is `[position xyz (m), velocity xyz (m/s), roll/pitch/yaw (rad),
roll/pitch/yaw rates (rad/s)]`. It is an exactly discretized (`dt=0.1 s`)
small-angle model near **stabilized hover**: horizontal accelerations depend
on pitch and roll, while velocity damping and attitude restoring terms
represent a stabilizing inner loop. The known input commands vertical and
angular accelerations. Six simulated measurements provide position xyz and
roll/pitch/yaw, leaving velocities and angular rates unmeasured. Independent
bounded process and measurement disturbances are sampled uniformly within
the per-coordinate radii recorded in `results/python_linear_systems/indoor_drone_model.json`.
The initial truth is the center of a bounded initial box. These dynamics,
sensor channels and noise radii are **simulation assumptions**, not parameters
identified from a real UAV or measured on the KR260. No avoidance controller
or real flight is claimed. The example evaluates state estimation that could
provide uncertainty bounds to a future avoidance system.

Results are in `results/python_linear_systems/`:

- `summary.csv`: mean and sample standard deviation across 20 seeds;
- `per_seed.csv` and `per_step.csv`: audit-level values;
- `python_linear_system_comparison.png`: within-system method comparisons;
- `indoor_drone_model.json`: model state order, sensor channels and bounds;
- `input_bundles/indoor_drone/seed_XXX.npz`: one saved truth, measurement,
  control and matrix bundle per seed, replayed by all three Python methods.

The drone adds position-center error (metres), mean position interval width
(metres), and attitude-center error (radians). Its full-state `center_l2`,
`width_mean` and log-volume proxy mix physical units, so compare those only
within the same model and coordinate convention. `containment_rate` is strict
full-state zonotope membership, solved by an LP for each tested state; 100%
on these simulated trajectories is not a universal guarantee. Timings are
Python host timings, not HLS or KR260 timings. The drone model has not been
ported to C++ or HLS.

### Existing Python and C++ sweep

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

## Dimension and generator-budget sweeps

Run `python3 tools/sweep_hls_resources.py --dry-run` to list supported HLS
configurations. The default sweep synthesizes 8, 16 and 24 state dimensions,
4, 8 and 12 measurement dimensions where valid, three generator budgets per
state size (`N_STATE+4`, `N_STATE+8`, `N_STATE+16`), and all three correction methods:

```bash
python3 tools/sweep_hls_resources.py
python3 src/compare/plot_hls_scaling.py --summary results/hls_scaling/summary.csv
python3 src/compare/sweep_generator_budgets.py
python3 src/compare/plot_generator_budget_tradeoff.py
```

Synthesis resumes by skipping configurations with an existing XML report.
`--max-runs 1` runs just one new configuration. Each run has a separate Vitis
project and log under `data/output/hls/scaling/`; the portable results table
is `results/hls_scaling/summary.csv`, and the plots go to
`results/hls_scaling/{state,measurement,budget}_scaling.png`. The current HLS
oscillator kernel supports `N_STATE=4,8,...,24` and an even `N_MEAS` from 2
through `N_STATE/2`. It measures the first two states of successive 4-state
oscillator blocks. The dense coupled benchmark remains software-only.
For each configuration, `MAX_GEN` is set to `REDUCTION_BUDGET + N_STATE`,
the minimum capacity that covers the prediction peak for these valid
measurement counts. Thus the HLS resource trade-off includes the memory and
logic needed for the chosen budget.

The HLS table gives estimated resources and clock period plus best- and
worst-case latency for a single batch call with a 200-step upper bound.
`worst_latency_ms_at_target` converts worst-case cycles using the requested
113 MHz clock; it is an HLS estimate, **not measured KR260 time**. Vitis may
report a clock estimate above the target or fail to fit a configuration;
inspect `status`, `hls_issue_type` and the log before interpreting comparisons.
Only Vivado implementation and the KR260 run can establish implemented timing
and execution latency.

The software budget sweep runs the same 20 seeds and 100 steps for each
budget (`N_STATE+4`, `N_STATE+8`, `N_STATE+16`) and method on the 24-state
oscillator. `results/generator_budgets/{per_seed,summary}.csv` contain center
error, full interval width, strict LP membership, shape proxy and Python host
estimator time. Matched seeds share the same generated noise across budgets.
The software timing is separate from the HLS estimates and later board timing.
`results/generator_budgets/tradeoff.png` places the software quality and HLS
resource/latency estimates side by side for the same 24-state configurations.
The [scaling experiment note](results/scaling_experiments.md) summarizes the
tested matrix, representative values, data provenance and current limitations.

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
