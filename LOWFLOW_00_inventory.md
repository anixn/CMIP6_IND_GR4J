# LOWFLOW_00_inventory.md — Function & convention inventory for the low-flow module

_Generated 2026-11-18 by a read-only subagent scan (no code changed)._
_Scope: `AGENTS.md`, `QED_README.md`, all `QED_*`/`HYD_*` Rmd notebooks, and
headers of the `data_processed/{qed,hyd}/*.csv` outputs the new low-flow module
will consume. Line numbers refer to the files as of this scan._

---

## 1. Metric functions (KGE / NSE / PBIAS)

Two independent metric stacks exist. **There is no log-NSE / log-KGE anywhere in
the repo** — the low-flow module will have to introduce it (with its own
zero-flow guard) and carry a `metric_version` column per AGENTS.md.

### 1.1 QED stack — `hydroGOF` (QED_30_rank_and_report.Rmd)

Used for the *forcing-based* ranking (corrected vs observed catchment-mean
forcings, per variable pr/tasmax/tasmin).

| Function | File:line | Signature | Notes |
|---|---|---|---|
| `hydroGOF::KGE` | QED_30_rank_and_report.Rmd:107 (corrected), :113 (raw) | `KGE(sim, obs)` positional | wrapped in `tryCatch(..., error = function(e) NA_real_)` |
| `hydroGOF::NSE` | QED_30_rank_and_report.Rmd:109 (corrected), :115 (raw) | `NSE(sim, obs)` | same tryCatch pattern |
| `hydroGOF::pbias` | QED_30_rank_and_report.Rmd:111 (corrected), :117 (raw) | `pbias(sim, obs)` (returns %) | same tryCatch pattern |

Pre-filtering before the call (QED_30_rank_and_report.Rmd:102–105): paired mask
`ok <- !is.na(x_corrected) & !is.na(ref) & !is.na(x_src) & !is.na(ref)`;
require `sum(ok) >= 365` valid days, else the (model, catchment, var) row is
skipped entirely.

**Zero-flow handling: none.** No log transform, no epsilon, no divide-by-zero
guard — irrelevant for pr/tas (never zero at the metric level), but a template
the low-flow module must not copy blindly for discharge.

### 1.2 HYD stack — hand-rolled (`kge_calc` / `nse_calc` / `pbias_calc`)

Used for the *discharge-based* ranking (GR4J sim vs observed Q, mm/day).
Defined **twice with identical bodies** (copy-paste, not sourced from setup):

| Function | File:line | Signature | Notes |
|---|---|---|---|
| `kge_calc` | HYD_20_calibrate.Rmd:121–129; duplicated at HYD_30_simulate.Rmd:86–92 | `function(o, s)` (obs first, sim second) | pairs on `!is.na(o) & !is.na(s)`; returns `NA_real_` if `length(o) < 365` **or `sd(o) == 0`** (constant-obs guard); decomposed Gupta KGE `1 - sqrt((r-1)^2 + (alpha-1)^2 + (beta-1)^2)` |
| `nse_calc` | HYD_20_calibrate.Rmd:130–134; duplicated at HYD_30_simulate.Rmd:93–96 | `function(o, s)` | plain Nash–Sutcliffe; **no** zero-variance / zero-flow guard beyond NA-pairing |
| `pbias_calc` | HYD_20_calibrate.Rmd:135–138; duplicated at HYD_30_simulate.Rmd:97–100 | `function(o, s)` | `100 * sum(s - o) / sum(o)`; **no guard** against `sum(o) == 0` (a zero-flow-sum window would give `NaN/Inf`) |

Argument order caveat: the HYD stack is `(o, s)` (obs first) whereas
`hydroGOF::KGE(sim, obs)` is (sim first). Any new module must pick one order and
document it.

**Zero-flow guard status summary:**
- HYD `kge_calc`: guarded against zero-variance obs (`sd(o) == 0`) and short
  windows (<365 paired days) — the closest thing to a zero-flow guard in the repo.
- HYD `nse_calc` / `pbias_calc`: unguarded.
- QED `hydroGOF` calls: unguarded, but wrapped in tryCatch → `NA_real_`.
- No `logNSE`, no `Q + eps` offset, no flow-duration/low-flow metric exists yet.

