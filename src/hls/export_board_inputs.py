#!/usr/bin/env python3

from __future__ import annotations

import argparse
import json
from pathlib import Path

import numpy as np


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="Export a complete input bundle matching the current HLS batch testbench."
    )
    parser.add_argument("--out-dir", default="data/output/board_inputs", help="Output directory")
    parser.add_argument("--n-state", type=int, default=24, help="State dimension")
    parser.add_argument("--n-meas", type=int, default=12, help="Measurements per step")
    parser.add_argument("--n-steps", type=int, default=200, help="Batch length")
    parser.add_argument("--max-gens", type=int, default=64, help="Physical generator capacity")
    parser.add_argument("--reduction-budget", type=int, default=32, help="Reduction budget")
    parser.add_argument("--dt", type=float, default=0.1, help="Sampling period")
    parser.add_argument("--omega", type=float, default=0.5, help="Oscillator frequency")
    parser.add_argument("--zeta", type=float, default=0.05, help="Damping ratio")
    parser.add_argument("--eps", type=float, default=0.1, help="Cross-coupling strength")
    parser.add_argument("--proc-noise", type=float, default=0.05, help="Process noise radius")
    parser.add_argument("--meas-noise", type=float, default=0.1, help="Measurement noise radius")
    parser.add_argument("--seed", type=int, default=1, help="LCG seed used by the HLS testbench")
    return parser.parse_args()


def make_rng(seed: int):
    state = seed & 0xFFFFFFFF

    def rand01() -> np.float32:
        nonlocal state
        state = (1664525 * state + 1013904223) & 0xFFFFFFFF
        value = (state >> 8) & 0x00FFFFFF
        return np.float32(value / float(0x01000000))

    def uniform_noise(radius: float) -> np.float32:
        return np.float32((2.0 * rand01() - 1.0) * radius)

    return uniform_noise


