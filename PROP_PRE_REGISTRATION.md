# PROP_PRE_REGISTRATION.md — drought-propagation test (H3 / Objective 3)

**Pre-registered: 18 November 2026** (before any CMIP-driven SRI is computed
and before any model is compared on propagation skill). This file is the
pre-registration required by AGENTS.md guardrail 6; its date is part of the
record. Later edits must be additive, dated, and flagged — never silent.

## 1. Definitions (fixed now, before implementation)

* **Monthly aggregation.** Calendar-month totals, per catchment:
  precipitation = sum of daily catchment-mean pr (mm); streamflow = sum of
  daily Q in mm/day (observed `Qobs_mm`, or GR4J-simulated `Qsim`). A month
  is *valid* only if ≥ 80% of its days are present.
* **SPI-12 / SRI-12.** 12-month rolling accumulation → standardized:
  gamma distribution fitted by maximum likelihood to the accumulation
  sample (1981–2014 reference period), standardized via the normal quantile
  transform. No zero-inflation adjustment (12-month accumulations in
  Peninsular India are practically never zero; if a catchment does contain
  zeros the catchment is excluded, reason `zero_accumulation`).
  Fitting convention fixed: `MASS::fitdistr(..., "gamma")`, shape/scale
  parameterization; the SAME convention for observed and modelled series.
* **Propagation time (the only allowed definition).** The lag
  `L ∈ {0, 1, ..., 12}` months maximizing the Pearson cross-correlation
  between the SPI-12 series and the SRI-12 series **lagged by L months
  behind SPI** (SRI responds after SPI). Ties → smallest lag.
  **The Machhar-type trap is forbidden:** propagation must never be inferred
  from near-identity of SPI and SRI. The diagnostic `mean|SRI − SPI|` is
  computed and reported ONLY as an artefact check (values ≈ 0.013 signal
  too-tight precipitation–runoff coupling in the model, not a climate
  finding), and it must never enter the ranking.

## 2. Data sources (fixed now)

* **Observed leg:** CAMELS-IND catchment-mean precipitation and observed
  streamflow (`Qobs_mm`), 1981–2014, catchments in the HYD calibrated roster
  (params exist). Series requirements: ≥ 144 valid months of SRI input and
  ≥ 144 valid months of SPI input; else excluded, reason
  `insufficient_months`.
* **Model leg:** the LOWFLOW_00 daily series cache
  (`data_processed/lowflow/series/<id>.rds`): model-corrected SPI-12 from the
  corrected `pr` (model column), SRI-12 from the GR4J `Qsim` driven by that
  corrected forcing. **No GR6J here** — the GR6J axis (O2) is a separate
  comparison, not part of the H3 pre-registration.

## 3. The tolerance band (the pre-registered object)

For every catchment, the observed propagation lag `L_obs` is computed from
observed data ONLY (no model in the loop). The band is:

> **A model "reproduces" a catchment's propagation time iff
> `|L_model − L_obs| ≤ 1 month`** (one monthly aggregation unit, absolute).

* `L_obs` and the roster after exclusions are frozen in
  `data_processed/prop/observed_lags.csv` **before** any model SRI is
  computed; the freeze date is recorded in that file's companion log.
* Band = ±1 month is fixed now; it is NOT tuned after seeing model results.
* Sensitivity with band ±2 months is allowed as a *reported* secondary
  number, clearly labelled, never used for the verdict.

## 4. Test statistics and the H3 decision rule

Per model: `prop_share` = share of roster catchments reproduced (band above).

* **Primary verdict input:** `prop_share` per model (22 models).
* **H3 is FALSIFIED** (mean-flow selection suffices) iff ALL of:
  1. every one of the 22 models has `prop_share ≥ 0.80`, **and**
  2. the inter-model spread `max(prop_share) − min(prop_share) < 0.10`
     (models do not differ materially), **and**
  3. the Spearman correlation between the QED forcing composite rank
     (`model_ranking_overall.csv` order) and `prop_share` exceeds 0.6
     (mean-flow selection already finds propagation skill).
  Otherwise **H3 stands** (models differ, and/or mean-flow selection misses
  propagation skill) — including partially: report which clause(s) failed.
* **Secondary (reported, not verdict-bearing):** per-catchment KS test of each
  model's lag distribution against the observed inter-catchment lag
  distribution; the "all 22 models inside the observed distribution" wording
  of AGENTS.md is operationalized by clause 1–2 above plus these KS tests as
  supporting evidence.
* Negative or partial results are reported as results (AGENTS.md guardrail 4).

## 5. Outputs planned (implementation module: `PROP_00_indices.R` → `PROP_10_lag.R`)

| file | content |
|---|---|
| `data_processed/prop/observed_lags.csv` | frozen `L_obs` + exclusion reasons + freeze timestamp |
| `data_processed/prop/prop_model_lags.csv` | `model, catchment, L_model, delta_lag, reproduced, mean_abs_SRI_SPI (diagnostic)` |
| `data_processed/prop/prop_model_scores.csv` | per-model `prop_share`, KS p-value, diagnostic artefact check |
| `data_processed/prop/h3_verdict.md` | verdict against the rule in §4, with date |

## 6. Signatures

Pre-registered by the OpenCode agent on behalf of Ankit Deshmukh,
18 Nov 2026, commit to be recorded in `manuscript/AGENT_LOG.md`.
