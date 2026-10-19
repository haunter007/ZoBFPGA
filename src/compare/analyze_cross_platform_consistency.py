#!/usr/bin/env python3
from __future__ import annotations

import argparse
import csv
from dataclasses import dataclass
from pathlib import Path
import sys

import numpy as np


METHODS = [
    {
        "label": "Fixed-gain",
        "dirs": {
            "Python": Path("data/output/python/Fixed-gain"),
            "C++": Path("data/output/cpp/Fixed-gain"),
            "HLS": Path("data/output/hls/csim_batch/Fixed-gain"),
        },
    },
    {
        "label": "Segment",
        "dirs": {
            "Python": Path("data/output/python/LAMBDA_SEGMENT"),
            "C++": Path("data/output/cpp/LAMBDA_SEGMENT"),
            "HLS": Path("data/output/hls/csim_batch/LAMBDA_SEGMENT"),
        },
    },
    {
        "label": "Volume",
        "dirs": {
            "Python": Path("data/output/python/LAMBDA_VOLUME"),
            "C++": Path("data/output/cpp/LAMBDA_VOLUME"),
            "HLS": Path("data/output/hls/csim_batch/LAMBDA_VOLUME"),
        },
    },
]

PAIRS = [("Python", "C++"), ("Python", "HLS"), ("C++", "HLS")]

RESULT_HEADER = [
    "Method",
    "Input Bundle Consistent",
    "Max Python-C++ Centre Difference",
    "Max Python-HLS Centre Difference",
    "Max C++-HLS Centre Difference",
    "Max Python-C++ Radius Difference",
    "Max Python-HLS Radius Difference",
    "Max C++-HLS Radius Difference",
    "Max Python-C++ Radius Relative Difference",
    "Max Python-HLS Radius Relative Difference",
    "Max C++-HLS Radius Relative Difference",
    "Generator Count Consistent",
]


@dataclass
class PlatformData:
    name: str
    root: Path
    center: np.ndarray | None
    x_true: np.ndarray | None
    meas: np.ndarray | None
    radii: np.ndarray | None
    generator_counts: np.ndarray | None


def repo_root() -> Path:
    return Path(__file__).resolve().parents[2]


def fmt(value: float | None) -> str:
    if value is None or not np.isfinite(value):
        return "N/A"
    return f"{value:.10g}"


def load_numeric_csv(path: Path) -> np.ndarray | None:
    if not path.exists() or path.stat().st_size == 0:
        return None
    data = np.loadtxt(path, delimiter=",")
    data = np.asarray(data, dtype=float)
    if data.ndim == 1:
        data = data.reshape(1, -1)
    return data


def load_zonotope(path: Path) -> tuple[np.ndarray, np.ndarray]:
    p: np.ndarray | None = None
    generators: list[list[float]] = []
    with path.open("r", encoding="utf-8") as f:
        for raw in f:
            parts = raw.strip().split(",")
            if len(parts) < 2:
                continue
            values = [float(x) for x in parts[1:]]
            if parts[0] == "p":
                p = np.asarray(values, dtype=float)
            elif parts[0] == "H":
                generators.append(values)
    if p is None:
        raise ValueError(f"missing p row in {path}")
    H = np.asarray(generators, dtype=float).T if generators else np.zeros((p.size, 0), dtype=float)
    return p, H


def load_platform(name: str, root: Path) -> PlatformData:
    zonotope_paths = sorted(root.glob("zonotope_*.csv"))
    radii = None
    generator_counts = None
    if zonotope_paths:
        radius_rows = []
        counts = []
        for path in zonotope_paths:
            _, H = load_zonotope(path)
            radius_rows.append(np.sum(np.abs(H), axis=1))
            counts.append(H.shape[1])
        radii = np.vstack(radius_rows)
        generator_counts = np.asarray(counts, dtype=int)
    return PlatformData(
        name=name,
        root=root,
        center=load_numeric_csv(root / "center.csv"),
        x_true=load_numeric_csv(root / "x_true.csv"),
        meas=load_numeric_csv(root / "meas.csv"),
        radii=radii,
        generator_counts=generator_counts,
    )


def arrays_match(a: np.ndarray | None, b: np.ndarray | None, tol: float = 1e-8) -> bool:
    if a is None or b is None or a.shape != b.shape:
        return False
    if a.size == 0 and b.size == 0:
        return True
    return bool(np.max(np.abs(a - b)) <= tol)


def array_status(a: np.ndarray | None, b: np.ndarray | None) -> str:
    if a is None or b is None:
        return "missing"
    if a.shape != b.shape:
        return f"shape mismatch {a.shape} vs {b.shape}"
    max_abs = float(np.max(np.abs(a - b))) if a.size else 0.0
    return f"shape {a.shape}, max_abs={max_abs:.10g}"


def pair_max_norm(a: np.ndarray | None, b: np.ndarray | None) -> float | None:
    if a is None or b is None or a.shape != b.shape:
        return None
    if a.size == 0:
        return 0.0
    return float(np.max(np.linalg.norm(a - b, axis=1)))


