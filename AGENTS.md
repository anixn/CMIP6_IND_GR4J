# AGENTS.md — CMIP6_IND_GR4J: Low-Flow Projection Uncertainty Project

## What this repository is

An out-of-sample, low-flow-aware model-selection framework for CMIP6 climate models
over Peninsular India. It ranks CMIP6 models on **low-flow and drought skill through a
calibrated hydrological model** — not on precipitation statistics — and separates three
sources of low-flow projection uncertainty: GCM choice, hydrological model structure
(GR4J vs GR6J), and bias-correction design (EQM tail policy).

The science question: *Which CMIP6 models are fit for low-flow and drought projection
over Peninsular India — and how much does the answer depend on the hydrological model
and the bias correction?*

**Two-track design (fixed 18 Nov 2026).** Track A (substrate, ours): own QED-corrected
CMIP6 series (14 hybrid-shortlisted GCMs × 4 SSPs incl. ssp370) → GR4J/GR6J → low-flow
projections. Track B (benchmark, theirs): CAMELS-IND-Proj (Zenodo 21775597) is used
ONLY as the audited object of H5 — never as substrate, never as input to our models.

Status: `paper.md` (draft v0.2) frames the objective and the prior-art differentiation.
The missing results are (a) the low-flow metric layer, (b) the GR6J structural axis,
(c) the drought-propagation selection test. The SSP projections are the demonstration,
not the product. Portfolio plan: `research_plan/PAPER_PORTFOLIO.md` (3–4 papers).

## Non-negotiable scientific guardrails

1. **Out-of-sample discipline.** Calibration/fit window is 1981–2000; scoring window
   is 2001–2014. Never score a model on data used to fit or calibrate it.
2. **Forcing rank ≠ low-flow rank.** The pilot Spearman ρ = 0.14 between forcing-skill
   rank and discharge-skill rank is the empirical wedge. Preserve it; re-estimate it
   when the low-flow metric layer lands. Do not tune toward a bigger divergence.
3. **Divergence is the signal, not the ranking.** GR4J vs GR6J is a structural
   uncertainty axis, not a beauty contest. GR6J was designed for low flows, but
   published evidence (Irish catchments; South Korea; regionalization studies) shows
   GR4J sometimes matches observed low flows more closely in prolonged dry periods.
   Never assert GR6J superiority; quantify the divergence.
4. **Negative results are results.** If H1/H2/H5 is falsified, report it. If low-flow
   rank correlates with forcing rank at ρ > 0.6, H1 fails and the framework collapses
   to one stage — say so in the paper. Do not tune the analysis to produce the
   expected direction.
5. **No metric averaging without inspection.** Before compositing ranks, check pairwise
   Spearman correlations among metrics; if two metrics are near-duplicates (ρ > 0.9),
   drop one instead of double-counting.
6. **Pre-registered tolerance bands.** For drought-propagation reproduction (H3), fix
   the tolerance band on observed propagation time **before** running the model
   comparison, and record the date of pre-registration in the output.
7. **No silent drops.** Every catchment exclusion, skipped calibration, and gap-fill
   gets a machine-readable log line with a reason code. Flags propagate downstream:
   every EQM-corrected value carries `within_range`/`extrapolation`; every discharge
   series carries `n_gap_filled`.
8. **Machhar-type traps.** Never infer drought propagation from near-identity of SPI
   and SRI (a mean |SRI−SPI| ≈ 0.013 is a model-structure artefact of too-tight
   precipitation–runoff coupling, not a climate finding). Compute propagation time
   explicitly as the SPI–SRI cross-correlation lag, with the observed distribution as
   benchmark.

## Repository map

| Path | Role |
|---|---|
| `QED_00–30` `.Rmd` | Forcing selection notebooks (setup → aggregate CMIP6 → inventory tiers → QM fit/apply → rank and report) |
| `HYD_00–30` `.Rmd` | GR4J calibration/discharge evaluation notebooks (setup → inputs → calibrate → simulate) |
| `data_processed/` | Outputs incl. `hyd/model_shortlist_final.csv` (14-model hybrid shortlist) |
| `India_Shp/` | India shapefiles for mapping |
| `manuscript/` | `paper.md`, `NOVELTY_AND_ANOVA_SPEC.md` (binding novelty + ANOVA spec, v2 23 Nov 2026), `H4_PIPELINE.md` (H4 data flow), `AGENT_LOG.md` and manuscript assets |
| `LOWFLOW_*`, `PROP_*`, `DECOMP_*`, `BENCH_*` | New modules to be added (see phase map below) — parallel to existing notebooks, never edits them |

