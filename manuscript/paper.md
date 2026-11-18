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
- **CAMELS-IND-Proj** (Singh et al. 2026, Zenodo 21775597, CC BY 4.0; EcoHydro Lab IIT Roorkee): daily LSTM streamflow 2015–2100, 13 GCMs × 4 SSPs, historical-per-GCM runs and forcings included; ~11.3 GB; `filter_catchment_model_scenario.py` for subsetting. **Track B only.** Confidence flags exist for a subset of catchments (239 per the project brief) — *unverified on the public record*; the number and flag semantics must be verified against the downloaded files before any use. **[TODO: survey]**

## 4. Methods

### 4.1 Historical leg (complete)
1. **Tiering** by forcing availability (1981–2014): Tier 1 ≥70% (180), Tier 2 ≥30% (62), Tier 3 excluded (230) — all logged.
2. **Aggregation**: area-weighted catchment means per model × variable (66 series per model).
3. **Seasonal EQM**: per variable × season (DJF/MAM/JJA/SON) × catchment; bins ≥300 days with annual fallback (331 of 15,972 fits); tie-collapsed CDF; tail policies pr=constant / T=linear for the historical evaluation; every value flagged (`within_range` vs extrapolation), flags counted never hidden.
4. **Out-of-sample forcing ranking**: EQM fit 1981–2000 → score 2001–2014 → KGE/NSE/PBIAS composite rank sum; natural break after rank 14 (non-overlapping out-of-sample KGE for every variable).
5. **GR4J hydrological leg**: airGR; Oudin PET; Q[mm/d] = Q[m³/s]×86.4/A[km²]; warm-up 1981; calibrate 1982–2000 (Michel local search on 1−KGE); validate out-of-sample 2001–2014 (KGE/NSE/PBIAS, PBIAS manual); <3,650 valid Q-days → skip and log. 192 of 242 calibrated.
6. **CMIP-driven discharge evaluation**: calibrated parameters driven with all 22 corrected series; scored on observed 2001–2014 discharge; per-catchment ranks → composite discharge ranking. Leap-day gaps of 365-day-calendar models filled conservatively (pr→0, T→interpolated), counted in `n_gap_filled`.

### 4.2 Phase methods (specified; to be executed — see phase map in `AGENTS.md`)
- **Low-flow metric layer (O1)**: logNSE, Q95 bias, low-flow volume bias (below observed Q90), dry-spell bias, mean annual 7-day minimum bias — computed 2001–2014 only; composite rank after pairwise ρ>0.9 de-duplication.
- **GR6J axis (O2)**: GR6J (6 parameters) via airGR, identical inputs/windows/warm-up/optimizer as GR4J, calibrated on the same 192 catchments; divergence `div = (GR6J−GR4J)/GR4J` per model × catchment × SSP × metric; stratified by aridity and baseflow-index proxy; ANOVA-style structure test.
- **Propagation (O3)**: SPI-12/SRI-12 (gamma fit, fixed convention); propagation time = SPI–SRI cross-correlation lag (0–12 months) — **never** inferred from SPI≈SRI near-identity; pre-registered tolerance band on observed propagation **before** any model comparison; propagation rate = share of SPI≤−1 months followed by SRI≤−1 within the window.
- **Decomposition (O4)**: multi-way ANOVA / variance components of Q95 change, 7-day min change, low-flow volume change ~ GCM × structure × tail policy, blocking by catchment type; bootstrap CIs (≥1000 resamples, recorded seed); responses never blended.
- **Benchmark (O5)**: same low-flow metric suite applied to CAMELS-IND-Proj historical-per-GCM runs (skill) and 2015–2100 projections (projected change); distributions and per-catchment win rates, stratified by confidence flag and aridity; the LSTM product is benchmarked, never regenerated.

## 5. Preliminary results (historical leg, completed)

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

## 6. Limitations

Single members only (no internal-variability spread). GR4J/GR6J parameters calibrated on observed forcings — transfer to model climates assumes structural stationarity (tested via O2/O4 interactions). Daily timing skill vs free-running models is inherently bounded; seasonal and distributional low-flow metrics complement daily KGE. **Abstraction/anthropogenic modulation is not modelled**: peninsular hard-rock basins with heavy pumping mean naturalized low-flow projections translate into water-scarcity statements only with caution — the anthropogenic-drought phase (roadmap Year 4, using CAMELS-IND regulation attributes) addresses this and is flagged here, not promised.

## 7. Publication portfolio and timeline

Planned as 3–4 papers — full objectives, data dependencies, target journals and quarter-level timeline in **`research_plan/PAPER_PORTFOLIO.md`**. Summary:

| Paper | Core content | Target | Status |
|---|---|---|---|
| **P1** (this repo) | Low-flow-aware CMIP6 selection + GR6J axis + propagation + decomposition (O1–O4/H1–H4) | WRR / HESS | historical leg done; SSP + phases pending |
| **P2** | CAMELS-IND-Proj low-flow audit (O5/H5) — first process-based critical user | HESS / Sci. Data companion | download pending |
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
