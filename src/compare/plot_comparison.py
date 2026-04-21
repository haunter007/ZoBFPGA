#!/usr/bin/env python3
"""
四版本对比脚本：Python / C++ / HLS cosim / SoC Board
Four-way comparison: Python / C++ / HLS cosim / SoC Board (Kria KR260)

用法 / Usage:
    python3 src/compare/plot_comparison.py

输出 / Output:
    data/output/comparison/<METHOD>/trajectory.png   (Python/C++/HLS 三者轨迹)
    data/output/comparison/<METHOD>/error.png        (Python/C++/HLS 三者误差)
    data/output/comparison/timing/timing_bar.png     (四者总耗时柱状图)
    data/output/comparison/timing/timing_table.png   (四者总耗时数值表格)
    data/output/comparison/timing/timing_table.csv   (四者总耗时数值 CSV)
    data/output/comparison/timing/timing_table.txt   (四者总耗时数值纯文本)
"""

from pathlib import Path
import numpy as np
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import shutil
import csv

# =============================================================================
# 配置 / Configuration
# =============================================================================

# 当前只比较 segment 方法
# Compare only the segment method for Python / C++ / HLS.
COMPARE_METHODS = ["LAMBDA_SEGMENT"]

# 轨迹/误差优先用 step 口径的 HLS 结果
# Prefer step-kernel HLS outputs for trajectory/error plots
HLS_PLOT_MODES = ["csim", "cosim"]

# timing_table 优先用 batch 口径；若没有 batch，再回退到 step/cosim
# Prefer batch-kernel timing for timing_table, then fall back to step/cosim
HLS_TIMING_MODES = ["csim_batch", "cosim_batch", "csim", "cosim"]

# 旧板测结果通常不是当前规模，默认先不混入 timing_table
# Old board data is often from a different problem size, so exclude it by default
INCLUDE_BOARD = True

# 四个版本的标签和颜色
# Labels and colors for all four implementations
IMPL_LABEL  = {"python": "Python",   "cpp": "C++",     "hls": "HLS Sim", "board": "SoC Board"}
IMPL_COLOR  = {"python": "tab:blue", "cpp": "tab:green","hls": "tab:orange","board": "tab:red"}
IMPL_LS     = {"python": "--",       "cpp": "-.",       "hls": "-",         "board": ":"}

# =============================================================================
# 路径工具 / Path helpers
# =============================================================================

def _repo_root() -> Path:
    return Path(__file__).resolve().parents[2]

def _find_hls_dir(method: str) -> Path | None:
    """查找 HLS 输出目录（轨迹/误差，step 优先）"""
    base = _repo_root() / "data" / "output" / "hls"
    for mode in HLS_PLOT_MODES:
        p = base / mode / method
        if p.exists():
            return p
    return None

def _find_hls_timing_dir(method: str) -> Path | None:
    """查找 HLS timing 目录（batch 优先）"""
    base = _repo_root() / "data" / "output" / "hls"
    for mode in HLS_TIMING_MODES:
        p = base / mode / method
        if p.exists():
            return p
    return None

def _find_board_dir(method: str) -> Path | None:
    """查找 Kria 板载实测数据目录 // Find Kria board measurement data dir"""
    if not INCLUDE_BOARD:
        return None
    p = _repo_root() / "data" / "output" / "hls" / "fpga_board" / method
    return p if p.exists() else None

def _load_csv(path: Path) -> np.ndarray | None:
    """读取 CSV，返回 2D ndarray，文件不存在返回 None
       Load CSV as 2D ndarray, return None if missing"""
    if not path.exists():
        return None
    try:
        a = np.loadtxt(path, delimiter=",")
        if a.ndim == 1:
            a = a.reshape(1, -1)
        return a
    except Exception:
        return None

def _get_dirs(method: str) -> dict:
    """返回四个版本对应 method 的数据目录
       Return data dirs for all four impls for the given method"""
    root = _repo_root() / "data" / "output"
    return {
        "python": root / "python" / method,
        "cpp":    root / "cpp"    / method,
        "hls":    _find_hls_dir(method),
        "hls_timing": _find_hls_timing_dir(method),
        "board":  _find_board_dir(method),
    }

