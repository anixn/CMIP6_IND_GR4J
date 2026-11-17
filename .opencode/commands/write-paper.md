---
description: Integrate verdicts and evidence into paper.md - methods, results, and discussion sections (all phases)
agent: general
---

Integrate Phase 1–5 verdicts and evidence into the manuscript. This command runs LAST,
after the phase commands have produced their verdict files.

## Inputs it must read first

- `paper.md` (draft v0.1) in the manuscript directory
- The five verdict files: `H1_verdict.md` (lowflow), `H2_verdict.md` (lowflow),
  `H3_verdict.md` (prop), `H4_verdict.md` (decomp), `H5_verdict.md` (bench)
- `LOWFLOW_00_inventory.md`, `data_processed/lowflow/*.csv`,
  `data_processed/prop/*.csv`, `data_processed/decomp/*.csv`,
  `data_processed/bench/*.csv`
- `manuscript/AGENT_LOG.md` for the history of convention changes

If any verdict file is missing, STOP and report which phase has not completed. Do not
write results for analyses that were not run.

## What to write

### 1. Methods section

- The two-stage selection framework with the low-flow metric layer (Phase 1): metric
  definitions with epsilon and Q90/Q95 conventions, the composite-rank construction,
  the rank-correlation test of H1.
- GR6J structural axis (Phase 2): airGR implementation, identical inputs/windows
  claim, divergence metric definitions.
- Drought propagation (Phase 3): SPI-12/SRI-12 construction, propagation time and rate
  definitions, pre-registered tolerance band (cite the pre-registration file and
  date), the benchmark against observed propagation.
- Uncertainty decomposition (Phase 4): ANOVA design, bootstrap CI method, seed.
- C21 benchmark (Phase 5): dataset citation, flag semantics actually found, win-rate
  definitions.

### 2. Results section — one subsection per phase

Each subsection: the headline number, the supporting table (from the CSVs, real
numbers only), the verdict, and the negative-result handling where applicable. Tables
must reproduce the CSV contents — no hand-typed numbers. If a number is not in a CSV,
it does not go in the paper.

### 3. Discussion section — the framing rules

- The headline of the paper is the **selection question**: which CMIP6 models are fit
  for low-flow/drought projection, and how much the answer depends on hydrological
  model and bias correction. SSP projections are the demonstration, not the product.
- Objectives 2, 3, 4 are the core novel contribution; Objective 1 is the necessary
  selection layer made novel through the ρ-divergence demonstration; Objective 5 is
  the C21 benchmark framed as a secondary contribution (CAMELS-IND-Proj owns the
  projection product; your contribution is the process-based low-flow benchmark).
- Anchor set for the survey (verified against the 2026 record): Park et al. 2025
  (Sci. Rep., GR5J/GR6J vs GR4J low flows, South Korea); GR6J designed for low flows;
  Irish catchment evidence GR6J best low flows / GR4J best high flows, GR4J closest
  in prolonged dry periods; Golian et al. 2021 (GR4J/GR6J regionalization, high/
  median/low flows); EQM preserves wet/dry ordering but not dry-spell duration;
  Singh et al. 2026 (HSJ, Betwa basin propagation time decrease up to 80% by
  2051–2100, propagation rates 42→63% Dhasan, 33→50% Lower Betwa under SSP5-8.5);
  regional India propagation gap statement; Naresh & Mathew 2026 (Hydrol. Proc./PCE,
  TOPSIS selection of seven CMIP6 models, EC-Earth3-Veg / MPI-ESM1-2-LR / BCC-CSM2-MR
  reliable); CAMELS-IND (Mangukiya et al. 2025 ESSD) and CAMELS-IND-Proj (Zenodo
  21775597); Wilby & Harris 2006 (WRR, Thames low-flow uncertainty ordering);
  streamflow-based vs climate-variable-based GCM weighting; Mangukiya et al. 2026
  (WRR 2026WR044753, 47 conceptual models, 159 watersheds, GR4J in the 5-model
  sufficient set, semi-arid hardest); Sharma et al. 2026 (Hydrol. Proc. 40(3),
  hyp.70476, India projections MILC/GR4J/HYMOD/HBV, 12 GCMs — closest prior art,
  no GR6J, no low-flow selection divergence, no decomposition).
- Do not state or imply that CAMELS-IND-Proj confidence flags number exactly 239
  unless your own Step-3 verification in `BENCH_00_ingest_lstm.R` confirmed it;
  otherwise describe them per the dataset's own documentation.

### 4. Abstract rewrite

Rewrite the abstract around the selection question, with the ρ-divergence number,
the GR4J–GR6J divergence magnitude, the variance-share ordering, and the LSTM
benchmark result — each traceable to a CSV.

## Rules

- Numbers in the paper must match the CSVs exactly; regenerate tables from the CSVs,
  never re-type them.
- Falsified hypotheses stay in the paper as negative results, with their decision
  rule quoted.
- Preserve the out-of-sample framing throughout: fit 1981–2000, score 2001–2014.
- Append a row to `manuscript/AGENT_LOG.md` for every manuscript section you touch.

Report back: which sections were written/rewritten, which verdicts were integrated,
any missing inputs that blocked a section, and a list of every number in the new text
with the CSV it traces to.