def build_a(n_state: int, dt: float, omega: float, zeta: float, eps: float) -> np.ndarray:
    if n_state % 4 != 0:
        raise ValueError(f"n_state must be a multiple of 4, got {n_state}")
    decay = np.exp(-zeta * dt)
    c_cos = np.cos(omega * dt) * decay
    c_sin = np.sin(omega * dt) * decay
    block = np.array(
        [
            [c_cos, -c_sin, eps, 0.0],
            [c_sin, c_cos, 0.0, eps],
            [-eps, 0.0, c_cos, -c_sin],
            [0.0, -eps, c_sin, c_cos],
        ],
        dtype=np.float32,
    )
    A = np.zeros((n_state, n_state), dtype=np.float32)
    for b in range(n_state // 4):
        i = 4 * b
        A[i : i + 4, i : i + 4] = block
    return A


def build_c(n_state: int, n_meas: int) -> np.ndarray:
    if n_state % 4 != 0:
        raise ValueError(f"n_state must be a multiple of 4, got {n_state}")
    C = np.zeros((n_meas, n_state), dtype=np.float32)
    for block in range(n_state // 4):
        meas_base = block * 2
        state_base = block * 4
        if meas_base + 1 < n_meas:
            C[meas_base + 0, state_base + 0] = 1.0
            C[meas_base + 1, state_base + 1] = 1.0
    return C


def export_inputs(args: argparse.Namespace) -> Path:
    out_dir = Path(args.out_dir)
    out_dir.mkdir(parents=True, exist_ok=True)

    A = build_a(args.n_state, args.dt, args.omega, args.zeta, args.eps)
    C = build_c(args.n_state, args.n_meas)
    uniform_noise = make_rng(args.seed)

    p_input = np.zeros(args.n_state, dtype=np.float32)
    p_input[0] = 1.0

    H_input = np.zeros((args.n_state, args.max_gens), dtype=np.float32)
    h_init_cols = min(args.n_state, args.max_gens)
    for i in range(h_init_cols):
        H_input[i, i] = np.float32(0.2)

    p_w = np.zeros(args.n_state, dtype=np.float32)
    H_w = np.zeros((args.n_state, args.max_gens), dtype=np.float32)
    m_w = min(args.n_state, args.max_gens)
    for i in range(m_w):
        H_w[i, i] = np.float32(args.proc_noise)

    x_true = np.zeros(args.n_state, dtype=np.float32)
    for b in range(args.n_state // 4):
        x_true[4 * b] = 1.0
    x_true_seq = np.zeros((args.n_steps, args.n_state), dtype=np.float32)

    phi_vec = np.full(args.n_meas, args.meas_noise, dtype=np.float32)
    y_all = np.zeros((args.n_steps, args.n_meas), dtype=np.float32)
    phi_all = np.zeros((args.n_steps, args.n_meas), dtype=np.float32)

    for k in range(args.n_steps):
        w_k = np.array([uniform_noise(args.proc_noise) for _ in range(args.n_state)], dtype=np.float32)
        x_true = (A @ x_true + w_k).astype(np.float32)
        x_true_seq[k, :] = x_true
        for j in range(args.n_meas):
            v = uniform_noise(args.meas_noise)
            y_all[k, j] = np.float32(C[j] @ x_true + v)
            phi_all[k, j] = phi_vec[j]

    np.save(out_dir / "A.npy", A)
    np.save(out_dir / "x_true.npy", x_true_seq)
    np.save(out_dir / "y_all.npy", y_all)
    np.save(out_dir / "phi_all.npy", phi_all)
    np.save(out_dir / "p_input.npy", p_input)
    np.save(out_dir / "H_input.npy", H_input)
    np.save(out_dir / "p_w.npy", p_w)
    np.save(out_dir / "H_w.npy", H_w)
    np.savetxt(out_dir / "A.csv", A, delimiter=",", fmt="%.9g")
    np.savetxt(out_dir / "x_true.csv", x_true_seq, delimiter=",", fmt="%.9g")
    np.savetxt(out_dir / "y_all.csv", y_all, delimiter=",", fmt="%.9g")
    np.savetxt(out_dir / "phi_all.csv", phi_all, delimiter=",", fmt="%.9g")
    np.savetxt(out_dir / "p_input.csv", p_input.reshape(1, -1), delimiter=",", fmt="%.9g")
    np.savetxt(out_dir / "H_input.csv", H_input, delimiter=",", fmt="%.9g")
    np.savetxt(out_dir / "p_w.csv", p_w.reshape(1, -1), delimiter=",", fmt="%.9g")
    np.savetxt(out_dir / "H_w.csv", H_w, delimiter=",", fmt="%.9g")

    meta = {
        "seed": args.seed,
        "n_state": args.n_state,
        "n_meas": args.n_meas,
        "n_steps": args.n_steps,
        "max_gens": args.max_gens,
        "reduction_budget": args.reduction_budget,
        "h_init_cols": int(h_init_cols),
        "m_w": int(m_w),
        "init_radius": 0.2,
        "proc_noise_radius": args.proc_noise,
        "meas_noise_radius": args.meas_noise,
    }
    (out_dir / "meta.json").write_text(json.dumps(meta, indent=2) + "\n", encoding="ascii")

    summary = [
        f"seed={args.seed}",
        f"n_state={args.n_state}",
        f"n_meas={args.n_meas}",
        f"n_steps={args.n_steps}",
        f"max_gens={args.max_gens}",
        f"reduction_budget={args.reduction_budget}",
        f"h_init_cols={h_init_cols}",
        f"m_w={m_w}",
        f"A_shape={A.shape}",
        f"x_true_shape={x_true_seq.shape}",
        f"y_all_shape={y_all.shape}",
        f"phi_all_shape={phi_all.shape}",
        f"p_input_shape={p_input.shape}",
        f"H_input_shape={H_input.shape}",
        f"p_w_shape={p_w.shape}",
        f"H_w_shape={H_w.shape}",
    ]
    (out_dir / "summary.txt").write_text("\n".join(summary) + "\n", encoding="ascii")
    return out_dir


def main() -> None:
    args = parse_args()
    out_dir = export_inputs(args)
    print(f"Saved inputs under: {out_dir}")
    print(f"A:      {out_dir / 'A.npy'}")
    print(f"x_true: {out_dir / 'x_true.npy'}")
    print(f"y_all:  {out_dir / 'y_all.npy'}")
    print(f"phi_all:{out_dir / 'phi_all.npy'}")
    print(f"p_input:{out_dir / 'p_input.npy'}")
    print(f"H_input:{out_dir / 'H_input.npy'}")
    print(f"p_w:    {out_dir / 'p_w.npy'}")
    print(f"H_w:    {out_dir / 'H_w.npy'}")
    print(f"meta:   {out_dir / 'meta.json'}")


if __name__ == "__main__":
    main()
