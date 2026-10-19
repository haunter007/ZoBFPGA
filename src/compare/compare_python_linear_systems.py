#!/usr/bin/env python3
"""Compare three zonotope methods on three linear systems using Python only.

Run: python3 src/compare/compare_python_linear_systems.py --seeds 20 --steps 100
This does not run C++, HLS, or the KR260 board.
"""

import argparse
import csv
import json
from pathlib import Path
import sys
import time

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np

from phase1_sweep import load_estimator, metrics, summarize


ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(ROOT / "src/python"))
import indoor_drone_model as drone

METHODS = (("Fixed-gain", "Fixed-gain"),
           ("segment", "Segment"), ("volume", "Volume"))
BENCHMARKS = ("oscillator", "coupled_oscillator", "indoor_drone")


def generate_drone_inputs(seed, steps):
    """Generate one bounded truth/measurement bundle for all three methods."""
    rng = np.random.default_rng(seed)
    A, B, C = drone.matrices()
    truth = drone.INITIAL_STATE.copy()
    truths, measurements, inputs = [], [], []
    for step in range(steps):
        u = drone.commanded_input(step)
        w = rng.uniform(-1, 1, 12) * drone.PROCESS_RADIUS
        v = rng.uniform(-1, 1, 6) * drone.MEASUREMENT_RADIUS
        truth = A @ truth + B @ u + w
        measurement = C @ truth + v
        truths.append(truth.copy())
        measurements.append(measurement)
        inputs.append(u)
    return dict(A=A, B=B, C=C, initial_state=drone.INITIAL_STATE.copy(),
                truth=np.asarray(truths), measurement=np.asarray(measurements),
                control=np.asarray(inputs))


def simulate_drone(zono, method, bundle):
    """Replay one saved input bundle with the existing Python estimator."""
    A, B, C = bundle["A"], bundle["B"], bundle["C"]
    W = zono.Zonotope(np.zeros(12), np.diag(drone.PROCESS_RADIUS))
    X = zono.Zonotope(bundle["initial_state"].copy(), np.diag(drone.INITIAL_RADIUS))
    records = []
    for truth, measurement, u in zip(bundle["truth"], bundle["measurement"],
                                     bundle["control"]):

        start = time.perf_counter()
        estimate = X.predict(A, B, u, W).reduce(max_gens=zono.REDUCTION_BUDGET)
        for i in range(6):
            estimate = estimate.intersect_with_strip(
                C[i], measurement[i], drone.MEASUREMENT_RADIUS[i], method)
        X = estimate.reduce(max_gens=zono.REDUCTION_BUDGET)
        elapsed_us = (time.perf_counter() - start) * 1e6
        records.append((truth.copy(), X.copy(), elapsed_us))
    return records


def make_rows(zono, benchmark, method, seed, steps, drone_bundle=None):
    if benchmark == "indoor_drone":
        samples = simulate_drone(zono, method, drone_bundle)
    else:
        truth, _, _, estimates, elapsed = zono.simulate_estimator(
            method, seed=seed, dense=(benchmark == "coupled_oscillator"),
            verbose=False)
        samples = [(truth[i], estimates[i], elapsed[i - 1])
                   for i in range(1, steps + 1)]
    rows = []
    for step, (truth, estimate, elapsed_us) in enumerate(samples, start=1):
        row = metrics(estimate.p, estimate.H, truth)
        row["estimator_us"] = elapsed_us
        if benchmark == "indoor_drone":
            # Position-only values have physical units and are more useful for
            # localization than a norm mixing metres, m/s, and radians.
            row["position_error_m"] = float(np.linalg.norm(estimate.p[:3] - truth[:3]))
            row["position_width_mean_m"] = float(np.mean(
                2 * np.sum(np.abs(estimate.H[:3]), axis=1)))
            row["attitude_error_rad"] = float(np.linalg.norm(estimate.p[6:9] - truth[6:9]))
        else:
            row["position_error_m"] = np.nan
            row["position_width_mean_m"] = np.nan
            row["attitude_error_rad"] = np.nan
        row.update(benchmark=benchmark, seed=seed, method=method, step=step)
        rows.append(row)
    return rows


def write_csv(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]), lineterminator="\n")
        writer.writeheader()
        writer.writerows(rows)


