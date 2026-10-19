#!/usr/bin/env python3
"""Plot paired software quality and HLS cost against generator budget."""

import argparse
import csv
from pathlib import Path

import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt


LABELS = {"Fixed-gain": "Fixed-gain", "LAMBDA_SEGMENT": "Segment", "LAMBDA_VOLUME": "Volume"}
HLS_LABELS = {"fixed_gain": "Fixed-gain", "segment": "Segment", "volume": "Volume"}


def read_csv(path):
    with path.open(newline="") as handle:
        return list(csv.DictReader(handle))


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--quality", type=Path, default=Path("results/generator_budgets/summary.csv"))
    parser.add_argument("--hls", type=Path, default=Path("results/hls_scaling/summary.csv"))
    parser.add_argument("--output", type=Path, default=Path("results/generator_budgets/tradeoff.png"))
    args = parser.parse_args()
    quality = read_csv(args.quality)
    hls = read_csv(args.hls) if args.hls.exists() else []
    fig, axes = plt.subplots(2, 3, figsize=(12, 7))
    panels = (
        (axes[0, 0], "center_l2", "Center error (L2)", quality, LABELS),
        (axes[0, 1], "width_mean", "Mean full interval width", quality, LABELS),
        (axes[0, 2], "containment_rate", "Tested containment rate", quality, LABELS),
        (axes[1, 0], "estimator_us_per_step", "Python host time (us/step)", quality, LABELS),
        (axes[1, 1], "lut", "HLS LUT estimate", hls, HLS_LABELS),
        (axes[1, 2], "worst_latency_cycles", "HLS 200-step worst-case cycles", hls, HLS_LABELS),
    )
    for ax, metric, title, source, labels in panels:
        for source_method, legend in labels.items():
            subset = []
            for row in source:
                if row["method"] != source_method:
                    continue
                if source is quality and row["metric"] != metric:
                    continue
                if source is hls and (row["status"] != "synthesized" or
                                      row["n_state"] != "24" or row["n_meas"] != "12"):
                    continue
                raw_value = row["mean"] if source is quality else row[metric]
                try:
                    value = float(raw_value)
                except ValueError:
                    continue
                deviation = float(row["std"]) if source is quality else 0.0
                subset.append((int(row["reduction_budget"]), value, deviation))
            subset.sort()
            if subset:
                ax.errorbar([point[0] for point in subset], [point[1] for point in subset],
                            yerr=[point[2] for point in subset], marker="o", capsize=2, label=legend)
        ax.set(xlabel="Generator budget", ylabel=title)
        ax.grid(alpha=0.3)
    handles, labels = axes[0, 0].get_legend_handles_labels()
    fig.legend(handles, labels, loc="upper center", bbox_to_anchor=(0.5, 0.95), ncol=3)
    fig.suptitle("24-state, 12-measurement oscillator: paired software seeds and HLS estimates", y=0.995)
    fig.tight_layout(rect=(0, 0, 1, 0.90))
    args.output.parent.mkdir(parents=True, exist_ok=True)
    fig.savefig(args.output, dpi=160)
    plt.close(fig)
    print(args.output)


if __name__ == "__main__":
    main()
