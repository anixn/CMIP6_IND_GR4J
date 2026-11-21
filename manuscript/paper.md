# A two-stage framework for selecting CMIP6 Earth-system models for catchment-scale low-flow and drought projection over Peninsular India

*Empirical quantile mapping onto CAMELS-IND forcings, GR4J/GR6J-based hydrological evaluation, and uncertainty decomposition for out-of-sample model shortlisting*

**Ankit Deshmukh** — draft v0.2, 18 November 2026

> **Status: objective framed; methods specified; historical leg complete; SSP leg and
> phase analyses (low-flow metrics, GR6J axis, propagation, decomposition, LSTM
> benchmark) pending.** Points needing the full literature survey are marked
> **[TODO: survey]**.

---

## Abstract

Scenario-driven water-availability and drought studies over Indian catchments depend on which CMIP6 models feed the hydrological analysis, yet model selection is usually arbitrary or inherited from global assessments. We develop a reproducible **two-stage, low-flow-aware model-selection framework** over the 472 CAMELS-IND catchments. **Stage one** bias-corrects daily CMIP6 precipitation and temperature (1981–2014, 22 all-variable models) onto catchment-mean forcings with seasonal empirical quantile mapping (EQM), and ranks models on *out-of-sample* forcing skill (fit 1981–2000, score 2001–2014). **Stage two** drives a lumped hydrological model (GR4J, calibrated per catchment on observed discharge; calibration median KGE 0.80, out-of-sample median 0.54 across 192 catchments) with each bias-corrected series and ranks models by how realistically simulated *discharge* matches observed flows. The pilot finding that forcing-skill and discharge-skill ranks diverge (Spearman ρ = 0.14) motivates the central hypothesis: **model selection for drought projection must be low-flow-aware**. We specify the extension to a five-metric low-flow layer, a GR4J–GR6J structural-uncertainty axis, a drought-propagation-time selection test, a GCM × structure × bias-correction variance decomposition, and a process-based low-flow audit of the new CAMELS-IND-Proj LSTM projections. A hybrid shortlist of 14 models spanning the CMIP6 ECS range (≈1.8–5.7 K) is fixed for projections under the four SSPs of the AR6 core scenario matrix (ssp126, ssp245, ssp370, ssp585). **[TODO: rewrite abstract with H1–H5 verdict numbers once analyses land]**

## 1. Objective framing

**Primary objective.** Determine *which CMIP6 models are fit for low-flow and drought projection over Peninsular India — and how much that answer depends on the hydrological model structure and the bias-correction design* — through an out-of-sample, hydrologically-evaluated selection framework, and deliver the resulting projection engine as the core of a national low-flow/drought programme.

**Sub-objectives (each with a pre-registered decision rule; negative results are reported as results):**

| # | Objective | Hypothesis | Decision rule |
|---|---|---|---|
| O1 | Low-flow metric layer: rank models on low-flow skill (logNSE, Q95 bias, low-flow volume bias, dry-spell bias, 7-day min bias), test divergence from forcing skill | **H1** forcing rank ≠ low-flow rank | Fails if pooled Spearman ρ > 0.6 → framework collapses to one stage |
| O2 | GR6J structural axis: quantify GR4J–GR6J divergence in low-flow projections, stratified by aridity/baseflow storage | **H2** structures differ materially | Fails if indistinguishable across catchment types |
| O3 | Drought-propagation selection: SPI-12 → SRI-12 propagation time as a selection criterion (pre-registered tolerance band) | **H3** mean-flow selection misses propagation skill | Fails if all 22 models reproduce observed propagation within band |
| O4 | Uncertainty decomposition: ANOVA of GCM × structure × EQM tail policy on low-flow projection variance | **H4** GCM dominates, structure ≥ 5% matters | Fails if structure share < 5% everywhere (still a publishable negative result) |
| O5 | C21 benchmark: audit CAMELS-IND-Proj LSTM projections against GR4J/GR6J low-flow skill | **H5** LSTM does not uniformly win at low flows | If LSTM dominates everywhere, publish as benchmark confirmation, framed as such from the outset |

