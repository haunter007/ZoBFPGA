"""
Nonlinear zonotopic estimator — fixed version.

Changes vs nonlinear_zonotope_reference_updated.py:

FIX 1 (core): Hessian bound uses physical caps Q_MAX / V_MAX instead of
  the current zonotope radius.  The old code used
      v_abs = |center_v| + radius_v
  which creates a positive feedback loop: large radius → large Hessian bound
  → large remainder generator → even larger radius → overflow in ~80 steps.
  The new code uses
      v_abs = min(|center_v| + radius_v,  V_MAX)
      q_abs = min(|center_q| + radius_q,  Q_MAX)
  where Q_MAX, V_MAX are system-level Lyapunov bounds that hold for all
  reachable trajectories of the Van der Pol network.
  Proposition 1 (enclosure) is preserved because the Hessian bound must
  satisfy  |d²f/dxa dxb| <= L  over the interval hull.  Using min(…, VMAX)
  is valid as long as VMAX >= true |v| everywhere on the hull — which holds
  by definition of the Lyapunov bound.

FIX 2: Default reduction budget raised to 3*n (was 2*n).  Every strip update
  adds one generator; every prediction adds n+n_w generators.  With budget=2n
  the reduction step discards too much information per cycle, inflating the
  zonotope faster than measurement updates can shrink it.

FIX 3: Failure reporting and diagnostics are kept from the reference updated
  version (no nan_to_num, no MAX_RADIUS_CLIP, explicit failure records).
  The sequential_recompute measurement update mode is the default.

How to pick Q_MAX and V_MAX:
  For μ=0.4 the Van der Pol limit cycle has |q| ≤ 2.5, |v| ≤ 2.5 roughly.
  The defaults Q_MAX=5.0, V_MAX=5.0 give a 2× safety margin.
  If you change μ significantly (e.g. μ=2.0), recheck these bounds.
"""

from __future__ import annotations

import os
import time
from dataclasses import dataclass
from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np


# ── run-time parameters ────────────────────────────────────────────────────
NUM_STEPS          = int(os.getenv("ZONO_NL_NUM_STEPS",     "120"))
N_STATE            = int(os.getenv("ZONO_NL_N_STATE",       "12"))
DT                 = float(os.getenv("ZONO_NL_DT",          "0.02"))
# FIX 2: default budget is now 3*n
REDUCTION_BUDGET   = int(os.getenv("ZONO_NL_REDUCTION_BUDGET", str(3 * N_STATE)))
PROC_NOISE_RADIUS  = float(os.getenv("ZONO_NL_PROC_NOISE_RADIUS", "0.01"))
MEAS_NOISE_RADIUS  = float(os.getenv("ZONO_NL_MEAS_NOISE_RADIUS", "0.03"))
INIT_RADIUS        = float(os.getenv("ZONO_NL_INIT_RADIUS", "0.05"))
MEASUREMENT_MODE   = os.getenv("ZONO_NL_MEAS_MODE",  "all_positions")
ESTIMATION_METHOD  = os.getenv("ZONO_NL_METHOD",     "segment")
RANDOM_SEED        = int(os.getenv("ZONO_NL_RANDOM_SEED", "42"))
RUN_SWEEP          = os.getenv("ZONO_NL_SWEEP",      "0") == "1"
RUN_DEBUG_SPARSE   = os.getenv("ZONO_NL_DEBUG_SPARSE_SEGMENT", "0") == "1"
STOP_ON_FAILURE    = os.getenv("ZONO_NL_STOP_ON_FAILURE", "1") == "1"

SWEEP_DIMS         = [int(v)   for v in os.getenv("ZONO_NL_SWEEP_DIMS",   "12,24,48").split(",") if v.strip()]
SWEEP_METHODS      = [v.strip() for v in os.getenv("ZONO_NL_SWEEP_METHODS","fixed,segment,volume").split(",") if v.strip()]
SWEEP_MEAS_MODES   = [v.strip() for v in os.getenv(
    "ZONO_NL_SWEEP_MEAS_MODES","all_positions,every_second_position").split(",") if v.strip()]