def pair_max_abs(a: np.ndarray | None, b: np.ndarray | None) -> float | None:
    if a is None or b is None or a.shape != b.shape:
        return None
    if a.size == 0:
        return 0.0
    return float(np.max(np.abs(a - b)))


def pair_max_relative(a: np.ndarray | None, b: np.ndarray | None) -> float | None:
    if a is None or b is None or a.shape != b.shape:
        return None
    if a.size == 0:
        return 0.0
    scale = np.maximum(np.maximum(np.abs(a), np.abs(b)), 1e-12)
    return float(np.max(np.abs(a - b) / scale))


def analyze_method(method: dict[str, object], root: Path, allow_unverified_input: bool) -> tuple[list[str], list[str]]:
    label = str(method["label"])
    dirs = method["dirs"]
    platforms = {name: load_platform(name, root / path) for name, path in dirs.items()}

    notes: list[str] = [f"\n[{label}]"]
    for name, data in platforms.items():
        notes.append(f"{name} root: {data.root}")
        notes.append(f"{name} center shape: {None if data.center is None else data.center.shape}")
        notes.append(f"{name} x_true shape: {None if data.x_true is None else data.x_true.shape}")
        notes.append(f"{name} meas shape: {None if data.meas is None else data.meas.shape}")
        notes.append(f"{name} radius shape: {None if data.radii is None else data.radii.shape}")
        notes.append(f"{name} generator-count shape: {None if data.generator_counts is None else data.generator_counts.shape}")

    input_verified = True
    for a, b in PAIRS:
        x_ok = arrays_match(platforms[a].x_true, platforms[b].x_true)
        y_ok = arrays_match(platforms[a].meas, platforms[b].meas)
        input_verified = input_verified and x_ok and y_ok
        notes.append(f"{a} vs {b} x_true: {array_status(platforms[a].x_true, platforms[b].x_true)}")
        notes.append(f"{a} vs {b} meas: {array_status(platforms[a].meas, platforms[b].meas)}")
    notes.append(f"same input bundle verified across Python/C++/HLS: {'Yes' if input_verified else 'No'}")

    center_diffs: list[float | None] = []
    radius_diffs: list[float | None] = []
    radius_rel_diffs: list[float | None] = []
    gen_consistent = "N/A"

    if not input_verified and not allow_unverified_input:
        notes.append("platform comparison: N/A, same input bundle was not verified")
    else:
        for a, b in PAIRS:
            center_diffs.append(pair_max_norm(platforms[a].center, platforms[b].center))
            radius_diffs.append(pair_max_abs(platforms[a].radii, platforms[b].radii))
            radius_rel_diffs.append(pair_max_relative(platforms[a].radii, platforms[b].radii))
        counts = [platforms[name].generator_counts for name in ("Python", "C++", "HLS")]
        if any(c is None for c in counts):
            notes.append("generator-count comparison: N/A, missing zonotope_*.csv on at least one platform")
        elif counts[0].shape != counts[1].shape or counts[0].shape != counts[2].shape:
            gen_consistent = "No"
            notes.append(f"generator-count shape mismatch: {[c.shape for c in counts if c is not None]}")
        elif arrays_match(counts[0], counts[1], tol=0.0) and arrays_match(counts[0], counts[2], tol=0.0):
            gen_consistent = "Yes"
        else:
            gen_consistent = "No"
            mismatch = np.flatnonzero((counts[0] != counts[1]) | (counts[0] != counts[2]))
            shown = ", ".join(str(int(i)) for i in mismatch[:20])
            notes.append(f"generator-count mismatched rows: {shown}")

    while len(center_diffs) < len(PAIRS):
        center_diffs.append(None)
    while len(radius_diffs) < len(PAIRS):
        radius_diffs.append(None)
    while len(radius_rel_diffs) < len(PAIRS):
        radius_rel_diffs.append(None)

    row = [
        label,
        "Yes" if input_verified else "No",
        *(fmt(x) for x in center_diffs),
        *(fmt(x) for x in radius_diffs),
        *(fmt(x) for x in radius_rel_diffs),
        gen_consistent,
    ]
    return row, notes


def main() -> int:
    parser = argparse.ArgumentParser(description="Analyze Python/C++/HLS cross-platform consistency from existing outputs.")
    parser.add_argument("--out", default="results/thesis/cross_platform_consistency.csv")
    parser.add_argument(
        "--allow-unverified-input",
        action="store_true",
        help="Compute diagnostic differences even when the same input bundle cannot be verified.",
    )
    args = parser.parse_args()

    root = repo_root()
    rows: list[list[str]] = []
    all_notes: list[str] = []
    for method in METHODS:
        row, notes = analyze_method(method, root, args.allow_unverified_input)
        rows.append(row)
        all_notes.extend(notes)

    out_path = root / args.out
    out_path.parent.mkdir(parents=True, exist_ok=True)
    with out_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(RESULT_HEADER)
        writer.writerows(rows)

    print("Data files, shapes, and input checks:")
    print("\n".join(all_notes))
    print(f"\nSaved CSV: {out_path}")
    print("\nCSV content:")
    writer = csv.writer(sys.stdout, lineterminator="\n")
    writer.writerow(RESULT_HEADER)
    writer.writerows(rows)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
