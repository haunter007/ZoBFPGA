# Oscillator dimension and generator-budget experiments

## Scope and provenance

- Vitis HLS 2025.2, batch AXI kernel, `xck26-sfvc784-2LV-c`, requested 113 MHz.
- 54 syntheses: `N_STATE=8,16,24`; valid `N_MEAS=4,8,12`; budgets
  `N_STATE+4`, `N_STATE+8`, `N_STATE+16`; Fixed-gain, Segment and Volume.
  `MAX_GEN=REDUCTION_BUDGET+N_STATE` in each synthesis.
- Software quality: Python NumPy double precision, 24 states, 12 measurements,
  20 paired seeds (0–19), 100 steps per seed and method. Strict LP membership
  tests the output zonotope against each simulated true state.
- HLS timing is a **200-step batch upper-bound estimate**. Software time is
  host estimator time per step. Neither number is a KR260 measurement.

## Main 24-state, 12-measurement budget comparison

| Method | Budget | Center L2 | Mean full interval width | Python us/step | HLS LUT (% of available) | HLS worst-case cycles |
|:--|--:|--:|--:|--:|--:|--:|
| Fixed-gain | 28 | 0.616 | 25.274 | 158.4 | 67,348 (57.50%) | 589,653 |
| Fixed-gain | 32 | 0.616 | 22.965 | 159.4 | 71,489 (61.04%) | 820,645 |
| Fixed-gain | 40 | 0.616 | 18.347 | 167.6 | 81,964 (69.98%) | 1,359,429 |
| Segment | 28 | 1.908 | 3.080 | 251.2 | 82,010 (70.02%) | 635,253 |
| Segment | 32 | 1.898 | 3.253 | 257.0 | 86,112 (73.52%) | 864,245 |
| Segment | 40 | 1.463 | 4.604 | 283.2 | 96,643 (82.52%) | 1,395,029 |
| Volume | 28 | 0.610 | 25.966 | 198.0 | 73,232 (62.53%) | 382,653 |
| Volume | 32 | 0.608 | 22.141 | 200.3 | 77,371 (66.06%) | 596,045 |
| Volume | 40 | 0.605 | 18.540 | 209.4 | 87,870 (75.03%) | 1,099,629 |

All 18,000 tested method-budget-step cases in this software budget scan were contained
(3 budgets × 3 methods × 20 seeds × 100 steps). This is tested-trajectory
evidence, not a universal guarantee. Wider budgets reduced the interval width
for Fixed-gain and Volume. Segment's interval width rose while its center
error fell at budget 40; its retained generators and subsequent correction
gains change with the budget, so the width need not be monotone.

All 54 configurations produced an XML synthesis report, and none exceeded the
available resource totals reported by HLS. However, **all 54 HLS reports mark
`Timing Violation`**. Their estimated clock periods and cycle counts do not
establish implemented timing. Vivado implementation and KR260 measurements are
still needed before journal performance claims.

## Files

- [HLS data](hls_scaling/summary.csv) and [state](hls_scaling/state_scaling.png),
  [measurement](hls_scaling/measurement_scaling.png),
  [budget](hls_scaling/budget_scaling.png) trend plots.
- [Software per-seed data](generator_budgets/per_seed.csv),
  [mean and standard deviation](generator_budgets/summary.csv), and
  [quality-cost plot](generator_budgets/tradeoff.png).
- Original XML and synthesis logs: `data/output/hls/scaling/` (generated,
  intentionally excluded from Git because the Vitis projects are large).
- Reproduction commands and supported kernel dimensions: [README](../README.md).
