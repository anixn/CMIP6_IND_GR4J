# Novelty Verification Memo — 17 Nov 2026

Editor: journal-editor review for Ankit Deshmukh, paper.md v0.1, repo `anixn/CMIP6_IND_GR4J`.

**Gate decision: NOVELTY SUFFICIENT — the instruction kit was produced.**

Everything below was checked against live web sources on 17 Nov 2026. Search was the
tool (publisher pages 403 on direct fetch for two items, so abstracts were verified
via multiple independent search snippets).

## 1. Core facts verified

| Claim in the brief | Verification |
|---|---|
| CAMELS-IND: 472 Peninsular India catchments | Confirmed — Mangukiya et al. 2025, ESSD 17:461; Zenodo 14999580; 228 catchments with ≥30% observed streamflow 1980–2020 |
| CAMELS-IND-Proj: 472 catchments, 13 GCMs, 4 SSPs, daily 2015–2100, LSTM | Confirmed — Zenodo record 21775597 (V1.0, 3 Aug 2026), CC BY 4.0, EcoHydroX Lab IIT Roorkee (Singh, Mangukiya, Sahu, Sharma), software hydroDL (Shen 2020), 11.3 GB zip + filter script; historical-per-GCM streamflow included |
| Repo `github.com/anixn/CMIP6_IND_GR4J` exists, public | Confirmed — public repo, 3 commits, master branch, MIT license, QED_00–30 and HYD_00–30 .Rmd notebooks, `data_processed/`, `manuscript/`, `India_Shp/`, README, Suggestion-workflow.md |
| Mangukiya et al. 2026 WRR: GR4J among 5 models sufficient in >85% of Peninsular watersheds | Confirmed — WRR 2026WR044753, "Benchmarking and Selecting Optimal Hydrological Models..."; 47 conceptual models, 159 watersheds, MARRMoT; compact set of 5 (HBV, GR4J, MODHYDROLOG, SMA, Hillslope) sufficient in >85% |
| Park et al. 2025 Sci. Rep.: GR5J/GR6J outperform GR4J for low flows (South Korea) | Confirmed — s41598-025-16429-z |
| GR6J best for low flows, GR4J best for high flows (Irish/Golian 2021 evidence) | Confirmed — Golian et al. 2021 (S2214581821000884) regionalizes GR4J and GR6J for high/median/low flows; Wiley 2026 hyp.70429 review cites "GR6J performed best for low flows, while GR4J excelled at simulating high flows (Golian et al. 2021)"; Flores et al. 2021 (Water 13:3191) same pattern |
| TOPSIS CMIP6 selection, EC-Earth3-Veg / MPI-ESM1-2-LR / BCC-CSM2-MR | Confirmed — ResearchGate 408412200: "A TOPSIS-based framework was used to evaluate seven CMIP6 models... EC-Earth3-Veg, MPI-ESM1-2-LR..." (Naresh & Mathew group; journal listed around PCE/HP — cite from the snippet, verify journal name at camera-ready) |
| Betwa propagation time, Singh et al. 2026 HSJ | Anchor supported by the figshare record "Assessment of drought propagation characteristics in the Betwa river basin under CMIP6 climate projections" (Dec 2025, Taylor & Francis). The 80%-decrease and 42→63% numbers could not be independently confirmed from snippets — treat as cited-from-brief, verify at camera-ready |
| Wilby & Harris 2006 WRR Thames uncertainty ordering | Consistent with search results; classical anchor, low risk |
| CAMELS-IND-Proj confidence flags = 239 catchments | NOT confirmed on the Zenodo landing page — flags are described in the dataset's separate data-description PDF. The kit instructs the agent to verify the actual number and flag semantics against the downloaded files before using them. Do not print "239" in the paper unverified |

## 2. Prior-art hunt (what would have killed novelty)

Closest prior art found, and why each does NOT break the novelty claims:

1. **Sharma et al. 2026, Hydrological Processes 40(3), hyp.70476** — "Projections of
   Future Streamflow for India Informed by CMIP6 Global Climate Models." Multi-model
   (MILC, GR4J, HYMOD, HBV) with 12 GCMs and their ensemble mean; MILC best for
   43.71% of basins, GR4J 22.52%. **No GR6J, no low-flow-specific selection
   divergence test, no uncertainty decomposition, no propagation-time selection.**
   This is the paper to cite as "closest prior art" and to differentiate against in
   the discussion. It actually strengthens the H2/H4 novelty claim by demonstrating
   that multi-structure India projections exist WITHOUT the low-flow lens.
