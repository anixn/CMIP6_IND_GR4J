# PIPELINE REPORT -- CAMELS-India quantile mapping (QED)

Generated: 2026-11-16 17:26:18

## 1. Data inventory summary

- Streamflow table : 472 gauge columns (1980-2020)
- Forcing CSVs     : 472 files, all complete within 1981-2014
- Shapefile        : 472 polygons
- ID sets identical across all three sources: TRUE
- CMIP6 models with all 3 variables: 22

## 2. Availability distribution (1981-2014, 12,418 days)

- min / median / max availability: 0 / 0.335 / 1

| tier | n |
|---|---|
| tier1 | 180 |
| tier2 | 62 |
| tier3_too_few_days | 230 |

## 3. Tier roster

- Tier 1: see `tier1_ids.txt` (180 catchments)
- Tier 2: see `tier2_ids.txt` (62 catchments)
- Tier 3: see `tier3_*_ids.txt` + `tier3_handling_log.csv` (Option C, excluded)

## 4. QM coverage

| status | n |
|---|---|
| fitted | 15641 |
| fitted_annual_fallback | 331 |

## 5. Extrapolation summary

- The corrected series in `qm_corrected/` were fitted and applied on the SAME
  1981-2014 window, so by construction no value falls outside the fitted
  source range there (`n_extrap = 0` in `qm_run_summary.csv` is expected).
- Out-of-sample check (fit 1981-2000, apply 2001-2014 in the ranking): 31365 of 60,673,320 scored values (0.05%) were flagged
  as `extrapolated_low/high` -- every flagged value keeps its flag in the
  evaluation, per the no-silent-extrapolation rule.
- per-catchment detail: `qm_run_summary.csv` columns `n_extrap`, `frac_extrap`

## 6. Model shortlist (out-of-sample, Tier 1 catchments)

| rank | model | mean composite |
|---|---|---|
| 1 | EC-Earth3-Veg-LR | 13.67 |
| 2 | FGOALS-g3 | 16.83 |
| 3 | MIROC-ES2L | 22 |
| 4 | INM-CM4-8 | 22.17 |
| 5 | GISS-E2-1-G | 27.17 |
| 6 | INM-CM5-0 | 27.67 |
| 7 | NorESM2-MM | 28.67 |
| 8 | BCC-CSM2-MR | 29.33 |
| 9 | MIROC6 | 33.17 |
| 10 | CNRM-CM6-1 | 33.33 |
| 11 | HadGEM3-GC31-MM | 33.33 |
| 12 | CanESM5 | 34.5 |
| 13 | ACCESS-ESM1-5 | 34.67 |
| 14 | EC-Earth3 | 35.5 |
| 15 | IPSL-CM6A-LR | 40.33 |
| 16 | MRI-ESM2-0 | 43.83 |
| 17 | MPI-ESM1-2-LR | 44 |
| 18 | CMCC-ESM2 | 44.83 |
| 19 | GFDL-ESM4 | 46 |
| 20 | TaiESM1 | 49 |
| 21 | ACCESS-CM2 | 49.33 |
| 22 | MPI-ESM1-2-HR | 49.67 |

**Recommended for future SSP downloads: the top 5 models above.**

## 7. Reproducibility block

- config file MD5 (QED_00_setup.Rmd): 6678c10fed0e6088db230441e4de6785
- code version: plain script folder (no git repo at run time)
- random seeds: none used (fully deterministic)
- R version: R version 4.5.1 (2025-06-13 ucrt)

## 8. Hard-rule compliance

- Tier 1/2/3 never pooled in a fit: OK (fits are per catchment, tier-gated)
- CAMELS-IND catchment-mean forcings used as the sole reference: OK
- Full daily index built for 1981-2014 (12,418 days verified): OK
- No silent drops: every skip/exclusion is a row in a CSV log: OK
- Extrapolation always flagged via method_flag: OK
- LSTM streamflow never used as observed: OK