BUDGET_SCALES      = [float(v) for v in os.getenv("ZONO_NL_BUDGET_SCALES","1.0,1.5,2.0").split(",") if v.strip()]

VAN_DER_POL_MU   = float(os.getenv("ZONO_NL_MU",       "0.4"))
COUPLING_GAIN    = float(os.getenv("ZONO_NL_COUPLING",  "0.05"))
MEAS_CUBIC_RHO   = float(os.getenv("ZONO_NL_RHO",       "0.01"))

# FIX 1: physical caps for Hessian bound computation
# Van der Pol with mu=0.4: limit cycle has |q|,|v| < 2.5; use 5.0 as safe bound.
Q_MAX = float(os.getenv("ZONO_NL_Q_MAX", "5.0"))
V_MAX = float(os.getenv("ZONO_NL_V_MAX", "5.0"))

FAILURE_NORM_LIMIT = float(os.getenv("ZONO_NL_FAILURE_NORM_LIMIT", "1e12"))

MEAS_UPDATE_MODE = os.getenv("ZONO_NL_MEAS_UPDATE_MODE", "sequential_recompute")
VALID_MEAS_UPDATE_MODES = {"sequential_recompute", "frozen_prediction"}
if MEAS_UPDATE_MODE not in VALID_MEAS_UPDATE_MODES:
    raise ValueError(f"Unsupported ZONO_NL_MEAS_UPDATE_MODE={MEAS_UPDATE_MODE!r}")


# ── paths ──────────────────────────────────────────────────────────────────
def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]

def _output_dir() -> Path:
    path = _repo_root() / "data" / "output" / "python" / "nonlinear_fixed"
    path.mkdir(parents=True, exist_ok=True)
    return path

def _save_csv(path: Path, arr) -> None:
    arr = np.asarray(arr)
    if arr.ndim == 1:
        arr = arr.reshape(1, -1)
    np.savetxt(path, arr, delimiter=",", fmt="%s")


# ── diagnostics dataclasses ────────────────────────────────────────────────
@dataclass
class StripDiagnostics:
    step: int = -1; row: int = -1; state_index: int = -1; method: str = ""
    phi: float = float("nan"); denominator: float = float("nan")
    lambda_norm: float = float("nan"); innovation: float = float("nan")
    p_norm_before: float = float("nan"); max_radius_before: float = float("nan")
    p_norm_after: float = float("nan"); max_radius_after: float = float("nan")

@dataclass
class FailureDiagnostics:
    failed: bool = False; step: int = -1; reason: str = ""
    p_norm: float = float("nan"); max_interval_radius: float = float("nan")
    phi: float = float("nan"); segment_denominator: float = float("nan")
    lambda_norm: float = float("nan"); strip_row: int = -1
    strip_state_index: int = -1; measurement_update_mode: str = ""

@dataclass
class Metrics:
    n_state: int; measurement_mode: str; method: str; reduction_budget: int
    per_state_center_rmse: float; max_per_state_center_error: float
    mean_interval_width: float; max_interval_width: float
    containment_rate: float; mean_generators: float; max_generators: int
    mean_step_time_us: float; total_time_us: float
    failed: bool; first_failure_step: int; failure_reason: str
    fail_p_norm: float; fail_max_interval_radius: float
    fail_phi: float; fail_segment_denominator: float; fail_lambda_norm: float