# =============================================================================
# 每方法的对比图 / Per-method comparison plots
# =============================================================================

def plot_trajectory(method: str, out_dir: Path):
    """轨迹对比图（x[0] vs x[1]）// Trajectory comparison (x[0] vs x[1])"""
    dirs = _get_dirs(method)
    plot_impls = ["python", "cpp", "hls", "board"]

    fig, ax = plt.subplots(figsize=(7, 7))

    # 画各版本 center 轨迹 // Draw center trajectory for each impl
    for impl in plot_impls:
        d = dirs[impl]
        if d is None or not d.exists():
            continue
        center = _load_csv(d / "center.csv")
        if center is None or center.shape[1] < 2:
            continue
        ax.plot(center[:, 0], center[:, 1],
                color=IMPL_COLOR[impl], linestyle=IMPL_LS[impl],
                linewidth=1.5, label=f"{IMPL_LABEL[impl]} center", marker="o",
                markersize=2, alpha=0.85)

    # 真实轨迹只需画一次（取第一个可用的）// True state once (from first available source)
    for impl in plot_impls:
        d = dirs[impl]
        if d is None or not d.exists():
            continue
        x_true = _load_csv(d / "x_true.csv")
        if x_true is not None and x_true.shape[1] >= 2:
            ax.plot(x_true[:, 0], x_true[:, 1],
                    "k-", linewidth=2, label="True state", alpha=0.7)
            break

    ax.set_aspect("equal")
    ax.set_xlabel("x[0]")
    ax.set_ylabel("x[1]")
    ax.set_title(f"{method}: Trajectory Comparison (Python / C++ / HLS)")
    ax.grid(True, linestyle=":", alpha=0.5)
    ax.legend(loc="best", fontsize="small")
    fig.tight_layout()
    fig.savefig(out_dir / "trajectory.png", dpi=160)
    plt.close(fig)


def plot_error(method: str, out_dir: Path):
    """误差曲线对比图 // Error norm comparison"""
    dirs = _get_dirs(method)
    plot_impls = ["python", "cpp", "hls", "board"]

    fig, ax = plt.subplots(figsize=(8, 4))

    for impl in plot_impls:
        d = dirs[impl]
        if d is None or not d.exists():
            continue
        err = _load_csv(d / "error.csv")
        if err is None:
            continue
        # 最后一列是 L2 误差 // Last column is L2 error
        l2 = err[:, -1] if err.shape[1] >= 2 else np.linalg.norm(err, axis=1)
        steps = np.arange(len(l2))
        ax.plot(steps, l2,
                color=IMPL_COLOR[impl], linestyle=IMPL_LS[impl],
                linewidth=1.5, label=IMPL_LABEL[impl])

    ax.set_xlabel("Step k")
    ax.set_ylabel("L2 Error (center vs true)")
    ax.set_title(f"{method}: Estimation Error Comparison")
    ax.grid(True, linestyle=":", alpha=0.5)
    ax.legend(loc="best", fontsize="small")
    fig.tight_layout()
    fig.savefig(out_dir / "error.png", dpi=160)
    plt.close(fig)

# =============================================================================
# 计时对比 / Timing comparison
# =============================================================================

def _load_timing_info(d: Path, impl: str = "") -> tuple[float | None, int | None]:
    """从各版本数据目录读整批总耗时（µs）和步数
       Read total batch/runtime time (µs) and step count.

    格式差异 / Format differences:
      Python/C++: kernel_time_summary_us.csv [total, avg, count]
      HLS top sim: kernel_time_summary_us.csv [9 cols]             → count at index 3
      Board:      timing.npy  单位秒 / unit seconds → mean × 1e6 → µs
    """
    if d is None or not d.exists():
        return None, None

    # Board：读 timing.npy，单位秒，转换为 µs
    # Board: read timing.npy (seconds), convert to µs
    if impl == "board":
        count = None
        summary = d / "summary.txt"
        if summary.exists():
            try:
                for line in summary.read_text(encoding="utf-8").splitlines():
                    if line.startswith("steps:") or line.startswith("n_steps:"):
                        count = int(line.split(":", 1)[1].strip())
                        break
            except Exception:
                count = None
        npy = d / "timing.npy"
        if npy.exists():
            t = np.load(npy)
            if t.size > 0:
                return float(np.mean(t) * 1e6), count
        return None, None

    # CSV 路径 // CSV path
    s = _load_csv(d / "kernel_time_summary_us.csv")
    if s is not None:
        flat = s.flatten()
        if flat.size == 9:
            return float(flat[0]), int(flat[3])
        if flat.size >= 3:
            return float(flat[0]), int(flat[2])
        if flat.size >= 1:
            return float(flat[0]), None
    # fallback：从逐步文件第0列求和 // fallback: sum of col-0 (timing) from per-step file
    t = _load_csv(d / "kernel_time_step_us.csv")
    if t is not None and t.size > 0:
        return float(np.sum(t[:, 0])), int(t.shape[0])
    return None, None


