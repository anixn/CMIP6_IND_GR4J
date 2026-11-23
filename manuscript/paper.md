---
bibliography: references.bib
link-citations: true
lang: en
---

# A two-stage framework for selecting CMIP6 Earth-system models for catchment-scale low-flow and drought projection over Peninsular India

*Empirical quantile mapping onto CAMELS-IND forcings, GR4J/GR6J-based hydrological evaluation, and uncertainty decomposition for out-of-sample model shortlisting*

**Ankit Deshmukh** — draft v0.6, 23 November 2026 (v0.2 18 Nov, v0.3–0.4 18 Nov, v0.5 21 Nov)

> **Status: O1–O5 all executed with verdicts (§5.1–5.5); H4 executed 23 Nov 2026
> (`data_processed/decomp/h4_verdict.md`, H4 STANDS).** Novelty framing and the
> H4 ANOVA specification are governed by `manuscript/NOVELTY_AND_ANOVA_SPEC.md`
> (v2, 23 Nov 2026). Points needing the full literature survey are marked
> **[TODO: survey]**.

---

## Abstract

Scenario-driven water-availability and drought studies over Indian catchments depend on which CMIP6 models feed the hydrological analysis, yet model selection is usually arbitrary or inherited from global assessments. We present the **first low-flow-aware CMIP6 model-selection framework for Peninsular India at the 472-catchment scale** (CAMELS-IND universe), combining a formal forcing-vs-low-flow rank-divergence test, a GR4J/GR6J structural-uncertainty axis, drought-propagation reproduction as a selection dimension, and a three-factor variance decomposition (GCM × structure × bias-correction tail policy) that treats tail design as an explicit uncertainty source — a combination novelty: the ANOVA machinery, the low-flow metrics and the SPI/SRI index are borrowed, the axes, the selection logic and the application are new. **Stage one** bias-corrects daily CMIP6 precipitation and temperature (1981–2014, 22 all-variable models) onto catchment-mean forcings with seasonal empirical quantile mapping (EQM) and ranks models on *out-of-sample* forcing skill (fit 1981–2000, score 2001–2014). **Stage two** drives calibrated GR4J and GR6J (192 catchments calibrated under both structures; calibration median KGE 0.80, out-of-sample 0.54) with each bias-corrected series and evaluates low-flow realism. The executed results: **(H1)** forcing-skill and low-flow-skill ranks are essentially orthogonal (Spearman ρ = −0.027, 95% CI [−0.095, 0.038]) — one-stage forcing selection cannot stand in for low-flow selection; **(H2)** GR4J and GR6J diverge materially and low-flow-specifically at observed forcings (dry-tercile 7-day-minimum divergence −449 pp); **(H3)** all 22 models reproduce the observed SPI-12→SRI-12 propagation lag (propagation share 0.91–0.96), so mean-flow selection does not find propagation skill (ρ = −0.350); **(H5)** the CAMELS-IND-Proj LSTM benchmark wins low-flow *magnitudes* (win shares 0.71–0.95) but loses drought *duration* (0.39) — its dry tail is not uniformly superior. **(H4)** the GCM × structure × tail-policy decomposition of projected low-flow variance (192 catchments, 4 SSPs, 3 future windows, 11,520 saturated-design cells) shows hydrological model structure is non-negligible in **149 of 180** summary cells — it is the *largest* single uncertainty source for extreme low flows in dry catchments (66–68% of variance for Q95 and 7-day minima, versus ~23% for GCM choice), GCM dominates whole-flow variance (95–96%), and the EQM tail policy is a negligible source (≤ 0.5%) — the variance-level confirmation that mean-flow-based selection cannot arbitrate low-flow projection uncertainty.

## 1. Objective framing

**Headline claim (spec v2 §1 — use verbatim or near-verbatim; the rest of the paper is supporting evidence for this sentence):**

> We present the first low-flow-aware CMIP6 model-selection framework for Peninsular India at the 472-catchment scale, combining a formal forcing-vs-low-flow rank-divergence test, a GR4J/GR6J structural-uncertainty axis, drought-propagation reproduction as a selection dimension, and a three-factor variance decomposition (GCM × structure × bias-correction tail policy) that treats tail design as an explicit uncertainty source.

**Primary objective.** Determine *which CMIP6 models are fit for low-flow and drought projection over Peninsular India — and how much that answer depends on the hydrological model structure and the bias-correction design* — through an out-of-sample, hydrologically-evaluated selection framework, and deliver the resulting projection engine as the core of a national low-flow/drought programme.

**Scale honesty (roster numbers are exact and never interchangeable — full table in `NOVELTY_AND_ANOVA_SPEC.md` §2).** "472-catchment scale" names the framework's setting (the CAMELS-IND / CAMELS-IND-Proj universe). The decomposition itself runs on the **192** catchments calibrated under both structures (64/64/64 aridity terciles), the H1 composite on **78** non-ephemeral catchments, the H2 base case on **172** paired catchments, and the frozen propagation lags number **167**. "472" never attaches to an ANOVA, divergence or correlation sentence; each roster number is stated exactly where it first appears.

**Sub-objectives (each with a pre-registered decision rule; negative results are reported as results):**

| # | Objective | Hypothesis | Decision rule |
|---|---|---|---|
| O1 | Low-flow metric layer: rank models on low-flow skill (logNSE, Q95 bias, low-flow volume bias, dry-spell bias, 7-day min bias), test divergence from forcing skill | **H1** forcing rank ≠ low-flow rank | Fails if pooled Spearman ρ > 0.6 → framework collapses to one stage |
| O2 | GR6J structural axis: quantify GR4J–GR6J divergence in low-flow projections, stratified by aridity/baseflow storage | **H2** structures differ materially | Fails if indistinguishable across catchment types |
| O3 | Drought-propagation selection: SPI-12 → SRI-12 propagation time as a selection criterion (pre-registered tolerance band) | **H3** mean-flow selection misses propagation skill | Fails if all 22 models reproduce observed propagation within band |
| O4 | Uncertainty decomposition: ANOVA of GCM × structure × EQM tail policy on low-flow projection variance | **H4** GCM dominates, structure ≥ 5% matters | Fails if structure share < 5% everywhere (still a publishable negative result) |
| O5 | C21 benchmark: audit CAMELS-IND-Proj LSTM projections against GR4J/GR6J low-flow skill | **H5** LSTM does not uniformly win at low flows | If LSTM dominates everywhere, publish as benchmark confirmation, framed as such from the outset |

