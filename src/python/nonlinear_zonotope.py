"""
Nonlinear zonotopic estimator reference for the journal extension.

This script keeps the existing linear implementation intact and adds a
standalone nonlinear benchmark based on a coupled Van der Pol network with a
polynomial measurement model:

    x_{k+1} = f(x_k, u_k) + w_k
    y_k     = h(x_k) + v_k

The estimator uses online Jacobians plus conservative Taylor-remainder bounds
so the result remains a bounded-error set estimator rather than a pure EKF
heuristic.
"""

from __future__ import annotations

import os
import time
from dataclasses import dataclass
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


NUM_STEPS = int(os.getenv("ZONO_NL_NUM_STEPS", "120"))
N_STATE = int(os.getenv("ZONO_NL_N_STATE", "12"))
DT = float(os.getenv("ZONO_NL_DT", "0.02"))
REDUCTION_BUDGET = int(os.getenv("ZONO_NL_REDUCTION_BUDGET", str(2 * N_STATE)))
PROC_NOISE_RADIUS = float(os.getenv("ZONO_NL_PROC_NOISE_RADIUS", "0.01"))
MEAS_NOISE_RADIUS = float(os.getenv("ZONO_NL_MEAS_NOISE_RADIUS", "0.03"))
INIT_RADIUS = float(os.getenv("ZONO_NL_INIT_RADIUS", "0.05"))
MEASUREMENT_MODE = os.getenv("ZONO_NL_MEAS_MODE", "all_positions")
ESTIMATION_METHOD = os.getenv("ZONO_NL_METHOD", "segment")
RANDOM_SEED = int(os.getenv("ZONO_NL_RANDOM_SEED", "42"))
RUN_SWEEP = os.getenv("ZONO_NL_SWEEP", "0") == "1"
SWEEP_DIMS = [int(v) for v in os.getenv("ZONO_NL_SWEEP_DIMS", "12,24,48").split(",") if v.strip()]
SWEEP_METHODS = [v.strip() for v in os.getenv("ZONO_NL_SWEEP_METHODS", "fixed,segment,volume").split(",") if v.strip()]
SWEEP_MEAS_MODES = [
    v.strip() for v in os.getenv("ZONO_NL_SWEEP_MEAS_MODES", "all_positions,every_second_position").split(",") if v.strip()
]
BUDGET_SCALES = [float(v) for v in os.getenv("ZONO_NL_BUDGET_SCALES", "1.0,1.5,2.0").split(",") if v.strip()]

VAN_DER_POL_MU = float(os.getenv("ZONO_NL_MU", "0.4"))
COUPLING_GAIN = float(os.getenv("ZONO_NL_COUPLING", "0.05"))
MEAS_CUBIC_RHO = float(os.getenv("ZONO_NL_RHO", "0.01"))
MAX_RADIUS_CLIP = float(os.getenv("ZONO_NL_MAX_RADIUS_CLIP", "1000.0"))


def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def _output_dir() -> Path:
    path = _repo_root() / "data" / "output" / "python" / "nonlinear"
    path.mkdir(parents=True, exist_ok=True)
    return path


def _save_csv(path: Path, arr: np.ndarray) -> None:
    arr = np.asarray(arr, dtype=float)
    if arr.ndim == 1:
        arr = arr.reshape(1, -1)
    np.savetxt(path, arr, delimiter=",")


@dataclass
class Metrics:
    n_state: int
    measurement_mode: str
    method: str
    reduction_budget: int
    per_state_center_rmse: float
    max_per_state_center_error: float
    mean_interval_width: float
    max_interval_width: float
    containment_rate: float
    mean_generators: float
    max_generators: int
    mean_step_time_us: float
    total_time_us: float