## Data in play

- **CAMELS-IND** (Mangukiya et al. 2025, ESSD 17:461, Zenodo 14999580): 472 catchments,
  228 with observed streamflow ≥30% of 1980–2020. Tier 1 n=180, Tier 2 n=62, Tier 3
  excluded n=230.
- **CAMELS-IND-Proj** (Zenodo 21775597, CC BY 4.0, EcoHydroX Lab IIT Roorkee; derived
  from CAMELS-IND; LSTM via hydroDL; 11.3 GB zip + `filter_catchment_model_scenario.py`):
  daily streamflow 2015–2100 for 13 CMIP6 GCMs × 4 SSPs (126/245/370/585) across 472
  catchments, plus historical-per-GCM streamflow and forcings. Confidence flags exist
  for a subset of catchments (239 per the project brief; details in the dataset's
  data-description PDF — verify against the actual downloaded files).
- **CMIP6**: 22 all-variable models for forcing selection; 14 shortlisted for SSP runs
  (hybrid forcing + discharge rank, `data_processed/hyd/model_shortlist_final.csv`).
  SSP plan: **ssp126, ssp245, ssp370, ssp585** (AR6 core matrix; ssp370 added 18 Nov
  2026 for drought-envelope completeness and CAMELS-IND-Proj comparability).
- GR4J status: calibration median KGE 0.80, validation median 0.54 across 192
  catchments.

## Prior-art positioning (differentiation anchors — cite and differentiate, never ignore)

| Group / product | What they own | Why our lane survives |
|---|---|---|
| India Drought Monitor + **Drought Atlas of India** (Chuphal et al. 2024, Sci. Data; IITGN Water & Climate Lab) + bias-corrected CMIP6 South Asia (Mishra et al. 2020, Sci. Data) | Meteorological/agricultural drought monitoring at 0.05°; coarse-scale bias-corrected CMIP6 | No streamflow drought at catchment scale; their bias correction is not catchment-tuned, not seasonally stratified, not hydrologically evaluated, not out-of-sample ranked |
| **CAMELS-IND** (Mangukiya et al. 2025, ESSD) + **CAMELS-IND-Proj** (Singh et al. 2026, Zenodo 21775597; 13 GCMs × 4 SSPs, LSTM) + MARRMoT adequacy benchmark (Mangukiya et al. 2026, WRR) | Datasets, regional LSTM projections, model-adequacy benchmarking | No low-flow-aware analysis of their own product yet; LSTM dry tail unaudited; we are the first critical process-based user (H5). Their forcings inherit Mishra 2020 bias correction — another reason they must never be our substrate |
| **Sharma, Barbhuiya & Gupta 2026** (Hydrol. Process. 40(3), e70476; IIT Mandi) — closest prior art | India-wide future streamflow, 4 structures (MILC/GR4J/HBV/HYMOD), 12 GCMs, 128 basins | No GR6J, no low-flow-specific selection, no forcing-vs-low-flow rank-divergence test, no propagation-time selection, no uncertainty decomposition |
| Tiwary & Mondal 2026 (EGU abstract) | Historical Q7min trends on 55 minimally-regulated CAMELS-IND catchments | Historical description only; our work is projections + selection + uncertainty |
| **Park, Kim, Sung & Chung 2025** (J. Hydrol.: Reg. Stud. 62:102991, doi:10.1016/j.ejrh.2025.102991) | ANOVA of uncertainty contributions to hydrologic drought projection, South Korea | Method borrowed (concede, cite); Korea not India; no GR4J/GR6J axis; no tail-policy factor. Verify its exact factor list at camera-ready |
| **Kim & Chung 2026** (HESS 30:227–247, doi:10.5194/hess-30-227-2026) | ANOVA of GCM × SSP × calibration-condition × calibration-length, future drought, South Korea (SWAT, SDI; GCM > 60% for runoff, calibration-related 3.9–9.8%) | Method borrowed; single structure (SWAT) so no structural axis; no bias-correction factor. **Cite in §2 AND §4.2 — HESS is a P1 target journal** |
| Senatore et al. 2022 (Mediterranean ANOVA of GCM + bias correction; verify full citation at camera-ready) | ANOVA with bias-correction method as a factor | Method borrowed; this is why P4's claim must say **"tail design"**, never "bias correction" generically |
| **Cannon, Sobie & Murdock 2015** (J. Climate 28(17):6938–6959, doi:10.1175/JCLI-D-14-00754.1) | Quantile-mapping algorithms modify trends/quantiles/extremes; tail behaviour is a documented sensitivity | Not a competitor — the methodological anchor for the `tail_policy` factor; cite in §4.2/§4.3 next to the tail-policy definition |
| **Themeßl, Gobiet & Heinrich 2012** (Climatic Change 112(2):449–468) | Error-correction method choice materially alters the climate-change signal | Same anchoring role as Cannon 2015; cite alongside it |
| Liu et al. 2025 (Atmosphere 16(6):691, doi:10.3390/atmos16060691 — **journal corrected 23 Nov 2026, was mis-cited "Climate"**) | CMIP6 selection + streamflow + hydrological drought (SWAT+MODFOOD) | Single-basin scale; no 192-catchment out-of-sample rank; no rank-divergence test. Complete author list at camera-ready |