**Two-track design (fixed 18 Nov 2026).** *Track A (substrate, ours):* own QED-corrected CMIP6 series (14 hybrid-shortlisted GCMs × 4 SSPs) → GR4J/GR6J → low-flow projections. *Track B (benchmark, theirs):* CAMELS-IND-Proj is used **only** as the audited object of O5/H5 — never as substrate, never as input to our models. Rationale: their forcings inherit the coarse-scale Mishra et al. (2020) [@mishra2020biascorrected] bias correction (no catchment tuning, no tail-policy axis — using them would kill O4), and analysis-only papers of another group's product compete with the producers on their home turf. Method-level contributions survive scooping; data-application papers do not.

**Combination novelty (spec v2 §1).** The novelty is a *combination* — low-flow lens + GR4J/GR6J axis + propagation selection + three-factor decomposition — and is stated as such so no reviewer reads the paper as claiming a new method: the ANOVA (Park et al. 2025 [@park2025jhrs]; Kim & Chung 2026 [@kimchung2026hess]; Senatore et al. 2022 [@senatore2022med]), the low-flow metrics and the SPI/SRI index are borrowed; the axes, the selection logic and the application are new (§2 concedes this in the same table).

## 2. Prior-art positioning

| Group / product | What they own | Why our lane survives |
|---|---|---|
| **Sharma, Barbhuiya & Gupta 2026 [@sharma2026hp]** (*Hydrol. Process.* 40(3) e70476; IIT Mandi) — **closest prior art** | India-wide future streamflow; 4 structures (MILC/GR4J/HBV/HYMOD); 12 GCMs; 128 basins | No GR6J, no low-flow-specific selection, no forcing-vs-low-flow divergence test, no propagation-time selection, no uncertainty decomposition. They note "uncertainty existed for low flow events" but do not formalise it — we do |
| **Park, Kim, Sung & Chung 2025 [@park2025jhrs]** (*J. Hydrol.: Reg. Stud.* 62:102991, doi:10.1016/j.ejrh.2025.102991) | ANOVA of uncertainty contributions to hydrologic drought projection, South Korea | **Method borrowed — conceded here and in §4.2**; Korea not India; no GR4J/GR6J axis; no tail-policy factor. *(exact factor list verified at camera-ready)* |
| **NA** (*HESS* 30:227–247, doi:10.5194/hess-30-227-2026) | ANOVA of GCM × SSP × calibration-condition × calibration-length for future drought, South Korea (SWAT, SDI, 20 CMIP6 GCMs; GCM > 60% for runoff; calibration-related 3.9–9.8%) | **Method borrowed; single structure (SWAT) so no structural axis; no bias-correction factor.** Cited in §2 *and* §4.2 — HESS is a target journal and its reviewers will know this paper |
| NA (Mediterranean ANOVA of GCM + bias correction) *(full citation verified at camera-ready)* | ANOVA with bias-correction method as a factor | Method borrowed; not India, no GR4J/GR6J axis, not catchment-scale 192 — which is why P4's claim says **"tail design"**, never "bias correction" generically |
| **Cannon, Sobie & Murdock 2015 [@cannon2015qm]** (*J. Climate* 28(17):6938–6959, doi:10.1175/JCLI-D-14-00754.1) + **Themeßl, Gobiet & Heinrich 2012 [@themessl2012ecc]** (*Climatic Change* 112(2):449–468) | Quantile-mapping/error-correction choices materially alter extremes and the climate-change signal | Not competitors — the **methodological anchors for the `tail_policy` factor** (cited in §4.2/§4.3). The 23 Nov EQM defect (a drizzle-interval slope turning 60 mm/d into 4.0×10⁹ mm/d pre-fix) is a concrete instance of exactly the failure class Cannon documents |
| Liu et al. 2025 [@liu2025atmosphere] (*Atmosphere* 16(6):691, doi:10.3390/atmos16060691 — journal corrected 23 Nov 2026, previously mis-cited as "Climate") | CMIP6 selection + streamflow + hydrological drought (SWAT+MODFOOD) | Single-basin scale; no 192-catchment out-of-sample rank; no rank-divergence test. *(complete author list at camera-ready)* |
| **India Drought Monitor + Drought Atlas of India** (Chuphal et al. 2024 [@chuphal2024droughtatlas], *Sci. Data*; IITGN) + bias-corrected CMIP6 South Asia (Mishra et al. 2020 [@mishra2020biascorrected], *Sci. Data*) | Meteorological/agricultural drought monitoring at 0.05° (1901–2020); coarse-scale bias-corrected CMIP6 | No streamflow drought at catchment scale; bias correction not catchment-tuned, not seasonally stratified, not hydrologically evaluated, not out-of-sample ranked |
| **CAMELS-IND** (Mangukiya et al. 2025 [@mangukiya2025camelsind], ESSD) + **CAMELS-IND-Proj** (Singh et al. 2026 [@singh2026camelsindproj], Zenodo 21775597) + MARRMoT adequacy benchmark (Mangukiya et al. 2026 [@mangukiya2026wrr], WRR) | Datasets; regional LSTM projections (13 GCMs × 4 SSPs); model-adequacy benchmarking | No low-flow-aware analysis of their own product yet; LSTM dry tail unaudited; we are the first critical process-based user. GR4J is in their 5-model sufficient set (WRR 2026) — independent support for our structural choice, cited as an ally, not a competitor |
| **India Drought Atlas operational ecosystem** (IITGN) | Monitoring infrastructure with institutional appetite | Our streamflow-drought layer is a candidate addition to that ecosystem (roadmap Phase 5), not a competitor to it |
| Tiwary & Mondal 2026 (EGU abstract) | Historical Q7min trends, 55 minimally-regulated catchments | Historical description; ours is projections + selection + uncertainty |
| Meresa et al. 2023; Wang et al. 2025 *(full citations verified at camera-ready)* | CMIP6 drought propagation (Ireland; other) | Propagation analysis exists elsewhere; the **selection use** over Indian catchments is new (§4.2 states the index is borrowed) |