2. **Liu et al. 2025, Climate/Atmosphere (MDPI 16(6):691)** — CMIP6 selection +
   streamflow + hydrological drought. Single-basin-scale framework, not a 472-catchment
   large-sample out-of-sample ranking, and not a forcing-vs-lowflow rank-divergence
   test.
3. **Meresa et al. 2023 (Irish catchments, CMIP6 drought propagation)** and **Wang
   et al. 2025 (drought propagation, CMIP6)** — propagation analysis exists in other
   regions, so propagation time itself is NOT novel (the brief says this). The novel
   element is using propagation reproduction as a CMIP6 SELECTION criterion over
   472 catchments, which none of these do.
4. **Senatore et al. 2022 (ANOVA of GCM + bias correction, Mediterranean)** — ANOVA
   decomposition exists (so the method is not novel), but not for Peninsular India,
   not with GR4J/GR6J as the structural axis, not at 472-catchment scale. Method
   borrowed, application + axis new.
5. **Lees et al. 2021 (HESS, LSTM benchmarks, GB)** — LSTM vs conceptual benchmarking
   exists in the UK; not against CAMELS-IND-Proj, not low-flow-specific, not India.
6. **No existing "CAMELS-IND-Proj + GR4J/GR6J low-flow benchmark" work found** — the
   only search hit for CAMELS-IND-Proj benchmarking is the dataset record itself.

## 3. Novelty verdict per pillar (after verification)

- **P1 (low-flow-aware selection, C9): sufficient, conditional** — the condition
  (rank divergence not an artefact of one metric; ≥3 metrics with inter-metric rank
  correlations reported) is baked into the `/lowflow-metrics` command.
- **P2 (GR4J–GR6J structural axis, C2): strong** — no Peninsular India study uses the
  pair as a structural-uncertainty axis; Sharma 2026 confirms the gap. Strongest
  objective; keep as the core.
- **P3 (propagation-time selection, C2): sufficient with precise framing** — the
  selection angle is the gap; the index is not new. Machhar-type near-identity trap
  is explicitly forbidden in `/propagation`.
- **P4 (decomposition, C9+C21): strong** — ANOVA methods exist (Senatore 2022), the
  472-catchment GR4J/GR6J-axis application does not.
- **P5 (C21 benchmark): strong as secondary** — CAMELS-IND-Proj owns the projections;
  your contribution is the process-based low-flow benchmark they have not been tested
  against.

Bottom line from the earlier editorial stands after verification: pursue Objectives
2, 3, 4 as the core; 1 is the selection layer made novel by the ρ-divergence; 5 is
the secondary C21 benchmark.

## 4. Caveats carried into the kit

- The "239 confidence-flagged catchments" number is unverified on the public record;
  `/benchmark-lstm` forces verification against the downloaded files before use.
- Betwa quantitative details (80% decrease, 42→63%) are cited-from-brief; verify at
  camera-ready.
- Naresh & Mathew 2026 journal attribution varies across snippets (Hydrol. Proc. vs
  PCE); confirm before citing.
- The repo's `paper.md` lives in `manuscript/` (not visible at repo root); the kit's
  commands reference the manuscript directory accordingly.

## 1b. Data-description PDF verified (18 Nov 2026)

`Data_description for CAMELS-IND-Proj_data.pdf` (192 KB, downloaded from Zenodo
21775597 alongside the 11.3 GB zip; text extracted, 4 pages). Findings:

- Confirmed: 13 CMIP6 GCMs x 4 SSPs (SSP126/245/370/585), daily streamflow (cumecs)
  2015-2100, historical-per-GCM streamflow, forcings (pr mm, tasmax/tasmin C)
  historical + future per GCM per SSP, hydroDL (Shen 2020) LSTM, 472 catchments,
  `filter_catchment_model_scenario.py` inside the zip. All as briefed.
- **Two-track rule hard-confirmed:** the acknowledgements explicitly thank
  Mishra et al. 2020 for the bias-corrected CMIP6 precipitation/temperature data
  (Zenodo 3987736) used as the forcing basis. CAMELS-IND-Proj forcings therefore
  inherit the coarse-scale Mishra correction - they must never be our substrate;
  Track-B-only status is now evidence-backed, not just strategic.
- **"239 confidence-flagged catchments" still unverified:** the number does NOT
  appear in this PDF (its file-structure section points at an embedded
  table/figure not extractable from the text layer). Verification must come from
  the downloaded zip contents (look for a confidence-flag column/file). Keep
  "239" out of any manuscript text until then.
- Bibliography anchors for P2 obtained: Singh/Mangukiya/Sahu/Sharma authorship
  (IIT Roorkee Dept. of Hydrology; correspondence ashutosh.sharma@hy.iitr.ac.in);
  APN grant CRRP2022-01MY-Sharma; FIG-100917.