## Roadmap mapping (5-year Low-Flow & Drought programme, `Low-Flow-Profile/`)

This repository is the **Year-1/2 core of Phase 2** (national low-flow climatology &
projections) and the method foundation for Phase 3 (ML low-flow forecasting). Year-4
(anthropogenic drought, e-flow exceedance) enters later via CAMELS-IND regulation
attributes — flagged as a limitation in the current paper, not promised in it.

## Conventions

- **Stack:** R + airGR (+ airGRteaching or manual wrapper for GR6J), R Markdown
  notebooks, Oudin PET for both structures, identical calibration/validation windows
  and warm-up handling for GR4J and GR6J.
- **New modules are parallel, not invasive.** Write `LOWFLOW_00_metrics.R`-style
  modules as new files; do not modify existing `QED_*`/`HYD_*` notebooks.
- **Reproducibility:** every script writes a session-info file and uses `set.seed()`
  where resampling is used. Output tables are tracked in git; bulk series are
  regenerated, not committed.
- **Naming:** catchment ID columns keep CAMELS-IND gauge IDs; every metric table has
  `model`, `catchment`, `period`, `window` (calib/valid), `metric`, `value`,
  `n_gap_filled`, `extrapolation_share`.
- **Logs:** `data_processed/logs/<module>_exclusions.csv` with columns
  `module, catchment, reason_code, detail`.

## Novelty framing & roster discipline (spec v2, 23 Nov 2026 — binding)

Full spec: `manuscript/NOVELTY_AND_ANOVA_SPEC.md`. Summary rules every agent
must follow when touching `paper.md`:

1. **Headline (use verbatim or near-verbatim):** the first low-flow-aware
   CMIP6 model-selection framework for Peninsular India — ρ-divergence test +
   GR4J/GR6J structural axis + propagation-reproduction selection +
   three-factor decomposition with **bias-correction tail design** as an
   explicit uncertainty source. "Combination novelty" — never claim a new
   method. ANOVA (Park 2025; Kim & Chung 2026; Senatore 2022), the low-flow
   metrics, and the SPI/SRI index are **borrowed**; the axes, the selection
   logic and the application are new.
2. **Pillar claims / do-not-claims:** P2 (GR4J/GR6J axis) is the strongest —
   lead the contribution list with it, never claim GR6J is "better".
   P4: claim the *factor set* (tail-design axis, anchored by Cannon 2015 and
   Themeßl 2012), always say "tail design/tail policy", never "bias
   correction" generically. P1: the ρ-divergence *test* is the claim, the
   metrics are standard; report ρ = −0.027 with CI, never the pilot 0.14.
   P3: the *selection use* of propagation lag is the claim, the index is
   standard, the Machhar near-identity trap is forbidden. P5: we own the
   *audit lens*, not the projections; the number "239" must never appear
   (failed the in-data check 19 Nov).
3. **Roster numbers are exact and never interchangeable** (472 = the setting;
   242 = forcing evaluation; **192 = every H2/H4 claim**, 64/64/64 terciles;
   172 = H2 base case; 78 = H1 composite and H5 volume/dry-spell rates; 167 =
   frozen propagation lags; 22 = historical GCM pool; 14/13/13/14 =
   projection GCM coverage; 12 = H5 overlap; 11,520 = ANOVA cells; 180 =
   summary cells for the decision rule). Never let "472" attach to any
   ANOVA, divergence or correlation sentence.