**Conceded machinery (state once here, do not hide):** seasonal EQM, the low-flow metric suite (logNSE, Q95/mam7/volume/dry-spell biases), the SPI/SRI construction and the cross-correlation lag, and multi-way ANOVA variance decomposition are all standard or borrowed (NA; NA; NA). What is claimed as new is stated in §1: the axes, the selection logic, and the application.

## 3. Data

- **CAMELS-IND** (NA, ESSD 17:461; Zenodo 14999580): daily catchment-mean forcings (pr, tasmax, tasmin), observed streamflow, 211 attributes, 472 catchments, 1981–2014 (12,418 days; forcings complete). Area (`cwc_area`, km²) and latitude (`cwc_lat`) from the topography file.
- **CMIP6 historical**: daily `pr`, `tasmax`, `tasmin`, 24 models over the Indian domain; CESM2 and IITM-ESM precipitation-only → excluded; **22 all-variable models** form the selection pool. HadGEM3-GC31-MM 360-day calendar handled (invalid Feb 29/30 → NA). Single members (`r1i1p1f1` or nearest).
- **CMIP6 scenarios (Track A)**: the hybrid-shortlisted **14 models × 4 SSPs (ssp126, ssp245, ssp370, ssp585)** × near (2015–2040), mid (2041–2060), long (2081–2100) windows. ssp370 added 18 Nov 2026 to complete the AR6 core scenario matrix and align with CAMELS-IND-Proj's 4-SSP design.
- **Scenario acquisition and QC**: 11,088 daily files expected (14 models × 4 SSPs × 3 variables × 66 window years; 2061–2080 never downloaded, by design). Acquisition is variable-major into `Download_CMIP/SSP/{pr,tasmax,tasmin}/` (20 Nov 2026). Two acquisition facts are recorded here because they are data-quality facts, not logistics. (i) Several ESGF THREDDS nodes intermittently returned a Java stack trace (`StorageExceptionNotActive`) as the HTTP body, which the R client wrote to disk as `<name>.nc`; every file is therefore validated by **magic bytes** (`\x89HDF` for netCDF-4/HDF5, `CDF\x01` for netCDF-3) before use, and non-netCDF files are excluded with reason `not_netcdf_error_page`. The 21 Nov scan of the full archive found **0** remaining, i.e. the re-fetches succeeded. (ii) The archive also holds two models dropped from the hybrid shortlist (`GISS-E2-1-G`, `INM-CM5-0`; 831 files), logged and ignored. A model × SSP × variable combo enters the pipeline only when all 66 years are present (§4.3).
- **CAMELS-IND-Proj** (NA, Zenodo 21775597, CC BY 4.0; EcoHydro Lab IIT Roorkee): daily LSTM streamflow 2015–2100, 13 GCMs × 4 SSPs, historical-per-GCM runs and forcings included; ~11.3 GB; `filter_catchment_model_scenario.py` for subsetting. **Track B only.** The project brief's confidence-flag construct was checked against the distributed archive and is **not present in the data** (no flag/mask file; aggregate header is exactly year/month/day + 472 gauge columns — §5.4); the paper therefore does not use it. **[TODO: survey]**

## 4. Methods

### 4.1 Historical leg (complete)
1. **Tiering** by forcing availability (1981–2014): Tier 1 ≥70% (180), Tier 2 ≥30% (62), Tier 3 excluded (230) — all logged.
2. **Aggregation**: area-weighted catchment means per model × variable (66 series per model).
3. **Seasonal EQM**: per variable × season (DJF/MAM/JJA/SON) × catchment; bins ≥300 days with annual fallback (331 of 15,972 fits); tie-collapsed CDF; tail policies pr=constant / T=linear for the historical evaluation; every value flagged (`within_range` vs extrapolation), flags counted never hidden.
4. **Out-of-sample forcing ranking**: EQM fit 1981–2000 → score 2001–2014 → KGE/NSE/PBIAS composite rank sum; natural break after rank 14 (non-overlapping out-of-sample KGE for every variable).
5. **GR4J hydrological leg**: airGR; Oudin PET; Q[mm/d] = Q[m³/s]×86.4/A[km²]; warm-up 1981; calibrate 1982–2000 (Michel local search on 1−KGE); validate out-of-sample 2001–2014 (KGE/NSE/PBIAS, PBIAS manual); <3,650 valid Q-days → skip and log. 192 of 242 calibrated.
6. **CMIP-driven discharge evaluation**: calibrated parameters driven with all 22 corrected series; scored on observed 2001–2014 discharge; per-catchment ranks → composite discharge ranking. Leap-day gaps of 365-day-calendar models filled conservatively (pr→0, T→interpolated), counted in `n_gap_filled`.