**Two-track design (fixed 18 Nov 2026).** *Track A (substrate, ours):* own QED-corrected CMIP6 series (14 hybrid-shortlisted GCMs × 4 SSPs) → GR4J/GR6J → low-flow projections. *Track B (benchmark, theirs):* CAMELS-IND-Proj is used **only** as the audited object of O5/H5 — never as substrate, never as input to our models. Rationale: their forcings inherit the coarse-scale Mishra et al. (2020) bias correction (no catchment tuning, no tail-policy axis — using them would kill O4), and analysis-only papers of another group's product compete with the producers on their home turf. Method-level contributions survive scooping; data-application papers do not.

## 2. Prior-art positioning

| Group / product | What they own | Why our lane survives |
|---|---|---|
| **India Drought Monitor + Drought Atlas of India** (Chuphal et al. 2024, *Sci. Data*; IITGN) + bias-corrected CMIP6 South Asia (Mishra et al. 2020, *Sci. Data*) | Meteorological/agricultural drought monitoring at 0.05° (1901–2020); coarse-scale bias-corrected CMIP6 | No streamflow drought at catchment scale; bias correction not catchment-tuned, not seasonally stratified, not hydrologically evaluated, not out-of-sample ranked |
| **CAMELS-IND** (Mangukiya et al. 2025, ESSD) + **CAMELS-IND-Proj** (Singh et al. 2026, Zenodo 21775597) + MARRMoT adequacy benchmark (Mangukiya et al. 2026, WRR) | Datasets; regional LSTM projections (13 GCMs × 4 SSPs); model-adequacy benchmarking | No low-flow-aware analysis of their own product yet; LSTM dry tail unaudited; we are the first critical process-based user. GR4J is in their 5-model sufficient set (WRR 2026) — independent support for our structural choice |
| **Sharma, Barbhuiya & Gupta 2026** (*Hydrol. Process.* 40(3) e70476; IIT Mandi) — **closest prior art** | India-wide future streamflow; 4 structures (MILC/GR4J/HBV/HYMOD); 12 GCMs; 128 basins | No GR6J, no low-flow-specific selection, no forcing-vs-low-flow divergence test, no propagation-time selection, no uncertainty decomposition |
| **India Drought Atlas operational ecosystem** (IITGN) | Monitoring infrastructure with institutional appetite | Our streamflow-drought layer is a candidate addition to that ecosystem (roadmap Phase 5), not a competitor to it |
| Tiwary & Mondal 2026 (EGU abstract) | Historical Q7min trends, 55 minimally-regulated catchments | Historical description; ours is projections + selection + uncertainty |

## 3. Data

