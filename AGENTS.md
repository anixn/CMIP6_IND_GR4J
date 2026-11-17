# AGENTS.md — CMIP6_IND_GR4J: Low-Flow Projection Uncertainty Project

## What this repository is

An out-of-sample, low-flow-aware model-selection framework for CMIP6 climate models
over Peninsular India. It ranks CMIP6 models on **low-flow and drought skill through a
calibrated hydrological model** — not on precipitation statistics — and separates three
sources of low-flow projection uncertainty: GCM choice, hydrological model structure
(GR4J vs GR6J), and bias-correction design (EQM tail policy).

The science question: *Which CMIP6 models are fit for low-flow and drought projection
over Peninsular India — and how much does the answer depend on the hydrological model
and the bias correction?*

Status: `paper.md` (draft v0.1) is ~60% complete. The missing 40% is (a) the low-flow
metric layer, (b) the GR6J structural axis, (c) the drought-propagation selection test.
The SSP projections are the demonstration, not the product.

## Non-negotiable scientific guardrails

1. **Out-of-sample discipline.** Calibration/fit window is 1981–2000; scoring window
   is 2001–2014. Never score a model on data used to fit or calibrate it.
2. **Forcing rank ≠ low-flow rank.** The pilot Spearman ρ = 0.14 between forcing-skill
   rank and discharge-skill rank is the empirical wedge. Preserve it; re-estimate it
   when the low-flow metric layer lands. Do not tune toward a bigger divergence.
3. **Divergence is the signal, not the ranking.** GR4J vs GR6J is a structural
   uncertainty axis, not a beauty contest. GR6J was designed for low flows, but
   published evidence (Irish catchments; South Korea; regionalization studies) shows
   GR4J sometimes matches observed low flows more closely in prolonged dry periods.
   Never assert GR6J superiority; quantify the divergence.
4. **Negative results are results.** If H1/H2/H5 is falsified, report it. If low-flow
   rank correlates with forcing rank at ρ > 0.6, H1 fails and the framework collapses
   to one stage — say so in the paper. Do not tune the analysis to produce the
   expected direction.
5. **No metric averaging without inspection.** Before compositing ranks, check pairwise
   Spearman correlations among metrics; if two metrics are near-duplicates (ρ > 0.9),
   drop one instead of double-counting.
6. **Pre-registered tolerance bands.** For drought-propagation reproduction (H3), fix
   the tolerance band on observed propagation time **before** running the model
   comparison, and record the date of pre-registration in the output.
7. **No silent drops.** Every catchment exclusion, skipped calibration, and gap-fill
   gets a machine-readable log line with a reason code. Flags propagate downstream:
   every EQM-corrected value carries `within_range`/`extrapolation`; every discharge
   series carries `n_gap_filled`.
8. **Machhar-type traps.** Never infer drought propagation from near-identity of SPI
   and SRI (a mean |SRI−SPI| ≈ 0.013 is a model-structure artefact of too-tight
   precipitation–runoff coupling, not a climate finding). Compute propagation time
   explicitly as the SPI–SRI cross-correlation lag, with the observed distribution as
   benchmark.

## Repository map

| Path | Role |
|---|---|
| `QED_00–30` `.Rmd` | Forcing selection notebooks (setup → aggregate CMIP6 → inventory tiers → QM fit/apply → rank and report) |
| `HYD_00–30` `.Rmd` | GR4J calibration/discharge evaluation notebooks (setup → inputs → calibrate → simulate) |
| `data_processed/` | Outputs incl. `hyd/model_shortlist_final.csv` (14-model hybrid shortlist) |
| `India_Shp/` | India shapefiles for mapping |
| `manuscript/` | `paper.md` and manuscript assets |
| `LOWFLOW_*`, `PROP_*`, `DECOMP_*`, `BENCH_*` | New modules to be added (see phase map below) — parallel to existing notebooks, never edits them |

## Data in play

- **CAMELS-IND** (Mangukiya et al. 2025, ESSD 17:461, Zenodo 14999580): 472 catchments,
  228 with observed streamflow ≥30% of 1980–2020. Tier 1 n=180, Tier 2 n=62, Tier 3
  excluded n=230.
