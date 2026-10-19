#!/usr/bin/env python3
"""Synthesize oscillator configurations and collect Vitis HLS estimates.

This measures synthesis estimates, not KR260 execution time. Each row keeps
the original report and log path so figures can be audited later.
"""

import argparse
import csv
import itertools
import subprocess
import sys
import xml.etree.ElementTree as ET
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
HLS_DIR = ROOT / "src/hls"
DEFAULT_OUTPUT = ROOT / "data/output/hls/scaling"
DEFAULT_SUMMARY = ROOT / "results/hls_scaling/summary.csv"
FIELDS = [
    "method", "n_state", "n_meas", "reduction_budget", "max_gen",
    "part", "clock_mhz", "hls_version", "status", "target_clock_ns", "estimated_clock_ns", "hls_issue_type",
    "best_latency_cycles", "worst_latency_cycles", "worst_latency_ms_at_target",
    "bram_18k", "dsp", "ff", "lut", "uram",
    "bram_pct", "dsp_pct", "ff_pct", "lut_pct", "report", "log",
]


def report_value(root, path):
    node = root.find(path)
    return "" if node is None or node.text is None else node.text.strip()


def read_report(path):
    root = ET.parse(path).getroot()
    latency = "PerformanceEstimates/SummaryOfOverallLatency"
    resources = "AreaEstimates/Resources"
    result = {
        "hls_version": report_value(root, "ReportVersion/Version"),
        "target_clock_ns": report_value(root, "UserAssignments/TargetClockPeriod"),
        "estimated_clock_ns": report_value(root, "PerformanceEstimates/SummaryOfTimingAnalysis/EstimatedClockPeriod"),
        "hls_issue_type": report_value(root, "PerformanceEstimates/SummaryOfViolations/IssueType"),
        "best_latency_cycles": report_value(root, latency + "/Best-caseLatency"),
        "worst_latency_cycles": report_value(root, latency + "/Worst-caseLatency"),
        "bram_18k": report_value(root, resources + "/BRAM_18K"),
        "dsp": report_value(root, resources + "/DSP"),
        "ff": report_value(root, resources + "/FF"),
        "lut": report_value(root, resources + "/LUT"),
        "uram": report_value(root, resources + "/URAM"),
    }
    for key, resource in (("bram_pct", "BRAM_18K"), ("dsp_pct", "DSP"),
                          ("ff_pct", "FF"), ("lut_pct", "LUT")):
        used = result[resource.lower() if resource != "BRAM_18K" else "bram_18k"]
        available = report_value(root, "AreaEstimates/AvailableResources/" + resource)
        result[key] = round(100 * int(used) / int(available), 2) if used.isdecimal() and available.isdecimal() and int(available) else ""
    return result


def report_matches(path, part, clock_mhz):
    if not path.exists():
        return False
    try:
        root = ET.parse(path).getroot()
        reported_part = report_value(root, "UserAssignments/Part")
        period = float(report_value(root, "UserAssignments/TargetClockPeriod"))
        return reported_part == part and abs(period - 1000 / clock_mhz) < 0.02
    except (ET.ParseError, OSError, ValueError):
        return False


def parse_ints(value):
    return [int(item) for item in value.split(",")]


