#!/usr/bin/env python3
"""Paired-seed software comparison of three estimators on two linear systems.

Run from anywhere: python3 src/compare/phase1_sweep.py --seeds 20 --steps 100
Requires NumPy, SciPy and Matplotlib. Results go to results/phase1 by default.
"""
import argparse
import csv
import importlib.util
import os
from pathlib import Path
import subprocess
import sys

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from scipy.optimize import linprog


ROOT = Path(__file__).resolve().parents[2]
METHODS = [("Fixed-gain", "Fixed-gain"), ("segment", "LAMBDA_SEGMENT"),
           ("volume", "LAMBDA_VOLUME")]
BENCHMARKS = ("oscillator", "dense")


def load_estimator():
    spec = importlib.util.spec_from_file_location("zonotope_phase1", ROOT / "src/python/zonotope.py")
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def membership_margin(p, H, x):
    """Minimum ||xi||_inf subject to H xi = x-p; infinity if infeasible.

    Scale by a characteristic generator radius for a stable absolute LP
    feasibility tolerance. A result at the boundary is marked ambiguous.
    """
    n, m = H.shape
    delta = x - p
    scale = max(1.0, np.max(np.sum(np.abs(H), axis=1)), np.max(np.abs(delta)))
    Hs, ds = H / scale, delta / scale
    objective = np.zeros(m + 1)
    objective[-1] = 1.0
    eye = np.eye(m)
    Aub = np.vstack((np.column_stack((eye, -np.ones(m))),
                     np.column_stack((-eye, -np.ones(m)))))
    result = linprog(objective, A_ub=Aub, b_ub=np.zeros(2 * m),
                     A_eq=np.column_stack((Hs, np.zeros(n))), b_eq=ds,
                     bounds=[(None, None)] * m + [(0, None)], method="highs",
                     options={"primal_feasibility_tolerance": 1e-9,
                              "dual_feasibility_tolerance": 1e-9})
    if not result.success:
        return np.inf
    residual = np.max(np.abs(Hs @ result.x[:m] - ds))
    if residual > 1e-8:
        return np.inf
    return float(max(result.x[-1], np.max(np.abs(result.x[:m]))))


def metrics(p, H, x):
    radius = np.sum(np.abs(H), axis=1)
    margin = membership_margin(p, H, x)
    # Ellipsoid shape proxy, not exact zonotope volume. Full rank is expected
    # because every prediction adds diagonal process-noise generators.
    sign, logdet = np.linalg.slogdet(H @ H.T)
    return dict(center_l2=float(np.linalg.norm(p - x)),
                width_mean=float(np.mean(2 * radius)),
                width_max=float(np.max(2 * radius)),
                log_volume_proxy=float(0.5 * logdet) if sign > 0 else np.nan,
                membership_margin=margin,
                contained=int(margin <= 1 + 1e-6),
                boundary_ambiguous=int(np.isfinite(margin) and abs(margin - 1) <= 1e-6),
                generator_count=H.shape[1])


def read_zonotope(path):
    with path.open(newline="") as f:
        rows = list(csv.reader(f))
    p = np.asarray(rows[0][1:], dtype=float)
    H = np.asarray([row[1:] for row in rows[1:]], dtype=float).T
    return p, H


def summarize(rows, time_us):
    return dict(center_l2=np.mean([r["center_l2"] for r in rows]),
                width_mean=np.mean([r["width_mean"] for r in rows]),
                width_max=np.max([r["width_max"] for r in rows]),
                log_volume_proxy=np.mean([r["log_volume_proxy"] for r in rows]),
                containment_rate=np.mean([r["contained"] for r in rows]),
                ambiguous_count=sum(r["boundary_ambiguous"] for r in rows),
                generator_count=np.mean([r["generator_count"] for r in rows]),
                estimator_us_per_step=time_us)


def write_csv(path, rows):
    path.parent.mkdir(parents=True, exist_ok=True)
    with path.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def compile_cpp(out, steps):
    sources = [ROOT / "src/cpp" / name for name in
               ("main.cpp", "fpga_kernels.cpp", "zonotope_operations.cpp", "dump.cpp")]
    binary = out / "zonotope_cpp_phase1"
    subprocess.run(["g++", "-O2", "-std=c++14", "-I" + str(ROOT / "include"),
                    "-DNUM_STEPS=" + str(steps), *map(str, sources), "-o", str(binary)],
                   check=True, cwd=ROOT)
    return binary