- **CAMELS-IND** (Mangukiya et al. 2025, ESSD 17:461; Zenodo 14999580): daily catchment-mean forcings (pr, tasmax, tasmin), observed streamflow, 211 attributes, 472 catchments, 1981–2014 (12,418 days; forcings complete). Area (`cwc_area`, km²) and latitude (`cwc_lat`) from the topography file.
- **CMIP6 historical**: daily `pr`, `tasmax`, `tasmin`, 24 models over the Indian domain; CESM2 and IITM-ESM precipitation-only → excluded; **22 all-variable models** form the selection pool. HadGEM3-GC31-MM 360-day calendar handled (invalid Feb 29/30 → NA). Single members (`r1i1p1f1` or nearest).
- **CMIP6 scenarios (Track A)**: the hybrid-shortlisted **14 models × 4 SSPs (ssp126, ssp245, ssp370, ssp585)** × near (2015–2040), mid (2041–2060), long (2081–2100) windows. ssp370 added 18 Nov 2026 to complete the AR6 core scenario matrix and align with CAMELS-IND-Proj's 4-SSP design.
- **Scenario acquisition and QC**: 11,088 daily files expected (14 models × 4 SSPs × 3 variables × 66 window years; 2061–2080 never downloaded, by design). Acquisition is variable-major into `Download_CMIP/SSP/{pr,tasmax,tasmin}/` (20 Nov 2026). Two acquisition facts are recorded here because they are data-quality facts, not logistics. (i) Several ESGF THREDDS nodes intermittently returned a Java stack trace (`StorageExceptionNotActive`) as the HTTP body, which the R client wrote to disk as `<name>.nc`; every file is therefore validated by **magic bytes** (`\x89HDF` for netCDF-4/HDF5, `CDF\x01` for netCDF-3) before use, and non-netCDF files are excluded with reason `not_netcdf_error_page`. The 21 Nov scan of the full archive found **0** remaining, i.e. the re-fetches succeeded. (ii) The archive also holds two models dropped from the hybrid shortlist (`GISS-E2-1-G`, `INM-CM5-0`; 831 files), logged and ignored. A model × SSP × variable combo enters the pipeline only when all 66 years are present (§4.3).
- **CAMELS-IND-Proj** (Singh et al. 2026, Zenodo 21775597, CC BY 4.0; EcoHydro Lab IIT Roorkee): daily LSTM streamflow 2015–2100, 13 GCMs × 4 SSPs, historical-per-GCM runs and forcings included; ~11.3 GB; `filter_catchment_model_scenario.py` for subsetting. **Track B only.** Confidence flags exist for a subset of catchments (239 per the project brief) — *unverified on the public record*; the number and flag semantics must be verified against the downloaded files before any use. **[TODO: survey]**

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
- **Propagation (O3)**: SPI-12/SRI-12 (gamma-MLE + normal-quantile transform, identical convention both sides); propagation time **defined exclusively** as the SPI–SRI cross-correlation lag (0–12 months, ties → smallest) — **never** inferred from SPI≈SRI near-identity (the Machhar-type artefact; mean |SRI−SPI| computed as diagnostic only); tolerance band `|L_model − L_obs| ≤ 1 month` and the falsification rule (all models ≥ 80% reproduced AND spread < 0.10 AND ρ(forcing rank, prop_share) > 0.6) pre-registered in `PROP_PRE_REGISTRATION.md` (18 Nov 2026) **before** any model SRI was computed; observed lags frozen (167 catchments).
- **Decomposition (O4)**: multi-way ANOVA / variance components of Q95 change, 7-day min change, low-flow volume change ~ GCM × structure × tail policy, blocking by catchment type; bootstrap CIs (≥1000 resamples, recorded seed); responses never blended.
- **Benchmark (O5)**: same low-flow metric suite applied to CAMELS-IND-Proj historical-per-GCM runs (skill) and 2015–2100 projections (projected change); distributions and per-catchment win rates, stratified by confidence flag and aridity; the LSTM product is benchmarked, never regenerated.

### 4.3 SSP projection leg (the substrate for O4)

Two notebooks, parallel to the historical chain and leaving every `QED_*`/`HYD_*` notebook untouched.

**Aggregation (`QED_40_ssp_aggregate.Rmd`).** Raw daily NetCDF → area-weighted (cos-latitude) catchment means on the 24,206-day window grid (2015–2040 + 2041–2060 + 2081–2100). The 2061–2080 gap is absent by design and travels downstream as a counted gap, never as an interpolated one. Unit handling is identical to the historical leg (pr kg m⁻² s⁻¹ → mm/day, K → °C; the 360-day HadGEM3-GC31-MM calendar is mapped day 1..30 of real months, invalid dates → NA). Three gates protect the output: (i) **magic-byte validation** of every input file (§3), so a server error page can never be read as a year of data; (ii) a **completeness gate** — a combo is aggregated only when all 66 window years are present, because a half-downloaded series would produce NA-window low-flow metrics that are not low-flow metrics; (iii) a **per-combo status table** (`qed_40_combo_status.csv`, 168 rows) that makes partial progress visible instead of inferred. Aggregation is idempotent: a combo already written is skipped, so the notebook can be re-run as acquisition fills, and every incomplete combo is logged with its year count and reason code.