### 4.2 Phase methods (O1, O2, O3, O5 executed — verdicts in §5.1–5.4; O4 pending, §4.3)
- **Low-flow metric layer (O1)**: logNSE, Q95 bias, low-flow volume bias (below observed Q90), dry-spell bias, mean annual 7-day minimum bias — computed 2001–2014 only; composite rank after pairwise ρ>0.9 de-duplication.
- **GR6J axis (O2)**: GR6J (6 parameters) via airGR, identical inputs/windows/warm-up/optimizer as GR4J, calibrated on the same catchments; divergence `div = GR6J − GR4J` (difference for logNSE; percentage points for the % bias metrics — not divided by GR4J, which would explode near zero biases; documented deviation, pre-registered in `GR6J_00_setup.Rmd`); stratified by aridity tercile (annual PET/P); materiality thresholds pre-registered (logNSE ≥ 0.10 or ≥ 10 pp); direction reported, never claimed as superiority.
- **Propagation (O3)**: SPI-12/SRI-12 (gamma-MLE + normal-quantile transform, identical convention both sides — **the index is borrowed; the selection use is the contribution**); propagation time **defined exclusively** as the SPI–SRI cross-correlation lag (0–12 months, ties → smallest) — **never** inferred from SPI≈SRI near-identity (the Machhar-type artefact; mean |SRI−SPI| computed as diagnostic only); tolerance band `|L_model − L_obs| ≤ 1 month` and the falsification rule (all models ≥ 80% reproduced AND spread < 0.10 AND ρ(forcing rank, prop_share) > 0.6) pre-registered in `PROP_PRE_REGISTRATION.md` (18 Nov 2026) **before** any model SRI was computed; observed lags frozen (167 catchments).
- **Decomposition (O4 — methods frozen 23 Nov 2026, spec `NOVELTY_AND_ANOVA_SPEC.md` §5):**
  1. **Full factorial design** `value ~ gcm × structure × tail_policy`, balanced within every cell; **11,520 cells** (192 catchments × 5 indicators × 4 SSPs × 3 windows); GCM coverage **14/13/13/14** (HadGEM3-GC31-MM has no published ssp245/ssp370 — logged, never padded).
  2. **Saturation statement.** 56 (52) observations per cell equal the full parameter count, so the design has **no residual df**: the per-cell analysis is an **exact variance partition, not a significance test** — no F, no p, no per-cell CI from the ANOVA. Inference rests on the pre-registered rule and the catchment bootstrap, not per-cell F-tests. The arithmetic is verified on the real input table before any fit (`DECOMP_00`, saturation check).
  3. **Variance shares** = SS_term / SS_total over the **seven** terms (3 main effects, three 2-way, and the 3-way interaction, always reported) — classical η² in this balanced design; η²p is identically 1 and ω² undefined under saturation, so neither is computed.
  4. **Tail-policy levels, precisely.** `linear` = per-tail linear extension beyond the training CDF range (per-tail applier for pr, corrected 23 Nov 2026, `QED_50` §0b); `constant` = clamp at the reference tail. Anchored with Cannon et al. (2015) [@cannon2015qm] and Themeßl et al. (2012) [@themessl2012ecc]; one factual sentence on the 23 Nov defect (a drizzle-interval slope turned 60 mm/d into 4.0×10⁹ mm/d before the fix) as evidence that tail design is consequential — the fix preceded any H4 result, and the historical leg used `constant` for precipitation, so H1–H3 are unaffected.
  5. **Catchment bootstrap** (1,000 resamples, seed 20261118) for 95% CIs on the tercile-median structure share; catchments are resampled because factor levels within a catchment are not independent draws.
  6. **Pre-registered 5% threshold** for "structure non-negligible" (dated 18 Nov 2026, unchanged; §5.5 reports where it holds and where it does not).
  7. **Fixed-GCM caveat:** shares describe the stated shortlist, not the CMIP6 population.
  8. **Tercile is a stratification, not a factor** in the ANOVA; tercile contrasts are descriptive (medians + bootstrap CIs).
  9. **Multiplicity:** the decision rule is a disjunction over 180 summary cells (3 terciles × 5 indicators × 4 SSPs × 3 windows); noted as a limitation (§6).
  10. **Sensitivity (supplement, labelled):** `lmer(value ~ structure × tail_policy + (1|gcm))` per cell — residual df ≈ 47–51 — reported as a robustness check next to the fixed-effects partition, never as the primary result.
- **Benchmark (O5)**: same low-flow metric suite applied to CAMELS-IND-Proj historical-per-GCM runs (skill) and 2015–2100 projections (projected change); distributions and per-catchment win rates, stratified by confidence flag and aridity; the LSTM product is benchmarked, never regenerated.

### 4.3 SSP projection leg (the substrate for O4)

Two notebooks, parallel to the historical chain and leaving every `QED_*`/`HYD_*` notebook untouched.

**Aggregation (`QED_40_ssp_aggregate.Rmd`).** Raw daily NetCDF → area-weighted (cos-latitude) catchment means on the 24,206-day window grid (2015–2040 + 2041–2060 + 2081–2100). The 2061–2080 gap is absent by design and travels downstream as a counted gap, never as an interpolated one. Unit handling is identical to the historical leg (pr kg m⁻² s⁻¹ → mm/day, K → °C; the 360-day HadGEM3-GC31-MM calendar is mapped day 1..30 of real months, invalid dates → NA). Three gates protect the output: (i) **magic-byte validation** of every input file (§3), so a server error page can never be read as a year of data; (ii) a **completeness gate** — a combo is aggregated only when all 66 window years are present, because a half-downloaded series would produce NA-window low-flow metrics that are not low-flow metrics; (iii) a **per-combo status table** (`qed_40_combo_status.csv`, 168 rows) that makes partial progress visible instead of inferred. Aggregation is idempotent: a combo already written is skipped, so the notebook can be re-run as acquisition fills, and every incomplete combo is logged with its year count and reason code.

