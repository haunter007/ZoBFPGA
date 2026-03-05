#!/usr/bin/env python3
import argparse
import math
from pathlib import Path

import numpy as np

import matplotlib

matplotlib.use("Agg")
import matplotlib.pyplot as plt


def _as_2d(a: np.ndarray) -> np.ndarray:
    if a.size == 0:
        return a.reshape(0, 0)
    if a.ndim == 1:
        return a.reshape(1, -1)
    return a


def _load_numeric_csv(path: Path) -> np.ndarray:
    if not path.exists():
        return np.zeros((0, 0), dtype=float)
    a = np.loadtxt(path, delimiter=",")
    return _as_2d(np.asarray(a, dtype=float))


def load_zonotope_csv(path: Path) -> tuple[np.ndarray, np.ndarray]:
    p = None
    generators = []
    with path.open("r", encoding="utf-8") as f:
        for raw in f:
            line = raw.strip()
            if not line:
                continue
            parts = line.split(",")
            label = parts[0]
            if len(parts) == 1:
                continue
            data = [float(x) for x in parts[1:]]
            if label == "p":
                p = np.array(data, dtype=float)
            elif label == "H":
                generators.append(data)
    if p is None:
        raise ValueError(f"Missing center line 'p' in {path}")
    H = np.array(generators, dtype=float).T if generators else np.zeros((p.size, 0), dtype=float)
    return p, H


def convex_hull_2d(points: np.ndarray) -> np.ndarray:
    pts = np.unique(points, axis=0)
    if pts.shape[0] <= 1:
        return pts

    pts_list = [(float(x), float(y)) for x, y in pts]
    pts_list = sorted(set(pts_list))
    if len(pts_list) <= 1:
        return np.array(pts_list, dtype=float)

    def cross(o, a, b) -> float:
        return (a[0] - o[0]) * (b[1] - o[1]) - (a[1] - o[1]) * (b[0] - o[0])

    lower = []
    for p in pts_list:
        while len(lower) >= 2 and cross(lower[-2], lower[-1], p) <= 0.0:
            lower.pop()
        lower.append(p)

    upper = []
    for p in reversed(pts_list):
        while len(upper) >= 2 and cross(upper[-2], upper[-1], p) <= 0.0:
            upper.pop()
        upper.append(p)

    hull = lower[:-1] + upper[:-1]
    return np.array(hull, dtype=float)


def zonotope_vertices_2d(p: np.ndarray, H: np.ndarray, dims=(0, 1), n_dirs: int = 180) -> np.ndarray:
    if H.size == 0 or H.shape[1] == 0:
        return np.zeros((0, 2), dtype=float)

    p2 = p[list(dims)].reshape(2, 1)
    H2 = H[list(dims), :]  # 2 x m

    angles = np.linspace(0.0, 2.0 * math.pi, n_dirs, endpoint=False)
    dirs = np.vstack((np.cos(angles), np.sin(angles)))  # 2 x n_dirs

    proj = H2.T @ dirs  # m x n_dirs
    s = np.sign(proj)
    s[s == 0.0] = 1.0
    verts = (p2 + H2 @ s).T  # n_dirs x 2

    # Reduce near-duplicates due to floating noise.
    return np.unique(np.round(verts, 12), axis=0)


def plot_zonotope(ax, p: np.ndarray, H: np.ndarray, color: str, alpha: float, n_dirs: int = 180):
    verts = zonotope_vertices_2d(p, H, n_dirs=n_dirs)
    if verts.shape[0] == 0:
        ax.plot([p[0]], [p[1]], "o", color=color, markersize=2, alpha=alpha)
        return

    if verts.shape[0] == 1:
        ax.plot([verts[0, 0]], [verts[0, 1]], "o", color=color, markersize=2, alpha=alpha)
        return

    if verts.shape[0] == 2:
        ax.plot(verts[:, 0], verts[:, 1], "-", color=color, linewidth=1.0, alpha=min(1.0, alpha * 2.0))
        return

    hull = convex_hull_2d(verts)
    if hull.shape[0] >= 3:
        ax.fill(hull[:, 0], hull[:, 1], facecolor=color, edgecolor=color, alpha=alpha, linewidth=0.5)
    else:
        ax.plot(hull[:, 0], hull[:, 1], "-", color=color, linewidth=1.0, alpha=min(1.0, alpha * 2.0))