---

## 2. Rank / composite functions

### 2.1 Forcing-based ranking — QED_30_rank_and_report.Rmd §2 (`r ranking`, lines 137–166)

1. Per-catchment metrics (lines 65–131) → `model_metrics_per_catchment.csv`
   (`model, id, var, n_valid, n_extrap_val, kge_corr, nse_corr, pbias_corr,
   kge_raw, nse_raw, pbias_raw`).
2. Aggregate: **median across Tier 1 catchments** per `(model, var)` (lines
   139–147) — median, not mean.
3. Ranks within each `var` (lines 150–155):
   - `rank_kge  <- data.table::frank(-kge_corr, na.last = "keep"), by = var`
   - `rank_nse  <- data.table::frank(-nse_corr, na.last = "keep"), by = var`
   - `rank_pb   <- data.table::frank(abs(pbias_corr), na.last = "keep"), by = var`
   - `frank` default `ties.method = "average"` (not stated explicitly in QED_30;
     HYD_30 does state it).
4. `composite := rank_kge + rank_nse + rank_pb` per (model, var) (line 156).
5. Overall: `mean_composite = mean(composite, na.rm = TRUE)` across the 3 vars
   by model, then `[order(mean_composite)]` (lines 159–160). **Ties broken only
   by `order()` stability (input row order); no explicit tiebreak key.** Lower
   total = better.

Output key columns of `model_ranking_overall.csv`: `model, mean_composite,
n_vars`. By-var output `model_ranking_by_var.csv`: `model, var, <6 metric
medians>, n_catch, rank_kge, rank_nse, rank_pb, composite`.

### 2.2 Discharge-based ranking — HYD_30_simulate.Rmd §4 (`r ranking`, lines 218–244)

1. Per-catchment per-model sim metrics `hyd_sim_summary.csv` (see §6).
2. Per-catchment ranks within each `id` (lines 222–224):
   - `rank_kge   <- data.table::frank(-kge,   ties.method = "average"), by = id`
   - `rank_nse   <- data.table::frank(-nse,   ties.method = "average"), by = id`
   - `rank_pbias <- data.table::frank(abs(pbias), ties.method = "average"), by = id`
3. Model table `rank_table` (lines 226–236): `n_catchments, mean_kge,
   median_kge, mean_nse, mean_pbias, rank_sum_kge, rank_sum_nse,
   rank_sum_pbias, extrap_pct` `by = model` — rank **sums** here (unlike QED_30's
   per-var medians → per-var ranks).
4. `composite_rank_sum := rank_sum_kge + rank_sum_nse + rank_sum_pbias`
   (line 238), ordered ascending, `discharge_rank := seq_len(.N)` (lines
   239–240). Ties: only via the stable `order(composite_rank_sum)`; explicit
   `"average"` tie method at the per-catchment frank level.
5. Agreement with QED ranking (§5, lines 250–255): merge on `model`,
   `rank_shift := qed_rank - discharge_rank`, Spearman
   `cor(discharge_rank, qed_rank, method = "spearman")` printed to console.
   Written to `ranking_agreement.csv`.

### 2.3 Hybrid shortlist — `data_processed/hyd/model_shortlist_final.csv`