- **CAMELS-IND-Proj** (Zenodo 21775597, CC BY 4.0, EcoHydroX Lab IIT Roorkee; derived
  from CAMELS-IND; LSTM via hydroDL; 11.3 GB zip + `filter_catchment_model_scenario.py`):
  daily streamflow 2015–2100 for 13 CMIP6 GCMs × 4 SSPs (126/245/370/585) across 472
  catchments, plus historical-per-GCM streamflow and forcings. Confidence flags exist
  for a subset of catchments (239 per the project brief; details in the dataset's
  data-description PDF — verify against the actual downloaded files).
- **CMIP6**: 22 all-variable models for forcing selection; 14 shortlisted for SSP runs.
- GR4J status: calibration median KGE 0.80, validation median 0.54 across 192
  catchments.

## Conventions

- **Stack:** R + airGR (+ airGRteaching or manual wrapper for GR6J), R Markdown
  notebooks, Oudin PET for both structures, identical calibration/validation windows
  and warm-up handling for GR4J and GR6J.
- **New modules are parallel, not invasive.** Write `LOWFLOW_00_metrics.R`-style
  modules as new files; do not modify existing `QED_*`/`HYD_*` notebooks.
- **Reproducibility:** every script writes a session-info file and uses `set.seed()`
  where resampling is used. Output tables are tracked in git; bulk series are
  regenerated, not committed.
- **Naming:** catchment ID columns keep CAMELS-IND gauge IDs; every metric table has
  `model`, `catchment`, `period`, `window` (calib/valid), `metric`, `value`,
  `n_gap_filled`, `extrapolation_share`.
- **Logs:** `data_processed/logs/<module>_exclusions.csv` with columns
  `module, catchment, reason_code, detail`.

## The five hypotheses (decision rules)

- **H1** — Forcing-skill rank and low-flow-skill rank diverge (pilot ρ = 0.14).
  Fails if ρ > 0.6 pooled.
- **H2** — GR4J and GR6J low-flow projections differ materially (structured by
  aridity/storage). Fails if statistically indistinguishable across catchment types →
  Objective 4 collapses to GCM + bias-correction only.
- **H3** — CMIP6 models differ in reproducing observed SPI-12→SRI-12 propagation time;
  mean-flow selection misses it. Fails if all 22 models fall inside the observed
  inter-catchment distribution.
- **H4** — GCM dominates low-flow projection variance; structure share non-negligible
  (≥5% matters for adaptation). Fails if structure share < 5% everywhere → still a
  useful negative result.
- **H5** — LSTM projections do not uniformly beat GR4J/GR6J at low flows (esp.
  semi-arid, hard-rock). Fails if LSTM dominates on all low-flow metrics → publish as
  benchmark confirmation, framed as such from the outset.

## Phase map (execution order)

| Phase | Module(s) | Hypothesis / Objective | Duration |
|---|---|---|---|
| 1. Low-flow metric layer | `LOWFLOW_00_metrics.R` → `LOWFLOW_10_ranks.R` | H1 / Obj 1 | 2–3 wk |
| 2. GR6J structural axis | `GR6J_00_setup.R` → `GR6J_20_calibrate.R` → `GR6J_30_divergence.R` | H2 / Obj 2 | 3–4 wk |
| 3. Drought propagation | `PROP_00_indices.R` → `PROP_10_lag.R` → `LOWFLOW_11_propagate.R` | H3 / Obj  3 | 2–3 wk |
| 4. Uncertainty decomposition | `DECOMP_00_anova.R` | H4 / Obj 4 | 2 wk |
| 3→5. C21 benchmark | `BENCH_00_ingest_lstm.R` → `BENCH_10_lowflow_eval.R` | H5 / Obj 5 | 2–3 wk |
| 5b. Manuscript assembly | `paper.md` updates | all | — |

## Touched-by-agents registry

When an agent-driven change alters results or conventions, append a row to
`manuscript/AGENT_LOG.md`: `date | agent | module | what changed | why`.

## Contributor checklist before any commit

1. Did any new code change a metric definition? → bump a `metric_version` column and
   note it in `AGENT_LOG.md`.
2. Do all output tables still pass the flag-propagation rule (`n_gap_filled`,
   `extrapolation_share` present)?
3. Was any catchment dropped without a log line? → fix before commit.
4. Are calibration vs scoring windows still strictly 1981–2000 / 2001–2014?
5. Does the new module leave existing `QED_*`/`HYD_*` notebooks untouched?