def plot_method(method_dir: Path, n_dirs: int = 180) -> list[Path]:
    plots_dir = method_dir / "plots"
    plots_dir.mkdir(parents=True, exist_ok=True)

    centers = _load_numeric_csv(method_dir / "center.csv")
    true_states = _load_numeric_csv(method_dir / "x_true.csv")
    meas = _load_numeric_csv(method_dir / "meas.csv")
    err = _load_numeric_csv(method_dir / "error.csv")
    ktime = _load_numeric_csv(method_dir / "kernel_time_step_us.csv")
    ksum = _load_numeric_csv(method_dir / "kernel_time_summary_us.csv")

    zonofiles = sorted(method_dir.glob("zonotope_*.csv"))

    out_paths: list[Path] = []

    # --- Trajectory + zonotopes ---
    fig, ax = plt.subplots(figsize=(7.0, 7.0))
    for zf in zonofiles:
        p, H = load_zonotope_csv(zf)
        plot_zonotope(ax, p, H, color="tab:blue", alpha=0.10, n_dirs=n_dirs)

    if centers.shape[0] > 0 and centers.shape[1] >= 2:
        ax.plot(centers[:, 0], centers[:, 1], "r-o", label="Estimated Center (FPGA sim)", markersize=3, linewidth=1)

    if true_states.shape[0] > 0 and true_states.shape[1] >= 2:
        ax.plot(true_states[:, 0], true_states[:, 1], "k-", linewidth=2, label="True State")

    if meas.shape[0] > 0 and meas.shape[1] >= 2:
        ax.scatter(meas[:, 0], meas[:, 1], s=18, marker="x", color="tab:orange", label="Observations")

    ax.set_aspect("equal")
    ax.set_xlabel("State x[0]")
    ax.set_ylabel("State x[1]")
    ax.set_title(f"{method_dir.name}: True / Obs / Zonotopes")
    ax.grid(True, linestyle=":", alpha=0.6)
    ax.legend(loc="best")
    fig.tight_layout()

    traj_png = plots_dir / "trajectory.png"
    fig.savefig(traj_png, dpi=160)
    plt.close(fig)
    out_paths.append(traj_png)

    # --- Error ---
    if err.shape[0] > 0:
        steps = np.arange(err.shape[0])
        fig, ax = plt.subplots(figsize=(7.5, 3.8))
        if err.shape[1] >= 5:
            ax.plot(steps, err[:, 4], "k-", linewidth=2, label="L2(center - true)")
        else:
            ax.plot(steps, np.linalg.norm(err, axis=1), "k-", linewidth=2, label="L2(center - true)")

        ax.set_xlabel("Step")
        ax.set_ylabel("Error")
        ax.set_title(f"{method_dir.name}: Error")
        ax.grid(True, linestyle=":", alpha=0.6)
        ax.legend(loc="best")
        fig.tight_layout()

        err_png = plots_dir / "error.png"
        fig.savefig(err_png, dpi=160)
        plt.close(fig)
        out_paths.append(err_png)

    # --- Kernel timing ---
    if ktime.shape[0] > 0 and ktime.shape[1] >= 3:
        steps = np.arange(ktime.shape[0])
        fig, ax = plt.subplots(figsize=(7.5, 3.8))
        ax.plot(steps, ktime[:, 0], label="predict_kernel (us)")
        ax.plot(steps, ktime[:, 1], label="strip_update total/step (us)")
        ax.plot(steps, ktime[:, 2], label="row_sum_abs_kernel (us)")

        title = f"{method_dir.name}: Kernel Time (per step)"
        if ksum.shape[0] > 0 and ksum.shape[1] >= 9:
            total_predict, total_strip, total_row = ksum[0, 0], ksum[0, 1], ksum[0, 2]
            avg_predict, avg_strip, avg_row = ksum[0, 6], ksum[0, 7], ksum[0, 8]
            title += f"\nTotal(us): pred={total_predict:.1f}, strip={total_strip:.1f}, row={total_row:.1f} | Avg(us): pred={avg_predict:.2f}, strip={avg_strip:.2f}, row={avg_row:.2f}"

        ax.set_xlabel("Step")
        ax.set_ylabel("Time (us)")
        ax.set_title(title)
        ax.grid(True, linestyle=":", alpha=0.6)
        ax.legend(loc="best")
        fig.tight_layout()

        kt_png = plots_dir / "kernel_time.png"
        fig.savefig(kt_png, dpi=160)
        plt.close(fig)
        out_paths.append(kt_png)

    return out_paths


def main() -> int:
    ap = argparse.ArgumentParser()
    ap.add_argument("--mode", default="csim", choices=["csim", "cosim"], help="FPGA simulation mode directory")
    ap.add_argument("--root", default=None, help="Override repo root (defaults to inferred repo root)")
    ap.add_argument("--n-dirs", type=int, default=180, help="Support-function directions for zonotope boundary")
    args = ap.parse_args()

    repo_root = Path(args.root).resolve() if args.root else Path(__file__).resolve().parents[2]
    base = repo_root / "data" / "output" / "fpga" / args.mode
    if not base.exists():
        print(f"ERROR: not found: {base}")
        print(f"Run: make {args.mode}")
        return 2

    methods = sorted([p for p in base.iterdir() if p.is_dir()])
    if not methods:
        print(f"ERROR: no method directories under: {base}")
        return 3

    all_out: list[Path] = []
    for method_dir in methods:
        out_paths = plot_method(method_dir, n_dirs=args.n_dirs)
        all_out.extend(out_paths)

    print(f"OK: generated {len(all_out)} plot files under: {base}")
    for p in all_out:
        print(str(p))
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