Not produced by any current notebook (assembled manually after HYD_30; the
notebook's take-away says "top-14 under BOTH rankings"). Columns: `model,
qed_forcing_rank, gr4j_discharge_rank, hybrid_rank_mean, selected, note`. The
low-flow module should treat `selected == 1` as the 14-model SSP roster.

---

## 3. Screening conventions (Tier 1/2/3)

### 3.1 Tier definition (QED_10_inventory_tiers.Rmd)

Thresholds in QED_00_setup.Rmd:55–60: Tier 1 ≥ 0.70 availability, Tier 2 ≥ 0.30,
hard floor `qed_min_days_for_qm = 3650` valid days for any tier, forcing QA
`qed_forcing_min_availability = 0.95`. Availability measured over the fixed
daily index 1981-01-01..2014-12-31 (12,418 days, asserted at
QED_10_inventory_tiers.Rmd:48).

Tier assignment logic (QED_10_inventory_tiers.Rmd:149–163):
`tier3_too_few_days` (n_valid < 3650) → `tier1` (≥0.70) → `tier2` (≥0.30) →
`tier3_low_availability`.

Final action (QED_10_inventory_tiers.Rmd:198–203): `excluded_no_forcing` if
forcing QA missing, `correct_with_warning` if forcing QA < 0.95, else the tier.

### 3.2 Who gets modelled (HYD_10/HYD_20/HYD_30)

- `hyd_ok_tiers <- c("tier1", "tier2", "correct_with_warning")`
  (HYD_00_setup.Rmd:74–75) — Tier 3 never modelled; warning-tier still modelled.
- HYD_10 drops catchments with no `cwc_area` → `hyd_skipped_no_area.csv`
  (HYD_10_inputs.Rmd:50–58), columns `id, reason`.
- HYD_20 drops catchments with < 3650 valid Q days inside the calibration run
  window → `status = "skipped_less_than_3650_valid_Q_in_calib"` row kept in
  `hyd_calib_summary.csv` (HYD_20_calibrate.Rmd:71–75).
- HYD_30 roster = `hyd_calib_summary[status == "calibrated"]` intersected with
  existing `params/<id>.rds` (HYD_30_simulate.Rmd:44–55).

### 3.3 Reason codes & logs actually present

There is **no `data_processed/logs/` directory yet** (AGENTS.md convention not
yet instantiated). Current logs and their reason codes:

| File | Columns | Reason codes / values |
|---|---|---|
| `data_processed/qed/tier3_handling_log.csv` | `catchment_id, option, reason, availability, n_valid_days, note` | `option = "C"`; `reason ∈ {tier3_too_few_days, tier3_low_availability}` |
| `data_processed/qed/inventory.csv` | `id, availability_frac, n_valid_days, tier, forcing_ok, final_action` | `final_action ∈ {tier1, tier2, tier3_too_few_days, tier3_low_availability, correct_with_warning, excluded_no_forcing}` |
| `data_processed/qed/excluded_not_in_universe.csv` | `id, reason` | `"not in streamflow+forcing+shapefile intersection"` |
| `data_processed/qed/qm_run_summary.csv` | `model, id, var, tier, status, n_overlap, bins_used, n_extrap, frac_extrap` | `status ∈ {fitted, fitted_annual_fallback, skipped_overlap_lt_3650, skipped_no_fit_possible}` |
| `data_processed/hyd/hyd_skipped_no_area.csv` | `id, reason` | `"no cwc_area in topo attributes"` |
| `data_processed/hyd/hyd_calib_summary.csv` | `id, status, kge_calib, nse_calib, kge_valid, nse_valid, pbias_valid, param_x1..x4` | `status ∈ {calibrated, skipped_less_than_3650_valid_Q_in_calib, "error:<msg>"}` (error rows are logged to `hyd_20_log.txt`, not always as CSV rows) |
| `data_processed/hyd/hyd_sim_summary.csv` | see §6 | error rows carry all-NA metrics |

---

## 4. Flag conventions (`within_range` / `extrapolation` / `n_gap_filled`)

**Creation — `qed_apply_eqm` (QED_00_setup.Rmd:227–268).** Returns a
data.table with columns `x_src, x_corrected, within_range, extrapolated_low,
extrapolated_high`. `within_range = !na & !low & !high`; `extrap = "constant"`
clamps to reference tail (pr policy), `"linear"` extends the outermost CDF
segment slope (temperature policy); pr clamped to ≥ 0 (line 266). NA in → NA
out, never filled.

**First persistence — QED_20 (lines 197–235).** Corrected CSVs
`qm_corrected/<model>/<tier>/<id>_<var>.csv` carry
`date, source_value, corrected_value, method_flag` where `method_flag ∈
{within_range, extrapolated_low, extrapolated_high, source_nan}`
(line 219–222). `qm_run_summary.csv` carries `n_extrap, frac_extrap`.

**Propagation — HYD_30 (lines 110–118, 176–194).**

- `hyd_read_corrected()` reads `date, corrected_value, method_flag` and renames
  `method_flag` → `flag_<var>` (pr/tasmax/tasmin), so flags travel with the
  series into the model loop.
- Evaluation-window flags are counted per (catchment, model):
  `n_extrap_values = sum(flags_eval != "within_range" & !is.na(flags_eval))`
  (lines 182, 192–193).
- **`n_gap_filled` is created in HYD_30** (line 147–156, 194): Feb-29 NAs from
  noleap GCM calendars (and other interior gaps) are filled — temps by
  `zoo_gapfill` linear interpolation (lines 103–108), pr by 0 mm — and the
  count is stored as `n_gap_filled` in `hyd_sim_summary.csv`. Unfillable gaps
  raise an error ("unfillable input gaps") which is logged, never silent.
- Downstream persistence of flags: `model_metrics_per_catchment.csv`
  (`n_extrap_val`), `hyd_sim_summary.csv` (`n_extrap_values, n_gap_filled`),
  `model_ranking_discharge.csv` (`extrap_pct`).
- **AGENTS.md-mandated `extrapolation_share` column does not exist yet** — the
  closest are `frac_extrap` (QED) and `extrap_pct` (HYD). The low-flow module
  should add the canonical name.

---

## 5. Calibration setup (GR4J, HYD_20_calibrate.Rmd)

| Element | Value | Reference |
|---|---|---|
| Structure | GR4J via airGR (`airGR::RunModel_GR4J`), daily, lumped | HYD_00_setup.Rmd:59 |
| Inputs | `P_mm` (mm/day), `PET_mm` — Oudin 2005 via `airGR::PE_Oudin` (Tmean = (tmax+tmin)/2, catchment lat), alt. Hargreaves implemented `hyd_pet_hargreaves` (HYD_00_setup.Rmd:79–89) | HYD_10_inputs.Rmd:87–98 |
| Period | 1981-01-01 .. 2014-12-31 (`hyd_period_*`) | HYD_00_setup.Rmd:41–43 |
| Calibration window | 1981-01-01 .. 2000-12-31 (`hyd_calib_*`) | HYD_00_setup.Rmd:45–46 |
| Validation window | 2001-01-01 .. 2014-12-31 (`hyd_valid_*`) | HYD_00_setup.Rmd:47–48 |
| Warm-up | first **365 days** of the full series (all of 1981) as `IndPeriod_WarmUp`; run indices start after it (`i_run_cal` = 1982-01-01..2000-12-31) — i.e. **the calibration year 1981 is entirely warm-up, effective calibration data = 1982–2000** | HYD_20_calibrate.Rmd:53–59 |
| Objective function | `airGR::ErrorCrit_KGE` on `Qobs_mm` (mm/day model space) | HYD_20_calibrate.Rmd:90–95 |
| Optimizer | `airGR::Calibration_Michel` (local search) with `CreateCalibOptions(RunModel_GR4J)` | HYD_20_calibrate.Rmd:61, 97–100 |
| Units | Q stays in mm/day throughout; `Q[mm/d] = Q[m3/s] × 86.4 / Area[km2]` | HYD_00_setup.Rmd:70 |
| Skip rule | < 3650 valid Q days inside the calibration run window → skipped, logged | HYD_20_calibrate.Rmd:71–75 |
| Evaluation | full continuous run 1982–2014 with calibrated params; KGE/NSE/PBIAS recomputed by hand on calib and validation slices; Qsim indexed as `i - hyd_warmup_days` | HYD_20_calibrate.Rmd:102–119 |
| Saved artifacts | `params/<id>.rds` = `list(id, param, area_km2)`; `hyd_calib_summary.csv` | HYD_20_calibrate.Rmd:151–152, 160–162 |

HYD_30 re-uses exactly the same indices, warm-up and evaluation window for the
CMIP6-driven simulations (HYD_30_simulate.Rmd:78–84), applying the catchment's
calibrated parameters to bias-corrected CMIP6 forcings.

---

## 6. Data schema of the consumer-facing outputs

Headers read directly from the CSVs (first data row in parentheses where
useful).

### 6.1 `data_processed/hyd/model_shortlist_final.csv`

```
model, qed_forcing_rank, gr4j_discharge_rank, hybrid_rank_mean, selected, note
```
units: ranks = integers (1 = best); `hybrid_rank_mean` = mean of the two ranks;
`selected` = 0/1; `note` free text (e.g. "both top-3").

### 6.2 `data_processed/hyd/hyd_sim_summary.csv`

```
id, model, kge, nse, pbias, n_eval_days, n_extrap_values, n_gap_filled
```
units: `id` = 5-digit CAMELS-IND gauge ID (character, e.g. "03005"); `kge`,
`nse` dimensionless (rounded 3dp); `pbias` percent (rounded 2dp, sim−obs over
obs); `n_eval_days`, `n_extrap_values`, `n_gap_filled` = day counts within the
2001–2014 evaluation window. One row per catchment × model.

### 6.3 `data_processed/hyd/model_ranking_discharge.csv`

```
model, n_catchments, mean_kge, median_kge, mean_nse, mean_pbias,
rank_sum_kge, rank_sum_nse, rank_sum_pbias, extrap_pct,
composite_rank_sum, discharge_rank
```
units: metrics dimensionless / percent; `extrap_pct` percent of evaluation
days flagged extrapolated; `discharge_rank` 1 = best (ascending
`composite_rank_sum`).

### 6.4 `data_processed/hyd/ranking_agreement.csv`

```
model, discharge_rank, qed_rank, rank_shift
```
units: integer ranks; `rank_shift = qed_rank - discharge_rank`.

### 6.5 `data_processed/qed/model_ranking_overall.csv`

```
model, mean_composite, n_vars
```
units: `mean_composite` = mean of per-variable rank sums (lower better);
`n_vars` = 3 for all-variable models. Companion
`data_processed/qed/model_ranking_by_var.csv` holds
`model, var, kge_corr, nse_corr, pbias_corr, kge_raw, nse_raw, pbias_raw,
n_catch, rank_kge, rank_nse, rank_pb, composite`.

### 6.6 Supporting tables (for completeness)

- `data_processed/hyd/hyd_calib_summary.csv`: `id, status, kge_calib,
  nse_calib, kge_valid, nse_valid, pbias_valid, param_x1, param_x2, param_x3,
  param_x4` (X1/X2 mm & mm/d, X3 mm, X4 days — airGR GR4J units).
- `data_processed/hyd/hyd_inputs_summary.csv`: `id, area_km2, n_valid_Q,
  n_valid_P, PET_mm_yr` (PET mm/year over 1981–2014).
- `data_processed/qed/inventory.csv`: `id, availability_frac, n_valid_days,
  tier, forcing_ok, final_action`.
- `data_processed/qed/qm_run_summary.csv`: `model, id, var, tier, status,
  n_overlap, bins_used, n_extrap, frac_extrap`.
- `qm_corrected/<model>/<tier>/<id>_<var>.csv`: `date, source_value,
  corrected_value, method_flag`.

---

## 7. Open questions (conventions not determinable from the code)

1. **No log-scale / low-flow metrics exist.** No `logNSE`, no Q7/Q10, no
   flow-duration metrics, no epsilon/offset convention for zero-flow days. The
   HYD `nse_calc`/`pbias_calc` have **no zero-flow guard at all** (a
   zero-mean or zero-sum obs window would produce `NaN`/`Inf` silently passed
   through rounding). The low-flow module must define its own guard and log it.
2. **Tie-breaking at the composite level is implicit.** Both rankings break
   final ties only by stable row order of `order()` / `data.table` grouping —
   no documented secondary key. QED_30's `frank` calls don't even state
   `ties.method` explicitly (inherits `"average"`). New module should declare
   an explicit tiebreak.
3. **`data_processed/logs/` does not exist.** AGENTS.md specifies
   `logs/<module>_exclusions.csv` with `module, catchment, reason_code,
   detail`, but current exclusion logs are scattered under `qed/` and `hyd/`
   with non-standard column names (`id` vs `catchment_id`, `reason` vs
   `reason_code`). Low-flow module should follow AGENTS.md, not precedent.
4. **`extrapolation_share` does not exist** under that name; `frac_extrap`
   (per QM fit, full 1981–2014) vs `extrap_pct` (per HYD eval window) differ in
   denominator and window. Canonical column name/window needs a decision.
5. **Metric averaging is already in place without the AGENTS.md §5
   duplicate-check:** QED_30 sums rank(KGE)+rank(NSE)+rank(|PBIAS|) — KGE and
   NSE ranks are near-duplicates by construction; no pairwise-ρ check is
   recorded anywhere. The low-flow module's compositing must run the check.
6. **Warm-up consumes calibration year 1981.** The stated "calibration window
   1981–2000" is effectively scored over 1982–2000 (1981 = warm-up, run starts
   1982-01-01). Confirm whether the low-flow module should score 1982–2000 or
   re-derive 1981 data with a separate warm-up run.
7. **Which roster the SSP projection layer uses** for future windows is
   implied but not coded: `model_shortlist_final.csv` `selected == 1`
   (14 models), but no notebook reads that file yet.
8. **`hyd_sim_summary.csv` contains rows with all-NA metrics** (error rows
   from HYD_30's inner tryCatch) — consumers must filter (`!is.na(kge)` as
   HYD_30 does) and decide whether error rows need a `reason_code` column.
9. **Rank table row count:** `hyd_sim_summary.csv` includes Tier-2
   `correct_with_warning` catchments; the QED ranking uses Tier 1 only
   (`tier1_ids.txt`). The pilot ρ = 0.14 (AGENTS.md) was computed on these two
   different rosters — fine for the pilot, but the H1 re-estimation should fix
   one roster.
10. **`QED_05_aggregate_cmip6.Rmd` helper `qed_nc_dates()`** (line 87) is the
    only function not inventoried in detail (raw-NetCDF date extraction;
    upstream of everything above, not consumed by the low-flow module).

---

## 8. Function index (complete, by file)

| Function | File:line | Signature |
|---|---|---|
| `qed_normalize_id` | QED_00_setup.Rmd:107 | `function(x)` → 5-digit IDs |
| `qed_month_to_season` | QED_00_setup.Rmd:122 | `function(month, seasons = qed_seasons)` |
| `qed_date_to_season` | QED_00_setup.Rmd:128 | `function(dates, seasons = qed_seasons)` |
| `qed_full_dates` | QED_00_setup.Rmd:133 | `function(start = qed_period_start, end = qed_period_end)` |
| `qed_longest_run` | QED_00_setup.Rmd:138 | `function(ok)` → longest TRUE run |
| `qed_log` | QED_00_setup.Rmd:147 | `function(msg, log_file = NULL)` |
| `qed_read_forcing` | QED_00_setup.Rmd:159 | `function(path, var_cols = qed_camels_var_cols)` |
| `qed_read_agg` | QED_00_setup.Rmd:175 | `function(path)` → list(ids, dates, values) |
| `qed_get_series` | QED_00_setup.Rmd:189 | `function(agg, id)` |
| `qed_fit_eqm` | QED_00_setup.Rmd:204 | `function(src, ref, n_q = qed_n_quantiles)` |
| `qed_apply_eqm` | QED_00_setup.Rmd:227 | `function(x, fit, extrap = "constant")` |
| `qed_nc_dates` | QED_05_aggregate_cmip6.Rmd:87 | (NetCDF date extraction; upstream only) |
| `hyd_pet_hargreaves` | HYD_00_setup.Rmd:79 | `function(doy, tmax, tmin, lat_deg)` |
| `hyd_normalize_id` | HYD_00_setup.Rmd:92 | `function(x)` |
| `hyd_log` | HYD_00_setup.Rmd:101 | `function(msg, log_file = NULL)` |
| `hyd_read_forcing` | HYD_00_setup.Rmd:108 | `function(path)` |
| `hyd_read_q_obs` | HYD_00_setup.Rmd:123 | `function(id)` |
| `idx` | HYD_20_calibrate.Rmd:50 | `function(d) which(full_dates >= d & full_dates <= d)` |
| `kge_calc` | HYD_20_calibrate.Rmd:121; HYD_30_simulate.Rmd:86 | `function(o, s)` |
| `nse_calc` | HYD_20_calibrate.Rmd:130; HYD_30_simulate.Rmd:93 | `function(o, s)` |
| `pbias_calc` | HYD_20_calibrate.Rmd:135; HYD_30_simulate.Rmd:97 | `function(o, s)` |
| `zoo_gapfill` | HYD_30_simulate.Rmd:103 | `function(x)` linear interior-gap fill |
| `hyd_read_corrected` | HYD_30_simulate.Rmd:111 | `function(model, tier, id, var)` |
