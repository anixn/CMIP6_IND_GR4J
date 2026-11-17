# A two-stage framework for selecting CMIP6 Earth-system models for catchment-scale hydrological application over Peninsular India

*Empirical quantile mapping onto CAMELS-IND forcings, and a GR4J-based discharge evaluation for out-of-sample model shortlisting*

**Ankit Deshmukh** — draft v0.1, 17 November 2026

> **Status: methods documentation draft.** The literature survey is not yet
> done; points needing real citations are marked **[TODO]**. The final
> objective is not yet formulated (see §7).

---

## Abstract

Earth-system models participating in CMIP6 differ strongly in how realistically they reproduce the hydro-climate of Peninsular India, yet scenario-driven catchment water-availability studies typically use model ensembles selected arbitrarily or inherited from other regions. We develop a reproducible two-stage model-selection framework over the 472 CAMELS-IND catchments. **Stage one** bias-corrects daily CMIP6 precipitation and temperature (1981–2014, 22 models with all three required variables) onto catchment-mean forcings with seasonal empirical quantile mapping, and ranks models on *out-of-sample* forcing skill (fit 1981–2000, score 2001–2014). **Stage two** drives a lumped hydrological model (GR4J, calibrated per catchment on observed discharge) with each bias-corrected series and ranks models by how realistically the resulting *discharge* matches observed flows. A hybrid of the two rankings yields a defensible 14-model shortlist spanning the CMIP6 ECS range (1.8–5.7 K) for future SSP1-2.6/SSP2-4.5/SSP5-8.5 water-availability and drought analyses. GR4J calibration across 192 gauged catchments reaches median calibration KGE 0.80 and out-of-sample (validation) median 0.54. **[TODO: rewrite abstract once the final objective is formulated; add headline future-projection result when SSP runs complete]**

## 1. Introduction

Scenario-driven water-availability assessments over Indian catchments face a selection problem that is rarely treated explicitly: **which CMIP6 models should feed the hydrological analysis?** Three gaps motivate this work:

1. **Regional bias structure.** Persistent precipitation biases of CMIP6 models in the AR6 regions covering South Asia (EAS, WSB, ESB) make raw model output unsuitable for catchment water-balance studies. *(research-agenda anchor: **C9** — regional climate biases & explainable downscaling)* **[TODO: citations — survey pending]**
2. **Hydrological (not just meteorological) skill.** A model can reproduce rainfall statistics yet fail to generate realistic runoff, because discharge integrates seasonality, soil-moisture dynamics and evaporative demand. Model selection should include a hydrological test.
3. **Global-South benchmarking.** Lumped conceptual models remain the baseline that new (e.g., deep-learning) approaches must beat when local data are sparse. *(anchor: **C21** — Global-South data equity; the C21 pilot explicitly compares against GR4J)* **[TODO: survey pending]**

## 2. Data

- **CAMELS-IND**: daily catchment-mean forcings (pr, tasmax, tasmin), observed streamflow (m³/s), attributes for **472 catchments**, 1981–2014 (12,418 days; forcings complete). Area (`cwc_area`, km²) and latitude (`cwc_lat`) from the topography file. **[TODO: cite dataset paper]**
- **CMIP6 historical**: daily `pr`, `tasmax`, `tasmin` for 24 models over the Indian domain. CESM2 and IITM-ESM are precipitation-only → excluded; **22 all-variable models** form the selection pool. HadGEM3-GC31-MM's 360-day calendar handled (invalid Feb 29/30 → NA). Single members only (`r1i1p1f1` or nearest) — ensemble spread not assessed. **[TODO: limitation + large-ensemble literature]**

## 3. Methods

### 3.1 Catchment tiering (forcing availability, 1981–2014)
| Tier | Rule | n | Use |
|---|---|---|---|
| 1 | ≥ 70 % valid days | 180 | modelled |
| 2 | ≥ 30 % valid days | 62 | modelled |
| 3 | < ~10 yr | 230 | excluded, logged |

### 3.2 Catchment-mean aggregation
Area-weighted mean of intersecting grid cells per model × variable × catchment (66 series per model).

### 3.3 Seasonal empirical quantile mapping (EQM)
- Fitted per variable × season (DJF/MAM/JJA/SON) × catchment; bins need ≥ 300 days, else **annual fallback** (331 of 15,972 fits).
- Tie-collapsed empirical CDF.
- Tail policy: **pr = constant** (clamped) for historical evaluation; **T = linear**. For SSP application pr switches to **linear** (constant clamping would truncate intensified future extremes). **[TODO: EQM extrapolation literature]**
- Every corrected value carries a flag (`within_range` vs extrapolation); flags are counted, never hidden.

### 3.4 Out-of-sample forcing ranking (QED leg)
EQM fitted 1981–2000 → applied 2001–2014 → KGE/NSE/PBIAS vs observed forcings → composite rank sum per model. Natural break after rank 14 (non-overlapping out-of-sample KGE between ranks 1–14 and 15–22 for every variable) → provisional 14-model shortlist.

