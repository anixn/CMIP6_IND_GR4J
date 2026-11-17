---
description: Phase 5 - C21 benchmark of CAMELS-IND-Proj LSTM projections vs GR4J/GR6J on low-flow skill (H5)
agent: general
---

Run Phase 5 of the phase map in `AGENTS.md`: the CAMELS-IND-Proj low-flow benchmark.
New modules only; existing notebooks untouched. Prerequisites: Phase 1 metrics, and
Phase 2 GR6J outputs (both structures).

## Step 1 — Ingest (`BENCH_00_ingest_lstm.R`)

1. Download CAMELS-IND-Proj (Zenodo record 21775597, CC BY 4.0, EcoHydroX Lab IIT
   Roorkee). Main file is an ~11.3 GB zip `CAMELS-IND-Proj_data.zip` plus
   `filter_catchment_model_scenario.py`; use the filter script to subset by GCM, SSP,
   and gauge ID rather than unpacking everything.
2. Align identifiers: CAMELS-IND-Proj gauge IDs must match CAMELS-IND gauge IDs
   (verify on 5 sample catchments; log any mismatches with a reason code).
3. Read the confidence flags from the dataset's own documentation/files. The project
   brief says 239 catchments carry confidence flags with explicit `low_reason` values
   — **verify the actual number and flag semantics against the downloaded files** and
   record what you find in `data_processed/bench/flag_semantics.md`. If the real flag
   set differs from the brief, use the dataset's own semantics and say so.
4. Subset: 13 GCMs × 4 SSPs (126/245/370/585), historical 2015 is not in LSTM
   projections — the overlapping evaluation window with observed discharge does not
   exist for the projection period. Therefore benchmark on the historical-per-GCM LSTM
   runs for skill, and on 2015–2100 projections for projected low-flow changes.

## Step 2 — Evaluate (`BENCH_10_lowflow_eval.R`)

Compute the SAME low-flow metric suite (`LOWFLOW_00_metrics.R` definitions, same
epsilon, same Q90/Q95 reference conventions) for:

- LSTM historical-per-GCM streamflow vs observed (skill comparison), and
- LSTM projections vs GR4J/GR6J projections (projected low-flow change comparison,
  2015–2100 vs historical baseline, SSP by SSP).

Then:

1. **Compare distributions, not means.** Per metric: median, IQR, and per-catchment
   win rates (LSTM wins / ties / losses vs GR4J and vs GR6J separately).
2. Stratify by confidence flag (flagged vs unflagged catchments — report separately,
   never merged) and by aridity class.
3. Key question for H5: is the LSTM's advantage smaller (or absent) for low-flow and
   drought metrics than for mean-flow metrics, particularly in semi-arid / hard-rock
   catchments? Report mean-flow metrics alongside low-flow metrics so the contrast is
   explicit.

Output `data_processed/bench/lstm_vs_gr4j_lowflow_benchmark.csv` (columns: `metric,
catchment, ssp, structure (GR4J/GR6J/LSTM), value, win_flag, confidence_flag,
aridity_class`).

## Step 3 — H5 decision gate

Write `data_processed/bench/H5_verdict.md`:

- LSTM mean-flow advantage shrinks or disappears on low-flow metrics, or is absent in
  semi-arid/hard-rock/flagged catchments → H5 supported. Quantify per stratum.
- LSTM dominates GR4J/GR6J on ALL low-flow metrics across ALL catchment types → H5
  falsified. Frame the benchmark as a confirmation from the outset: "the LSTM
  projections pass the process-based low-flow benchmark" is still a publishable C21
  result, but frame it as such — do not retro-fit the framing after seeing the numbers.

## Guardrails

- Cite the dataset as: CAMELS-IND-Proj, Zenodo DOI 10.5281/zenodo.21775597, CC BY 4.0,
  EcoHydroX Lab IIT Roorkee, derived from CAMELS-IND. Include the citation string in
  every output README.
- The LSTM projections are the dataset's own product — you are benchmarking them, not
  regenerating them. Make that explicit in every table caption.
- 11.3 GB download: verify disk space and checksums before unpacking; subset with the
  provided filter script; log every skipped file with a reason code.
- Session-info file next to outputs.

Report back: the flag semantics you actually found (vs the 239 claimed in the brief),
per-metric win rates LSTM vs GR4J and vs GR6J, the flagged vs unflagged contrast, and
the H5 verdict.
