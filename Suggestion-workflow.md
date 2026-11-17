# Agent Instructions: CAMELS-India Data Preparation & Quantile Mapping Workflow

## 0. Objective

Build a reproducible pipeline that:

1. Filters 400+ CAMELS-India catchments by **streamflow data availability within 1981–2014**.
2. Assigns catchments to **three analysis tiers** based on completeness.
3. Performs **quantile mapping** of climate model data against **CAMELS-India catchment-mean forcings**, stratified by tier.
4. Produces transparent logs, reports, and outputs that document every filtering decision.

**Period of interest:** 1981-01-01 → 2014-12-31 (inclusive).
**Reference dataset for QM:** CAMELS-India catchment-mean meteorological forcings.

---

## 1. Configuration Block (create this first)

Create a single config file (e.g., `config.yaml`) with the following keys. The agent must read all thresholds from here — **do not hardcode thresholds inside scripts.**

```yaml
paths:
  camels_root: "<path to CAMELS-IND root>"
  streamflow_dir: "<path>/streamflow"
  forcing_dir: "<path>/forcings" # catchment-mean forcings
  boundaries_dir: "<path>/boundaries"
  metadata_file: "<path>/camels_ind_metadata.csv"
  lstm_pred_dir: "<path>/lstm_streamflow" # optional gap-filling
  output_dir: "./outputs"

period:
  start: "1981-01-01"
  end: "2014-12-31"

thresholds:
  tier1_min_availability: 0.70 # >=70% valid days in period
  tier2_min_availability: 0.30 # 30-70%
  min_days_for_qm: 3650 # ~10 years minimum to fit QM (hard floor for any tier)
  missing_value_flags: [-999, -9999, -999.0, "NaN", ""]

qm:
  method: "empirical" # or "parametric"
  n_quantiles: 100
  extrapolation: "constant" # or "linear" for tails
  min_quantile_sample: 300 # min valid days per quantile bin per season

outputs:
  save_tier_csv: true
  save_availability_report: true
  save_qm_params_per_catchment: true
  save_logs: true
```

---

## 2. Step-by-Step Tasks

### Step 1 — Inventory & Discovery

**Goal:** Discover what files exist and in what format, before any filtering.

1. Recursively list all files under `streamflow_dir`, `forcing_dir`, `boundaries_dir`.
2. For each streamflow file, parse the **catchment ID** from the filename (follow CAMELS-IND naming convention; if ambiguous, log the pattern and ask).
3. Load `metadata_file` and confirm the list of catchment IDs. Cross-check that every ID in metadata has a matching streamflow and forcing file.
4. Write `outputs/inventory.csv` with columns: `catchment_id`, `streamflow_file_exists`, `forcing_file_exists`, `boundary_file_exists`, `start_date`, `end_date`, `n_records_total`.

**Acceptance check:** Every catchment in metadata is accounted for; missing files are logged but do not halt the pipeline.

---

### Step 2 — Compute Availability Within the Exact Period

**Goal:** Compute **valid-day availability specifically within 1981–2014**, not over the whole record. This is the single most important filtering step.