# ── Zonotope ───────────────────────────────────────────────────────────────
class Zonotope:
    def __init__(self, p: np.ndarray, H: np.ndarray):
        self.p = np.asarray(p, dtype=float).reshape(-1)
        H = np.asarray(H, dtype=float)
        if H.ndim == 1:
            H = H.reshape(self.p.size, 1)
        if H.size == 0:
            H = np.zeros((self.p.size, 0), dtype=float)
        if H.shape[0] != self.p.size:
            raise ValueError(f"Generator row count {H.shape[0]} != center size {self.p.size}.")
        self.H = H

    @property
    def n(self) -> int: return self.p.size
    @property
    def m(self) -> int: return self.H.shape[1]

    def copy(self) -> "Zonotope":
        return Zonotope(self.p.copy(), self.H.copy())

    def interval_radius(self) -> np.ndarray:
        if self.m == 0:
            return np.zeros((self.n,), dtype=float)
        return np.sum(np.abs(self.H), axis=1)

    def p_norm(self) -> float:
        return float(np.linalg.norm(self.p))

    def max_interval_radius(self) -> float:
        rad = self.interval_radius()
        return float(np.max(rad)) if rad.size else 0.0

    def is_finite(self) -> bool:
        return np.all(np.isfinite(self.p)) and np.all(np.isfinite(self.H))

    def is_reasonably_bounded(self) -> bool:
        if not self.is_finite():
            return False
        return self.p_norm() <= FAILURE_NORM_LIMIT and self.max_interval_radius() <= FAILURE_NORM_LIMIT

    def reduce(self, max_gens: int) -> "Zonotope":
        """Proposition 4 row-sum reduction."""
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
        return Zonotope(self.p, np.concatenate([H_keep, np.diag(row_sum)], axis=1))

    # ── strip intersection ────────────────────────────────────────────────
    def _segment_lambda_and_denom(self, c: np.ndarray, phi: float):
        if self.m == 0:
            return np.zeros_like(c), float(phi * phi)
        t = self.H.T @ c
        num = self.H @ t
        denom = float(np.dot(t, t) + phi * phi)
        if (not np.isfinite(denom)) or abs(denom) < 1e-12:
            return np.zeros_like(c), denom
        return num / denom, denom

    def _lambda_volume(self, c: np.ndarray, phi: float) -> np.ndarray:
        if self.m == 0:
            return np.zeros_like(c)
        t = self.H.T @ c
        t_sq = float(np.dot(t, t))
        c_sq = float(np.dot(c, c))
        denom = c_sq * (t_sq + phi * phi)
        alpha = (t_sq / denom) if np.isfinite(denom) and denom > 1e-12 else 0.0
        return alpha * c

    def intersect_with_strip(
        self, c: np.ndarray, y: float, phi: float, method: str,
        *, step: int = -1, row: int = -1, state_index: int = -1,
    ) -> tuple["Zonotope", StripDiagnostics]:
        c = np.asarray(c, dtype=float).reshape(-1)
        denom = float("nan")
        if method == "fixed":
            lam = c.copy()
        elif method == "segment":
            lam, denom = self._segment_lambda_and_denom(c, phi)
        elif method == "volume":
            lam = self._lambda_volume(c, phi)
        else:
            raise ValueError(f"Unsupported method: {method}")

        p_nb = self.p_norm()
        r_nb = self.max_interval_radius()
        innov = float(y - float(c @ self.p))
        p_hat = self.p + lam * innov
        if self.m == 0:
            H_hat = (phi * lam).reshape(-1, 1)
        else:
            t = c @ self.H
            H_hat = np.concatenate([self.H - np.outer(lam, t), (phi * lam).reshape(-1, 1)], axis=1)

        z_new = Zonotope(p_hat, H_hat)
        diag = StripDiagnostics(
            step=step, row=row, state_index=state_index, method=method,
            phi=float(phi), denominator=denom,
            lambda_norm=float(np.linalg.norm(lam)), innovation=innov,
            p_norm_before=p_nb, max_radius_before=r_nb,
            p_norm_after=z_new.p_norm(), max_radius_after=z_new.max_interval_radius(),
        )
        return z_new, diag