### 3.5 GR4J calibration and validation (HYD leg)
- GR4J (4 parameters) via **airGR**; inputs: precipitation + **Oudin PET** (daily mean temperature + latitude).
- Q[mm/d] = Q[m³/s] × 86.4 / A[km²].
- Warm-up 1981 (verified: airGR discards warm-ups overlapping the run window); **calibrate 1982–2000** (Michel local search on 1−KGE); **validate out-of-sample 2001–2014** (KGE/NSE/PBIAS; PBIAS computed manually).
- Catchments with < 3,650 valid Q-days in the calibration window are skipped and logged.

### 3.6 CMIP-driven discharge evaluation
Each calibrated parameter set is driven with each of the 22 corrected CMIP6 series; simulated discharge scored against observed 2001–2014 discharge; per-catchment ranks (KGE, NSE, |PBIAS|) → composite **discharge ranking**. Leap-day gaps of 365-day-calendar models filled conservatively (pr → 0 mm, T → linear interpolation), always counted (`n_gap_filled`).

### 3.7 Hybrid shortlist synthesis
Mean of forcing rank and discharge rank. From the forcing-only top-14, **GISS-E2-1-G** (discharge 21/22) and **INM-CM5-0** (20/22) are dropped; **MPI-ESM1-2-HR** (5/22) and **GFDL-ESM4** (9/22) are added. Full ECS range retained (INM-CM4-8 ≈ 1.8 K → CanESM5 ≈ 5.7 K). Final list in `data_processed/hyd/model_shortlist_final.csv`.

## 4. Preliminary results (historical leg, completed)

**GR4J split-sample performance** (192 of 242 Tier-1/2 catchments; 50 skipped, logged):

| Window | median KGE | median NSE | share NSE > 0.5 |
|---|---|---|---|
| Calibration 1982–2000 | 0.80 | 0.64 | 0.66 |
| Validation 2001–2014 (out-of-sample) | 0.54 | 0.43 | 0.43 |

**Hybrid shortlist (top 7; full table in the repo):**

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

- Agreement between forcing and discharge rankings is weak (**Spearman ρ = 0.14**) — the hydrological test adds information beyond forcing skill.
- Absolute daily discharge skill is ≈ 0 for *all* models (median KGE −0.05 to −0.11). Expected: CMIP6 historical runs are **free-running**; QM corrects distributions, not timing. Volume bias (PBIAS) and *relative* ordering are the interpretable signals. **[TODO: QM-limits literature]**
- Volume bias standouts: NorESM2-MM −4.3 %, HadGEM3-GC31-MM +0.4 %, MIROC6 +3.9 %, MPI-ESM1-2-HR +5.3 %.
- Extrapolation exposure: 0.05 % of scored forcing values, 0.13 % of discharge-evaluation values — future warmer windows will raise this (reason for the linear pr policy).

## 5. Limitations

Single members only (no internal-variability spread). GR4J parameters calibrated on observed forcings — transfer to model climates assumes structural stationarity. Daily timing skill vs free-running models is inherently bounded; **seasonal / distributional hydrological metrics (monthly flow-duration, low-flow and flood quantiles) should complement daily KGE** in the final analysis.

## 6. Planned extensions (SSP leg)

For the 14 shortlisted models: download SSP1-2.6 / SSP2-4.5 / SSP5-8.5 (near 2015–2040, mid 2041–2060, long 2081–2100); apply historical-fitted EQM with the **linear pr tail**; drive calibrated GR4J → future daily discharge ensembles; derive water-availability and drought indicators (low-flow quantiles, dry-spell statistics) — anchor **C2** (compound extremes).

## 7. Formulation of the final objective — OPEN

**[TODO]** Candidate framings, to be resolved after the literature survey:
1. methods paper: two-stage GCM selection for catchment hydrology;
2. projection paper: water availability / drought over Peninsular India under SSPs;
3. benchmarking paper: GR4J baseline for Global-South hydrological ML (C21);
or a combination. Anchors: C9, C21, C2 in the open-problem list.

## Literature survey TODO

GR4J/airGR origins; EQM variants on unpaired series; CMIP6 Indian-region evaluation studies; CAMELS-IND dataset paper and prior applications; KGE/NSE interpretation; ECS values for shortlisted models; IAHS HELPING positioning.

## Data and code availability

Reproducible from R Markdown notebooks (`QED_00–30`, `HYD_00–30`) at <https://github.com/anixn/CMIP6_IND_GR4J>. Small result tables tracked in the repo; bulk series regenerated by the notebooks.

## Core references (verified minimal set — full survey pending)

1. Perrin, C., Michel, C., Andréassian, V. (2003). *Improvement of a parsimonious model for streamflow simulation.* J. Hydrol., 279, 275–289.
2. Coron, L., et al. (2017). *airGR* R package. **[TODO: verify full citation]**
3. Oudin, L., et al. (2005). *Which potential evapotranspiration input for a lumped rainfall–runoff model?* J. Hydrol., 303, 290–306.
4. Eyring, V., et al. (2016). *Overview of CMIP6.* Geosci. Model Dev., 9, 1937–1958.
5. Gupta, H.V., et al. (2009). *Decomposition of the mean squared error and NSE performance criteria.* J. Hydrol., 377, 80–91.
6. Hargreaves, G.H., Samani, Z.A. (1985). *Reference crop evapotranspiration from temperature.* Appl. Eng. Agric., 1, 96–99.
