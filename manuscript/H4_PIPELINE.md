# H4 pipeline — full picture (working document, updated 23 Nov 2026, ~11:20)

**Purpose.** One page that shows the whole H4 (uncertainty decomposition) pipeline
end-to-end: what runs where, with what data, why each design choice was made, what
exists already, what is running now, and exactly which numbers land in which paper
section. Every claim here is checkable against the file paths given.

---

## 1. Where H4 sits in the framework

The paper's five hypotheses, all pre-registered in `AGENTS.md`:

| Hypothesis | Question | Status | Verdict file |
|---|---|---|---|
| H1 | Does forcing-skill rank diverge from low-flow rank? | **DONE** 18 Nov — ρ = −0.027, CI [−0.095, 0.038] | `data_processed/lowflow/h1_verdict.md` |
| H2 | Do GR4J and GR6J diverge materially at low flows? | **DONE** 18 Nov — dry-tercile mam7 div −449 pp | `data_processed/gr6j/h2_verdict.md` |
| H3 | Do GCMs differ in reproducing observed SPI→SRI propagation? | **DONE** 18 Nov — prop_share 0.91–0.96, mean-flow selection misses it | `data_processed/prop/prop_verdict.md` |
| **H4** | **Who owns the variance in low-flow projections: GCM, hydrological structure, or bias-correction tail design?** | **IN PROGRESS — the only open phase** | `data_processed/decomp/h4_verdict.md` (to be produced) |
| H5 | Does the LSTM benchmark uniformly beat GR4J/GR6J at low flows? | **DONE** 19 Nov — wins magnitudes (0.71–0.95), loses drought duration (0.39) | `data_processed/bench/h5_verdict.md` |

Two-track rule (fixed 18 Nov): **Track A** (our substrate) = own QED-corrected
CMIP6 → GR4J/GR6J. **Track B** (CAMELS-IND-Proj) = audit object only, never
substrate. H4 is pure Track A.

**H4's decision rule (pre-registered 18 Nov 2026, unchanged):** GCM is expected to
dominate the variance; the **structure share is "non-negligible" if its median is
≥ 5% in at least one aridity tercile × metric × SSP × window**. Structure < 5%
everywhere ⇒ H4 fails — and that is itself the reportable result (Objective 4 then
collapses to GCM + bias correction).

---

## 2. The pipeline, end to end