def plot_summary(rows, output):
    fields = [("center_l2", "Mean center error (L2)"),
              ("width_mean", "Mean interval width"),
              ("containment_rate", "Containment rate"),
              ("estimator_us_per_step", "Estimator time (us/step)")]
    fig, axes = plt.subplots(2, 2, figsize=(12, 8))
    for ax, (field, title) in zip(axes.flat, fields):
        labels, samples = [], []
        for impl in ("python", "cpp"):
            for bench in BENCHMARKS:
                for _, method in METHODS:
                    subset = [float(r[field]) for r in rows if r["implementation"] == impl
                              and r["benchmark"] == bench and r["method"] == method]
                    if subset:
                        labels.append(f"{impl}\n{bench}\n{method.replace('LAMBDA_', '')}")
                        samples.append(subset)
        ax.boxplot(samples, labels=labels, showmeans=True)
        ax.set_title(title)
        ax.tick_params(axis="x", labelrotation=60, labelsize=7)
        ax.grid(axis="y", alpha=0.25)
    fig.tight_layout()
    fig.savefig(output / "comparison_boxplots.png", dpi=160)
    plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--seeds", type=int, default=20)
    parser.add_argument("--seed-start", type=int, default=0)
    parser.add_argument("--steps", type=int, default=100)
    parser.add_argument("--output", type=Path, default=ROOT / "results/phase1")
    parser.add_argument("--python-only", action="store_true")
    args = parser.parse_args()
    if args.seeds < 1 or args.steps < 1:
        parser.error("--seeds and --steps must be positive")
    output = args.output.resolve()
    output.mkdir(parents=True, exist_ok=True)
    zono = load_estimator()
    zono.NUM_STEPS = args.steps
    binary = None if args.python_only else compile_cpp(output, args.steps)
    per_step, per_seed = [], []
    for bench in BENCHMARKS:
        for seed in range(args.seed_start, args.seed_start + args.seeds):
            print(f"{bench}, seed {seed}", flush=True)
            if binary:
                cpp_base = output / "raw_cpp" / bench / str(seed)
                env = os.environ.copy()
                env.update(ZONO_RANDOM_SEED=str(seed), ZONO_BENCHMARK=bench,
                           ZONO_EXPORT_ZONOTOPES="1", ZONO_OUTPUT_BASE=str(cpp_base))
                subprocess.run([str(binary)], check=True, cwd=ROOT, env=env,
                               stdout=subprocess.DEVNULL)
            for method, label in METHODS:
                x, centers, _, zonotopes, times = zono.simulate_estimator(
                    method, seed=seed, dense=(bench == "dense"), verbose=False)
                rows = []
                for step in range(1, args.steps + 1):
                    value = metrics(zonotopes[step].p, zonotopes[step].H, x[step])
                    rows.append(value)
                    per_step.append(dict(implementation="python", benchmark=bench,
                                         seed=seed, method=label, step=step, **value))
                per_seed.append(dict(implementation="python", benchmark=bench,
                                     seed=seed, method=label,
                                     **summarize(rows, float(np.mean(times)))))
                if binary:
                    folder = cpp_base / label
                    truths = np.loadtxt(folder / "x_true.csv", delimiter=",", ndmin=2)
                    runtime = np.loadtxt(folder / "kernel_time_summary_us.csv", delimiter=",", ndmin=1)[1]
                    rows = []
                    for step in range(1, args.steps + 1):
                        p, H = read_zonotope(folder / f"zonotope_{step:03d}.csv")
                        value = metrics(p, H, truths[step - 1])
                        rows.append(value)
                        per_step.append(dict(implementation="cpp", benchmark=bench,
                                             seed=seed, method=label, step=step, **value))
                    per_seed.append(dict(implementation="cpp", benchmark=bench,
                                         seed=seed, method=label,
                                         **summarize(rows, float(runtime))))
    write_csv(output / "per_step.csv", per_step)
    write_csv(output / "per_seed.csv", per_seed)
    aggregate = []
    for impl in ("python", "cpp"):
        for bench in BENCHMARKS:
            for _, method in METHODS:
                subset = [r for r in per_seed if r["implementation"] == impl
                          and r["benchmark"] == bench and r["method"] == method]
                if not subset:
                    continue
                for key in ("center_l2", "width_mean", "width_max", "log_volume_proxy",
                            "containment_rate", "estimator_us_per_step"):
                    values = np.asarray([r[key] for r in subset], dtype=float)
                    aggregate.append(dict(implementation=impl, benchmark=bench, method=method,
                                          metric=key, mean=float(np.mean(values)),
                                          std=float(np.std(values, ddof=1)) if len(values) > 1 else 0.0,
                                          n_seeds=len(values)))
    write_csv(output / "summary.csv", aggregate)
    plot_summary(per_seed, output)
    print(f"Wrote {output / 'summary.csv'} and comparison_boxplots.png")


if __name__ == "__main__":
    main()
