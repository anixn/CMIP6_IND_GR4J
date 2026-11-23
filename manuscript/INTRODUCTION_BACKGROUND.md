# INTRODUCTION_BACKGROUND.md — bullet bank for §1 (merge-ready)

Purpose: background material for the Introduction, kept as **bullets** so you can
merge/trim them yourself. Every bullet carries its `@bibkey` (all keys are in
`manuscript/references.bib` and were verified against publisher pages on
23 Nov 2026 — see `LITERATURE_SURVEY.md`). Bullets marked **[needs citation]**
assert something true but not yet backed by a verified reference.

**Web of Science status:** the WoS interface loads **IP-authenticated for your
institute** (the footer shows PANDIT DEENDAYAL PETROLEUM UNIV), but its Nextgen
Angular search form ignores synthetic input from automation — only real
keystrokes register. Two ways to bring WoS results in: (i) type one query in the
visible tab (e.g. `TS=("low flow" AND CMIP6 AND India)`) and tell me, and I will
harvest the result list; or (ii) paste the WoS search URL after you run it.
Meanwhile the bullets below use the publisher-verified set plus **OpenAlex**
searches run 23 Nov 2026 (verified metadata and citation counts), which surfaced
the India-propagation and ANOVA-canon references now added (Bhardwaj 2020,
Gupta 2024, Bosshard 2013, Chen 2011, Clark 2016).

---

## A. Why low flows decide water security in Peninsular India

- Peninsular India's water availability is decided in the non-monsoon months: irrigation, drinking-water supply, hydropower and environmental flows all draw on low flows, while ~80–90 % of annual rainfall arrives in the monsoon. **[needs citation: monsoon fraction]**
- Meteorological and agricultural drought are already pervasive and well mapped: the Drought Atlas of India provides 0.05° monitoring for 1901–2020 [@chuphal2024droughtatlas] — but it is not a streamflow-drought product.
- Peninsular catchments are dominated by hard-rock aquifers with limited deep storage, so rainfall deficits translate quickly into streamflow deficits; propagation from meteorological to hydrological drought is controlled by catchment storage, baseflow index and fractured-rock fraction [@barker2016propagation].
- Consequence for modelling: the storage terms of a conceptual model — not the monsoon flush — set the low-flow response, which is why a four-parameter structure (GR4J) and its six-parameter low-flow variant (GR6J) can agree on mean flow while disagreeing on droughts [@pushpalatha2011gr6j; @perrin2003gr4j].
- Abstraction and regulation are not modelled here; they are flagged as a limitation and deferred to the anthropogenic-drought phase. **[needs citation: CAMELS-IND regulation attributes]**

## B. The projection landscape over India (what exists)

- Bias-corrected CMIP6 at 0.25° for South Asia [@mishra2020biascorrected]: broad-scale, not catchment-tuned, and not hydrologically evaluated at low flows.
- India-wide streamflow projections with four hydrological structures (MILC/GR4J/HBV/HYMOD), 12 GCMs, 128 basins [@sharma2026hp] — the closest prior art; they note that "uncertainty existed for low flow events" without formalising it.
- Observation-constrained projections report robust streamflow **increases** in Indian rivers [@chuphal2026obsconstrained] — a large-scale statement that says nothing about low-flow behaviour in dry catchments.
- CAMELS-IND: 472 catchments, daily forcings and streamflow, 211 attributes, 1981–2014 [@mangukiya2025camelsind]; CAMELS-IND-Proj: LSTM streamflow for 13 GCMs × 4 SSPs, 2015–2100, now published in *Scientific Data* [@singh2026scidata].
- Large-sample hydrological benchmarking over Peninsular India: 47 conceptual models on 159 watersheds, GR4J in the five-model sufficient set [@mangukiya2026wrr] — establishes that structure choice matters, but benchmarks *observed* flow, not projections or low flows specifically.
- Single-basin Indian studies select GCMs on forcing skill or ML ensembles before hydrological modelling (Krishna basin; Papagni [@naresh2026papagni]; Betwa) — useful precedents, but single-basin and not low-flow-specific.

