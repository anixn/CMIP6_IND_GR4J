# LITERATURE_SURVEY.md — verified survey (23 Nov 2026)

**Method.** Scopus/WoS unauthenticated sessions gate the result lists, so every
entry below was verified against **open publisher pages** (ScienceDirect,
Copernicus/HESS, Wiley open, Nature, AGU, CSDMS listing, Maynooth eprint,
Google Scholar) via the in-app browser and web search on 23 Nov 2026. Scopus/WoS
sign-in was attempted (session found unauthenticated; user directed us to
proceed). Any entry not fully verified is flagged `VERIFY` and listed in the
camera-ready checklist (bottom).

Status: every "what they own / why our lane survives" cell below is now backed
by a verified fact from the publisher page, not from the earlier working notes.

---

## 1. The ANOVA / uncertainty-decomposition family (conceded machinery)

| Ref | Verified facts | Use in our paper | Why our lane survives |
|---|---|---|---|
| **Park, Kim, Sung & Chung 2025**, *J. Hydrol.: Reg. Stud.* 62, 102991, doi:10.1016/j.ejrh.2025.102991 (open access; Dec 2025) | ANOVA of climate-projection + hydrologic-modelling uncertainty on **two drought projections (low flows AND drought-event characteristics)** in three Korean reservoir basins (Andong, Hapcheon, Seomjingang). Hydrologic models: **GR4J, GR6J, SWAT**. Results: GCMs dominant for runoff; scenarios matter for drought events; **hydrologic-model selection explains 51.9 / 21.9 / 50.5 % of projected low-flow variance** (site-dependent); 5.6–12.4 % for drought-event characteristics | Cited in §2, §4.2 and §6 as the closest methodological relative | 3 basins vs our **192** (aridity-stratified, tercile medians + catchment bootstrap); Korea vs Peninsular India; **no tail-policy factor** (their BC is not a factor); no forcing-vs-low-flow **rank-divergence** test; no propagation-selection dimension. Their "site-dependent" low-flow finding is *corroborated* by our H4 (structure 34–68 %), which we state — corroboration strengthens both papers |
| **Kim & Chung 2026**, *HESS* 30, 227–247, doi:10.5194/hess-30-227-2026 (15 Jan 2026; HESS = P1 target journal) | ANOVA with replication (3,600 combos): 20 CMIP6 GCMs × 3 SSPs × SWAT × calibration conditions (SDI: dry/normal/wet) × calibration length (1–20 y), four Korean dam basins. **GCM dominant**; hydrologic-model calibration contributes **3.9–9.8 %** to future runoff (largest in low-runoff periods), **2.7 %** to future drought analysis. They **exclude 3-way interactions** as hard to interpret | Cited in §2, §4.2, §6 | Single structure (SWAT) → no structural axis; calibration-length axis, not bias-correction axis; no low-flow-specific metric layer; no selection framework. Their replication-based design (residual df > 0) contrasts with our saturated exact partition — a methodological difference worth one sentence |
| **Senatore, Fuoco, Maiolo, Mendicino, Smiatek & Kunstmann 2022**, *J. Hydrol.: Reg. Stud.* 42, 101120, doi:10.1016/j.ejrh.2022.101120 (open access) | ANOVA of **15 EURO-CORDEX GCM-RCM members × 3 bias-correction methods** (60 simulations, 3 future periods, RCP4.5), Crati basin (S. Italy). **GCM primary**; BC methods "smooth the projected hydrological impact" (runoff reduction ~3 % smaller with BC) | §2, §4.2 (the "bias correction as ANOVA factor" precedent), §6 | Single catchment; BC as *methods* (not the **tail/extrapolation design** of one method); no low-flow focus; no GR4J/GR6J axis; no selection logic. This paper is exactly why P4's claim says **"tail design"**, never "bias correction" generically |

**Corroboration synthesis (for §6):** Park et al. (low flows: model selection
21.9–51.9 %, site-dependent) and Kim & Chung (calibration: 3.9–9.8 %, largest in
low-runoff periods) bracket our H4 result (structure 34–68 %, stratified by
aridity) — the structural/calibration axis is significant wherever anyone has
looked at low flows, and nobody has looked at it at large-sample scale in India.

## 2. The tail-behaviour anchors (the `tail_policy` factor)