class Zonotope:
    def __init__(self, p: np.ndarray, H: np.ndarray):
        self.p = np.asarray(p, dtype=float).reshape(-1)
        H = np.asarray(H, dtype=float)
        if H.ndim == 1:
            H = H.reshape(self.p.size, 1)
        if H.size == 0:
            H = np.zeros((self.p.size, 0), dtype=float)
        self.H = H

    @property
    def n(self) -> int:
        return self.p.size

    @property
    def m(self) -> int:
        return self.H.shape[1]

    def copy(self) -> "Zonotope":
        return Zonotope(self.p.copy(), self.H.copy())

    def interval_radius(self) -> np.ndarray:
        if self.m == 0:
            return np.zeros((self.n,), dtype=float)
        rad = np.sum(np.abs(np.nan_to_num(self.H, nan=0.0, posinf=MAX_RADIUS_CLIP, neginf=-MAX_RADIUS_CLIP)), axis=1)
        return np.clip(rad, 0.0, MAX_RADIUS_CLIP)

    def is_finite(self) -> bool:
        return np.all(np.isfinite(self.p)) and np.all(np.isfinite(self.H))

    def reduce(self, max_gens: int) -> "Zonotope":
        if self.m <= max_gens:
            return self
        keep_count = max(0, max_gens - self.n)
        norms = np.linalg.norm(self.H, axis=0)
        order = np.argsort(-norms)
        keep_idx = order[:keep_count]
        drop_idx = order[keep_count:]
        H_keep = self.H[:, keep_idx]
        H_drop = self.H[:, drop_idx]
        row_sum = np.sum(np.abs(H_drop), axis=1)
        H_red = np.concatenate([H_keep, np.diag(row_sum)], axis=1)
        return Zonotope(self.p, H_red)

    def _optimal_lambda_segment(self, c: np.ndarray, phi: float) -> np.ndarray:
        if self.m == 0:
            return np.zeros_like(c)
        t = self.H.T @ c
        if not np.all(np.isfinite(t)):
            return c.copy()
        numerator = self.H @ t
        denominator = float(np.dot(t, t) + phi * phi)
        if (not np.isfinite(denominator)) or abs(denominator) < 1e-12:
            return np.zeros_like(c)
        return numerator / denominator

    def _optimal_lambda_p_radius(self, c: np.ndarray, phi: float) -> np.ndarray:
        if self.m == 0:
            return np.zeros_like(c)
        HHT = self.H @ self.H.T
        try:
            P = np.linalg.inv(HHT + 1e-6 * np.eye(self.n))
        except np.linalg.LinAlgError:
            P = np.linalg.pinv(HHT + 1e-6 * np.eye(self.n))
        c_col = c.reshape(-1, 1)
        numerator = P @ HHT @ c_col
        denominator = float(c_col.T @ HHT @ P @ HHT @ c_col + phi * phi * c_col.T @ P @ c_col)
        if (not np.isfinite(denominator)) or abs(denominator) < 1e-12:
            return np.zeros_like(c)
        return (numerator / denominator).reshape(-1)

    def _optimal_lambda_volume(self, c: np.ndarray, phi: float) -> np.ndarray:
        t = self.H.T @ c
        if not np.all(np.isfinite(t)):
            return c.copy()
        t_sq = float(np.dot(t, t))
        c_sq = float(np.dot(c, c))
        denom = c_sq * (t_sq + phi * phi)
        alpha = (t_sq / denom) if np.isfinite(denom) and denom > 1e-12 else 0.0
        return alpha * c

    def intersect_with_strip(self, c: np.ndarray, y: float, phi: float, method: str) -> "Zonotope":
        c = np.asarray(c, dtype=float).reshape(-1)
        if method == "fixed":
            lam = c.copy()
        elif method == "segment":
            lam = self._optimal_lambda_segment(c, phi)
        elif method == "p_radius":
            lam = self._optimal_lambda_p_radius(c, phi)
        elif method == "volume":
            lam = self._optimal_lambda_volume(c, phi)
        else:
            raise ValueError(f"Unsupported method: {method}")

        residual = float(c @ self.p)
        innovation = y - residual
        p_hat = self.p + lam * innovation
        if self.m == 0:
            H_hat = (phi * lam).reshape(-1, 1)
        else:
            t = c @ self.H
            H_hat = self.H - np.outer(lam, t)
            H_hat = np.concatenate([H_hat, (phi * lam).reshape(-1, 1)], axis=1)
        z = Zonotope(np.nan_to_num(p_hat, nan=0.0, posinf=MAX_RADIUS_CLIP, neginf=-MAX_RADIUS_CLIP), np.nan_to_num(H_hat, nan=0.0, posinf=MAX_RADIUS_CLIP, neginf=-MAX_RADIUS_CLIP))
        return z


