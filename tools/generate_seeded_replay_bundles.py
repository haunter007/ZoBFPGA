#!/usr/bin/env python3
"""Generate validated, shared CSV input bundles for seeded estimator replays."""

from __future__ import annotations

import argparse
import csv
import hashlib
import json
from pathlib import Path
import sys

import numpy as np

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT))
from src.hls.export_board_inputs import build_a, export_inputs  # noqa: E402

INPUT_NAMES = ("A", "C", "H_input", "H_w", "p_input", "p_w",
               "x_true", "y_all", "phi_all")


def check_bundle(folder: Path, args: argparse.Namespace) -> dict:
    arrays = {name: np.load(folder / f"{name}.npy") for name in INPUT_NAMES}
    for name, expected in arrays.items():
        from_csv = np.loadtxt(folder / f"{name}.csv", delimiter=",", ndmin=2)
        if not np.array_equal(from_csv.reshape(expected.shape).astype(np.float32), expected):
            raise ValueError(f"CSV does not reproduce float32 values: {folder}/{name}.csv")

    A, C = arrays["A"], arrays["C"]
    x, y, phi = arrays["x_true"], arrays["y_all"], arrays["phi_all"]
    if A.shape != (args.n_state, args.n_state) or C.shape != (args.n_meas, args.n_state):
        raise ValueError(f"Wrong matrix shape: {folder}")
    if x.shape != (args.n_steps + 1, args.n_state) or y.shape != (args.n_steps, args.n_meas):
        raise ValueError(f"Wrong trajectory shape: {folder}")
    expected_A = build_a(args.n_state, args.dt, args.omega, args.zeta, args.eps,
                         args.benchmark, args.cross_gain)
    if not np.array_equal(A, expected_A) or not np.array_equal(x[0], arrays["p_input"]):
        raise ValueError(f"Transition or initial state mismatch: {folder}")
    if not np.all(phi == np.float32(args.meas_noise)):
        raise ValueError(f"Measurement bounds mismatch: {folder}")

    w = x[1:].astype(np.float64) - x[:-1].astype(np.float64) @ A.astype(np.float64).T
    v = y.astype(np.float64) - x[1:].astype(np.float64) @ C.astype(np.float64).T
    max_w, max_v = float(np.max(np.abs(w))), float(np.max(np.abs(v)))
    if max_w > args.proc_noise + 2e-6 or max_v > args.meas_noise + 2e-6:
        raise ValueError(f"Generated noise exceeds declared bounds: {folder}")

    digest = hashlib.sha256()
    for name in INPUT_NAMES:
        digest.update((folder / f"{name}.csv").read_bytes())
    return dict(benchmark=args.benchmark, seed=args.seed,
                input_dir=str(folder.relative_to(ROOT)), n_steps=args.n_steps,
                n_state=args.n_state, n_meas=args.n_meas,
                max_process_residual=max_w, max_measurement_residual=max_v,
                input_sha256=digest.hexdigest())


def main() -> None:
    config = json.loads((ROOT / "config/zonotope_params.json").read_text())
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--n-seeds", type=int, default=20)
    parser.add_argument("--seed-start", type=int, default=0)
    parser.add_argument("--n-steps", type=int, default=100)
    parser.add_argument("--output", type=Path, default=ROOT / "data/input/seeded_replay")
    parser.add_argument("--benchmarks", nargs="+", choices=("oscillator", "dense"),
                        default=("oscillator", "dense"))
    opts = parser.parse_args()
    if opts.n_seeds < 1 or opts.n_steps < 1 or opts.seed_start < 0:
        parser.error("n-seeds and n-steps must be positive; seed-start cannot be negative")
    if config["max_gen"] < config["reduction_budget"] + max(config["n_state"], config["n_meas"]):
        parser.error("max_gen cannot accommodate prediction/measurement generators")

    output = opts.output.resolve()
    if not output.is_relative_to(ROOT):
        parser.error("output must be inside the repository for portable manifest paths")
    output.mkdir(parents=True, exist_ok=True)
    rows = []
    for benchmark in opts.benchmarks:
        for seed in range(opts.seed_start, opts.seed_start + opts.n_seeds):
            folder = output / benchmark / f"seed_{seed:03d}"
            args = argparse.Namespace(
                out_dir=str(folder), n_state=config["n_state"], n_meas=config["n_meas"],
                n_steps=opts.n_steps, max_gens=config["max_gen"],
                reduction_budget=config["reduction_budget"], dt=config["dt"],
                omega=0.5, zeta=0.05, eps=0.1,
                proc_noise=config["proc_noise_radius"],
                meas_noise=config["meas_noise_radius"],
                init_radius=config["init_radius"], seed=seed,
                benchmark=benchmark, cross_gain=0.05)
            export_inputs(args)
            rows.append(check_bundle(folder, args))
            print(f"Validated {folder.relative_to(ROOT)}", flush=True)

    manifest = output / "manifest.csv"
    with manifest.open("w", newline="") as f:
        writer = csv.DictWriter(f, fieldnames=list(rows[0]))
        writer.writeheader()
        writer.writerows(rows)
    print(f"Wrote {len(rows)} input bundles and {manifest}")


if __name__ == "__main__":
    main()