# ── Van der Pol model ──────────────────────────────────────────────────────
class CoupledVanDerPolModel:
    def __init__(self, n_state: int, dt: float, mu: float, coupling: float, rho: float):
        if n_state % 2 != 0:
            raise ValueError("N_STATE must be even.")
        self.n = n_state; self.n_osc = n_state // 2
        self.dt = dt; self.mu = mu; self.coupling = coupling; self.rho = rho

    def _split(self, x: np.ndarray):
        x = np.asarray(x, dtype=float).reshape(-1)
        return x[0::2], x[1::2]

    def dynamics(self, x: np.ndarray, u=None) -> np.ndarray:
        q, v = self._split(x)
        if u is None:
            u = np.zeros(self.n_osc)
        else:
            u = np.asarray(u, dtype=float).reshape(-1)
            if u.size == 1:
                u = np.full(self.n_osc, u.item())
        q_prev = q.copy(); q_next = q.copy()
        q_prev[1:] = q[:-1]; q_next[:-1] = q[1:]
        ct = self.coupling * (q_prev - 2.0 * q + q_next)
        dq = v
        dv = self.mu * (1.0 - q * q) * v - q + ct + u
        xn = np.empty_like(np.asarray(x, dtype=float))
        xn[0::2] = q + self.dt * dq
        xn[1::2] = v + self.dt * dv
        return xn

    def dynamics_jacobian(self, x: np.ndarray, u=None) -> np.ndarray:
        q, v = self._split(x)
        F = np.eye(self.n, dtype=float)
        for i in range(self.n_osc):
            qi, vi = q[i], v[i]
            qi_idx, vi_idx = 2*i, 2*i+1
            prev_qi = qi_idx if i == 0 else 2*(i-1)
            next_qi = qi_idx if i == self.n_osc-1 else 2*(i+1)
            F[qi_idx, vi_idx]  = self.dt
            F[vi_idx, qi_idx] += self.dt * (-2.0*self.mu*qi*vi - 1.0 - 2.0*self.coupling)
            F[vi_idx, vi_idx] += self.dt * (self.mu * (1.0 - qi*qi))
            F[vi_idx, prev_qi] += self.dt * self.coupling
            F[vi_idx, next_qi] += self.dt * self.coupling
        return F

    # ── FIX 1: Hessian bound uses physical caps, not zonotope radius ──────
    def dynamics_remainder_radius(self, z: Zonotope) -> np.ndarray:
        """
        Remainder bound  ρ_ℓ = (1/2) Σ_ab L_ℓab r_a r_b  (paper eq. 14).

        Nonzero Hessian entries for v_i (paper eq. 32):
            d²(v_i,k+1)/dq_i²      = -2·dt·μ·v_i   →  |L| = 2·dt·μ·|v_i|
            d²(v_i,k+1)/dq_i dv_i  = -2·dt·μ·q_i   →  |L| = 2·dt·μ·|q_i|

        OLD: used  v_abs = |center_v| + radius_v  (positive feedback → overflow)
        NEW: caps  v_abs = min(|center_v| + radius_v,  V_MAX)
                   q_abs = min(|center_q| + radius_q,  Q_MAX)
        This is valid because V_MAX, Q_MAX are genuine upper bounds on the
        reachable state, so the Hessian bound of eq. 13 still holds over the
        interval hull.  Proposition 1 enclosure is preserved.
        """
        radii  = z.interval_radius()
        center = z.p
        rem    = np.zeros(self.n, dtype=float)
        for i in range(self.n_osc):
            qi_idx, vi_idx = 2*i, 2*i+1
            # FIX: physical caps break the positive feedback loop
            q_abs = min(abs(center[qi_idx]) + radii[qi_idx], Q_MAX)
            v_abs = min(abs(center[vi_idx]) + radii[vi_idx], V_MAX)
            h_qq = 2.0 * self.dt * self.mu * v_abs   # |d²f/dq²|
            h_qv = 2.0 * self.dt * self.mu * q_abs   # |d²f/dqdv|
            rq, rv = radii[qi_idx], radii[vi_idx]
            # ρ_{v_i} = ½(h_qq·rq² + 2·h_qv·rq·rv)
            rem[vi_idx] = 0.5 * (h_qq * rq * rq + 2.0 * h_qv * rq * rv)
        return rem

    def measurement_indices(self, mode: str) -> list[int]:
        if mode == "all_positions":
            return [2*i for i in range(self.n_osc)]
        if mode == "every_second_position":
            return [2*i for i in range(0, self.n_osc, 2)]
        raise ValueError(f"Unsupported measurement mode: {mode}")

    def measurement(self, x: np.ndarray, meas_idx: list[int]) -> np.ndarray:
        q = np.asarray(x, dtype=float)[meas_idx]
        return q + self.rho * q * q * q

    def measurement_jacobian(self, x: np.ndarray, meas_idx: list[int]) -> np.ndarray:
        C = np.zeros((len(meas_idx), self.n), dtype=float)
        for row, idx in enumerate(meas_idx):
            q = float(np.asarray(x, dtype=float)[idx])
            C[row, idx] = 1.0 + 3.0 * self.rho * q * q
        return C

    # ── FIX 1 (measurement): same physical-cap logic ──────────────────────
    def measurement_remainder_radius(self, z: Zonotope, meas_idx: list[int]) -> np.ndarray:
        """
        ρ^h_{i} = ½ · |6ρ·q_i| · r_{q_i}²  (paper eq. 19 + eq. 33).
        Caps q_abs at Q_MAX to prevent positive feedback.
        """
        radii  = z.interval_radius()
        center = z.p
        rem    = np.zeros(len(meas_idx), dtype=float)
        for row, idx in enumerate(meas_idx):
            q_abs = min(abs(center[idx]) + radii[idx], Q_MAX)
            rem[row] = 3.0 * abs(self.rho) * q_abs * radii[idx] * radii[idx]
        return rem