class CoupledVanDerPolModel:
    def __init__(self, n_state: int, dt: float, mu: float, coupling: float, rho: float):
        if n_state % 2 != 0:
            raise ValueError("N_STATE must be even for 2-state oscillator blocks.")
        self.n = n_state
        self.n_osc = n_state // 2
        self.dt = dt
        self.mu = mu
        self.coupling = coupling
        self.rho = rho

    def _split(self, x: np.ndarray) -> tuple[np.ndarray, np.ndarray]:
        q = x[0::2]
        v = x[1::2]
        return q, v

    def dynamics(self, x: np.ndarray, u: np.ndarray | None = None) -> np.ndarray:
        q, v = self._split(np.asarray(x, dtype=float).reshape(-1))
        if u is None:
            u = np.zeros((self.n_osc,), dtype=float)
        else:
            u = np.asarray(u, dtype=float).reshape(-1)
            if u.size == 1:
                u = np.full((self.n_osc,), u.item(), dtype=float)

        q_prev = q.copy()
        q_next = q.copy()
        q_prev[1:] = q[:-1]
        q_prev[0] = q[0]
        q_next[:-1] = q[1:]
        q_next[-1] = q[-1]
        coupling_term = self.coupling * (q_prev - 2.0 * q + q_next)

        dq = v
        dv = self.mu * (1.0 - q * q) * v - q + coupling_term + u

        x_next = np.empty_like(x, dtype=float)
        x_next[0::2] = q + self.dt * dq
        x_next[1::2] = v + self.dt * dv
        return x_next

    def dynamics_jacobian(self, x: np.ndarray, u: np.ndarray | None = None) -> np.ndarray:
        q, v = self._split(np.asarray(x, dtype=float).reshape(-1))
        F = np.eye(self.n, dtype=float)
        for i in range(self.n_osc):
            qi = q[i]
            vi = v[i]
            q_idx = 2 * i
            v_idx = q_idx + 1
            prev_q_idx = q_idx if i == 0 else 2 * (i - 1)
            next_q_idx = q_idx if i == (self.n_osc - 1) else 2 * (i + 1)

            F[q_idx, v_idx] = self.dt
            F[v_idx, q_idx] += self.dt * (-2.0 * self.mu * qi * vi - 1.0 - 2.0 * self.coupling)
            F[v_idx, v_idx] += self.dt * (self.mu * (1.0 - qi * qi))
            F[v_idx, prev_q_idx] += self.dt * self.coupling
            F[v_idx, next_q_idx] += self.dt * self.coupling
        return F

    def dynamics_remainder_radius(self, z: Zonotope) -> np.ndarray:
        radii = z.interval_radius()
        center = z.p
        rem = np.zeros((self.n,), dtype=float)
        for i in range(self.n_osc):
            q_idx = 2 * i
            v_idx = q_idx + 1
            q_abs = abs(center[q_idx]) + radii[q_idx]
            v_abs = abs(center[v_idx]) + radii[v_idx]
            h_qq = 2.0 * self.dt * self.mu * v_abs
            h_qv = 2.0 * self.dt * self.mu * q_abs
            rq = radii[q_idx]
            rv = radii[v_idx]
            rem[v_idx] = 0.5 * (h_qq * rq * rq + 2.0 * h_qv * rq * rv)
        return np.clip(np.nan_to_num(rem, nan=MAX_RADIUS_CLIP, posinf=MAX_RADIUS_CLIP, neginf=MAX_RADIUS_CLIP), 0.0, MAX_RADIUS_CLIP)

    def measurement_indices(self, mode: str) -> list[int]:
        if mode == "all_positions":
            return [2 * i for i in range(self.n_osc)]
        if mode == "every_second_position":
            return [2 * i for i in range(0, self.n_osc, 2)]
        raise ValueError(f"Unsupported measurement mode: {mode}")

    def measurement(self, x: np.ndarray, meas_idx: list[int]) -> np.ndarray:
        x = np.asarray(x, dtype=float).reshape(-1)
        q = x[meas_idx]
        return q + self.rho * q * q * q

    def measurement_jacobian(self, x: np.ndarray, meas_idx: list[int]) -> np.ndarray:
        x = np.asarray(x, dtype=float).reshape(-1)
        C = np.zeros((len(meas_idx), self.n), dtype=float)
        for row, idx in enumerate(meas_idx):
            q = x[idx]
            C[row, idx] = 1.0 + 3.0 * self.rho * q * q
        return C

    def measurement_remainder_radius(self, z: Zonotope, meas_idx: list[int]) -> np.ndarray:
        radii = z.interval_radius()
        center = z.p
        rem = np.zeros((len(meas_idx),), dtype=float)
        for row, idx in enumerate(meas_idx):
            q_abs = abs(center[idx]) + radii[idx]
            rem[row] = 3.0 * abs(self.rho) * q_abs * radii[idx] * radii[idx]
        return np.clip(np.nan_to_num(rem, nan=MAX_RADIUS_CLIP, posinf=MAX_RADIUS_CLIP, neginf=MAX_RADIUS_CLIP), 0.0, MAX_RADIUS_CLIP)