| Ref | Verified facts | Use |
|---|---|---|
| **Cannon, Sobie & Murdock 2015**, *J. Climate* 28(17), 6938–6959, doi:10.1175/JCLI-D-14-00754.1 | Quantile-mapping algorithms modify trends/quantiles/extremes; tail handling is a documented first-order sensitivity | §4.2/§4.3 anchor + §6 (our 23 Nov defect is a concrete instance of this failure class) |
| **Themeßl, Gobiet & Heinrich 2012**, *Climatic Change* 112(2), 449–468 | Error-correction method choice materially alters the climate-change signal | cited alongside Cannon 2015 |
| **Gudmundsson et al. 2012**, *HESS* 16, 3383–3390 (Technical Note) | Empirical quantile-mapping transformations compared at station scale (the canonical EQM reference; also cited by Kim & Chung) | §4.1/§4.3 EQM description |

## 3. Low flows + structural axis (GR4J/GR6J)

| Ref | Verified facts | Use |
|---|---|---|
| **Pushpalatha, Perrin, Le Moine & Andréassian 2011**, *J. Hydrol.* 411, 66–79 (VERIFY end page), doi:10.1016/j.jhydrol.2011.10.022 (cited by ~279) | Introduces **GR6J** (exponential-store exchange branch) specifically to improve low-flow simulation; downward structural sensitivity analysis | §4.2 GR6J rationale — the structural axis is not arbitrary; it is the low-flow-designed variant |
| **Meresa, Donegan, Golian & Murphy 2022**, *Water* 14(10), 1556, doi:10.3390/w14101556 (open) | GR4J + SMART, **Q95 low flows**, 37 Irish catchments, climate-change projections | §2/§6: GR4J-based low-flow projection exists (Ireland) — but no GR6J axis, no model-selection framework |
| **Mangukiya, Sahu, Gupta & Sharma 2026**, *WRR* 62(7), e2026WR044753 | **47 MARRMoT models benchmarked on 159 Peninsular India watersheds**; GR4J in the 5-model sufficient set | §2 (ally, not competitor — independent support for the structural choice), §4.2 |
| **Sharma, Barbhuiya & Gupta 2026**, *Hydrol. Process.* 40(3), e70476 | India-wide future streamflow, 4 structures (MILC/GR4J/HBV/HYMOD), 12 GCMs, 128 basins (verified via the CAMELS-IND-Proj reference list) | §2 closest prior art |

## 4. Propagation (H3)

| Ref | Verified facts | Use |
|---|---|---|
| **Barker, Hannaford, Chiverton & Svensson 2016**, *HESS* 20, 2483–2505, doi:10.5194/hess-20-2483-2016 (cited by ~711) | **Cross-correlation of SSI-1 with SPI accumulation periods across 121 UK catchments**; catchment storage properties (baseflow index, fractured-rock %) control propagation | §4.2 (the cross-correlation-lag method we borrow) + §6: our hard-rock Peninsular catchments are the storage-poor end of exactly the gradient Barker describes — a physical explanation for short lags |
| **Meresa, Murphy & Donegan 2023**, *JGR-Atmospheres* 128, e2022JD038025, doi:10.1029/2022JD038025 (cited by 26) | Propagation under climate change, 10 Irish catchments, standardised indices | §2/§6 propagation exists elsewhere; the **selection use** over Indian catchments is new |
| **Ma et al. 2023**, *Int. J. Climatol.* 43(12), 5640–, doi:10.1002/joc.8165 (cited by 43; first author F. Ma per ADS/Copernicus listing) | Propagation under climate warming, Yangtze; 40–50 % of meteorological droughts develop into hydrological droughts with lags < 1.4 months | §6; **corrects the spec's "Wang et al. 2025" placeholder — that citation did not resolve; Ma et al. 2023 is the verified referent** |

## 5. The LSTM benchmark debate (H5)

| Ref | Verified facts | Use |
|---|---|---|
| **Kratzert et al. 2018**, *HESS* 22, 6005–6020, doi:10.5194/hess-22-6005-2018 | LSTM rainfall–runoff modelling established (241 CAMELS basins) | §5.4/§6: the methodological basis of CAMELS-IND-Proj's hydroDL LSTM |
| **Kratzert et al. 2019**, *HESS* 23, 5089–5111, doi:10.5194/hess-23-5089-2019 | Regional LSTM (EA-LSTM) trained on many catchments with static attributes | §6: the *right* way to train an LSTM — context for why benchmark medians (our H5 basis) are the fair comparison |
| **Kratzert, Gauch, Klotz & Nearing 2024**, *HESS Opinions* 28, 4187–4201, doi:10.5194/hess-28-4187-2024 | "Never train an LSTM on a single basin" — best practice is large-sample training | §6: supports treating the benchmark's cross-model medians as its best case, and our process-based audit as the complement |

