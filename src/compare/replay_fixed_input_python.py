#!/usr/bin/env python3

from __future__ import annotations

import argparse
from pathlib import Path
import sys

import numpy as np

REPO_ROOT = Path(__file__).resolve().parents[2]
if str(REPO_ROOT) not in sys.path:
    sys.path.insert(0, str(REPO_ROOT))

from src.python.zonotope import Zonotope


def load_csv(path: Path) -> np.ndarray:
    arr = np.loadtxt(path, delimiter=",")
    if arr.ndim == 1:
        arr = arr.reshape(1, -1)
    return np.asarray(arr, dtype=float)


def save_csv(path: Path, arr: np.ndarray) -> None:
    np.savetxt(path, np.asarray(arr, dtype=float), delimiter=",", fmt="%.17g")


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


def replay(bundle_dir: Path, out_dir: Path) -> None:
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
    C = build_measurement_matrix(n_state, n_meas)

    m_x = infer_generator_count(H_input)
    m_w = infer_generator_count(H_w)
    X = Zonotope(p_input, H_input[:, :m_x])
    W = Zonotope(p_w, H_w[:, :m_w])

    centers = np.zeros((n_steps, n_state), dtype=float)
    errors = np.zeros((n_steps, n_state + 1), dtype=float)

    out_dir.mkdir(parents=True, exist_ok=True)
    for k in range(n_steps):
        X = X.predict(A=A, B=np.zeros((n_state, 1)), u=np.zeros(1), W=W)
        if X.m > 32:
            X = X.reduce(32)
        for meas in range(n_meas):
            X = X.intersect_with_strip(
                c=C[meas],
                y=float(y_all[k, meas]),
                phi=float(phi_all[k, meas]),
                method="segment",
            )
        X = X.reduce(32)
        centers[k, :] = X.p
        err = X.p - x_true[k, :]
        errors[k, :-1] = err
        errors[k, -1] = np.linalg.norm(err)

    save_csv(out_dir / "center.csv", centers)
    save_csv(out_dir / "x_true.csv", x_true)
    save_csv(out_dir / "meas.csv", y_all)
    save_csv(out_dir / "error.csv", errors)


def main() -> None:
    parser = argparse.ArgumentParser(description="Replay the fixed board input bundle with the Python estimator.")
    parser.add_argument("--bundle-dir", default="data/output/board_inputs_rebuilt_max32")
    parser.add_argument("--out-dir", default="data/output/python_fixed/LAMBDA_SEGMENT")
    args = parser.parse_args()
    replay(Path(args.bundle_dir), Path(args.out_dir))


if __name__ == "__main__":
    main()