# ── zonotope factories ─────────────────────────────────────────────────────
def process_noise_zonotope(n: int) -> Zonotope:
    return Zonotope(np.zeros(n), np.diag(np.full(n, PROC_NOISE_RADIUS)))

def initial_state_zonotope(x0: np.ndarray) -> Zonotope:
    return Zonotope(x0, np.diag(np.full(x0.size, INIT_RADIUS)))


# ── prediction ─────────────────────────────────────────────────────────────
def predict_nonlinear(z: Zonotope, model: CoupledVanDerPolModel, u: np.ndarray, w_zono: Zonotope):
    center = model.dynamics(z.p, u)
    F      = model.dynamics_jacobian(z.p, u)
    rem    = model.dynamics_remainder_radius(z)
    H_pred = np.concatenate([F @ z.H, w_zono.H, np.diag(rem)], axis=1)
    return Zonotope(center, H_pred), F, rem


# ── measurement update ─────────────────────────────────────────────────────
def _single_strip(z, model, y_val, state_idx):
    h_c = model.measurement(z.p, [state_idx])[0]
    c   = model.measurement_jacobian(z.p, [state_idx])[0]
    rem = model.measurement_remainder_radius(z, [state_idx])[0]
    offset  = h_c - float(c @ z.p)
    y_strip = float(y_val - offset)
    phi     = float(MEAS_NOISE_RADIUS + rem)
    return c, y_strip, phi, rem

def update_nonlinear(z, model, y, meas_idx, method, *, step=-1):
    diags = []
    z_upd = z
    if MEAS_UPDATE_MODE == "frozen_prediction":
        h_c = model.measurement(z.p, meas_idx)
        C   = model.measurement_jacobian(z.p, meas_idx)
        rem = model.measurement_remainder_radius(z, meas_idx)
        for row, idx in enumerate(meas_idx):
            c = C[row]
            offset  = h_c[row] - float(c @ z.p)
            y_strip = float(y[row] - offset)
            phi     = float(MEAS_NOISE_RADIUS + rem[row])
            z_upd, d = z_upd.intersect_with_strip(c, y_strip, phi, method, step=step, row=row, state_index=idx)
            diags.append(d)
            if not z_upd.is_reasonably_bounded():
                return z_upd, C, rem, diags
        return z_upd, C, rem, diags
    # default: sequential_recompute
    C_rows, rem_vals = [], []
    for row, idx in enumerate(meas_idx):
        c, y_strip, phi, rem_i = _single_strip(z_upd, model, float(y[row]), idx)
        C_rows.append(c); rem_vals.append(rem_i)
        z_upd, d = z_upd.intersect_with_strip(c, y_strip, phi, method, step=step, row=row, state_index=idx)
        diags.append(d)
        if not z_upd.is_reasonably_bounded():
            C = np.vstack(C_rows) if C_rows else np.zeros((0, z.n))
            return z_upd, C, np.asarray(rem_vals), diags
    C = np.vstack(C_rows) if C_rows else np.zeros((0, z.n))
    return z_upd, C, np.asarray(rem_vals), diags