def process_noise_zonotope(n_state: int) -> Zonotope:
    return Zonotope(np.zeros((n_state,), dtype=float), np.diag(np.full((n_state,), PROC_NOISE_RADIUS, dtype=float)))


def initial_state_zonotope(x0: np.ndarray) -> Zonotope:
    return Zonotope(np.asarray(x0, dtype=float).reshape(-1), np.diag(np.full((x0.size,), INIT_RADIUS, dtype=float)))


def predict_nonlinear(z: Zonotope, model: CoupledVanDerPolModel, u: np.ndarray, w_zono: Zonotope) -> tuple[Zonotope, np.ndarray, np.ndarray]:
    center = model.dynamics(z.p, u)
    F = model.dynamics_jacobian(z.p, u)
    rem_radius = model.dynamics_remainder_radius(z)
    H_parts = [F @ z.H, w_zono.H, np.diag(rem_radius)]
    H_pred = np.concatenate([part for part in H_parts if part.size > 0], axis=1)
    z_pred = Zonotope(
        np.nan_to_num(center, nan=0.0, posinf=MAX_RADIUS_CLIP, neginf=-MAX_RADIUS_CLIP),
        np.nan_to_num(H_pred, nan=0.0, posinf=MAX_RADIUS_CLIP, neginf=-MAX_RADIUS_CLIP),
    )
    return z_pred, F, rem_radius


def update_nonlinear(
    z: Zonotope,
    model: CoupledVanDerPolModel,
    y: np.ndarray,
    meas_idx: list[int],
    method: str,
) -> tuple[Zonotope, np.ndarray, np.ndarray]:
    h_center = model.measurement(z.p, meas_idx)
    C = model.measurement_jacobian(z.p, meas_idx)
    rem = model.measurement_remainder_radius(z, meas_idx)

    z_upd = z
    for row, idx in enumerate(meas_idx):
        c = C[row]
        offset = h_center[row] - float(c @ z.p)
        y_strip = y[row] - offset
        phi = MEAS_NOISE_RADIUS + rem[row]
        z_upd = z_upd.intersect_with_strip(c, y_strip, phi, method)
        if not z_upd.is_finite():
            return z, C, rem
    return z_upd, C, rem


def simulate_truth(model: CoupledVanDerPolModel, x0: np.ndarray, num_steps: int, meas_idx: list[int], rng: np.random.Generator) -> tuple[np.ndarray, np.ndarray]:
    x_true = np.zeros((num_steps, model.n), dtype=float)
    y_true = np.zeros((num_steps, len(meas_idx)), dtype=float)
    x = np.asarray(x0, dtype=float).reshape(-1)
    for k in range(num_steps):
        x = model.dynamics(x) + rng.uniform(-PROC_NOISE_RADIUS, PROC_NOISE_RADIUS, size=model.n)
        y = model.measurement(x, meas_idx) + rng.uniform(-MEAS_NOISE_RADIUS, MEAS_NOISE_RADIUS, size=len(meas_idx))
        x_true[k] = x
        y_true[k] = y
    return x_true, y_true