def plot_timing(out_dir: Path):
    """分组柱状图 + 数值表格（四版本）// Grouped bar chart + numeric table (4 impls)"""
    methods = COMPARE_METHODS
    impls = ["python", "cpp", "hls"]
    if INCLUDE_BOARD:
        impls.append("board")

    # 收集数据 // Collect timing data
    times: dict[str, dict[str, float | None]] = {m: {} for m in methods}
    counts: dict[str, dict[str, int | None]] = {m: {} for m in methods}
    for method in methods:
        dirs = _get_dirs(method)
        for impl in impls:
            time_dir = dirs["hls_timing"] if impl == "hls" else dirs[impl]
            total_us, count = _load_timing_info(time_dir, impl)
            times[method][impl] = total_us
            counts[method][impl] = count

    comparable_impls: dict[str, set[str]] = {}
    for method in methods:
        valid_counts = [c for c in counts[method].values() if c is not None]
        if not valid_counts:
            comparable_impls[method] = set(impls)
            continue
        common_count = max(set(valid_counts), key=valid_counts.count)
        comparable_impls[method] = {
            impl for impl in impls
            if counts[method].get(impl) is None or counts[method].get(impl) == common_count
        }

    # ── 1. 分组柱状图 // Grouped bar chart ──────────────────────────────────
    x = np.arange(len(methods))
    n  = len(impls)
    width = 0.18
    offsets = np.linspace(-(n - 1) / 2, (n - 1) / 2, n) * width

    fig, ax = plt.subplots(figsize=(11, 5))
    for i, impl in enumerate(impls):
        vals = [
            (times[m][impl] / 1000.0) if (times[m][impl] is not None and impl in comparable_impls[m]) else None
            for m in methods
        ]
        vals_plot = [v if v is not None else 0 for v in vals]
        bars = ax.bar(x + offsets[i], vals_plot, width,
                      label=IMPL_LABEL[impl], color=IMPL_COLOR[impl], alpha=0.85)
        # 标注数值 // Annotate values
        for bar, v in zip(bars, vals):
            if v is not None and v > 0:
                ax.text(bar.get_x() + bar.get_width() / 2,
                        bar.get_height() * 1.05,
                        f"{v:.1f}", ha="center", va="bottom", fontsize=7)

    ax.set_yscale("log")   # log 刻度（量级差异大）// log scale
    ax.set_xticks(x)
    ax.set_xticklabels([m.replace("LAMBDA_", "") for m in methods])
    ax.set_xlabel("Method")
    ax.set_ylabel("Total runtime (ms)  [log scale]")
    title = "Total Runtime: Python vs C++ vs HLS Sim"
    subtitle = "Only implementations with matching step counts are compared; HLS = batch csim if available"
    if INCLUDE_BOARD:
        title += " vs SoC Board"
        subtitle += "; Board = Kria KR260 measured"
    ax.set_title(title + "\n" + subtitle)
    ax.legend()
    ax.grid(True, axis="y", linestyle=":", alpha=0.5)
    fig.tight_layout()
    fig.savefig(out_dir / "timing_bar.png", dpi=160)
    plt.close(fig)

    # ── 2. 数值表格图 // Numeric table figure ────────────────────────────────
    col_labels = ["Method", "Steps"] + [IMPL_LABEL[i] for i in impls]
    if INCLUDE_BOARD:
        col_labels += ["Python/Board ×", "C++/Board ×", "HLS/Board ×"]
    rows = []
    for method in methods:
        t_py    = times[method]["python"]
        t_cpp   = times[method]["cpp"]
        t_hls   = times[method]["hls"]
        t_board = times[method].get("board")
        cands = [c for c in counts[method].values() if c is not None]
        common_count = max(set(cands), key=cands.count) if cands else None

        def fmt(v, impl):
            if v is None:
                return "N/A"
            if impl not in comparable_impls[method]:
                mismatch = counts[method].get(impl)
                return f"N/A ({mismatch})"
            return f"{v / 1000.0:.3f}"
        def ratio(a, b): return f"{a/b:.1f}×" if (a is not None and b is not None and b > 0) else "N/A"

        row = [
            method.replace("LAMBDA_", ""),
            str(common_count) if common_count is not None else "N/A",
            fmt(t_py, "python"), fmt(t_cpp, "cpp"), fmt(t_hls, "hls"),
        ]
        if INCLUDE_BOARD:
            row += [
                fmt(t_board, "board"),
                ratio(t_py, t_board), ratio(t_cpp, t_board), ratio(t_hls, t_board),
            ]
        rows.append(row)

    fig_w = 13 if INCLUDE_BOARD else 9
    fig2, ax2 = plt.subplots(figsize=(fig_w, 2 + 0.6 * len(rows)))
    ax2.axis("off")
    tbl = ax2.table(
        cellText=rows,
        colLabels=col_labels,
        loc="center",
        cellLoc="center",
    )
    tbl.auto_set_font_size(False)
    tbl.set_fontsize(9.5)
    tbl.scale(1.2, 1.7)

    # 表头加色 // Color header
    for j in range(len(col_labels)):
        tbl[0, j].set_facecolor("#404040")
        tbl[0, j].set_text_props(color="white", fontweight="bold")

    if INCLUDE_BOARD:
        table_title = ("Total Runtime Summary (ms)  —  Speedup relative to SoC Board\n"
                       "HLS = batch testbench if available, else summed step testbench; Board = Kria KR260 measured; "
                       "Python/C++ = host CPU wall-clock")
    else:
        table_title = ("Total Runtime Summary (ms)\n"
                       "Only rows with matching step counts are compared; mismatched counts are marked N/A (<count>)")
    ax2.set_title(table_title, pad=12, fontsize=9.5)
    fig2.tight_layout()
    fig2.savefig(out_dir / "timing_table.png", dpi=160)
    plt.close(fig2)

    with open(out_dir / "timing_table.csv", "w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(col_labels)
        writer.writerows(rows)

    with open(out_dir / "timing_table.txt", "w", encoding="utf-8") as f:
        header = f"{'Method':<12}" + "".join(f"  {IMPL_LABEL[i]:>12}" for i in impls)
        f.write("Timing data (total ms)\n")
        f.write(header + "\n")
        for row in rows:
            f.write("  " + " | ".join(row) + "\n")

    print("Timing data (total ms):")
    header = f"  {'Method':<12}" + "".join(f"  {IMPL_LABEL[i]:>12}" for i in impls)
    print(header)
    for method, row in zip(methods, rows):
        print("  " + " | ".join(row))

# =============================================================================
# 主入口 / Main
# =============================================================================

def main():
    out_root = _repo_root() / "data" / "output" / "comparison"
    if out_root.exists():
        shutil.rmtree(out_root)
    out_root.mkdir(parents=True)

    # 每方法的轨迹 + 误差图 // Per-method trajectory + error plots
    for method in COMPARE_METHODS:
        method_out = out_root / method
        method_out.mkdir(parents=True, exist_ok=True)
        plot_trajectory(method, method_out)
        plot_error(method, method_out)
        print(f"[{method}] trajectory.png + error.png -> {method_out}")

    # 计时对比 // Timing comparison
    timing_out = out_root / "timing"
    timing_out.mkdir(parents=True, exist_ok=True)
    plot_timing(timing_out)
    print(f"[timing] timing_bar.png + timing_table.png + timing_table.csv/txt -> {timing_out}")

    print(f"\n完成。所有对比图在: {out_root}")


if __name__ == "__main__":
    main()