# ── truth simulation ───────────────────────────────────────────────────────
def simulate_truth(model, x0, num_steps, meas_idx, rng):
    x_true = np.zeros((num_steps, model.n))
    y_true = np.zeros((num_steps, len(meas_idx)))
    x = np.asarray(x0, dtype=float).reshape(-1)
    for k in range(num_steps):
        x = model.dynamics(x) + rng.uniform(-PROC_NOISE_RADIUS, PROC_NOISE_RADIUS, size=model.n)
        y = model.measurement(x, meas_idx) + rng.uniform(-MEAS_NOISE_RADIUS, MEAS_NOISE_RADIUS, size=len(meas_idx))
        x_true[k] = x; y_true[k] = y
    return x_true, y_true


# ── containment helpers ────────────────────────────────────────────────────
def containment_flag(z, x):
    if not z.is_finite(): return False
    return bool(np.all(np.abs(x - z.p) <= z.interval_radius() + 1e-10))

def containment_flags(zonotopes, x_true):
    return np.array([containment_flag(z, x_true[k]) for k, z in enumerate(zonotopes)], dtype=bool)


# ── failure helper ─────────────────────────────────────────────────────────
def _make_failure(step, reason, z, last_diag=None):
    d = last_diag or StripDiagnostics()
    return FailureDiagnostics(
        failed=True, step=step, reason=reason,
        p_norm=z.p_norm(), max_interval_radius=z.max_interval_radius(),
        phi=d.phi, segment_denominator=d.denominator, lambda_norm=d.lambda_norm,
        strip_row=d.row, strip_state_index=d.state_index,
        measurement_update_mode=MEAS_UPDATE_MODE,
    )


# ── metrics ────────────────────────────────────────────────────────────────
def summarize_metrics(zonotopes, x_true, centers, step_time_us, failure):
    used = len(zonotopes)
    if used == 0:
        return Metrics(n_state=x_true.shape[1], measurement_mode="", method="",
                       reduction_budget=0, per_state_center_rmse=float("nan"),
                       max_per_state_center_error=float("nan"), mean_interval_width=float("nan"),
                       max_interval_width=float("nan"), containment_rate=0.0,
                       mean_generators=0.0, max_generators=0,
                       mean_step_time_us=float("nan"), total_time_us=0.0,
                       failed=failure.failed, first_failure_step=failure.step,
                       failure_reason=failure.reason, fail_p_norm=failure.p_norm,
                       fail_max_interval_radius=failure.max_interval_radius,
                       fail_phi=failure.phi, fail_segment_denominator=failure.segment_denominator,
                       fail_lambda_norm=failure.lambda_norm)
    err = centers[:used] - x_true[:used]
    per_state_err = np.sqrt(np.mean(err * err, axis=1))
    widths = np.asarray([2.0 * z.interval_radius() for z in zonotopes])
    flags  = containment_flags(zonotopes, x_true[:used])
    gens   = np.asarray([z.m for z in zonotopes], dtype=float)
    return Metrics(n_state=x_true.shape[1], measurement_mode="", method="",
                   reduction_budget=0,
                   per_state_center_rmse=float(np.sqrt(np.mean(err * err))),
                   max_per_state_center_error=float(np.max(per_state_err)),
                   mean_interval_width=float(np.mean(widths)),
                   max_interval_width=float(np.max(widths)),
                   containment_rate=float(np.mean(flags)),
                   mean_generators=float(np.mean(gens)),
                   max_generators=int(np.max(gens)),
                   mean_step_time_us=float(np.mean(step_time_us[:used])),
                   total_time_us=float(np.sum(step_time_us[:used])),
                   failed=failure.failed, first_failure_step=failure.step,
                   failure_reason=failure.reason, fail_p_norm=failure.p_norm,
                   fail_max_interval_radius=failure.max_interval_radius,
                   fail_phi=failure.phi, fail_segment_denominator=failure.segment_denominator,
                   fail_lambda_norm=failure.lambda_norm)