def configurations(states, measures, budget_extras, methods):
    for n_state, n_meas, extra, method in itertools.product(states, measures, budget_extras, methods):
        if n_state % 4 or not 4 <= n_state <= 24:
            raise ValueError("HLS oscillator supports N_STATE=4,8,...,24")
        if n_meas < 2 or n_meas % 2:
            raise ValueError("N_MEAS must be positive and even")
        if n_meas > n_state // 2:
            continue
        if extra <= 0:
            raise ValueError("budget extra must be positive")
        budget = n_state + extra
        yield method, n_state, n_meas, budget, budget + max(n_state, n_meas)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--states", type=parse_ints, default=[8, 16, 24])
    parser.add_argument("--measurements", type=parse_ints, default=[4, 8, 12])
    parser.add_argument("--budget-extras", type=parse_ints, default=[4, 8, 16])
    parser.add_argument("--methods", default="fixed_gain,segment,volume")
    parser.add_argument("--part", default="xck26-sfvc784-2LV-c")
    parser.add_argument("--clock-mhz", type=int, default=113)
    parser.add_argument("--output", type=Path, default=DEFAULT_OUTPUT)
    parser.add_argument("--summary", type=Path, default=DEFAULT_SUMMARY)
    parser.add_argument("--max-runs", type=int, default=0, help="Limit new syntheses; 0 means all")
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    methods = args.methods.split(",")
    if not set(methods) <= {"fixed_gain", "segment", "volume"}:
        parser.error("methods must be fixed_gain, segment or volume")
    if args.clock_mhz <= 0 or args.max_runs < 0:
        parser.error("clock-mhz must be positive and max-runs nonnegative")

    try:
        configs = list(configurations(args.states, args.measurements, args.budget_extras, methods))
    except ValueError as exc:
        parser.error(str(exc))
    if not configs:
        parser.error("no valid configurations")

    output = args.output.resolve()
    if not args.dry_run:
        output.mkdir(parents=True, exist_ok=True)
        args.summary.parent.mkdir(parents=True, exist_ok=True)
    rows = []
    launched = 0
    for method, n_state, n_meas, budget, max_gen in configs:
        label = f"{method}_n{n_state}_m{n_meas}_s{budget}"
        project = output / label
        report = project / "sol1/syn/report/zonotope_batch_kernel_axi_csynth.xml"
        log = output / f"{label}.log"
        row = dict(method=method, n_state=n_state, n_meas=n_meas,
                   reduction_budget=budget, max_gen=max_gen, part=args.part,
                   clock_mhz=args.clock_mhz, status="pending",
                   report=str(report.relative_to(ROOT)) if report.is_relative_to(ROOT) else str(report),
                   log=str(log.relative_to(ROOT)) if log.is_relative_to(ROOT) else str(log))
        if args.dry_run:
            print(label, "MAX_GEN=", max_gen)
        elif not report_matches(report, args.part, args.clock_mhz) and (not args.max_runs or launched < args.max_runs):
            flags = f"-DN_STATE={n_state} -DN_MEAS={n_meas} -DREDUCTION_BUDGET={budget} -DMAX_GEN={max_gen}"
            command = ["make", "-C", str(HLS_DIR), "synth", f"METHOD={method}",
                       f"PROJ={project}", f"SIZE_CFLAGS={flags}",
                       f"PART={args.part}", f"CLK_MHZ={args.clock_mhz}"]
            print(f"Synthesizing {label}", flush=True)
            with log.open("w") as handle:
                result = subprocess.run(command, cwd=ROOT, stdout=handle, stderr=subprocess.STDOUT, check=False)
            launched += 1
            if result.returncode:
                row["status"] = f"failed:{result.returncode}"
        if report_matches(report, args.part, args.clock_mhz) and not row["status"].startswith("failed"):
            try:
                row.update(read_report(report))
                cycles = row["worst_latency_cycles"]
                if cycles.isdecimal():
                    row["worst_latency_ms_at_target"] = float(cycles) / args.clock_mhz / 1000
                row["status"] = "synthesized"
            except (ET.ParseError, OSError) as exc:
                row["status"] = f"bad_report:{exc}"
        rows.append(row)
        if not args.dry_run:
            for summary in (output / "summary.csv", args.summary):
                with summary.open("w", newline="") as handle:
                    writer = csv.DictWriter(handle, fieldnames=FIELDS)
                    writer.writeheader()
                    writer.writerows(rows)
    print(f"{len(configs)} configurations; {launched} synthesis runs launched")
    if not args.dry_run:
        print(output / "summary.csv")
    return 1 if any(row["status"].startswith(("failed", "bad_report")) for row in rows) else 0


if __name__ == "__main__":
    sys.exit(main())
