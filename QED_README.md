# QED -- CAMELS-India quantile mapping workflow (1981-2014)

Tiered, reproducible **empirical quantile mapping** of CMIP6 catchment-mean
series (pr, tasmax, tasmin) onto **CAMELS-India catchment-mean forcings**,
built per `Suggestion-workflow.md`.

## How to run

Open `QED_run_all.Rmd` in RStudio and knit it -- that renders all notebooks in
order:

| Notebook | Does | Spec steps |
|---|---|---|
| `QED_00_setup.Rmd` | All paths, thresholds, QM settings + helper library | config block |
| `QED_05_aggregate_cmip6.Rmd` | Raw CMIP6 nc -> catchment-mean `agg_*.csv` (run once per archive change, ~1-2 h) | source data |
| `QED_10_inventory_tiers.Rmd` | Inventory cross-check, 1981-2014 availability, tiers, forcing QA | 1-4 |
| `QED_20_qm_fit_apply.Rmd` | Seasonal EQM fit + apply per model x catchment x variable | 5-7 |
| `QED_30_rank_and_report.Rmd` | Out-of-sample model ranking + `PIPELINE_REPORT.md` | 8 |

`QED_run_all.Rmd` renders 10 -> 20 -> 30. Run `QED_05_aggregate_cmip6.Rmd`
manually (knit it) whenever the raw CMIP6 archive changes; 22 models have all
three variables in the current archive.

You can also knit any single notebook (they read the previous notebook's CSV
outputs from `data_processed/qed/`).

## One switch you must know

`qed_test_mode` in `QED_00_setup.Rmd`:

- `TRUE` = quick look (2 models x 3 catchments), for verifying the pipeline.
- `FALSE` = production run (all 20 models x 242 Tier 1/2 catchments,
  ~40-60 min, ~7 GB of corrected CSVs).

## What it produces (in `data_processed/qed/`)

- `inventory.csv`, `availability_report.csv`, `tier_assignment.csv`,
  `tier1_ids.txt`, `tier2_ids.txt`, `tier3_*_ids.txt`,
  `forcing_availability.csv` -- every filtering decision, nothing silent.
- `qm_corrected/<model>/<tier>/<catchment>_<var>.csv` -- corrected series with
  `method_flag` (`within_range`, `extrapolated_low`, `extrapolated_high`,
  `source_nan`).
- `qm_params/<model>/<tier>/*.rds` -- fitted quantile pairs (100-point CDFs).
- `qm_run_summary.csv`, `tier3_handling_log.csv` -- coverage + Option C log.
- `model_ranking_overall.csv` + `PIPELINE_REPORT.md` -- **the shortlist**:
  out-of-sample ranking (EQM fit 1985-2000, scored 2001-2014 with KGE/NSE/PBIAS
  vs CAMELS-IND forcings) to decide which few models deserve future SSP
  downloads.

## Hard rules honoured

Tiers are never pooled in a fit; CAMELS-IND catchment-mean forcings are the
only reference; the full 12,418-day daily index is used; no catchment is
silently dropped; every extrapolated value is flagged; LSTM streamflow is never
treated as observed.