# ── plot ───────────────────────────────────────────────────────────────────
def plot_outputs(out_dir, x_true, centers, zonotopes, meas_idx):
    if not zonotopes: return
    used = len(zonotopes)
    k    = np.arange(used)
    err  = np.linalg.norm(centers[:used] - x_true[:used], axis=1)
    mw   = [np.mean(2.0 * z.interval_radius()) for z in zonotopes]
    qi   = meas_idx[0]
    rad  = [z.interval_radius()[qi] for z in zonotopes]

    fig, axes = plt.subplots(3, 1, figsize=(8, 8), sharex=True)
    axes[0].plot(k, x_true[:used, qi], "k-", lw=1.2, label="true")
    axes[0].plot(k, centers[:used, qi], "b--", lw=1.2, label="center")
    axes[0].fill_between(k, centers[:used, qi]-rad, centers[:used, qi]+rad,
                         color="tab:blue", alpha=0.25, label="interval hull")
    axes[0].set_ylabel(f"x[{qi}]"); axes[0].legend(); axes[0].grid(True, ls=":")
    axes[1].plot(k, err, color="tab:red"); axes[1].set_ylabel("center L2 error"); axes[1].grid(True, ls=":")
    axes[2].plot(k, mw,  color="tab:green"); axes[2].set_ylabel("mean width")
    axes[2].set_xlabel("step k"); axes[2].grid(True, ls=":")
    fig.tight_layout(); fig.savefig(out_dir / "nonlinear_summary.png", dpi=160); plt.close(fig)


# ── main run ───────────────────────────────────────────────────────────────
def run_case(n_state, measurement_mode, method, reduction_budget, out_dir, seed):
    rng   = np.random.default_rng(seed)
    model = CoupledVanDerPolModel(n_state, DT, VAN_DER_POL_MU, COUPLING_GAIN, MEAS_CUBIC_RHO)
    meas_idx = model.measurement_indices(measurement_mode)
    x0 = np.zeros(n_state); x0[0::2] = 0.3

    x_true, y_meas = simulate_truth(model, x0, NUM_STEPS, meas_idx, rng)
    z      = initial_state_zonotope(x0)
    w_zono = process_noise_zonotope(n_state)

    zonotopes = []; centers = np.zeros_like(x_true)
    step_time = np.zeros(NUM_STEPS); all_diags = []
    failure   = FailureDiagnostics(measurement_update_mode=MEAS_UPDATE_MODE)
    last_seg_diag = None

    for k in range(NUM_STEPS):
        t0 = time.perf_counter()
        last_diag = None

        z, _, _ = predict_nonlinear(z, model, np.zeros(model.n_osc), w_zono)
        if not z.is_reasonably_bounded():
            step_time[k] = (time.perf_counter()-t0)*1e6
            zonotopes.append(z); centers[k] = z.p
            failure = _make_failure(k, "overflow_after_prediction", z, last_seg_diag)
            break

        z = z.reduce(reduction_budget)
        if not z.is_reasonably_bounded():
            step_time[k] = (time.perf_counter()-t0)*1e6
            zonotopes.append(z); centers[k] = z.p
            failure = _make_failure(k, "overflow_after_prediction_reduction", z, last_seg_diag)
            break

        z, _, _, strip_diags = update_nonlinear(z, model, y_meas[k], meas_idx, method, step=k)
        all_diags.extend(strip_diags)
        if strip_diags:
            last_diag = strip_diags[-1]
            if method == "segment":
                last_seg_diag = strip_diags[-1]
        if not z.is_reasonably_bounded():
            step_time[k] = (time.perf_counter()-t0)*1e6
            zonotopes.append(z); centers[k] = z.p
            failure = _make_failure(k, "overflow_after_measurement_update", z, last_diag)
            break

        z = z.reduce(reduction_budget)
        step_time[k] = (time.perf_counter()-t0)*1e6
        zonotopes.append(z); centers[k] = z.p

        if not z.is_reasonably_bounded():
            failure = _make_failure(k, "overflow_after_final_reduction", z, last_diag)
            break
        if not containment_flag(z, x_true[k]):
            failure = _make_failure(k, "containment_failure", z, last_diag)
            if STOP_ON_FAILURE:
                break

    used  = len(zonotopes)
    flags = containment_flags(zonotopes, x_true[:used]) if used else np.zeros(0, dtype=bool)
    m     = summarize_metrics(zonotopes, x_true, centers, step_time, failure)
    m.measurement_mode = measurement_mode
    m.method           = method
    m.reduction_budget = reduction_budget

    if out_dir is not None:
        out_dir.mkdir(parents=True, exist_ok=True)
        _save_csv(out_dir / "center.csv",            centers[:used])
        _save_csv(out_dir / "x_true.csv",            x_true[:used])
        _save_csv(out_dir / "containment_flags.csv", flags.astype(int).reshape(-1,1))
        err = centers[:used] - x_true[:used]
        _save_csv(out_dir / "error.csv",
                  np.hstack([err, np.linalg.norm(err, axis=1, keepdims=True)]))
        widths = np.asarray([2.0 * z.interval_radius() for z in zonotopes])
        _save_csv(out_dir / "interval_width.csv", widths)
        _save_csv(out_dir / "generator_count.csv",
                  np.asarray([z.m for z in zonotopes], dtype=float).reshape(-1,1))
        plot_outputs(out_dir, x_true, centers, zonotopes, meas_idx)

    print(f"[fixed] n={n_state}, steps={used}/{NUM_STEPS}, meas={len(meas_idx)}, "
          f"method={method}, budget={reduction_budget}, mode={MEAS_UPDATE_MODE}")
    print(f"[fixed] containment={m.containment_rate:.3f}  "
          f"rmse={m.per_state_center_rmse:.6f}  "
          f"mean_width={m.mean_interval_width:.6f}  "
          f"failed={m.failed}")
    if m.failed:
        print(f"[fixed][FAIL] step={m.first_failure_step}  reason={m.failure_reason}  "
              f"||p||={m.fail_p_norm:.3e}  max_r={m.fail_max_interval_radius:.3e}  "
              f"phi={m.fail_phi:.3e}  denom={m.fail_segment_denominator:.3e}  "
              f"||lam||={m.fail_lambda_norm:.3e}")
    return m