1. For each catchment, read the streamflow time series.
2. Parse dates; restrict to `[period.start, period.end]`.
3. Build a **complete daily date index** for the period (do not trust the file's own index — files may silently omit rows).
4. Reindex the series to the complete daily index.
5. Replace all `missing_value_flags` with `NaN`.
6. Compute:
   - `n_days_in_period` = total days in 1981–2014 (should be 12,418 — verify, leap years included).
   - `n_valid_days` = count of non-NaN discharge values.
   - `availability = n_valid_days / n_days_in_period`.
   - `first_valid_date`, `last_valid_date` (within the period).
   - `longest_gap_days` (max consecutive NaN run) — flag this for transparency.
7. Write `outputs/availability_report.csv` with all columns above.

**Acceptance check:** No catchment is dropped yet — this is purely diagnostic. Report the distribution of `availability` (min, median, max, count ≥0.70, count 0.30–0.70, count <0.30).

---

### Step 3 — Assign Tiers

**Goal:** Stratify catchments explicitly so downstream analysis never pools across data-quality regimes.

Apply this logic per catchment:

| Condition                                                               | Tier                     | Use in QM pipeline                                                   |
| ----------------------------------------------------------------------- | ------------------------ | -------------------------------------------------------------------- |
| `availability >= 0.70` **and** `n_valid_days >= min_days_for_qm`        | **Tier 1 (Core)**        | Full QM calibration + application                                    |
| `0.30 <= availability < 0.70` **and** `n_valid_days >= min_days_for_qm` | **Tier 2 (Extended)**    | QM calibration with caveats; separate outputs                        |
| `availability < 0.30` **or** `n_valid_days < min_days_for_qm`           | **Tier 3 (Exploratory)** | **Do not calibrate QM**; reserve for validation / LSTM gap-fill only |

1. Write `outputs/tier_assignment.csv` with columns: `catchment_id`, `availability`, `n_valid_days`, `tier`, `rationale`.
2. Emit a console summary: counts per tier, list of catchment IDs per tier (or file paths to per-tier lists in `outputs/tier1_ids.txt`, etc.).

**Acceptance check:** Every catchment has exactly one tier. No catchment with `n_valid_days < min_days_for_qm` is assigned Tier 1 or 2.

---

### Step 4 — Forcing Data Cleaning (Reference Dataset)

**Goal:** Prepare CAMELS-India catchment-mean forcings as the QM reference. These are provided as catchment-mean forcings in CAMELS-India — do **not** re-aggregate from any other gridded product unless explicitly instructed.

1. For each catchment in Tier 1 and Tier 2, load the forcing file (precipitation and temperature at minimum).
2. Restrict to `[period.start, period.end]`; reindex to complete daily index; replace missing flags with `NaN`.
3. Record `forcing_availability` (same logic as Step 2) into `outputs/forcing_availability.csv`.
4. **Flag any catchment where forcing availability < 0.95 within the period** — this indicates a problem with the reference itself and must be logged (do not silently proceed).

**Acceptance check:** All Tier 1/2 catchments have forcing availability ≥ 0.95, or are explicitly flagged in the log.

---

### Step 5 — Quantile Mapping Setup (per catchment, per variable)

**Goal:** Fit an empirical quantile mapping from a **model/source distribution** to the **CAMELS-India forcing reference distribution**, using only Tier 1/2 catchments.

For each catchment `c` and variable `v` (e.g., `pr`, `tas`):

1. **Reference series:** CAMELS-India catchment-mean forcing for `c`, restricted to 1981–2014, `NaN`-filtered.
2. **Source series:** the climate model / dataset to be bias-corrected, co-located to catchment `c` (agent should accept this as an input path — if not provided, halt and ask).
3. Restrict both series to the **overlapping valid dates**.
4. Verify `len(overlap) >= min_days_for_qm`; otherwise skip this catchment-variable pair and log the skip reason.
5. Fit empirical CDFs:
   - `F_ref` on reference values.
   - `F_src` on source values.
6. Define the mapping: `x_corrected = F_ref^{-1}( F_src(x_source) )`.
7. For values falling outside the source CDF range (tails), apply `qm.extrapolation` policy from config (`constant` recommended for precipitation; `linear` optional for temperature).
8. **Seasonal stratification:** fit separate mappings for DJF, MAM, JJA, SON if `min_quantile_sample` is met per season; otherwise fall back to annual mapping and log the fallback.

**Acceptance check:** Every Tier 1/2 catchment × variable has either (a) a saved QM parameter object, or (b) a logged, explicit skip reason.

---

### Step 6 — Apply QM and Save Outputs

1. Apply each fitted mapping to the full source series for that catchment (not just the overlap window — but flag extrapolated regions in metadata).
2. Save corrected series to `outputs/qm_corrected/{tier}/{catchment_id}_{variable}.csv` with columns: `date`, `source_value`, `corrected_value`, `method_flag` (e.g., `within_range`, `extrapolated_low`, `extrapolated_high`).
3. Save QM parameters (empirical quantile pairs) to `outputs/qm_params/{catchment_id}_{variable}.npz` (or `.json`).

**Acceptance check:** No `NaN` in `corrected_value` except where `source_value` was `NaN` on input.

---

### Step 7 — Tier 3 Handling (Do Not Calibrate QM)

For Tier 3 catchments:

1. **Do not** fit or apply quantile mapping.
2. **Option A (validation use):** If a nearby Tier 1/2 catchment has a fitted QM, optionally apply that mapping and flag the result as `transferred_from: <donor_id>` in the output metadata. This is for **validation only**, never as primary data.
3. **Option B (LSTM gap-fill):** If `lstm_pred_dir` is available, load the LSTM-predicted streamflow for that catchment, mark it clearly as `model_derived`, and **do not treat it as observed discharge** in any quantile fit.
4. **Option C (exclude):** Simply exclude from the QM pipeline and document why.

The agent must emit `outputs/tier3_handling_log.csv` documenting which option was chosen per catchment and why.

---

### Step 8 — Validation & Reporting

Produce a single summary report `outputs/PIPELINE_REPORT.md` containing:

1. **Data inventory summary:** counts of files found, missing, parse errors.
2. **Availability distribution:** histogram or table of `availability` across all 400+ catchments; specifically report counts in each tier.
3. **Tier roster:** explicit catchment IDs in each tier (or reference to `outputs/tier*_ids.txt`).
4. **QM coverage table:** for each Tier 1/2 catchment × variable, indicate `fitted`, `skipped (<min_days)`, `skipped (forcing gap)`, `seasonal fallback used`.
5. **Extrapolation summary:** count and fraction of corrected values that fell outside the source CDF range, per catchment.
6. **Reproducibility block:** config hash, code version (git commit), timestamp, random seeds (none should be used; if any, list them).

**Acceptance check:** The report renders without missing sections and all numeric summaries are internally consistent (e.g., tier counts sum to total catchments).

---

## 3. Hard Rules (Do Not Violate)

1. **Never pool Tier 1, 2, and 3 catchments in a single quantile fit.** Always stratify.
2. **Never replace the CAMELS-India catchment-mean forcing reference with a different gridded product** unless explicitly instructed and fully documented.
3. **Never reindex to a partial calendar.** Always build the full daily index for 1981–2014 and treat absent rows as `NaN` before counting valid days.
4. **Never silently drop catchments.** Every excluded catchment must appear in a log with a reason.
5. **Never extrapolate without flagging.** Every corrected value outside the source quantile range gets a `method_flag`.
6. **Never treat LSTM-predicted streamflow as observed** in any quantile fit.

---

## 4. Deliverables Checklist

- [ ] `config.yaml` (final, committed)
- [ ] `outputs/inventory.csv`
- [ ] `outputs/availability_report.csv`
- [ ] `outputs/tier_assignment.csv`
- [ ] `outputs/tier1_ids.txt`, `tier2_ids.txt`, `tier3_ids.txt`
- [ ] `outputs/forcing_availability.csv`
- [ ] `outputs/qm_params/*.npz`
- [ ] `outputs/qm_corrected/tier1/*.csv`, `tier2/*.csv`
- [ ] `outputs/tier3_handling_log.csv`
- [ ] `outputs/PIPELINE_REPORT.md`
- [ ] `logs/run_<timestamp>.log`

---

## 5. Suggested Execution Order (for the agent)

```
1. Load config
2. Inventory files                -> inventory.csv
3. Compute availability in period -> availability_report.csv
4. Assign tiers                   -> tier_assignment.csv
5. Clean forcing data (T1, T2)    -> forcing_availability.csv
6. Fit QM (T1, T2)                -> qm_params/*.npz
7. Apply QM (T1, T2)              -> qm_corrected/**
8. Handle Tier 3                  -> tier3_handling_log.csv
9. Generate report                -> PIPELINE_REPORT.md
```
