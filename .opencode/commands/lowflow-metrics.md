---
description: Phase 1 - build the low-flow metric layer and the forcing-vs-lowflow rank divergence (H1)
agent: general
---

Build the low-flow metric layer (Phase 1 of the phase map in `AGENTS.md`). Work in a
**new parallel module**; do not modify existing `QED_*`/`HYD_*` notebooks.

## Step 1 — Read first

Start from `LOWFLOW_00_inventory.md` (from `/lowflow-inventory`). If it does not exist
yet, run `/lowflow-inventory` first. Match every convention found there: gauge ID
column, screening rules, flag columns (`n_gap_filled`, `extrapolation_share`), and
the existing KGE/NSE/|PBIAS| composite's assembly logic in `QED_30_rank_and_report.Rmd`.

## Step 2 — Write `LOWFLOW_00_metrics.R`

From existing simulated-discharge evaluation outputs, compute per CMIP6 model ×
catchment (scoring window 2001–2014 only):

| Metric | Definition |
|---|---|
| `logNSE` | NSE on log(Q + epsilon); document the epsilon choice |
| `q95_bias` | (simulated Q95 − observed Q95) / observed Q95, dimensionless |
| `lowvol_bias` | (sum of simulated Q below observed Q90 − sum of observed Q below observed Q90) / observed low-flow volume |
| `dryspell_bias` | (mean consecutive days below observed Q90, simulated − observed) / observed |
| `min7_bias` | bias in mean annual 7-day minimum flow, relative |
| `kge`, `nse`, `pbias` | carried over from the existing evaluation for context |

Definitions are fixed once written: any later change bumps `metric_version` and gets an
`AGENT_LOG.md` row.

Output `data_processed/lowflow/lowflow_metrics.csv` with columns `model, catchment,
period, window, metric, value, n_gap_filled, extrapolation_share`. Every catchment
exclusion gets a row in `data_processed/logs/lowflow_exclusions.csv` with a reason code
— no silent drops.

## Step 3 — Write `LOWFLOW_10_ranks.R`

1. Compute a **low-flow composite rank** (mean rank across the five low-flow metrics)
   parallel to the existing KGE/NSE/|PBIAS| composite.
2. Before compositing, check pairwise Spearman correlation among the five metrics;
   if any pair has ρ > 0.9, drop one of the pair and record which and why in the log.
3. Compute **Spearman rank correlation between the forcing composite rank and the
   low-flow composite rank** across the 22 models — per catchment AND pooled. Report
   the **distribution** (quartiles), not just the pooled ρ.
4. Compare against the pilot ρ = 0.14.

Outputs: `data_processed/lowflow/lowflow_vs_forcing_rank.csv` and a diagnostic figure
`data_processed/lowflow/fig_rank_divergence.png` (scatter of forcing rank vs low-flow
rank, 22 models, labelled, with the pooled ρ annotated).

## Step 3.5 — H1 decision gate

Apply the decision rule from `AGENTS.md`:

- ρ ≤ 0.6 → H1 supported. Write `data_processed/lowflow/H1_verdict.md` with the
  number, the per-catchment distribution, and the interpretation.
- ρ > 0.6 → H1 falsified. Write the same file saying so, plainly: "the two-stage
  framework collapses to a one-stage forcing ranking." Do NOT tune the analysis to
  shrink ρ.

## Verify before reporting

- Reopen `lowflow_metrics.csv` and `lowflow_vs_forcing_rank.csv`; confirm row counts =
  screened catchments × models × metrics, no empty `value` cells in required metrics.
- Confirm the diagnostic figure exists, size > 0.
- Write a session-info file next to the outputs.

Report back: pooled ρ, the per-catchment ρ quartiles, the number of catchments/models/
metrics in each table, and the H1 verdict.