def containment_flags(zonotopes: list[Zonotope], x_true: np.ndarray) -> np.ndarray:
    flags = np.zeros((len(zonotopes),), dtype=bool)
    for k, z in enumerate(zonotopes):
        rad = z.interval_radius()
        flags[k] = np.all(np.abs(x_true[k] - z.p) <= rad + 1e-10)
    return flags


def summarize_metrics(zonotopes: list[Zonotope], x_true: np.ndarray, centers: np.ndarray, step_time_us: np.ndarray) -> Metrics:
    err = centers - x_true
    per_state_err = np.sqrt(np.mean(err * err, axis=1))
    widths = np.asarray([2.0 * z.interval_radius() for z in zonotopes], dtype=float)
    flags = containment_flags(zonotopes, x_true)
    gen_counts = np.asarray([z.m for z in zonotopes], dtype=float)
    per_state_err = np.nan_to_num(per_state_err, nan=MAX_RADIUS_CLIP, posinf=MAX_RADIUS_CLIP, neginf=MAX_RADIUS_CLIP)
    widths = np.nan_to_num(widths, nan=MAX_RADIUS_CLIP, posinf=MAX_RADIUS_CLIP, neginf=MAX_RADIUS_CLIP)
    return Metrics(
        n_state=x_true.shape[1],
        measurement_mode="",
        method="",
        reduction_budget=0,
        per_state_center_rmse=float(np.sqrt(np.mean(err * err))),
        max_per_state_center_error=float(np.max(per_state_err)),
        mean_interval_width=float(np.mean(widths)),
        max_interval_width=float(np.max(widths)),
        containment_rate=float(np.mean(flags)),
        mean_generators=float(np.mean(gen_counts)),
        max_generators=int(np.max(gen_counts)),
        mean_step_time_us=float(np.mean(step_time_us)),
        total_time_us=float(np.sum(step_time_us)),
    )


def export_outputs(
    out_dir: Path,
    zonotopes: list[Zonotope],
    centers: np.ndarray,
    x_true: np.ndarray,
    y_meas: np.ndarray,
    step_time_us: np.ndarray,
    containment: np.ndarray,
) -> None:
    _save_csv(out_dir / "center.csv", centers)
    _save_csv(out_dir / "x_true.csv", x_true)
    _save_csv(out_dir / "meas.csv", y_meas)
    _save_csv(out_dir / "kernel_time_step_us.csv", step_time_us.reshape(-1, 1))
    _save_csv(out_dir / "containment_flags.csv", containment.astype(int).reshape(-1, 1))

    err = centers - x_true
    err_l2 = np.linalg.norm(err, axis=1, keepdims=True)
    _save_csv(out_dir / "error.csv", np.hstack([err, err_l2]))

    widths = np.asarray([2.0 * z.interval_radius() for z in zonotopes], dtype=float)
    _save_csv(out_dir / "interval_width.csv", widths)
    _save_csv(out_dir / "generator_count.csv", np.asarray([z.m for z in zonotopes], dtype=float).reshape(-1, 1))

    for k, z in enumerate(zonotopes):
        path = out_dir / f"zonotope_{k:03d}.csv"
        with path.open("w", encoding="utf-8") as f:
            f.write("p," + ",".join(f"{v:.17g}" for v in z.p) + "\n")
            for j in range(z.m):
                f.write("H," + ",".join(f"{v:.17g}" for v in z.H[:, j]) + "\n")


