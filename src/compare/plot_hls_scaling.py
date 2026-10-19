#!/usr/bin/env python3
"""Plot state, measurement and generator-budget scaling from HLS CSV reports."""

import argparse
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


def draw(rows, output):
    methods = ("fixed_gain", "segment", "volume")
    metrics = (("lut", "LUT"), ("ff", "FF"), ("dsp", "DSP"),
               ("worst_latency_cycles", "Worst-case latency (cycles)"))
    scenarios = (
        ("state", "n_state", lambda r: r["n_meas"] == r["n_state"] // 2 and
         r["reduction_budget"] == r["n_state"] + 8, "State dimension"),
        ("measurement", "n_meas", lambda r: r["n_state"] == 24 and
         r["reduction_budget"] == 32, "Measurement dimension (N_STATE=24)"),
        ("budget", "reduction_budget", lambda r: r["n_state"] == 24 and
         r["n_meas"] == 12, "Generator budget (24 states, 12 measurements)"),
    )
    for name, x_field, include, x_label in scenarios:
        fig, axes = plt.subplots(2, 2, figsize=(10, 7))
        for ax, (metric, y_label) in zip(axes.flat, metrics):
            for method in methods:
                subset = sorted((r for r in rows if r["method"] == method and include(r)),
                                key=lambda r: r[x_field])
                if subset:
                    ax.plot([r[x_field] for r in subset], [r[metric] for r in subset],
                            marker="o", label=method)
            ax.set(xlabel=x_label, ylabel=y_label)
            ax.grid(alpha=0.3)
        handles, labels = axes[0, 0].get_legend_handles_labels()
        if handles:
            fig.legend(handles, labels, loc="upper center", bbox_to_anchor=(0.5, 0.95), ncol=3)
        fig.suptitle("Vitis HLS estimates (batch kernel, 200-step upper bound)", y=0.995)
        fig.tight_layout(rect=(0, 0, 1, 0.90))
        fig.savefig(output / f"{name}_scaling.png", dpi=160)
        plt.close(fig)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--summary", type=Path, default=Path("data/output/hls/scaling/summary.csv"))
    parser.add_argument("--output", type=Path, default=Path("results/hls_scaling"))
    args = parser.parse_args()
    with args.summary.open(newline="") as handle:
        rows = [dict(row, **{key: int(row[key]) for key in
                           ("n_state", "n_meas", "reduction_budget", "lut", "ff", "dsp", "worst_latency_cycles")})
                for row in csv.DictReader(handle) if row["status"] == "synthesized" and
                row["worst_latency_cycles"].isdigit()]
    if not rows:
        parser.error("no completed, numeric synthesis rows found")
    args.output.mkdir(parents=True, exist_ok=True)
    draw(rows, args.output)
    print(f"Plotted {len(rows)} completed configurations in {args.output}")


if __name__ == "__main__":
    main()