**EQM application (`QED_50_ssp_apply.Rmd`).** EQM is fitted per catchment × variable × season on the **full historical 1981–2014** pair (observed CAMELS-IND reference vs each model's historical aggregate) and applied to each SSP series with `pr` tail policy **linear**. Every corrected value carries `within_range` / `extrapolated_low` / `extrapolated_high` / `source_nan`, and every run writes `qed_50_run_summary.csv` with per-model × SSP × catchment × variable status and extrapolation share; combos lacking a complete aggregate are reported as `skipped_ssp_agg_missing`, never silently omitted.

**Tail-policy levels (the H4 factor — defined precisely, per spec v2 §4.2 item 4).** `linear` = per-tail linear extension beyond the training CDF range: each tail is extended with the slope of its own upper/lower CDF segment, estimated as an OLS fit over the outermost five CDF points (anchored: Cannon et al. 2015 [@cannon2015qm]; Themeßl et al. 2012 [@themessl2012ecc]). `constant` = clamp at the reference tail (the historical leg's precipitation policy). One factual sentence on why tail design is consequential: during a 23 Nov 2026 audit, the pre-fix `linear` implementation extended *both* tails with the slope of the *lowest* CDF interval — for precipitation a drizzle artefact (~10⁻¹⁰ mm/d) — turning a 60 mm/d future storm into 4.0×10⁹ mm/d; 9,985 of 13,068 corrected precipitation series exceeded 1,000 mm/d. The corrected applier (robust upper-tail slope plus a 1,000 mm/d physical ceiling on extrapolated precipitation, capped days counted and logged) was in place **before any H4 result existed**, and the historical leg used `constant` for precipitation, so the H1–H3 results are unaffected. The `constant` level is an H4-only experiment (`QED_SSP_TAIL` override), never a reported projection.

**Why the fit window differs from the ranking window.** The 1981–2000 fit / 2001–2014 score discipline exists to stop a model being *scored* on data used to *fit its correction*. Projection application is not scoring — there is no observation in 2015–2100 to score against — so the projection EQM is fitted on all available historical data to minimise correction error. The deviation is dated (18 Nov 2026) in `QED_40` so it is reviewable rather than implicit.

O4's decomposition (GCM × structure × tail policy) runs on the metric table these two notebooks produce; production facts are recorded because they bear on credibility: the aggregation path was validated end-to-end on one complete combo *before* production (365/366 layers, correct dates, pr in mm/day with a 145 mm/day extreme against a 602 mm/day historical maximum), the first QED_40 attempt **silently wrote zero files while reporting success** (a `split()` dot-vs-pipe keying bug, caught by comparing expected with written counts), and a 6-worker parallel version was abandoned after `std::bad_alloc` inside `terra` on a 15.7 GB machine — the sequential runtime (~2 min per combo) is a measured choice, not an oversight. The decomposition itself executed 23 Nov 2026: §5.5.

## 5. Results

**GR4J split-sample performance** (192 of 242 Tier-1/2 catchments; 50 skipped, logged):

| Window | median KGE | median NSE | share NSE > 0.5 |
|---|---|---|---|
| Calibration 1982–2000 | 0.80 | 0.64 | 0.66 |
| Validation 2001–2014 (out-of-sample) | 0.54 | 0.43 | 0.43 |

**Hybrid shortlist (top 7 of 14; full table: `data_processed/hyd/model_shortlist_final.csv`):**

| Hybrid | Model | QED | DIS | mean PBIAS [%] |
|---|---|---|---|---|
| 1 | EC-Earth3-Veg-LR | 1 | 3 | −2.4 |
| 2 | NorESM2-MM | 7 | 1 | −4.3 |
| 3 | MIROC6 | 9 | 2 | +3.9 |
| 4 | MIROC-ES2L | 3 | 7 | +17.7 |
| 5 | FGOALS-g3 | 2 | 13 | +14.1 |
| 6 | HadGEM3-GC31-MM | 11 | 6 | +0.4 |
| 7 | EC-Earth3 | 14 | 4 | +8.9 |

**Key observations**

- Forcing and discharge rankings are essentially orthogonal (Spearman ρ = −0.027, 95% CI [−0.095, 0.038]) — the empirical wedge that motivates O1/H1 (pilot estimate 0.14 re-estimated; §5.1).
- Absolute daily discharge skill is ≈0 for *all* models (median KGE −0.05 to −0.11): CMIP6 historical runs are free-running; EQM corrects distributions, not timing. Volume bias (PBIAS) and relative ordering are the interpretable signals. **[TODO: QM-limits literature]**
- Volume-bias standouts: NorESM2-MM −4.3%, HadGEM3-GC31-MM +0.4%, MIROC6 +3.9%, MPI-ESM1-2-HR +5.3%.
- Extrapolation exposure: 0.05% of scored forcing values, 0.13% of discharge-evaluation values — future windows will raise this (motivating the linear pr tail policy in projections).
- From the forcing-only top-14, GISS-E2-1-G (discharge 21/22) and INM-CM5-0 (20/22) were dropped; MPI-ESM1-2-HR (5/22) and GFDL-ESM4 (9/22) added — the first application of the framework's own principle.

### 5.1 H1 verdict: forcing rank vs low-flow rank (Phase 1, executed 18 Nov 2026)

The low-flow metric layer (`metric_version v1`, pre-registered) was computed for all 22 models on the full calibrated roster (192 catchments × 22 models = 21,120 metric rows, evaluation window 2001–2014 only). After the guardrail-5 de-duplication (q95_bias dropped: ρ = 0.937 with mam7_bias), the composite low-flow ranking was built on the 78 catchments with non-ephemeral observed low flows (complete rows on logNSE, lf_volume_bias, dry_spell_bias, mam7_bias).

**H1 is SUPPORTED.** The pooled Spearman correlation between the forcing-composite rank (QED_30) and the low-flow-composite rank is **ρ = −0.027** (catchment-bootstrap 95% CI [−0.095, 0.038]; 1,000 resamples, seed 20261118) — far below the pre-registered failure threshold of 0.6, and essentially zero rather than merely weak: the re-estimated wedge is *stronger* than the pilot estimate (ρ = 0.14), which used a Tier-1-only roster and mean-flow discharge ranks. Forcing-skill selection carries essentially no information about low-flow skill; the two-stage framework is retained as designed (verdict file: `data_processed/lowflow/h1_verdict.md`).

Two mechanistic observations from the metric layer, reported as findings (not tuned):

- On ephemeral catchments, CMIP-driven GR4J keeps baseflow running where the observed stream nearly dries up (simulated 10th-percentile flow ≈ 7× observed; simulated series never fall below the observed Q90 threshold → dry-spell bias −100%), while underestimating mean flow on the same catchments. Whole-flow KGE is nearly blind to this; the low-flow metrics are not — the empirical basis of the divergence.
- Observed SPI-12→SRI-12 propagation lags (frozen, 167 catchments) concentrate at 0–1 months (median 1; 150/167), with the mean |SRI−SPI| diagnostic ≈ 0.4–0.7 — far from the ≈0.013 Machhar-type coupling-artefact signature, confirming the observed benchmark is fit for the H3 comparison.

### 5.2 H2 verdict: GR4J vs GR6J structural divergence (observed forcings, base case)

GR6J was calibrated under the identical-treatment rule (192 catchments calibrated under both structures; median validation KGE 0.527 vs GR4J 0.543, paired Wilcoxon p = 0.45 — the structures are comparable at the whole-flow level, so the low-flow comparison is the informative one). Low-flow metrics were computed for both structures on observed forcings (172 paired catchments, evaluation window 2001–2014).

**H2 STANDS** (verdict file: `data_processed/gr6j/h2_verdict.md`). The divergence is material and **structured by aridity** exactly as the hypothesis anticipated, but with a direction that must be reported, not moralized:

| tercile | metric | median div (GR6J − GR4J) | n |
|---|---|---|---|
| dry | mam7_bias | −449 pp | 29 |
| dry | q95_bias | −111 pp | 7 |
| dry | lf_volume_bias | +158 pp | 8 |
| wet | lf_volume_bias | +52 pp | 34 |
| wet | mam7_bias | −47 pp | 51 |
| intermediate | lf_volume_bias | +32 pp | 36 |
| wet/intermediate | q95_bias | −12 / +13 pp | 32 / 31 |

logNSE is **not** materially divergent anywhere — the structures differ in *where* and *how much* water they leave in the dry season, not in overall log-skill. GR6J's exponential store produces substantially lower 7-day minima (mam7) in the dry tercile (negative div = GR6J smaller), while overestimating low-flow volume (positive lf_volume div) in wet and intermediate terciles. **Per the pre-registered guardrail this is quantified divergence, not a superiority claim**: whether GR6J's drier dry-season behaviour is more faithful on any given catchment is an out-of-sample question the SSP-projection leg (14 GCMs × 4 SSPs) will carry forward, and per H2's falsification rule the structural axis cannot be dropped from Objective 4.

### 5.3 H3 verdict: drought-propagation reproduction (Phase 3)

SPI-12→SRI-12 propagation was computed for all 22 models (corrected-forcing SPI-12; full-period GR4J-simulated SRI-12, 1982–2014) against the **frozen** observed lags, with the pre-registered reproduction band `|L_model − L_obs| ≤ 1 month` and the pre-registered three-clause falsification rule (`PROP_PRE_REGISTRATION.md`, dated before any model SRI was computed).

**H3 STANDS** (verdict file: `data_processed/prop/h3_verdict.md`) — with a structure that matters for the selection story:

- **Clauses 1–2 TRUE:** every model reproduces 0.91–0.96 of catchments and the inter-model spread is < 0.10 — reproduction of the observed 0–1-month propagation regime is nearly universal, and models differ only marginally on it.
- **Clause 3 FALSE:** ρ(forcing rank, prop_share) = **−0.350** — mean-flow selection does not find propagation skill. The two *kinds* of skill (whole-flow forcing skill vs drought-propagation fidelity) are again nearly orthogonal, consistent with H1's near-zero wedge: a framework that selects on mean-flow skill alone cannot claim propagation competence.
- **Artefact audit passed:** per-model mean |SRI−SPI| = 0.29–0.34, far from the ≈ 0.013 Machhar-type too-tight-coupling signature — propagation times were measured, not assumed by construction.
- 109 model-combos excluded with reason codes (77 SRI gamma-fit failures, 32 SPI gamma-fit failures; per-model denominators 156–166, logged in `PROP_10_exclusions.csv`).

**Implication carried forward to Objective 4:** because clause 3 fails, the drought-propagation criterion enters the selection test as a distinct dimension, not a corollary of forcing rank — models near-universal on the frozen band but unrankable by mean-flow skill is precisely the case the two-stage + propagation framework was built to separate.

### 5.4 H5 verdict: the CAMELS-IND-Proj LSTM benchmark audited at low flows (Phase 5, executed 19 Nov 2026)

Track B (CAMELS-IND-Proj, NA, Zenodo 21775597) was ingested as the **benchmark object only** — never substrate, LSTM series never treated as observed. The archive was verified by CRC test (30,751 files, 35.3 GB unpacked) and its structure discovered from the data: 13 GCMs × 5 scenarios, one aggregate streamflow table per GCM × scenario (472 catchments, daily, cumecs), converted to mm/day with the same CAMELS-IND catchment areas used by GR4J/GR6J — a conversion validated against the observed record (median LSTM/observed mean-flow ratio 1.17, hard-gated in `BENCH_00`).

Two audit findings about the dataset itself, both logged in `data_processed/bench/bench_00_log.txt`:

- **The brief's "confidence-flagged catchments" claim is unsupported by the distributed data.** No confidence/flag/NaN-mask file exists anywhere in the archive, and the aggregate streamflow header is exactly `year, month, day` + 472 gauge columns — no flag column. The claim must be re-scored against the data-description PDF or withdrawn; until then H5 is computed on the full benchmark set, and the paper does not use the flag construct (the count is deliberately not repeated here).
- **The benchmark shares only 8 of our 14 shortlisted GCMs** (12 of our 22-model Track-A pool). One is a naming variant (`EC-Earth3-Veg` = our `EC-Earth3-Veg-LR`); `NorESM2-LM` has no Track-A counterpart and is excluded with a log line. The H5 like-for-like win rate is therefore computed on the 12-GCM intersection; the 8-model shortlist subset is the one that will matter for the SSP-phase comparison.

The pre-registered rule was applied with **both legs evaluated**: the win rates below are shares of catchments where the LSTM cross-model median (over the 12 matched GCMs) beats the corresponding structure's cross-model median, on the shared catchment set, evaluation window 2001–2014, `metric_version v1`. The decision basis is the pooled table; the aridity split is supporting evidence only.

**H5 STANDS** (verdict file: `data_processed/bench/h5_verdict.md`) — the LSTM does **not** uniformly beat GR4J/GR6J at low flows, but the structure of the result is the finding:

| compared_with | metric | LSTM win share | n |
|---|---|---|---|
| GR4J / GR6J | lf_volume_bias | **0.92 / 0.95** | 78 |
| GR4J / GR6J | logNSE | **0.86 / 0.88** | 172 |
| GR4J / GR6J | mam7_bias | **0.81 / 0.78** | 127 |
| GR4J / GR6J | q95_bias | **0.71 / 0.71** | 70 |
| GR4J / GR6J | dry_spell_bias | **0.39 / 0.39** | 78 |

The LSTM is better on the **magnitude** low-flow metrics — total skill (logNSE), low-flow volume, 7-day minima, Q95 — but loses the **duration** metric on both structures: consecutive dry days below the observed Q90 threshold are reproduced better by the calibrated conceptual models in 61% of catchments. That split is exactly what a single blended score (the kind the LSTM leaderboard framing invites) would have hidden: the benchmark is *wetter and smoother*, not more faithful to drought spells. This is the process-based evidence behind the "LSTM dry tail unaudited" gap identified in the prior-art table — now audited, with the audit's own metric-level resolution.

The aridity split supports the pre-registered suspicion in its expected direction: the LSTM's logNSE advantage is smallest in the dry tercile (0.62 vs GR4J, 0.68 vs GR6J, against 0.98/0.98 and 0.93/0.95 in intermediate/wet), and on dry-spell duration in the dry tercile the LSTM wins only 25% of catchments. The dry-tercile cells are small (n = 7–53 per metric) and are reported as such, not averaged away.

**Implications carried forward:** (i) H4's decomposition remains necessary — a benchmark that wins magnitudes but loses drought duration cannot arbitrate drought-projection uncertainty on its own; (ii) the SSP-phase comparison (our GR4J/GR6J projections vs the benchmark's 2015–2100 envelope, already cached as per-SSP window summaries in `bench_lstm_proj_lowflow.csv`) now has a like-for-like GCM basis; (iii) the framework's two-track discipline is vindicated rather than merely asserted — the benchmark was usable *because* it was treated as an audit object, not as substrate.

### 5.5 H4 verdict: GCM × structure × tail-policy decomposition of projected low-flow variance (Phase 4, executed 23 Nov 2026)

The decomposition runs on the projection layer assembled 23 Nov 2026 (`DECOMP_10`, `metric_version v1_proj`): **192** catchments calibrated under both structures (64/64/64 aridity terciles), driven with each corrected SSP forcing under the calibrated GR4J **and** GR6J parameters, five always-defined low-flow indicators, three future windows (2021–2040, 2041–2060, 2082–2100; the 2061–2080 archive gap excluded, never interpolated), **14/13/13/14** GCMs (HadGEM3-GC31-MM unpublished for ssp245/ssp370 — logged, never padded). **11,520** ANOVA cells (192 × 5 metrics × 4 SSPs × 3 windows); 11,514 decomposed, 6 dropped (one catchment's `lf_ratio_q95` is zero-variance in six cells — logged in `h4_dropped_cells.csv`). Per the design note in §4.2, the per-cell factorial is **saturated** (residual df = 0): every number below is an exact variance partition, and the inference is the pre-registered rule plus a 1,000-resample catchment bootstrap (seed 20261118), not per-cell significance tests.

**H4 STANDS** (verdict file: `data_processed/decomp/h4_verdict.md`) — the pre-registered disjunction rule triggers in **149 of the 180** summary cells (3 terciles × 5 metrics × 4 SSPs × 3 windows), and in **all 36 cells for every one of the four low-flow-specific metrics** (Q95, 7-day minima, low-tail shape, dry-spell length). The only metric where structure does not matter is mean flow — and that contrast is itself the headline:

| metric | structure share, median (dry / intermediate / wet tercile) | GCM share, same terciles |
|---|---|---|
| `log10_q95` | **0.661 / 0.364 / 0.367** | 0.226 / 0.455 / 0.511 |
| `log10_mam7` | **0.677 / 0.350 / 0.568** | 0.232 / 0.547 / 0.363 |
| `lf_ratio_q95` | **0.592 / 0.361 / 0.342** | 0.208 / 0.423 / 0.552 |
| `dry_spell_days` | 0.254 / 0.137 / 0.110 | 0.445 / 0.626 / 0.723 |
| `log10_meanq` | 0.028 / 0.026 / 0.036 | **0.952 / 0.963 / 0.953** |

Three findings carry the paper's central argument:

1. **In dry catchments, hydrological model structure is the largest single source of projected low-flow variance** — 66% (Q95) and 68% (7-day minima) versus ~23% for GCM choice — with catchment-bootstrap 95% CIs on the structure share far above 5% (e.g. dry × Q95 × ssp585 × 2082–2100: median 0.56, CI [0.47, 0.73]). GCM dominance returns in intermediate and wet catchments (0.45–0.72). The adaptation message is tercile-specific: which GCM you project with matters most in wetter catchments; which *hydrological model* you project with matters most in the dry ones — exactly where low-flow decisions bite.
2. **Mean flow hides the structure axis entirely**: GCM choice explains 95–96% of whole-flow variance and structure ~3%, yet structure owns 34–68% of low-flow variance on the same simulations. This is the variance-decomposition restatement of the H1 rank divergence (ρ ≈ 0) — one-stage, mean-flow-based selection is not merely weakly correlated with low-flow skill; it is blind to the dominant low-flow uncertainty in dry catchments.
3. **The bias-correction tail design is a negligible uncertainty source**: the `tail_policy` share is ≤ 0.5% in every cell (median 0.000–0.0015), with `structure:tail` interaction shares of the same order. Given the 23 Nov EQM defect history (§4.3), this is a substantive result, not an artefact of the fix: once the linear extension is physically bounded, *whether* the quantile mapper clamps or extrapolates future extremes barely moves catchment low-flow indicators. The three sources are also demonstrably not additive — the `gcm:structure` interaction reaches 19% of variance (dry tercile, dry-spell length), which the reported seven-term partition makes visible.

**Sensitivity (supplement, `h4_lmer_sensitivity.csv`):** modelling GCM as a random intercept (`value ~ structure × tail_policy + (1|gcm)` per cell — the one H4 model with an error term, residual df ≈ 47–51) reproduces the qualitative ordering; the median signed difference to the fixed-effects GCM share is +11.5 pp (95th |difference| 65.1 pp), because the ICC-style share conditions only on GCM + residual variance while the fixed share partitions all variance including the large structure/tail effects. Both are reported; the fixed-effects partition remains primary (§6).

## 6. Limitations

**Fixed GCM factor.** GCM is a fixed factor — the 14-model shortlist is stated, not sampled — so the H4 shares describe variance among *these* models and do not generalise to the CMIP6 population; coverage is 14/13/13/14 GCMs (ssp126/245/370/585; HadGEM3-GC31-MM has no published ssp245/ssp370, logged). **Saturation.** The per-cell factorial is saturated (0 residual df), so there are no per-cell significance tests by design; the inference is the pre-registered 5% disjunction rule plus the catchment bootstrap, stated as methodological clarity in §4.2, not apologised for here. **Tercile is a stratification, not a factor** — "structure share is higher in dry catchments" is descriptive (medians + bootstrap CIs), not a formal test. **Multiplicity.** The disjunction rule spans 180 summary cells (3 terciles × 5 indicators × 4 SSPs × 3 windows); under a global null, at least one exceedance is plausible — the rule's safeguards are that it triggers on tercile *medians* and was pre-registered on 18 Nov 2026 before any H4 number existed. **The random-intercept sensitivity does not agree with the fixed share within 5 pp** (median +11.5 pp, 95th |difference| 65.1 pp; §5.5): the ICC-style share conditions only on GCM + residual variance, while the fixed share partitions all variance including the large structure and tail effects — the gap is evidence of how large those effects are, and both estimators are reported (supplement); the fixed partition is primary. **Tail policy.** The 23 Nov EQM defect and its fix preceded any H4 result; the historical leg used `constant` for precipitation, so H1–H3 are unaffected — the fix and its audit trail are in `QED_50` §0b and `AGENT_LOG.md`.

Single members only (no internal-variability spread). GR4J/GR6J parameters calibrated on observed forcings — transfer to model climates assumes structural stationarity (tested via O2/O4 interactions). Daily timing skill vs free-running models is inherently bounded; seasonal and distributional low-flow metrics complement daily KGE. **Abstraction/anthropogenic modulation is not modelled**: peninsular hard-rock basins with heavy pumping mean naturalized low-flow projections translate into water-scarcity statements only with caution — the anthropogenic-drought phase (roadmap Year 4, using CAMELS-IND regulation attributes) addresses this and is flagged here, not promised.

## 7. Publication portfolio and timeline

Planned as 3–4 papers — full objectives, data dependencies, target journals and quarter-level timeline in **`research_plan/PAPER_PORTFOLIO.md`**. Summary:

| Paper | Core content | Target | Status |
|---|---|---|---|
| **P1** (this repo) | Low-flow-aware CMIP6 selection + GR6J axis + propagation + decomposition (O1–O4/H1–H4) | WRR / HESS | **all five verdicts executed**; camera-ready polish pending |
| **P2** | CAMELS-IND-Proj low-flow audit (O5/H5) — first process-based critical user | HESS / Sci. Data companion | historical audit executed (H5 stands); SSP envelope comparison pending |
| **P3** | National streamflow-drought climatology & low-flow threshold framework for Peninsular India (roadmap Phase 2 flagship) | WRR / JoH | engine = P1 |
| **P4** | ML low-flow forecasting / S2S (roadmap Phase 3); optional P5 anthropogenic drought & e-flows (Year 4) | HESS / WRR | foundation = P1+P2 |

## 8. Literature survey TODO

GR4J/airGR origins; EQM variants on unpaired (free-running) series; CMIP6 South-Asia evaluation; CAMELS-IND + CAMELS-IND-Proj dataset papers and prior applications; KGE interpretability; ECS values for shortlisted models; drought-propagation canon (India: Betwa HSJ 2026 — verify 80%/42→63% figures at camera-ready); Wilby & Harris 2006 [@wilby2006thames] uncertainty ordering; IAHS HELPING positioning.


**Camera-ready verification list (spec v2 section 8):** Senatore 2022 full citation; Meresa 2023 and Wang 2025 full citations; Park 2025's exact factor list (does it include a bias-correction factor?); Naresh & Mathew 2026 journal attribution; Betwa quantitative details (80% decrease, 42→63%); Liu 2025 complete author list.
## Data and code availability

Reproducible from R Markdown notebooks (`QED_00–30`, `HYD_00–30`; phase modules `LOWFLOW_*`, `GR6J_*`, `PROP_*`, `DECOMP_*`, `BENCH_*` specified in `AGENTS.md`) at <https://github.com/anixn/CMIP6_IND_GR4J>. Small result tables tracked in the repo; bulk series regenerated by the notebooks.