def plot_outputs(out_dir: Path, x_true: np.ndarray, centers: np.ndarray, zonotopes: list[Zonotope], meas_idx: list[int]) -> None:
    k = np.arange(x_true.shape[0])
    err = np.linalg.norm(centers - x_true, axis=1)
    mean_width = np.asarray([np.mean(2.0 * z.interval_radius()) for z in zonotopes], dtype=float)

    fig, axes = plt.subplots(3, 1, figsize=(8, 8), sharex=True)
    q_idx = meas_idx[0]
    radii = np.asarray([z.interval_radius()[q_idx] for z in zonotopes], dtype=float)
    axes[0].plot(k, x_true[:, q_idx], "k-", linewidth=1.2, label="true")
    axes[0].plot(k, centers[:, q_idx], "b--", linewidth=1.2, label="center")
    axes[0].fill_between(k, centers[:, q_idx] - radii, centers[:, q_idx] + radii, color="tab:blue", alpha=0.25, label="interval hull")
    axes[0].set_ylabel(f"x[{q_idx}]")
    axes[0].legend(loc="best")
    axes[0].grid(True, linestyle=":")

    axes[1].plot(k, err, color="tab:red")
    axes[1].set_ylabel("center L2 error")
    axes[1].grid(True, linestyle=":")

    axes[2].plot(k, mean_width, color="tab:green")
    axes[2].set_ylabel("mean width")
    axes[2].set_xlabel("step k")
    axes[2].grid(True, linestyle=":")

    fig.tight_layout()
    fig.savefig(out_dir / "nonlinear_summary.png", dpi=160)
    plt.close(fig)


def _rows_to_structured(rows: list[list[object]]) -> np.ndarray:
    dtype = [
        ("n_state", int),
        ("measurement_mode", "U64"),
        ("method", "U32"),
        ("reduction_budget", int),
        ("per_state_center_rmse", float),
        ("max_per_state_center_error", float),
        ("mean_interval_width", float),
        ("max_interval_width", float),
        ("containment_rate", float),
        ("mean_generators", float),
        ("max_generators", int),
        ("mean_step_time_us", float),
        ("total_time_us", float),
    ]
    arr = np.zeros((len(rows),), dtype=dtype)
    for i, row in enumerate(rows):
        arr[i] = tuple(row)
    return arr


def export_sweep_tables(out_root: Path, rows: list[list[object]]) -> None:
    data = _rows_to_structured(rows)

    accuracy_header = (
        "n_state,measurement_mode,method,reduction_budget,per_state_center_rmse,"
        "max_per_state_center_error,mean_interval_width,max_interval_width,containment_rate"
    )
    accuracy = np.column_stack([
        data["n_state"],
        data["measurement_mode"],
        data["method"],
        data["reduction_budget"],
        np.round(data["per_state_center_rmse"], 8),
        np.round(data["max_per_state_center_error"], 8),
        np.round(data["mean_interval_width"], 8),
        np.round(data["max_interval_width"], 8),
        np.round(data["containment_rate"], 8),
    ])
    np.savetxt(out_root / "accuracy_table.csv", accuracy, fmt="%s", delimiter=",", header=accuracy_header, comments="")

    runtime_header = "n_state,measurement_mode,method,reduction_budget,mean_step_time_us,total_time_us"
    runtime = np.column_stack([
        data["n_state"],
        data["measurement_mode"],
        data["method"],
        data["reduction_budget"],
        np.round(data["mean_step_time_us"], 6),
        np.round(data["total_time_us"], 6),
    ])
    np.savetxt(out_root / "runtime_table.csv", runtime, fmt="%s", delimiter=",", header=runtime_header, comments="")

    scaling_header = (
        "n_state,measurement_mode,method,reduction_budget,mean_step_time_us,"
        "mean_generators,max_generators,mean_interval_width,containment_rate"
    )
    scaling = np.column_stack([
        data["n_state"],
        data["measurement_mode"],
        data["method"],
        data["reduction_budget"],
        np.round(data["mean_step_time_us"], 6),
        np.round(data["mean_generators"], 6),
        data["max_generators"],
        np.round(data["mean_interval_width"], 8),
        np.round(data["containment_rate"], 8),
    ])
    np.savetxt(out_root / "scaling_table.csv", scaling, fmt="%s", delimiter=",", header=scaling_header, comments="")