```
 RAW CMIP6 SSP archive (read-only)
 D:/Datasets/Download_CMIP/SSP/{pr,tasmax,tasmin}/
   10,692 netCDF files | 14 GCMs x 4 SSPs x 3 variables | 2015-2100
   NOTE: NO 2061-2080 files exist at all (66 of 86 years per combo)
        |
        |  QED_40_ssp_aggregate.Rmd      [DONE 21 Nov]
        |  - catchment-mean aggregation (terra), magic-byte gate,
        |    completeness gate: aggregate only with all 66 years
        |  - idempotent; skips combos already aggregated
        v
 SSP aggregates
 data_processed/ssp/agg_<var>_<model>_<ssp>.csv
   162 of 168 combos complete
   6 MISSING: HadGEM3-GC31-MM x {ssp245, ssp370} x {pr,tasmax,tasmin}
     -> logged, data_processed/logs/ssp_unavailable.csv
        ("gcm_scenario_not_published"; never padded, never interpolated)
        |
        |  QED_50_ssp_apply.Rmd          [RUNNING x2, ETA ~12:00-12:15]
        |  - empirical quantile mapping, fit per (GCM x catchment x var x season)
        |    on the full historical window 1981-2014 (projection-application
        |    choice, pre-registered 18 Nov)
        |  - TAIL POLICY = second H4 factor level:
        |      linear   <- pre-registered default, the REPORTED run
        |      constant <- H4-only second level (env QED_SSP_TAIL=constant)
        |  - 23 Nov fix: per-tail high-tail slope for pr (section 0b, see §5)
        v
 Corrected forcing trees (policy-scoped, cannot collide)
 data_processed/ssp/qm_corrected_linear/<gcm>/<ssp>/<tier>/<id>_<var>.csv
 data_processed/ssp/qm_corrected_constant/<gcm>/<ssp>/<tier>/<id>_<var>.csv
   ~39,200 files each | columns: date, source_value, corrected_value, method_flag
   method_flag in {within_range, extrapolated_low, extrapolated_high, source_nan}
   NAs = 2061-2080 gap + Feb-29 of noleap models  (counted downstream, never filled)
        |
        |  DECOMP_10_ssp_metrics.Rmd     [WRITTEN + PILOTED, production pending]
        |  - roster: 192 catchments calibrated under BOTH structures
        |    (64 dry / 64 intermediate / 64 wet, from GR6J_30 aridity terciles)
        |  - reads corrected pr + tasmax + tasmin
        |  - Oudin PET identical to calibration (airGR::PE_Oudin, LatUnit deg)
        |  - drives calibrated GR4J (data_processed/hyd/params/<id>.rds)
        |    and calibrated GR6J (data_processed/gr6j/params/<id>.rds)
        |    SAME params, SAME PET, SAME warm-up rule -> only the factor differs
        |  - windows: 2021-2040, 2041-2060, 2082-2100
        |    warm-up: 365 days immediately before each (2020 / 2040 / 2081)
        |    -> no warm-up ever crosses the 2061-2080 gap
        v
 THE H4 INPUT TABLE
 data_processed/decomp/input_metrics.csv
   long format, one row per (catchment x metric x gcm x structure x tail_policy
   x ssp x window); ~622,080 rows expected
   columns: catchment, arid_tercile, ssp, window, metric, gcm, structure,
            tail_policy, value, metric_note, n_gap_filled,
            extrapolation_share, pr_max_mm, metric_version ("v1_proj")
   11,520 distinct ANOVA cells (192 x 5 metrics x 4 SSPs x 3 windows)
        |
        |  DECOMP_00_anova.Rmd            [EXECUTED 23 Nov 2026 — H4 STANDS]
        |  - ANOVA spec: manuscript/NOVELTY_AND_ANOVA_SPEC.md (v2, 23 Nov 2026)
        |  - balance guard: unbalanced cells logged (h4_dropped_cells.csv),
        |    never fitted
        |  - SATURATION (verified on the real input before any fit):
        |    rows per cell = |GCM| x 2 x 2 = 56 (52) = the full parameter
        |    count -> residual df = 0 -> the per-cell ANOVA is an EXACT
        |    VARIANCE PARTITION. No F, no p, no per-cell eta-partial
        |    (identically 1) or omega-squared (undefined). Type I anova()
        |    only (I = II = III here; car::Anova would return NaN and can
        |    break the render).
        |  - SEVEN reported terms: gcm, structure, tail_policy,
        |    gcm:structure, gcm:tail_policy, structure:tail_policy AND
        |    gcm:structure:tail_policy (never buried in a residual)
        |  - variance shares = SS_term / SS_total (= classical eta-squared
        |    in this balanced design)
        |  - tercile medians + catchment bootstrap (1,000 resamples, seed
        |    20261118) 95% CI on the structure share; catchments resampled,
        |    never rows
        |  - sensitivity (supplement, labelled): lme4::lmer(value ~
        |    structure * tail_policy + (1|gcm)) per cell -> random-effects
        |    GCM share vs fixed-effects share (the one H4 model with an
        |    error term); agreement within ~5 pp = robustness confirmed
        v
 H4 OUTPUTS (data_processed/decomp/)
   variance_shares.csv   per catchment x metric x ssp x window, SEVEN shares
   h4_summary.csv        tercile medians (all 7 terms) + bootstrap CI per
                         metric x ssp x window
   h4_verdict.md         verdict + saturation note + GCM coverage (13 vs 14)
                         + cell counts + lmer-sensitivity statement
   h4_lmer_sensitivity.csv  random-intercept GCM share per cell (supplement)
   h4_dropped_cells.csv  every excluded cell + reason code (guardrail 7)
        |
        v
 PAPER
   manuscript/paper.md section 5.5 (currently "Status of the projection leg",
   written 21 Nov BEFORE any result) is REPLACED by the H4 verdict;
   section 6 (Limitations) gains the 13-vs-14 GCM statement.
```