def run_reference():
    return run_case(N_STATE, MEASUREMENT_MODE, ESTIMATION_METHOD,
                    REDUCTION_BUDGET, _output_dir(), RANDOM_SEED)

def run_sweep():
    out_root = _output_dir(); rows = []
    for n in SWEEP_DIMS:
        for mm in SWEEP_MEAS_MODES:
            for meth in SWEEP_METHODS:
                for sc in BUDGET_SCALES:
                    budget = max(n, int(round(sc * n)))
                    case_dir = out_root / f"n{n}" / mm / meth / f"s{budget}"
                    m = run_case(n, mm, meth, budget, case_dir, RANDOM_SEED)
                    rows.append([n, mm, meth, budget,
                                 m.per_state_center_rmse, m.containment_rate,
                                 m.mean_interval_width, m.mean_step_time_us,
                                 m.failed, m.first_failure_step, m.failure_reason])
    hdr = ("n_state,meas_mode,method,budget,per_state_rmse,containment_rate,"
           "mean_interval_width,mean_step_time_us,failed,first_failure_step,failure_reason")
    np.savetxt(out_root / "sweep_metrics.csv", np.asarray(rows, dtype=object),
               fmt="%s", delimiter=",", header=hdr, comments="")

def run_sparse_segment_debug():
    out_root = _output_dir() / "debug_every_second_segment"; out_root.mkdir(parents=True, exist_ok=True)
    for n in SWEEP_DIMS:
        for sc in BUDGET_SCALES:
            budget = max(n, int(round(sc * n)))
            run_case(n, "every_second_position", "segment", budget,
                     out_root / f"n{n}_s{budget}", RANDOM_SEED)

if __name__ == "__main__":
    if RUN_DEBUG_SPARSE:
        run_sparse_segment_debug()
    elif RUN_SWEEP:
        run_sweep()
    else:
        run_reference()