def export_sweep_plots(out_root: Path, rows: list[list[object]]) -> None:
    data = _rows_to_structured(rows)
    methods = list(dict.fromkeys(data["method"].tolist()))
    meas_modes = list(dict.fromkeys(data["measurement_mode"].tolist()))

    fig, axes = plt.subplots(2, 1, figsize=(8, 7), sharex=True)
    for meas_mode in meas_modes:
        for method in methods:
            mask = (data["measurement_mode"] == meas_mode) & (data["method"] == method)
            subset = np.sort(data[mask], order=["n_state", "reduction_budget"])
            if subset.size == 0:
                continue
            label = f"{method} | {meas_mode}"
            axes[0].plot(subset["n_state"], subset["mean_step_time_us"], marker="o", linewidth=1.2, label=label)
            axes[1].plot(subset["n_state"], subset["mean_interval_width"], marker="o", linewidth=1.2, label=label)

    axes[0].set_ylabel("mean step time [us]")
    axes[0].grid(True, linestyle=":")
    axes[0].legend(loc="best", fontsize=8)
    axes[1].set_ylabel("mean interval width")
    axes[1].set_xlabel("state dimension n")
    axes[1].grid(True, linestyle=":")
    fig.tight_layout()
    fig.savefig(out_root / "sweep_overview.png", dpi=160)
    plt.close(fig)

    fig, axes = plt.subplots(2, 1, figsize=(8, 7), sharex=True)
    for meas_mode in meas_modes:
        for method in methods:
            mask = (data["measurement_mode"] == meas_mode) & (data["method"] == method)
            subset = np.sort(data[mask], order=["n_state", "reduction_budget"])
            if subset.size == 0:
                continue
            label = f"{method} | {meas_mode}"
            axes[0].plot(subset["n_state"], subset["containment_rate"], marker="s", linewidth=1.2, label=label)
            axes[1].plot(subset["n_state"], subset["mean_generators"], marker="s", linewidth=1.2, label=label)

    axes[0].set_ylabel("containment rate")
    axes[0].set_ylim(0.0, 1.05)
    axes[0].grid(True, linestyle=":")
    axes[0].legend(loc="best", fontsize=8)
    axes[1].set_ylabel("mean generators")
    axes[1].set_xlabel("state dimension n")
    axes[1].grid(True, linestyle=":")
    fig.tight_layout()
    fig.savefig(out_root / "sweep_quality.png", dpi=160)
    plt.close(fig)