**EQM application (`QED_50_ssp_apply.Rmd`).** EQM is fitted per catchment × variable × season on the **full historical 1981–2014** pair (observed CAMELS-IND reference vs each model's historical aggregate) and applied to each SSP series with `pr` tail policy **linear**. Every corrected value carries `within_range` / `extrapolated_low` / `extrapolated_high` / `source_nan`, and every run writes `qed_50_run_summary.csv` with per-model × SSP × catchment × variable status and extrapolation share; combos lacking a complete aggregate are reported as `skipped_ssp_agg_missing`, never silently omitted.

**Why the fit window differs from the ranking window.** The 1981–2000 fit / 2001–2014 score discipline exists to stop a model being *scored* on data used to *fit its correction*. Projection application is not scoring — there is no observation in 2015–2100 to score against — so the projection EQM is fitted on all available historical data to minimise correction error. The deviation is dated (18 Nov 2026) in `QED_40` so it is reviewable rather than implicit.

O4's decomposition (GCM × structure × tail policy) runs on the metric table these two notebooks produce; until that table exists the decomposition notebook is dormant by construction.

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

- Forcing and discharge rankings diverge (Spearman ρ = 0.14) — the empirical wedge that motivates O1/H1.
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

Track B (CAMELS-IND-Proj, Singh et al. 2026, Zenodo 21775597) was ingested as the **benchmark object only** — never substrate, LSTM series never treated as observed. The archive was verified by CRC test (30,751 files, 35.3 GB unpacked) and its structure discovered from the data: 13 GCMs × 5 scenarios, one aggregate streamflow table per GCM × scenario (472 catchments, daily, cumecs), converted to mm/day with the same CAMELS-IND catchment areas used by GR4J/GR6J — a conversion validated against the observed record (median LSTM/observed mean-flow ratio 1.17, hard-gated in `BENCH_00`).

Two audit findings about the dataset itself, both logged in `data_processed/bench/bench_00_log.txt`:

- **The "239 confidence-flagged catchments" claim is unsupported by the distributed data.** No confidence/flag/NaN-mask file exists anywhere in the archive, and the aggregate streamflow header is exactly `year, month, day` + 472 gauge columns — no flag column. The claim must be re-scored against the data-description PDF or withdrawn; until then H5 is computed on the full benchmark set, and the paper does not use the flag construct.
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

### 5.5 Status of the projection leg (O4 substrate, in progress — no verdict yet)

The SSP projection leg is the only unexecuted part of the framework, and it is gated on data acquisition, not on method. State as of 21 Nov 2026: **162 of 168** model × SSP × variable combos hold all 66 window years; the aggregation notebook is running on those, and the EQM application follows. **No H4 verdict exists yet**, and the pre-registered decision rule is unchanged (structure share ≥ 5% counts as non-negligible; a structure share below 5% everywhere is itself a reportable negative result).

Two facts about this leg are recorded because they bear on the credibility of what will follow. First, the aggregation path was validated end-to-end on a single complete combo *before* production: layer counts and calendar dates correct (365/366, 2015-01-01…2015-12-31), precipitation in mm/day with an extreme of 145 mm/day against a historical maximum of 602 mm/day for the same model and catchments — the right order of magnitude, from the right units. Second, the first attempt at the notebook **silently wrote zero files while reporting success**: the combo index was keyed `var|model|ssp` but `split()` names its groups with `.`, so every combo looked absent to the loop. It was caught by comparing the expected combo count with the files written, and fixed; the completeness gate and the 168-row status table now make that class of failure visible rather than silent. A 6-worker parallel version was also tried and abandoned after `std::bad_alloc` inside `terra` on a 15.7 GB machine — recorded here so the sequential runtime (~2 min per combo) is understood as a measured choice, not an oversight.

## 6. Limitations

Single members only (no internal-variability spread). GR4J/GR6J parameters calibrated on observed forcings — transfer to model climates assumes structural stationarity (tested via O2/O4 interactions). Daily timing skill vs free-running models is inherently bounded; seasonal and distributional low-flow metrics complement daily KGE. **Abstraction/anthropogenic modulation is not modelled**: peninsular hard-rock basins with heavy pumping mean naturalized low-flow projections translate into water-scarcity statements only with caution — the anthropogenic-drought phase (roadmap Year 4, using CAMELS-IND regulation attributes) addresses this and is flagged here, not promised.

## 7. Publication portfolio and timeline

Planned as 3–4 papers — full objectives, data dependencies, target journals and quarter-level timeline in **`research_plan/PAPER_PORTFOLIO.md`**. Summary:

| Paper | Core content | Target | Status |
|---|---|---|---|
| **P1** (this repo) | Low-flow-aware CMIP6 selection + GR6J axis + propagation + decomposition (O1–O4/H1–H4) | WRR / HESS | historical leg done; SSP + phases pending |
| **P2** | CAMELS-IND-Proj low-flow audit (O5/H5) — first process-based critical user | HESS / Sci. Data companion | historical audit executed (H5 stands); SSP envelope comparison pending |
| **P3** | National streamflow-drought climatology & low-flow threshold framework for Peninsular India (roadmap Phase 2 flagship) | WRR / JoH | engine = P1 |
| **P4** | ML low-flow forecasting / S2S (roadmap Phase 3); optional P5 anthropogenic drought & e-flows (Year 4) | HESS / WRR | foundation = P1+P2 |

## 8. Literature survey TODO

GR4J/airGR origins; EQM variants on unpaired (free-running) series; CMIP6 South-Asia evaluation; CAMELS-IND + CAMELS-IND-Proj dataset papers and prior applications; KGE interpretability; ECS values for shortlisted models; drought-propagation canon (India: Betwa HSJ 2026 — verify 80%/42→63% figures at camera-ready); Wilby & Harris 2006 uncertainty ordering; IAHS HELPING positioning.

## Data and code availability

Reproducible from R Markdown notebooks (`QED_00–30`, `HYD_00–30`; phase modules `LOWFLOW_*`, `GR6J_*`, `PROP_*`, `DECOMP_*`, `BENCH_*` specified in `AGENTS.md`) at <https://github.com/anixn/CMIP6_IND_GR4J>. Small result tables tracked in the repo; bulk series regenerated by the notebooks.

## Core references (verified minimal set — full survey pending)

1. Perrin, C., Michel, C., Andréassian, V. (2003). *Improvement of a parsimonious model for streamflow simulation.* J. Hydrol., 279, 275–289.
2. Oudin, L., et al. (2005). *Which potential evapotranspiration input for a lumped rainfall–runoff model?* J. Hydrol., 303, 290–306.
3. Eyring, V., et al. (2016). *Overview of CMIP6.* Geosci. Model Dev., 9, 1937–1958.
4. Gupta, H.V., et al. (2009). *Decomposition of the mean squared error and NSE performance criteria.* J. Hydrol., 377, 80–91.
5. Mangukiya, N.K., et al. (2025). *CAMELS-IND: hydrometeorological time series and catchment attributes for 472 catchments in Peninsular India.* ESSD, 17, 461–491.
6. Chuphal, D.S., Kushwaha, A.P., Aadhar, S., Mishra, V. (2024). *Drought Atlas of India, 1901–2020.* Sci. Data, 11, 7.
7. Mishra, V., Bhatia, U., Tiwari, A.D. (2020). *Bias-corrected climate projections for South Asia from CMIP6.* Sci. Data, 7, 1–13.
8. Singh, A., Mangukiya, N.K., Sahu, G., Sharma, A. (2026). *CAMELS-IND-Proj: daily streamflow projections for 472 Peninsular Indian catchments under future climate scenarios.* Zenodo 21775597, CC BY 4.0.
9. Mangukiya, N.K., et al. (2026). *Benchmarking and selecting optimal hydrological models...* Water Resources Research, 2026WR044753.
10. Sharma, V., Barbhuiya, S., Gupta, V. (2026). *Projections of future streamflow for India informed by CMIP6 global climate models.* Hydrol. Process., 40(3), e70476.
11. Coron, L., et al. (2017). *airGR* R package. **[TODO: verify full citation]**
12. Wilby, R.L., Harris, I. (2006). *A framework for assessing uncertainties in climate change impacts: low-flow scenarios for the River Thames, UK.* WRR, 42, W02419. **[TODO: verify]**
