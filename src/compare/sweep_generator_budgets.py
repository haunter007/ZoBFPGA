#!/usr/bin/env python3
"""Compare generator budgets with paired seeded Python oscillator runs."""

import argparse
import csv
import importlib.util
import os
from pathlib import Path
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[2]
sys.path.insert(0, str(Path(__file__).resolve().parent))
from phase1_sweep import metrics, summarize  # noqa: E402

METHODS = [("Fixed-gain", "Fixed-gain"), ("segment", "LAMBDA_SEGMENT"),
           ("volume", "LAMBDA_VOLUME")]


def load_estimator(budget, steps):
    old = os.environ.get("ZONO_REDUCTION_BUDGET")
    os.environ["ZONO_REDUCTION_BUDGET"] = str(budget)
    try:
        spec = importlib.util.spec_from_file_location(f"zonotope_budget_{budget}", ROOT / "src/python/zonotope.py")
        module = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(module)
    finally:
        if old is None:
            del os.environ["ZONO_REDUCTION_BUDGET"]
        else:
            os.environ["ZONO_REDUCTION_BUDGET"] = old
    module.NUM_STEPS = steps
    return module


def write_csv(path, rows):
    with path.open("w", newline="") as handle:
        writer = csv.DictWriter(handle, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--budget-extras", default="4,8,16", help="Comma-separated extra generators above N_STATE")
    parser.add_argument("--seeds", type=int, default=20)
    parser.add_argument("--seed-start", type=int, default=0)
    parser.add_argument("--steps", type=int, default=100)
    parser.add_argument("--output", type=Path, default=ROOT / "results/generator_budgets")
    args = parser.parse_args()
    extras = [int(item) for item in args.budget_extras.split(",")]
    if not extras or any(extra <= 0 for extra in extras) or args.seeds < 1 or args.steps < 1:
        parser.error("budget extras, seeds and steps must be positive")
    args.output.mkdir(parents=True, exist_ok=True)
    rows = []
    for extra in extras:
        # The current quality benchmark is the default 24-state oscillator.
        n_state = int(os.environ.get("ZONO_N_STATE", "24"))
        budget = n_state + extra
        zono = load_estimator(budget, args.steps)
        for seed in range(args.seed_start, args.seed_start + args.seeds):
            for method, label in METHODS:
                truth, _, _, sets, times = zono.simulate_estimator(method, seed=seed, dense=False, verbose=False)
                samples = [metrics(sets[k].p, sets[k].H, truth[k]) for k in range(1, args.steps + 1)]
                rows.append(dict(implementation="python", benchmark="oscillator", n_state=n_state,
                                 n_meas=zono.N_MEAS, reduction_budget=budget, steps=args.steps, seed=seed,
                                 method=label, **summarize(samples, float(np.mean(times)))))
        print(f"Finished budget {budget}", flush=True)
    write_csv(args.output / "per_seed.csv", rows)
    aggregate = []
    for budget in sorted({row["reduction_budget"] for row in rows}):
        for _, method in METHODS:
            subset = [row for row in rows if row["reduction_budget"] == budget and row["method"] == method]
            for key in ("center_l2", "width_mean", "width_max", "log_volume_proxy",
                        "containment_rate", "estimator_us_per_step"):
                values = np.asarray([row[key] for row in subset], dtype=float)
                aggregate.append(dict(implementation="python", benchmark="oscillator", n_state=n_state,
                                      n_meas=zono.N_MEAS, reduction_budget=budget, steps=args.steps,
                                      seed_start=args.seed_start, method=method,
                                      metric=key, mean=float(np.mean(values)),
                                      std=float(np.std(values, ddof=1)) if len(values) > 1 else 0.0,
                                      n_seeds=len(values)))
    write_csv(args.output / "summary.csv", aggregate)
    print(args.output / "summary.csv")


if __name__ == "__main__":
    main()