def draw_comparison(per_seed, output):
    fig, axes = plt.subplots(3, 3, figsize=(13, 10))
    for row_index, benchmark in enumerate(BENCHMARKS):
        fields = (("position_error_m", "Position error (m)"),
                  ("position_width_mean_m", "Mean position interval width (m)")) if benchmark == "indoor_drone" else (
                  ("center_l2", "Center error (L2)"),
                  ("width_mean", "Mean interval width"))
        fields += (("estimator_us_per_step", "Python estimator time (us/step)"),)
        for col_index, (field, label) in enumerate(fields):
            ax = axes[row_index, col_index]
            values = [[r[field] for r in per_seed
                       if r["benchmark"] == benchmark and r["method"] == method]
                      for method, _ in METHODS]
            ax.boxplot(values, labels=[label for _, label in METHODS], showmeans=True)
            ax.set_title(f"{benchmark}: {label}")
            ax.grid(axis="y", alpha=0.3)
    fig.tight_layout()
    fig.savefig(output / "python_linear_system_comparison.png", dpi=160)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seeds", type=int, default=20)
    parser.add_argument("--seed-start", type=int, default=0)
    parser.add_argument("--steps", type=int, default=100)
    parser.add_argument("--output", type=Path,
                        default=ROOT / "results/python_linear_systems")
    args = parser.parse_args()
    if args.seeds <= 0 or args.steps <= 0:
        parser.error("--seeds and --steps must be positive")
    output = args.output.resolve()
    zono = load_estimator()
    zono.NUM_STEPS = args.steps

    A, B, C = drone.matrices()
    observability = np.vstack([C @ np.linalg.matrix_power(A, k) for k in range(12)])
    if np.linalg.matrix_rank(observability) != 12:
        raise RuntimeError("Indoor drone benchmark is not observable")
    model_definition = {
        "description": "Simulated stabilized-hover small-angle indoor drone localization",
        "state_names": drone.STATE_NAMES, "measurement_names": drone.MEASUREMENT_NAMES,
        "input_names": drone.INPUT_NAMES, "dt_s": drone.DT,
        "process_noise_radius": drone.PROCESS_RADIUS.tolist(),
        "measurement_noise_radius": drone.MEASUREMENT_RADIUS.tolist(),
        "initial_state": drone.INITIAL_STATE.tolist(),
        "initial_radius": drone.INITIAL_RADIUS.tolist(),
        "velocity_damping_per_s": drone.VELOCITY_DAMPING,
        "attitude_stiffness_per_s2": drone.ATTITUDE_STIFFNESS,
        "rate_damping_per_s": drone.RATE_DAMPING,
        "observability_rank": 12,
        "experiment_seeds": list(range(args.seed_start, args.seed_start + args.seeds)),
        "experiment_steps": args.steps,
        "estimator_reduction_budget": zono.REDUCTION_BUDGET,
        "noise_sampling": "independent uniform samples within each coordinate's stated bound",
        "note": "All parameters and sensors are simulation assumptions, not measured hardware values.",
    }
    output.mkdir(parents=True, exist_ok=True)
    (output / "indoor_drone_model.json").write_text(
        json.dumps(model_definition, indent=2) + "\n", encoding="utf-8")

    per_step, per_seed = [], []
    for benchmark in BENCHMARKS:
        for seed in range(args.seed_start, args.seed_start + args.seeds):
            print(f"{benchmark}, seed {seed}", flush=True)
            drone_bundle = None
            if benchmark == "indoor_drone":
                drone_bundle = generate_drone_inputs(seed, args.steps)
                bundle_dir = output / "input_bundles" / "indoor_drone"
                bundle_dir.mkdir(parents=True, exist_ok=True)
                np.savez_compressed(bundle_dir / f"seed_{seed:03d}.npz", **drone_bundle)
            for method, _ in METHODS:
                rows = make_rows(zono, benchmark, method, seed, args.steps, drone_bundle)
                per_step.extend(rows)
                summary = summarize(rows, float(np.mean([r["estimator_us"] for r in rows])))
                summary.update(benchmark=benchmark, seed=seed, method=method)
                for field in ("position_error_m", "position_width_mean_m", "attitude_error_rad"):
                    summary[field] = (float(np.mean([r[field] for r in rows]))
                                      if benchmark == "indoor_drone" else np.nan)
                per_seed.append(summary)

    write_csv(output / "per_step.csv", per_step)
    write_csv(output / "per_seed.csv", per_seed)
    aggregate = []
    common_fields = ("center_l2", "width_mean", "width_max", "log_volume_proxy",
              "containment_rate", "ambiguous_count", "generator_count",
              "estimator_us_per_step")
    for benchmark in BENCHMARKS:
        for method, _ in METHODS:
            selection = [r for r in per_seed if r["benchmark"] == benchmark
                         and r["method"] == method]
            fields = common_fields + (("position_error_m", "position_width_mean_m",
                                       "attitude_error_rad") if benchmark == "indoor_drone" else ())
            for field in fields:
                values = np.array([r[field] for r in selection], dtype=float)
                aggregate.append(dict(benchmark=benchmark, method=method, metric=field,
                                      mean=float(np.mean(values)),
                                      std=float(np.std(values, ddof=1)) if len(values) > 1 else 0.0,
                                      n_seeds=len(values)))
    write_csv(output / "summary.csv", aggregate)
    draw_comparison(per_seed, output)
    print(f"Wrote {output / 'summary.csv'}")


if __name__ == "__main__":
    main()