## C. The selection problem in the methods literature

- Forcing-based selection (rank GCMs on how well corrected rainfall/temperature match observations) is the default and is inherited from global assessments; it says nothing about discharge skill.
- Whole-flow criteria (KGE/NSE on the full hydrograph) are dominated by the monsoon season, where climate models are already similar; low-flow behaviour is a small fraction of the variance they see.
- GR4J-based low-flow projections exist (Q95, 37 Irish catchments) [@meresa2022water], showing the structural sensitivity of Q95 to climate change — but without a selection framework or a second structure.
- LSTM surrogates are trained across many basins with static attributes and evaluated regionally [@kratzert2018lstm; @kratzert2019regional]; best practice explicitly forbids single-basin training [@kratzert2024nevertrain], so a benchmark must be judged on its cross-model medians — which is what our audit does.
- Uncertainty decomposition is established: ANOVA over GCM × scenario × hydrologic-model factors in Korea for **low flows and drought events** (GR4J/GR6J/SWAT; model selection explains 21.9–51.9 % of low-flow variance) [@park2025jhrs], in Korea for calibration condition/length (3.9–9.8 % of runoff, 2.7 % of drought) [@kimchung2026hess], and in the Mediterranean for GCM-RCM × bias-correction method [@senatore2022med].

## D. Why bias-correction tail design deserves to be a factor

- Quantile-mapping choices materially alter projected extremes, quantiles and trends [@cannon2015qm]; error-correction method choice changes the climate-change signal [@themessl2012ecc; @gudmundsson2012eqm].
- Practice splits into *clamp at the training range* (constant) versus *extend linearly beyond it* (linear) — a design decision usually made silently and never tested against the response variable.
- Our own audit is a concrete instance of the failure class Cannon documents: the pre-fix linear implementation extended both tails with the slope of the lowest CDF interval (a drizzle artefact), turning a 60 mm/d future storm into 4.0×10⁹ mm/d and corrupting 9,985 of 13,068 corrected series before the guard caught it.
- After correction (per-tail robust slope + 1,000 mm/d ceiling), the tail policy turns out to matter ≤0.5 % of low-flow projection variance (H4) — a *bounded* negative finding with a practical message: tail-design anxiety is warranted for flood-oriented work, not for low-flow selection.

## E. The structural axis (why GR4J vs GR6J, not GR4J vs "any model")

- GR6J adds an exponential-store exchange branch explicitly designed to improve low-flow simulation [@pushpalatha2011gr6j] — the axis is the literature's own low-flow variant, not an arbitrary pair.
- Published evidence does **not** establish GR6J superiority: GR4J sometimes reproduces observed low flows more closely in prolonged dry periods; therefore the design quantifies **divergence**, never superiority (pre-registered in `GR6J_00_setup.Rmd`).
- Identical-treatment rule: same inputs, windows, warm-up, optimizer, objective, screening and out-of-sample evaluation for both structures — the only difference is the structure itself.

## F. Drought propagation as a selection dimension

- SPI→SRI lag via cross-correlation of standardised indices is standard [@barker2016propagation], and propagation under climate change is an active literature (Ireland [@meresa2023jgr]; Yangtze [@ma2023yangtze]).
- **India-specific propagation already exists and must be cited:** Bhardwaj, Shah, Aadhar & Mishra (2020, *JGR-Atmospheres*, 229 citations) map the propagation of meteorological to hydrological drought across India [@bhardwaj2020propagation]; Gupta, Jain & Pandey (2024, *Hydrol. Process.*) track changing propagation times in a semi-arid Indian basin [@gupta2024propagation]. **Differentiation:** both characterise propagation; neither turns reproduction of the observed propagation lag into a **GCM selection criterion** or asks whether mean-flow selection finds it — that is our H3.
- The **selection use** is what is new here: no prior study asks whether a GCM that reproduces the observed propagation lag is the one you should project droughts with.
- Guardrail: propagation must be measured as the cross-correlation lag, never inferred from near-identity of SPI and SRI (the Machhar-type artefact); our diagnostic (mean |SRI−SPI| = 0.29–0.34, far from the ≈0.013 signature) is reported as evidence.