## 6. Indian context (setting + precedents)

| Ref | Verified facts | Use |
|---|---|---|
| **Singh, Mangukiya, Sahu et al. 2026**, *Scientific Data*, doi:10.1038/s41597-026-08858-w — **CAMELS-IND-Proj is now formally published** (not only Zenodo) | Dataset paper for the Track-B benchmark | §3 data + §5.4; upgrade the citation from Zenodo to the journal paper (Zenodo kept as data reference) |
| **Mangukiya et al. 2025**, *ESSD* 17, 461–491 | CAMELS-IND dataset (472 catchments; LSTM streamflow included) | §3 |
| **Chuphal & Mishra 2026**, *Earth's Future* 14 | Observation-constrained projections: robust streamflow **increases** in Indian rivers | §6: large-scale Indian projections exist and project *increases* — our catchment-scale low-flow layer and the H1/H4 wedges explain why that is not a low-flow statement |
| **"Catchment response to climate change under CMIP6 scenarios: Krishna River Basin"**, *J. Water Clim. Change* 15(2), 476 (2024; VERIFY authors) | 18 CMIP6 GCMs, symmetric-uncertainty GCM **selection**, SWAT, single basin | §2: Indian GCM-selection precedents exist but are single-basin, forcing-based, no low-flow layer |
| **Naresh & Mathew 2026**, *J. Atmos. Solar-Terr. Phys.* (pii S1474706526002883; VERIFY volume/pages) — **resolves the spec's "HP vs PCE" question: it is neither** | ML-enhanced multi-model ensemble, Papagni basin (semi-arid India) | §6 (Indian ML/ensemble precedent) |
| **Singh et al. 2025/26 (Betwa)**, *J. Water Clim. Change* (manuscript id jwc2025598; VERIFY final details + the 80 %/42→63 % figures) | SWAT + CMIP6 + Land Change Modeler, Betwa basin | §6 (verify figures before quoting) |
| **Chuphal et al. 2024**, *Sci. Data* 11, 7; **Mishra et al. 2020**, *Sci. Data* 7, 331 (VERIFY article no.), doi:10.1038/s41597-020-00681-1 | Drought Atlas of India; bias-corrected CMIP6 South Asia | §2/§3 |

---

## 7. Scopus / Web of Science access status

- Scopus reached through the app browser shows the search form, but result
  lists require sign-in (session was unauthenticated; user directed to
  proceed without). Web of Science was not reachable without the same login.
- Consequence: citation-count and coverage statistics from Scopus/WoS are
  **pending** and should be re-run under the institutional session at
  camera-ready. Nothing in the written sections depends on them.
- Everything above was verified from publisher pages, which is stronger
  evidence than a database row for citation-accuracy purposes.

## 8. Camera-ready checklist (updated)

1. Park 2025 factor list — **DONE** (GR4J/GR6J/SWAT; low-flow shares 51.9/21.9/50.5 %).
2. Senatore 2022 full citation — **DONE** (JHRS 42:101120, 6 authors).
3. Liu 2025 author list — **DONE** (Liu, T.; Liu, Y.; Si, Z.; Wang, L.; Zhao, Y.; Wang, J.).
4. Kim & Chung 2026 numbers — **DONE** (calibration 3.9–9.8 % runoff / 2.7 % drought; GCM dominant).
5. "Wang et al. 2025" — **CORRECTED** to Ma et al. 2023, *IJC* 43:5640 (unverified placeholder removed).
6. Naresh & Mathew journal — **DONE** (JASTP, neither HP nor PCE).
7. Meresa 2023 — **DONE** (JGR-Atmospheres 128, e2022JD038025) + added Meresa et al. 2022 *Water* 14:1556.
8. Pushpalatha 2011 pages — end page `VERIFY` (66–79 likely).
9. Betwa figures (80 % decrease, 42→63 %) — `VERIFY` against the JWC paper before quoting.
10. Krishna-basin GCM-selection paper authors/year — `VERIFY`.
11. Mishra 2020 article number (331) — `VERIFY`.
12. Scopus/WoS citation counts + coverage re-check under institutional login — pending.
