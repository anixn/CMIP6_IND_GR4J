---
description: Phase 2 - GR6J structural axis via airGR, calibrate, and quantify GR4J-GR6J low-flow divergence (H2)
agent: general
---

Run Phase 2 of the phase map in `AGENTS.md`: the GR6J structural uncertainty axis.
New modules only; existing notebooks untouched.

## Prerequisites

1. `/lowflow-inventory` must have produced `LOWFLOW_00_inventory.md` — the calibration
   setup (windows, warm-up, objective, optimizer) you must replicate exactly for GR6J.
2. Confirm `airGR` is installed and that `RunModel_GR6J` is available. Verify GR6J
   parameter bounds from airGR docs and match warm-up handling to the GR4J setup.

## Step 1 — Write `GR6J_00_setup.R`

Mirror `HYD_00_setup.Rmd`: same Oudin PET, same catchment screening (Tier 1 + Tier 2
as in the GR4J runs), same calibration window (fit 1981–2000, score 2001–2014), same
warm-up handling, same optimizer and objective function. One difference: six GR6J
parameters instead of four. Skipped catchments are logged identically
(`data_processed/logs/gr6j_exclusions.csv`) with reason codes.

## Step 2 — Write `GR6J_20_calibrate.R`

Calibrate GR6J across **every catchment that passed Tier-1/Tier-2 screening and GR4J
calibration** (192-catchment target). Store parameters and performance per catchment,
with the same table schema as the GR4J outputs plus `structure = "GR6J"`. Validation
window scoring: KGE, NSE, PBIAS AND the five low-flow metrics from
`LOWFLOW_00_metrics.R`.

## Step 3 — Write `GR6J_30_divergence.R`

For each CMIP6 model × catchment × SSP (14 shortlisted models):

1. Compute projected Q95, 7-day minimum flow, low-flow volume under GR4J and under
   GR6J (same EQM-corrected inputs, identical windows).
2. Compute the **relative divergence** per metric:
   `div = (GR6J − GR4J) / GR4J` per model-catchment-SSP-metric.
3. Compare the spread of `div` against the inter-GCM spread of the same metric.
4. Stratify `div` by catchment aridity index and a baseflow-index proxy (use the
   CAMELS-IND attributes; state the exact attribute columns used).
5. Statistical test of "structured, not random": regression or ANOVA of `div` on
   aridity + baseflow index; report effect sizes, not just p-values.

Output `data_processed/lowflow/gr4j_gr6j_lowflow_divergence.csv` and a stratified
summary `data_processed/lowflow/gr6j_divergence_summary.csv`.

## Step 4 — H2 decision gate

Write `data_processed/lowflow/H2_verdict.md`:

- Divergence exceeds inter-GCM spread for ≥1 catchment type, or is statistically
  structured by aridity/storage → H2 supported. Quantify which types.
- GR4J and GR6J low-flow projections statistically indistinguishable across all
  catchment types → H2 falsified; say plainly that model-structure uncertainty is
  negligible and Objective 4 collapses to GCM + bias-correction only.

Do not present GR6J as the better model. The divergence is the result; the ranking
(GR4J vs GR6J) is not the finding. Published evidence cuts both ways: GR6J was built
for low flows, but GR4J sometimes matches observed low flows more closely in
prolonged dry periods.

## Guardrails

- Identical inputs: same EQM-corrected forcings as GR4J, same extrication of
  warm-up periods.
- `set.seed()` fixed and recorded; session-info file written next to outputs.
- Runtime safety: calibrate catchment-by-catchment, checkpoint after every ~25
  catchments to `data_processed/lowflow/gr6j_checkpoints/`, and make the script
  resumable so a crash does not restart the whole run.

Report back: number of catchments calibrated, median KGE calib/valid, the divergence
summary (share of catchment types where div exceeds inter-GCM spread), and the H2
verdict.
