#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path
import sys
import time

import numpy as np

REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from src.python.zonotope import REDUCTION_BUDGET, Zonotope

METHODS = [
    ("Fixed-gain", "Fixed-gain"),
    ("LAMBDA_SEGMENT", "segment"),
    ("LAMBDA_VOLUME", "volume"),
]


def load_csv(path: Path) -> np.ndarray:
    arr = np.loadtxt(path, delimiter=",")
    if arr.ndim == 1:
        arr = arr.reshape(1, -1)
    return np.asarray(arr, dtype=float)


def save_csv(path: Path, arr: np.ndarray) -> None:
    np.savetxt(path, np.asarray(arr, dtype=float), delimiter=",", fmt="%.17g")


def save_zonotope_csv(path: Path, z: Zonotope) -> None:
    with path.open("w", encoding="ascii") as f:
        f.write("p," + ",".join(f"{float(v):.17g}" for v in z.p) + "\n")
        for j in range(z.m):
            f.write("H," + ",".join(f"{float(v):.17g}" for v in z.H[:, j]) + "\n")


def infer_generator_count(H: np.ndarray, tol: float = 1e-12) -> int:
    return int(np.count_nonzero(np.any(np.abs(H) > tol, axis=0)))


def build_measurement_matrix(n_state: int, n_meas: int) -> np.ndarray:
    C = np.zeros((n_meas, n_state), dtype=float)
    for block in range(n_state // 4):
        meas_base = block * 2
        state_base = block * 4
        if meas_base + 1 < n_meas:
            C[meas_base + 0, state_base + 0] = 1.0
            C[meas_base + 1, state_base + 1] = 1.0
    return C


def replay(bundle_dir: Path, out_dir: Path, method: str) -> None:
    A = load_csv(bundle_dir / "A.csv")
    y_all = load_csv(bundle_dir / "y_all.csv")
    phi_all = load_csv(bundle_dir / "phi_all.csv")
    p_input = load_csv(bundle_dir / "p_input.csv").reshape(-1)
    H_input = load_csv(bundle_dir / "H_input.csv")
    p_w = load_csv(bundle_dir / "p_w.csv").reshape(-1)
    H_w = load_csv(bundle_dir / "H_w.csv")
    x_true = load_csv(bundle_dir / "x_true.csv")

    n_steps, n_meas = y_all.shape
    n_state = p_input.size
    c_path = bundle_dir / "C.csv"
    C = load_csv(c_path) if c_path.exists() else build_measurement_matrix(n_state, n_meas)
    if x_true.shape[0] == n_steps:
        x_true_out = np.vstack([p_input.reshape(1, -1), x_true])
    elif x_true.shape[0] == n_steps + 1:
        x_true_out = x_true
    else:
        raise ValueError(f"x_true rows must be {n_steps} or {n_steps + 1}, got {x_true.shape[0]}")

    m_x = infer_generator_count(H_input)
    m_w = infer_generator_count(H_w)
    X = Zonotope(p_input, H_input[:, :m_x])
    W = Zonotope(p_w, H_w[:, :m_w])

    centers = np.zeros((n_steps + 1, n_state), dtype=float)
    errors = np.zeros((n_steps + 1, n_state + 1), dtype=float)
    step_time_us = np.zeros((n_steps, 1), dtype=float)
    zonotopes = [X.copy()]
    centers[0, :] = X.p
    err0 = X.p - x_true_out[0, :]
    errors[0, :-1] = err0
    errors[0, -1] = np.linalg.norm(err0)

    out_dir.mkdir(parents=True, exist_ok=True)
    for old in out_dir.glob("zonotope_*.csv"):
        old.unlink()
    for k in range(n_steps):
        t0 = time.perf_counter()
        X = X.predict(A=A, B=np.zeros((n_state, 1)), u=np.zeros(1), W=W)
        if X.m > REDUCTION_BUDGET:
            X = X.reduce(REDUCTION_BUDGET)
        for meas in range(n_meas):
            X = X.intersect_with_strip(
                c=C[meas],
                y=float(y_all[k, meas]),
                phi=float(phi_all[k, meas]),
                method=method,
            )
        X = X.reduce(REDUCTION_BUDGET)
        step_time_us[k, 0] = (time.perf_counter() - t0) * 1e6
        centers[k + 1, :] = X.p
        err = X.p - x_true_out[k + 1, :]
        errors[k + 1, :-1] = err
        errors[k + 1, -1] = np.linalg.norm(err)
        zonotopes.append(X.copy())

    save_csv(out_dir / "center.csv", centers)
    save_csv(out_dir / "x_true.csv", x_true_out)
    save_csv(out_dir / "meas.csv", y_all)
    save_csv(out_dir / "error.csv", errors)
    total_us = float(np.sum(step_time_us[:, 0]))
    avg_us = float(np.mean(step_time_us[:, 0])) if n_steps else 0.0
    save_csv(out_dir / "kernel_time_step_us.csv", step_time_us)
    save_csv(out_dir / "kernel_time_summary_us.csv", np.array([[total_us, avg_us, n_steps]], dtype=float))
    for k, z in enumerate(zonotopes):
        save_zonotope_csv(out_dir / f"zonotope_{k:03d}.csv", z)


def main() -> None:
    parser = argparse.ArgumentParser(description="Replay the fixed board input bundle with the Python estimator.")
    parser.add_argument("--bundle-dir", default="data/input/shared_linear_24d_200")
    parser.add_argument("--out-base", default="data/output/python")
    parser.add_argument("--method", choices=[label for label, _ in METHODS] + ["all"], default="all")
    args = parser.parse_args()
    selected = METHODS if args.method == "all" else [m for m in METHODS if m[0] == args.method]
    for label, method in selected:
        out_dir = Path(args.out_base) / label
        replay(Path(args.bundle_dir), out_dir, method)
        print(f"Replayed {label}: {out_dir}")


if __name__ == "__main__":
    main()