def run_case(
    n_state: int,
    measurement_mode: str,
    method: str,
    reduction_budget: int,
    out_dir: Path | None,
    seed: int,
) -> Metrics:
    rng = np.random.default_rng(seed)
    model = CoupledVanDerPolModel(
        n_state=n_state,
        dt=DT,
        mu=VAN_DER_POL_MU,
        coupling=COUPLING_GAIN,
        rho=MEAS_CUBIC_RHO,
    )
    meas_idx = model.measurement_indices(measurement_mode)
    x0 = np.zeros((n_state,), dtype=float)
    x0[0::2] = 0.3
    x0[1::2] = 0.0

    x_true, y_meas = simulate_truth(model, x0, NUM_STEPS, meas_idx, rng)
    z = initial_state_zonotope(x0)
    w_zono = process_noise_zonotope(n_state)

    zonotopes: list[Zonotope] = []
    centers = np.zeros_like(x_true)
    step_time_us = np.zeros((NUM_STEPS,), dtype=float)

    for k in range(NUM_STEPS):
        t0 = time.perf_counter()
        z, _, _ = predict_nonlinear(z, model, np.zeros((model.n_osc,), dtype=float), w_zono)
        z = z.reduce(reduction_budget)
        z, _, _ = update_nonlinear(z, model, y_meas[k], meas_idx, method)
        z = z.reduce(reduction_budget)
        step_time_us[k] = (time.perf_counter() - t0) * 1e6
        zonotopes.append(z)
        centers[k] = z.p

    flags = containment_flags(zonotopes, x_true)
    metrics = summarize_metrics(zonotopes, x_true, centers, step_time_us)
    metrics.measurement_mode = measurement_mode
    metrics.method = method
    metrics.reduction_budget = reduction_budget

    if out_dir is not None:
        out_dir.mkdir(parents=True, exist_ok=True)
        export_outputs(out_dir, zonotopes, centers, x_true, y_meas, step_time_us, flags)
        plot_outputs(out_dir, x_true, centers, zonotopes, meas_idx)

        summary = np.array([
        ["n_state", str(n_state)],
        ["num_steps", str(NUM_STEPS)],
        ["measurement_mode", measurement_mode],
        ["method", method],
        ["reduction_budget", str(reduction_budget)],
        ["per_state_center_rmse", f"{metrics.per_state_center_rmse:.8f}"],
        ["max_per_state_center_error", f"{metrics.max_per_state_center_error:.8f}"],
        ["mean_interval_width", f"{metrics.mean_interval_width:.8f}"],
        ["max_interval_width", f"{metrics.max_interval_width:.8f}"],
        ["containment_rate", f"{metrics.containment_rate:.8f}"],
        ["mean_generators", f"{metrics.mean_generators:.3f}"],
        ["max_generators", str(metrics.max_generators)],
        ["mean_step_time_us", f"{metrics.mean_step_time_us:.3f}"],
        ["total_time_us", f"{metrics.total_time_us:.3f}"],
        ], dtype=object)
        np.savetxt(out_dir / "summary.txt", summary, fmt="%s")

    print(f"[nonlinear] n={n_state}, steps={NUM_STEPS}, meas={len(meas_idx)}, method={method}, budget={reduction_budget}")
    print(f"[nonlinear] containment_rate={metrics.containment_rate:.3f}")
    print(
        f"[nonlinear] per_state_center_rmse={metrics.per_state_center_rmse:.6f}, "
        f"max_per_state_center_error={metrics.max_per_state_center_error:.6f}"
    )
    print(f"[nonlinear] mean_interval_width={metrics.mean_interval_width:.6f}, max_interval_width={metrics.max_interval_width:.6f}")
    print(f"[nonlinear] mean_generators={metrics.mean_generators:.2f}, max_generators={metrics.max_generators}")
    print(f"[nonlinear] mean_step_time_us={metrics.mean_step_time_us:.2f}")
    return metrics


def run_reference() -> Metrics:
    return run_case(
        n_state=N_STATE,
        measurement_mode=MEASUREMENT_MODE,
        method=ESTIMATION_METHOD,
        reduction_budget=REDUCTION_BUDGET,
        out_dir=_output_dir(),
        seed=RANDOM_SEED,
    )


def run_sweep() -> None:
    out_root = _output_dir()
    rows = []
    for n_state in SWEEP_DIMS:
        for measurement_mode in SWEEP_MEAS_MODES:
            for method in SWEEP_METHODS:
                for scale in BUDGET_SCALES:
                    budget = max(n_state, int(round(scale * n_state)))
                    case_dir = out_root / f"n{n_state}" / measurement_mode / method / f"s{budget}"
                    metrics = run_case(
                        n_state=n_state,
                        measurement_mode=measurement_mode,
                        method=method,
                        reduction_budget=budget,
                        out_dir=case_dir,
                        seed=RANDOM_SEED,
                    )
                    rows.append([
                        metrics.n_state,
                        metrics.measurement_mode,
                        metrics.method,
                        metrics.reduction_budget,
                        metrics.per_state_center_rmse,
                        metrics.max_per_state_center_error,
                        metrics.mean_interval_width,
                        metrics.max_interval_width,
                        metrics.containment_rate,
                        metrics.mean_generators,
                        metrics.max_generators,
                        metrics.mean_step_time_us,
                        metrics.total_time_us,
                    ])

    header = (
        "n_state,measurement_mode,method,reduction_budget,per_state_center_rmse,"
        "max_per_state_center_error,mean_interval_width,max_interval_width,"
        "containment_rate,mean_generators,max_generators,mean_step_time_us,total_time_us"
    )
    np.savetxt(
        out_root / "sweep_metrics.csv",
        np.asarray(rows, dtype=object),
        fmt="%s",
        delimiter=",",
        header=header,
        comments="",
    )
    export_sweep_tables(out_root, rows)
    export_sweep_plots(out_root, rows)


if __name__ == "__main__":
    if RUN_SWEEP:
        run_sweep()
    else:
        run_reference()