## F2. The uncertainty-decomposition canon (for §4.2 positioning)

- ANOVA/variance decomposition of hydrological climate-impact ensembles has a canonical lineage: Chen, Brissette, Poulin & Leconte (2011, *WRR*, 469 citations) partitioned overall uncertainty for a Canadian watershed [@chen2011uncertainty]; **Bosshard et al. (2013, *WRR*, 389 citations) is the reference that formalised ANOVA over GCM × downscaling × hydrological-model factors** [@bosshard2013uncertainty] — cite it as the method's statistical anchor, alongside Park 2025 and Kim & Chung 2026 as the recent applications.
- Clark et al. (2016, *Curr. Clim. Change Rep.*, 334 citations) frames the uncertainty source inventory (GCM structure, downscaling, bias correction, hydrological model structure, internal variability) [@clark2016uncertainty] — use it to motivate *why* a three-factor decomposition with a tail-design axis is a defensible subset rather than an arbitrary one.
- These three make the concession in §2 airtight: the *method* is canonical, the *factor set* (tail design) and the *application* (India, low flows, 192 catchments) are the contribution.

## G. Ready-to-merge gap statements (one sentence each)

- No prior study tests whether forcing-skill rank and low-flow-skill rank diverge over Indian catchments — the formal ρ test and its near-zero outcome are new here.
- No prior Peninsular India study uses the GR4J/GR6J pair as a structural-uncertainty axis for low flows.
- No prior decomposition treats bias-correction **tail design** as a first-order factor alongside GCM and hydrological structure, and none runs at 192-catchment scale over India with a low-flow metric layer.
- Drought-propagation reproduction has been measured, but never used as a GCM selection criterion over Indian catchments.
- CAMELS-IND-Proj has not yet been audited at low flows by an independent process-based user; the dry-tail question is open in the dataset paper's own framing.

## H. Numbers ready to drop into the text (all executed)

- H1: ρ = −0.027, 95% CI [−0.095, 0.038], 1,000 bootstrap resamples, seed 20261118; 78 non-ephemeral catchments; pre-registered failure threshold ρ > 0.6.
- H2: dry-tercile 7-day minimum divergence −449 pp; Q95 −111 pp; whole-flow logNSE immaterial (median −0.01 to 0.05, p = 0.41–0.45); 172 paired catchments.
- H3: propagation share 0.91–0.96 for all 22 models; spread < 0.10; ρ(forcing rank, propagation share) = −0.350; 167 frozen observed lags.
- H4: structure ≥ 5% in 149 of 180 summary cells; dry-tercile structure share 0.66 / 0.68 / 0.59 (Q95 / 7-day minimum / low-tail shape) vs GCM 0.23 / 0.23 / 0.21; mean flow GCM 0.95–0.96; tail policy ≤ 0.005; 11,520 cells (11,514 decomposed, 6 logged).
- H5: LSTM win shares 0.86 / 0.88 logNSE, 0.92 / 0.95 low-flow volume, 0.81 / 0.78 7-day minimum, 0.71 / 0.71 Q95, 0.39 / 0.39 dry spell (vs GR4J / GR6J).
- Roster: 472 (setting) → 242 (Tier-1/2) → 192 (both structures; 64/64/64) → 172 (H2 base) / 78 (H1 composite) / 167 (propagation lags); GCM coverage 14/13/13/14.

## I. Citation items still open (for you, at camera-ready)

- Monsoon rainfall fraction and low-flow water-use statistics for Peninsular India.
- Anthropogenic abstraction/regulation quantification (CAMELS-IND attributes; the Year-4 phase).
- Full citations: Meresa 2023 (done), Ma 2023 author list, Pushpalatha 2011 end page, Krishna-basin GCM-selection paper authors, Mishra 2020 article number.
- WoS/Scopus coverage and citation counts under your institutional login.