4. **No per-cell significance in H4** (saturated design — see H4 above);
   any test introduced by a sensitivity is BH-corrected within its own family
   and labelled sensitivity. Shares are never averaged across metrics, SSPs,
   windows or terciles.
5. **Do not soften a negative H4** (structure < 5% everywhere is reportable),
   and **§5.5 must not be written before `h4_verdict.md` exists**.

## The five hypotheses (decision rules)

- **H1** — Forcing-skill rank and low-flow-skill rank diverge (pilot ρ = 0.14).
  Fails if ρ > 0.6 pooled.
- **H2** — GR4J and GR6J low-flow projections differ materially (structured by
  aridity/storage). Fails if statistically indistinguishable across catchment types →
  Objective 4 collapses to GCM + bias-correction only.
- **H3** — CMIP6 models differ in reproducing observed SPI-12→SRI-12 propagation time;
  mean-flow selection misses it. Fails if all 22 models fall inside the observed
  inter-catchment distribution.
- **H4** — GCM dominates low-flow projection variance; structure share non-negligible
  (≥5% matters for adaptation). Fails if structure share < 5% everywhere → still a
  useful negative result.
  - **ANOVA spec (binding: `manuscript/NOVELTY_AND_ANOVA_SPEC.md` v2, 23 Nov 2026).**
    The per-cell factorial is **saturated** (56 or 52 observations = the full
    parameter count → 0 residual df), so the per-cell analysis is an **exact
    variance partition — no F, no p, no per-cell η²p or ω²** (η²p ≡ 1 under
    saturation; ω² undefined). The SS share over the **seven** terms (3 main
    effects + three 2-way + the 3-way interaction) **is** classical η² in this
    balanced design; the 3-way interaction is always reported, never buried in a
    residual.
  - Inference = the pre-registered 5% disjunction rule + the **catchment**
    bootstrap (1,000 resamples, seed 20261118) — resample catchments, never rows.
  - GCM is a **fixed** factor (stated shortlist, not sampled): shares do not
    generalise beyond it; coverage is 14/13/13/14 GCMs for ssp126/245/370/585,
    stated everywhere, never padded.
  - `lme4::lmer(value ~ structure * tail_policy + (1|gcm))` is the one H4 model
    with an error term — a labelled sensitivity (supplement), never the primary
    result.
- **H5** — LSTM projections do not uniformly beat GR4J/GR6J at low flows (esp.
  semi-arid, hard-rock). Fails if LSTM dominates on all low-flow metrics → publish as
  benchmark confirmation, framed as such from the outset.

## Phase map (execution order)

| Phase | Module(s) | Hypothesis / Objective | Duration |
|---|---|---|---|
| 1. Low-flow metric layer | `LOWFLOW_00_metrics.R` → `LOWFLOW_10_ranks.R` | H1 / Obj 1 | 2–3 wk |
| 2. GR6J structural axis | `GR6J_00_setup.R` → `GR6J_20_calibrate.R` → `GR6J_30_divergence.R` | H2 / Obj 2 | 3–4 wk |
| 3. Drought propagation | `PROP_00_indices.R` → `PROP_10_lag.R` → `LOWFLOW_11_propagate.R` | H3 / Obj  3 | 2–3 wk |
| 4. Uncertainty decomposition | `DECOMP_00_anova.R` | H4 / Obj 4 | 2 wk |
| 3→5. C21 benchmark | `BENCH_00_ingest_lstm.R` → `BENCH_10_lowflow_eval.R` | H5 / Obj 5 | 2–3 wk |
| 5b. Manuscript assembly | `paper.md` updates | all | — |

## Touched-by-agents registry

When an agent-driven change alters results or conventions, append a row to
`manuscript/AGENT_LOG.md`: `date | agent | module | what changed | why`.

## Contributor checklist before any commit

1. Did any new code change a metric definition? → bump a `metric_version` column and
   note it in `AGENT_LOG.md`.
2. Do all output tables still pass the flag-propagation rule (`n_gap_filled`,
   `extrapolation_share` present)?
3. Was any catchment dropped without a log line? → fix before commit.
4. Are calibration vs scoring windows still strictly 1981–2000 / 2001–2014?
5. Does the new module leave existing `QED_*`/`HYD_*` notebooks untouched?
