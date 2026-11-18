# PAPER_PORTFOLIO.md — publication pipeline for the Low-Flow & Drought programme

**Prepared:** 18 November 2026 · **Owner:** Ankit Deshmukh (PDEU Gandhinagar)
**Anchor:** 5-year roadmap (`Low-Flow-Profile/`); repo framing in `AGENTS.md` +
`manuscript/paper.md` v0.2. Rules from `AGENTS.md` apply: verdict files
(`H*_verdict.md`) are the contract between analyses and papers — no results section
without them; negative results are results.

---

## P1 — Low-flow-aware selection of CMIP6 models for catchment-scale drought projection over Peninsular India

| | |
|---|---|
| **Objective** | O1–O4 / H1–H4: low-flow metric layer + forcing-vs-low-flow rank divergence; GR4J–GR6J structural axis; drought-propagation selection test (pre-registered); GCM × structure × EQM-tail variance decomposition |
| **Engine (owned)** | QED (seasonal EQM, catchment-tuned, out-of-sample) + HYD (GR4J, 192 catchments, calib KGE 0.80 / valid 0.54) + GR6J axis + SSP projections (14 GCMs × 4 SSPs, own QM-corrected forcings) |
| **Data** | CAMELS-IND; CMIP6 historical (done) + SSP downloads (in progress); CAMELS-IND attributes |
| **Headline claim** | Model selection for drought projection must be hydrologically evaluated, not meteorological; forcing rank ≠ low-flow rank (pilot ρ = 0.14) |
| **Target journal** | Water Resources Research (first choice) / HESS |
| **Timeline** | 2026 Q4: SSP downloads + Phase 1 (metrics) → 2027 Q1: Phase 2 (GR6J) + Phase 3 (propagation) → 2027 Q2: Phase 4 (decomposition) + draft → **submit ~2027 Q3** |
| **Status** | Historical leg complete; manuscript v0.2 objective framed |

## P2 — Do LSTM projections survive a process-based low-flow audit? Benchmarking CAMELS-IND-Proj

| | |
|---|---|
| **Objective** | O5 / H5: first process-based low-flow audit of the new national LSTM projection dataset (13 GCMs × 4 SSPs, 2015–2100, 472 catchments) |
| **Positioning** | C21-aligned (Global-South benchmarking). CAMELS-IND-Proj is the benchmarked object, never substrate (two-track rule). Framed as benchmark confirmation from the outset if LSTM wins |
| **Data** | CAMELS-IND-Proj (Zenodo 21775597, 11.3 GB — download in background ASAP); our GR4J/GR6J projections as the process-based comparator |
| **Key checks** | Verify "239 confidence-flagged catchments" against downloaded files before use; alignment of gauge IDs; whether their forcings are bias-corrected (expect: inherited Mishra 2020) |
| **Target journal** | HESS / Scientific Data companion |
| **Timeline** | 2027 Q1–Q2 (after P1 metric layer exists) → **submit ~2027 Q4** |
| **Status** | Blocked only on the 11.3 GB download — start immediately |

## P3 — A national streamflow-drought climatology and low-flow threshold framework for Peninsular India

| | |
|---|---|
| **Objective** | Roadmap Phase 2 flagship: streamflow-drought thresholds (Q90/deficit volume/duration), low-flow frequency under non-stationarity, national climatology 1981–2014 + SSP evolution for the 14-GCM ensemble |
| **Engine (reused)** | P1's projection ensembles + metric layer; observed Q from CAMELS-IND (+ CWC gauges for extension) |
| **Positioning** | The streamflow-drought layer the Drought Atlas ecosystem lacks — candidate integration with India Drought Monitor (roadmap Phase 5) rather than competition |
| **Target journal** | WRR / Journal of Hydrology |
| **Timeline** | 2027 Q3–2028 Q1 → **submit ~2028 Q2** |
| **Status** | Not started; depends on P1 engine |

## P4 — Machine-learning low-flow forecasting for Indian catchments (with optional P5: anthropogenic drought & e-flow exceedance)

| | |
|---|---|
| **Objective** | Roadmap Phase 3: low-flow/drought forecasting (S2S + ML), benchmarked against process-based and index baselines. Optional Year-4 P5: separating climate vs abstraction signals in Indian low flows (CAMELS-IND regulation attributes), e-flow exceedance during droughts |
| **Engine (reused)** | P1+P2 infrastructure; ICSSR early-warning project synergy |
| **Target journal** | HESS / WRR |
| **Timeline** | P4: 2028 Q1–Q3 → submit ~2028 Q4. P5: Year 4 (2029) |
| **Status** | Not started; foundation = P1 + P2 |

---

## Dependency map

```
P1 (selection + GR6J + propagation + decomposition)
 ├── P2 (LSTM audit)          [needs P1 metric layer; data download now]
 ├── P3 (national climatology)[needs P1 engine + projections]
 └── P4 (forecasting)         [needs P1 + P2]
      └── P5 (anthropogenic)  [Year 4; needs P1–P3 + regulation attributes]
```

## Near-term actions (no analysis yet — as of 18 Nov 2026)

1. **Now:** SSP download script updated to 4 SSPs (ssp370 added) — downloads in progress in `D:\Datasets\Download_CMIP\data_raw\cmip6`.
2. **Now:** start CAMELS-IND-Proj download (11.3 GB) in background — needed for P2 regardless of analysis start.
3. **Tomorrow (analysis start):** `/inventory` first, then `/lowflow-metrics` (Phase 1).
4. **Watch item:** IITR group's own application papers for CAMELS-IND-Proj — P1/P3 are method-protected; P2's "first critical user" advantage decays, so P2 should follow P1 tightly.