---

## 3. Why the decomposition has exactly three factors

> **Binding ANOVA/novelty spec: `manuscript/NOVELTY_AND_ANOVA_SPEC.md` (v2, 23 Nov
> 2026).** It fixes: the saturation statement (below), the seven-term reporting,
> the "no per-cell p-values" rule, the lmer sensitivity, the exact roster
> numbers, and the novelty claim/do-not-claim structure for the paper. If
> anything here conflicts with it, the spec wins — unless a dated
> pre-registration conflicts, in which case the pre-registration wins.

| Factor | Levels | What it isolates |
|---|---|---|
| `gcm` | 14 (13 for ssp245/ssp370) | Earth-system-model climate sensitivity/drought response |
| `structure` | GR4J / GR6J | hydrological model structure (GR6J's exponential store) |
| `tail_policy` | linear / constant | how far EQM may extrapolate beyond the training range |

Everything else is **held identical by construction**, which is what makes the
variance shares interpretable:

- same calibrated parameters (each catchment's own HYD_20 / GR6J_20 result);
- same Oudin PET (same corrected temperatures, same latitude);
- same warm-up rule (365 days immediately before the window — the `HYD_00` rule);
- same simulation code path, only `RunModel_GR4J` vs `RunModel_GR6J` swapped;
- same frozen evaluation window inside each projection window.

The GCM set is **stated, never balanced away**: ssp245/ssp370 run a 13-GCM
factorial (52 runs per catchment), ssp126/ssp585 a 14-GCM one (56 runs). Both are
balanced, which is all the ANOVA needs; `h4_gcm_coverage.csv` (written by
DECOMP_10) and the verdict file quote it.

### 3.1 What saturation means (spec v2 § 5.0 — read before interpreting any share)

- Rows per cell = |GCM| × 2 structures × 2 tail policies = **56** (ssp126/585)
  or **52** (ssp245/370). Parameters in `value ~ gcm * structure * tail_policy`
  = the same number → **residual df = 0**. DECOMP_00 verifies this arithmetic on
  the real `input_metrics.csv` **before** any fit and stops otherwise.
- The per-cell ANOVA is therefore an **exact variance partition, not a
  significance test**: no F, no p, no per-cell CI from the ANOVA; η²p ≡ 1
  (degenerate) and ω² undefined — **neither is computed**. The SS share over
  the seven terms **is** classical η² in this balanced design.
- This is **why the catchment bootstrap exists**: it is the inferential
  machinery (1,000 resamples of catchments, seed 20261118, percentile CI on the
  tercile-median structure share).
- The `lmer` random-intercept model (`value ~ structure * tail_policy +
  (1|gcm)`) is the only H4 model with an error term — run as a **labelled
  sensitivity** (`h4_lmer_sensitivity.csv`), agreement within ~5 pp confirms
  robustness; it never replaces the fixed-effects partition.
- Roster discipline for the paper: **472** is the setting, **192** is every H4
  claim, 78 the H1 composite; "11,520 cells" = 192 × 5 metrics × 4 SSPs × 3
  windows; "180 summary cells" = 3 terciles × 5 × 4 × 3.

---

## 4. The metric layer (pre-registered 21 Nov, `metric_version = "v1_proj"`)

Indicators, not biases — a projection has no observation to compare against. All
five are always defined (no all-NA cells expected), and no metric is ever
averaged into a composite (guardrail 5: one ANOVA per metric).

| metric | definition | reads as |
|---|---|---|
| `log10_q95` | log10(Q95 + 0.01 mm/d), Q95 = 5th percentile (type 7) of the window | magnitude of the low tail |
| `log10_mam7` | log10(mean annual min of the trailing 7-day mean + 0.01) | extreme low flow |
| `log10_meanq` | log10(mean daily flow + 0.01) | wetness context |
| `lf_ratio_q95` | Q95 / mean flow | shape of the low tail (threshold-free) |
| `dry_spell_days` | mean annual max spell below the window's own Q90 | low-flow persistence |

Two frozen-threshold drought-exposure metrics (`lf_deficit_mm` and
`dry_spell_days` against the observed 1981–2000 Q90) were **piloted and dropped
before any H4 number existed**: in the pilot they were identically zero for most
cells because projected flows sit above the historical 10th percentile, and a
zero-variance response has no variance share to decompose. The substitution is
recorded as a dated design note inside `DECOMP_10_ssp_metrics.Rmd` — it was a
metric-design decision made before the decomposition ran, not after seeing an H4
outcome.

---

## 5. The 23 Nov defect and fix (matters for the paper's methods text)

**Defect.** `qed_apply_eqm()` (QED_00) implements the `linear` tail by extending
*both* tails with the slope of the *lowest* CDF interval. For precipitation that
interval is a drizzle artefact — e.g. CanESM5/03008/DJF: `q_src = (0, 1.9e-10)`
mm/d against `q_ref = (0, 0.05)` mm/d — so the "slope" was 2.6×10⁸ mm/mm instead
of the true high-tail slope 2.11. A 60.13 mm/d future storm became **4.0×10⁹
mm/d**; a full-tree scan showed **9,985 of 13,068** corrected pr series with max
> 1000 mm/d (worst 1.7×10⁴²), 345,374 days above 500 mm/d.

**Fix v1 (per-tail slope) — measured insufficient.** Giving each tail its own
outermost CDF segment removed the drizzle-slope blow-up but not the pathology:
the outermost segment itself is numerically degenerate (its two top source
quantiles can be nearly identical), and the tree still peaked at **8,588 mm/d**
(11,260 days > 500). Caught by the new hard guard in QED_50's verification chunk.

**Fix v2 (final, user-approved scope).** QED_50 § 0b applies to `pr` only:
- **robust high-tail slope** — OLS over the top 5 CDF points (cov/var form).
  Slope census over all 5,324 pr fits: median 2.67, p95 7.4, p99 14.4 — the
  slope is legitimately large because GCM drizzle maps onto intense observed
  storms; no estimator alone can save the far tail;
- **physical ceiling** on extrapolated pr at **1,000 mm/d** (~8× the observed
  reference max, below the world-record 24-h rainfall of 1,825 mm). The
  pre-registered intent — "constant clamping would truncate intensified future
  rainfall extremes" — is preserved inside the ceiling: it binds only far
  beyond the mapped range, and every capped day is counted and logged.
- temperature and the `constant` policy untouched, so the historical leg (which
  used `constant` for pr anyway) and all H1–H3 results are unaffected.

**Validation.** Test render (1 model × 1 SSP × 5 catchments): max corrected pr =
1000.00 (the ceiling), 3 days > 500, 1 day capped. Full CanESM5/03008 series
under v2: max 151.9 mm/d for its own extremes. The `constant` tree audit found
zero files above 500 mm/d (max 464.15), so the policy contrast is clean.

**Audit trail.**
- pre-fix per-file maxima: `data_processed/logs/linear_pr_extreme_before_fix.csv`
- slope-estimator census (4 candidates × 20,867 fit-seasons):
  `C:/Users/ankit.deshmukh/AppData/Local/Temp/opencode/slope_estimator_test.csv`
- dated design note: `QED_50_ssp_apply.Rmd` § 0b (header note 3 updated)
- registry row: `manuscript/AGENT_LOG.md` entry 2026-11-23
- hard guards: QED_50 verification fails if any corrected pr > 1000 mm/d;
  DECOMP_10 fails if any `pr_max_mm > 1000`.

The H4 tail-policy factor is therefore: **"linear" = per-tail linear extension
with a robust upper-tail slope and a 1,000 mm/d physical ceiling (23 Nov 2026);
"constant" = clamp at the reference tail.** No pre-registered result was produced
before the fix, so nothing needs retracting.

---

## 6. What runs right now, and what is queued

| Job | State (20:00, 23 Nov) | ETA |
|---|---|---|
| QED_50 `constant` render | **DONE** — 39,204 files; audit: zero files > 500 mm/d (max 464.15) | — |
| QED_50 `linear` re-render (fix v2) | **DONE** — 39,204 files; max = 1,000 ceiling, 970 days capped; guard passed | — |
| DECOMP_10 production run | **DONE** — 622,080 rows, 192 catchments, zero exclusions; all checks passed | — |
| DECOMP_00 render | **DONE** — 11,514/11,520 cells decomposed (6 logged); **H4 STANDS** (149/180 cells ≥ 5%) | — |
| Paper §5.5 + abstract | **DONE** — written strictly from `h4_verdict.md` | — |

Queued, in order:

1. **DECOMP_10 production render** — RUNNING since 14:25. Writes
   `input_metrics.csv` + exclusions log; the notebook's own checks must all
   pass (balanced grid, no all-NA cells, `pr_max_mm <= 1000`).
2. **Grid verification** — balanced cells, `h4_gcm_coverage.csv` (expect 14/13/13/14
   GCMs for ssp126/245/370/585), flag columns complete.
3. **DECOMP_00 render** — 11,520 ANOVA cells + 1,000-resample bootstrap. Produces
   `variance_shares.csv`, `h4_summary.csv`, `h4_verdict.md`,
   `h4_dropped_cells.csv`. Runtime minutes.
4. **Paper update** — § 5.5 rewritten from the verdict file only; § 6 limitation
   sentence for the 13-GCM SSPs; § 4.3 gets the corrected-tail description.

---

## 7. What the paper will be able to say (hypotheses, not results)

> Novelty framing per spec v2: the headline is the **combination** —
> low-flow-aware selection with a formal ρ-divergence test, the GR4J/GR6J
> structural axis (lead contribution), propagation reproduction as a selection
> dimension, and a three-factor decomposition treating **tail design** as an
> explicit uncertainty source. ANOVA, the low-flow metrics and the SPI/SRI
> index are **borrowed** (Park 2025; Kim & Chung 2026; Senatore 2022) — concede
> in §2, claim the axes and the application. Never "first streamflow
> projection" (Sharma 2026 owns that).

Until the verdict lands, nothing below is asserted — these are the decision
branches the machinery is built to distinguish:

1. **GCM dominance confirmed, structure ≥ 5% somewhere** (H4 stands): the
   adaptation-relevant message is *which models you project with matters AND the
   hydrological structure is a first-order uncertainty source at low flows* —
   supporting the two-stage framework (selection + decomposition) and the GR6J
   axis.
2. **GCM dominance confirmed, structure < 5% everywhere** (H4 fails): reportable
   negative result — Objective 4 collapses to GCM + bias-correction uncertainty;
   the GR6J axis is then justified only by H2's historical divergence, not by
   projections. The paper says exactly that.
3. **Tail policy shares large**: the bias-correction design choice is itself a
   first-order uncertainty — feeds directly into the "their forcings inherit
   Mishra 2020 bias correction" Track-B argument with a quantified number.
4. **Stratified by aridity tercile** (the decomposition's key stratification):
   whether structure/tail uncertainty concentrates in dry catchments — the
   drought-adaptation reading.

The decomposition also quantifies the two-way interactions (`gcm:structure`,
`gcm:tail`, `structure:tail`), which is what "the three uncertainty sources are
not additive" looks like as evidence.

---

## 8. Levers you can change, and their consequences

| Lever | Where | Effect of changing it |
|---|---|---|
| Projection windows | `dec_windows` in DECOMP_10 config | bounded by the archive: no 2061–2080 exists; anything else breaks the warm-up rule |
| Metric set | `dec_metrics_vec` | changes `metric_version`; re-run DECOMP_10 + DECOMP_00; guardrail 5 (ρ > 0.9 de-dup) still applies before compositing anywhere |
| Tail-policy levels | `QED_SSP_TAIL` env | a third level would need a new QED_50 run per level (~40–90 min each) |
| Bootstrap count / seed | DECOMP_00 config | only affects CI width, never the point estimates |
| Structure threshold 5% | `decomp_h4_structure_min` | pre-registered; changing it after seeing results would invalidate the verdict — record a dated pre-registration change if ever needed |
| Catchment roster | DECOMP_10 roster chunk | 192 = both-structures-calibrated; shrinking it changes every share |

---

## 9. Guardrail compliance checklist for the H4 outputs

- [x] Out-of-sample discipline: calibration 1981–2000 untouched; projections use
      calibrated parameters on 2021–2100 windows only; thresholds window-relative.
- [x] No metric averaging: one ANOVA per metric per tercile per (SSP, window).
- [x] No silent drops: `metric_note`, `DECOMP_10_exclusions.csv`,
      `h4_dropped_cells.csv`, `n_gap_filled`, `extrapolation_share` on every row.
- [x] Explicit gaps: 2061–2080 excluded (never interpolated); 6 HadGEM3 combos
      logged, never padded.
- [x] Machhar-type trap avoided: no SPI≈SRI inference anywhere in H4.
- [x] New modules parallel: `DECOMP_10` is new; `QED_50`/`DECOMP_00` were built
      earlier in this project and were never part of the original `QED_00–30` /
      `HYD_*` series.
- [x] Reproducibility: seeds recorded (decomp_seed 20261118), session-info files
      written by both notebooks, all outputs tracked in git except bulk series.

---

## 10. File index (everything H4 touches)

| Path | Role |
|---|---|
| `QED_40_ssp_aggregate.Rmd` | raw .nc → catchment-mean SSP aggregates (162/168) |
| `QED_50_ssp_apply.Rmd` | EQM apply × tail policy → corrected trees |
| `DECOMP_10_ssp_metrics.Rmd` | corrected forcings → GR4J/GR6J projections → `input_metrics.csv` |
| DECOMP_00_anova.Rmd | `input_metrics.csv` -> variance shares -> `h4_verdict.md` (**H4 STANDS**: structure >= 5% in 149/180 summary cells; dry-tercile structure share 0.66/0.68 for Q95/mam7 vs GCM ~0.22; tail policy <= 0.5% everywhere; log10_meanq: GCM 0.95) |
| `data_processed/decomp/` | all H4 outputs (this document's §2 tail) |
| `data_processed/ssp/qm_corrected_{linear,constant}/` | corrected forcing trees |
| `data_processed/hyd/params/<id>.rds`, `data_processed/gr6j/params/<id>.rds` | calibrated parameters (192 each) |
| `data_processed/gr6j/struct_metrics.csv` | aridity terciles (64/64/64) |
| `data_processed/logs/ssp_unavailable.csv` | 6 HadGEM3 gaps, reason-coded |
| `data_processed/logs/linear_pr_extreme_before_fix.csv` | pre-fix defect evidence |
| `manuscript/AGENT_LOG.md` | dated registry row for the fix + metric change |
| `manuscript/paper.md` § 5.5, § 4.3, § 6 | where the verdict lands |
