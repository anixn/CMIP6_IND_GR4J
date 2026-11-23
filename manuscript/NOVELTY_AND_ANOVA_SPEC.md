# NOVELTY_AND_ANOVA_SPEC.md — v2

**Binding spec for the opencode agent. Dated 23 Nov 2026 (evening). Supersedes the v1 spec of 23 Nov 2026. If a draft sentence conflicts with this file, this file wins — UNLESS the conflict is with a dated pre-registration (`PROP_PRE_REGISTRATION.md`, `GR6J_00_setup.Rmd` materiality thresholds, the DECOMP 5% rule, seed 20261118), in which case the pre-registration wins and this file must be corrected.**

Save as `manuscript/NOVELTY_AND_ANOVA_SPEC.md`, replacing v1. Read before touching paper.md §Abstract, §1, §2, §4.2, §4.3, §5.5, §6, §8.

---

## 0. What changed in v2 (read before reusing any v1 text)

| # | v1 said / lacked | v2 says | Why |
|---|---|---|---|
| 1 | "Report both η²p and ω²" (§4.3); residual QQ plots per stratum (§4.4); FDR on per-cell p-values (§4.8) | The per-cell factorial is **saturated**: 56 observations = 56 parameters (52 = 52 for the 13-GCM SSPs) → **0 residual df** → η²p ≡ 1, ω² undefined, F/p impossible per cell. The SS share is the only per-cell statistic and it is exact. | v1's instructions would print degenerate statistics into the paper. §5.0 derives this; the agent must verify the arithmetic on `input_metrics.csv` before rendering DECOMP_00. |
| 2 | "South Korea ANOVA low-flow/drought study (2025, *J. Hydrol.: Reg. Stud.*)" — no authors, no title | Full citation: **Park, Kim, Sung & Chung 2025, *J. Hydrol.: Reg. Stud.* 62:102991**, doi:10.1016/j.ejrh.2025.102991 | An unverifiable placeholder is not a citable reference. |
| 3 | (missing entirely) | **Kim & Chung 2026, *HESS* 30:227–247** — ANOVA of GCM × SSP × calibration-condition × calibration-length for future drought, South Korea | The closest methodological relative of H4, published 15 Jan 2026 in a P1 target journal. Reviewers there will know it. Must be cited and differentiated. |
| 4 | "Liu et al. 2025 (MDPI *Climate* 16(6):691)" | Liu et al. 2025, ***Atmosphere* 16(6):691**, doi:10.3390/atmos16060691 | Wrong journal in v1 (verified on mdpi.com). |
| 5 | (missing) | **Cannon, Sobie & Murdock 2015** and **Themeßl, Gobiet & Heinrich 2012** added as the methodological anchors for the `tail_policy` factor | H4's newest factor needs prior art showing tail/extrapolation handling is a recognized first-order sensitivity. The 23 Nov EQM defect (a drizzle-interval slope turning 60 mm/d into 4.0×10⁹ mm/d) is a concrete instance of exactly the failure mode Cannon documents. |
| 6 | Headline "at the 472-catchment scale" next to P4's "over 192 catchments", with no reconciliation | Roster table (§2) fixing the exact n for every analysis; "472" is the setting, "192" is every H2/H4 claim | An agent following v1 verbatim could write a "472-catchment decomposition"; one arithmetic check kills that sentence. |
| 7 | (missing) | Abstract rewrite instructions (pilot ρ = 0.14 → −0.027 with CI; H1–H5 verdict numbers; drop the "[TODO: rewrite abstract]" only when all five verdict numbers are in) | paper.md's abstract still carries the pilot number. |
| 8 | §4.1 primary code: `car::Anova(m, type = 3)` | Primary: `anova(m)` (Type I). In a balanced, orthogonal, saturated design I = II = III, so `car` is unnecessary and its NaN F/p output on a saturated model can break a render | Robustness of the render, identical statistics. |

Carried forward unchanged from v1: the five-pillar CLAIM / DO-NOT-CLAIM structure, the headline sentence, the guardrails, the bootstrap specification, the fixed-GCM caveat, the tercile-stratification rule, the 5% pre-registered threshold, the "239" prohibition.

---

## 1. The headline novelty claim (use this sentence, verbatim or near-verbatim)

> We present the first low-flow-aware CMIP6 model-selection framework for Peninsular India at the 472-catchment scale, combining a formal forcing-vs-low-flow rank-divergence test, a GR4J/GR6J structural-uncertainty axis, drought-propagation reproduction as a selection dimension, and a three-factor variance decomposition (GCM × structure × bias-correction tail policy) that treats tail design as an explicit uncertainty source.

Everything else in the paper is supporting evidence for this sentence. Do not introduce a second headline claim.

**Scale honesty rule (new).** "472-catchment scale" refers to the framework's setting (CAMELS-IND / CAMELS-IND-Proj universe). The decomposition itself runs on the 192 both-structures-calibrated catchments, and the H1 composite on 78 non-ephemeral catchments. The first time each roster number appears, state it exactly (§2 table). Never let "472" attach to a sentence about ANOVA, GR6J divergence, or rank correlation.

---

## 2. Roster numbers — use these exactly, never interchangeably

| n | What it is | Where it is the right number |
|---|---|---|
| 472 | CAMELS-IND / CAMELS-IND-Proj catchments (the setting) | §1 setting, §3 data, the H5 benchmark universe |
| 242 | Tier-1+2 catchments entering the forcing evaluation (180 + 62) | §4.1 tiering |
| 192 | Calibrated under BOTH GR4J and GR6J — the H2 and H4 roster (64/64/64 aridity terciles) | §4.2, §5.2, §5.5, every decomposition sentence |
| 172 | Paired catchments in the H2 observed-forcing base case | §5.2 divergence table |
| 78 | Non-ephemeral catchments: H1 low-flow composite; H5 lf_volume / dry_spell win rates | §5.1, §5.4 |
| 167 | Frozen observed SPI-12→SRI-12 propagation lags | §5.3 |
| 22 | Historical all-variable GCM pool (H1, H3) | §4.1, §5.1, §5.3 |
| 14 | Projection shortlist — and 13 for ssp245/ssp370 (HadGEM3-GC31-MM not published there; logged, never padded) | §4.3, H4, §6 |
| 12 | Track-A ∩ benchmark GCM overlap used for H5 win rates | §5.4 |
| 11,520 | ANOVA cells (192 × 5 metrics × 4 SSPs × 3 windows) | §4.2 |
| 180 | Summary cells for the decision rule (3 terciles × 5 × 4 × 3) | §5.5, §6 multiplicity |

---

## 3. Novelty per pillar — CLAIM / DO NOT CLAIM

### P1 — low-flow-aware selection / ρ-divergence

- **CLAIM:** the formal test that forcing-skill rank and low-flow rank diverge (H1: ρ = −0.027, CI [−0.095, 0.038], 1,000 resamples, seed 20261118) is new for India, and the near-zero result is the finding — forcing-skill selection carries essentially no information about low-flow skill.
- **DO NOT CLAIM:** that the low-flow metrics (logNSE, Q95 bias, mam7 bias, dry-spell bias, lf_volume bias) are new. They are standard. The novelty is the _selection logic built on them_, not the metrics.
- **DO NOT** frame the result as "the ranks differ." Frame it as "the ranks are essentially orthogonal (ρ ≈ 0), so one-stage forcing selection cannot stand in for low-flow selection."
- **DO NOT** leave the pilot number standing anywhere: the abstract and §1 of the current draft still say ρ = 0.14 (Tier-1-only roster, mean-flow ranks). Every occurrence becomes −0.027 with the CI and the re-estimation note.

### P2 — GR4J/GR6J structural axis (STRONGEST)

- **CLAIM:** no Peninsular India study uses the GR4J/GR6J pair as a structural-uncertainty axis for low flows; this is the paper's strongest objective and should lead the contribution list.
- **SUPPORT:** Mangukiya et al. 2026 (WRR 2026WR044753) places GR4J in the five-model sufficient set — cite as independent support for the structural choice, NOT as a competitor.
- **DO NOT CLAIM:** that GR6J is "better." H2 quantifies divergence (dry-tercile mam7 div −449 pp), not superiority. Direction is reported, never moralised.

### P3 — propagation-time selection

- **CLAIM:** using reproduction of observed SPI-12→SRI-12 propagation lag as a GCM selection criterion is new. The selection angle is the gap.
- **DO NOT CLAIM:** that the SPI/SRI index or the cross-correlation lag is new. Both are standard. State explicitly in §4.2 that the index is borrowed and the _selection use_ is the contribution.
- **GUARDRAIL:** the Machhar-type near-identity trap is forbidden. The diagnostic (mean |SRI−SPI| ≈ 0.29–0.34, far from the ≈0.013 artefact signature) must appear in §5.3 as evidence the lags were measured, not assumed.

### P4 — three-factor ANOVA decomposition

- **CLAIM:** the _factor set_ is new — no prior decomposition treats bias-correction **tail design** (`linear` vs `constant`) as a first-order uncertainty alongside GCM and structure, and none does it over 192 Peninsular India catchments with GR4J/GR6J as the structural axis.
- **WORDING GUARDRAIL (new):** always write "tail design" or "tail policy", never "bias correction" generically, when naming the new factor. Senatore et al. 2022 already put bias-correction method into an ANOVA (Mediterranean), and Park et al. 2025 decomposes hydrologic-modeling factors in Korea — the specific, defensible gap is the _tail/extrapolation axis_, anchored by Cannon et al. 2015 and Themeßl et al. 2012 (§4).
- **DO NOT CLAIM:** that ANOVA / variance decomposition is a new method. Park et al. 2025 (Korea), Kim & Chung 2026 (Korea, HESS), and Senatore et al. 2022 (Mediterranean) all used it. Cite all three and say the method is borrowed; the axes and the application are new.
- **DO NOT CLAIM:** that the variance shares generalise beyond the shortlisted GCMs. GCM is a FIXED factor (the shortlist is stated, not sampled). State this limitation in §6.

### P5 — CAMELS-IND-Proj LSTM audit

- **CLAIM:** first low-flow-specific, process-based audit of CAMELS-IND-Proj. The producers own the projections; we own the audit lens. The H5 split (LSTM wins magnitudes 0.71–0.95, loses drought duration 0.39) is the new empirical result.
- **DO NOT CLAIM:** the projections themselves as a contribution. Position as a critical-user contribution, consistent with the two-track rule.
- **DO NOT** print "239 confidence-flagged catchments" anywhere. The number failed the in-data check against the distributed archive (BENCH_00, 19 Nov: no flag file exists, header is exactly year/month/day + 472 gauges). H5 is computed on the full benchmark set; the paper says the flag construct was checked and is not used.

---

## 4. Prior art the paper MUST cite and differentiate against

All citations below verified against live sources on 23 Nov 2026 unless marked "verify at camera-ready". Each entry gets a one-line "why our lane survives" cell in the §2 prior-art table.

| Cite | Owns | Our differentiation |
| --- | --- | --- |
| Sharma, Barbhuiya & Gupta 2026, *Hydrol. Process.* 40(3) e70476 | India-wide streamflow projections; MILC/GR4J/HYMOD/HBV; 12 GCMs; 128 basins | **Closest prior art.** No GR6J, no low-flow-specific selection, no ρ-divergence test, no propagation selection, no decomposition. They note "uncertainty existed for low flow events" but do not formalise it — we do. |
| **Park, Kim, Sung & Chung 2025**, *J. Hydrol.: Reg. Stud.* 62:102991, doi:10.1016/j.ejrh.2025.102991 | ANOVA of uncertainty contributions to hydrologic drought projection, South Korea | Method borrowed; Korea not India; no GR4J/GR6J axis; no tail-policy factor. Verify its exact factor list at camera-ready before describing it beyond this. |
| **Kim & Chung 2026**, *HESS* 30:227–247, doi:10.5194/hess-30-227-2026 | ANOVA of GCM × SSP × calibration-condition × calibration-length for future drought, South Korea (SWAT, SDI, 20 CMIP6 GCMs; GCM >60% for runoff; calibration-related 3.9–9.8%) | Method borrowed; Korea not India; single-structure (SWAT) so no structural axis; no bias-correction factor. **Cite in §2 AND §4.2** — HESS is a P1 target journal and its reviewers will know this paper. |
| Senatore et al. 2022 (Mediterranean ANOVA of GCM + bias correction) | ANOVA with bias-correction method as a factor | Method borrowed; not India, not GR4J/GR6J axis, not catchment-scale 192. This is why P4's claim must say "tail design", not "bias correction". *(verify full citation at camera-ready)* |
| **Cannon, Sobie & Murdock 2015**, *J. Climate* 28(17):6938–6959, doi:10.1175/JCLI-D-14-00754.1 | Shows quantile-mapping algorithms modify trends/quantiles/extremes; tail behaviour of QM is a documented sensitivity | Not a competitor — the methodological anchor for the `tail_policy` factor. Cite in §4.2/§4.3 next to the tail-policy definition. The 23 Nov EQM defect (drizzle-interval slope → 4.0×10⁹ mm/d) is a concrete instance of this failure class; one factual sentence, no drama. |
| **Themeßl, Gobiet & Heinrich 2012**, *Climatic Change* 112(2):449–468 | Error-correction method choice materially alters the climate-change signal | Same anchoring role as Cannon; cite alongside it. |
| Mangukiya et al. 2026, *WRR* 2026WR044753 | 47-model benchmarking; GR4J in the 5-model sufficient set | Ally, not competitor. Supports the structural choice. |
| Mishra et al. 2020, *Sci. Data* | Bias-corrected CMIP6 South Asia | Coarse-scale, not catchment-tuned, no tail-policy axis — exactly the dimension H4 exposes. Also the inherited correction inside CAMELS-IND-Proj forcings (two-track rule evidence). |
| Liu et al. 2025, *Atmosphere* 16(6):691, doi:10.3390/atmos16060691 (**journal corrected from v1's "Climate"**) | CMIP6 selection + streamflow + hydrological drought (SWAT+MODFOOD) | Single-basin-scale; not a 192-catchment out-of-sample rank; no rank-divergence test. *(complete author list at camera-ready)* |
| Meresa et al. 2023; Wang et al. 2025 | CMIP6 drought propagation (Ireland; other) | Propagation exists elsewhere; the _selection use_ over Indian catchments is new. *(verify full citations at camera-ready)* |

Independent re-check (23 Nov 2026, web search): no India-specific CMIP6 low-flow uncertainty-decomposition study surfaced; the closest India hits are projection studies without decomposition. The P4 lane survives. This does not replace the camera-ready survey.

---

## 5. ANOVA specification for H4 (this is what the agent implements)

### 5.0 READ FIRST — the per-cell design is saturated; verify before rendering

Arithmetic, which the agent MUST re-check against the real `input_metrics.csv` before the DECOMP_00 production render:

- One cell = (catchment × metric × SSP × window). Rows per cell = |GCM| × 2 structures × 2 tail policies = **56** (ssp126/ssp585) or **52** (ssp245/ssp370).
- Parameters in `value ~ gcm * structure * tail_policy` = 1 + (|GCM|−1) + 1 + 1 + (|GCM|−1) + (|GCM|−1) + 1 + (|GCM|−1) = **56 / 52**.
- **Residual df = 0.** The full three-way factorial with one observation per combination is saturated.

Consequences (all mandatory):

1. The per-cell ANOVA is an exact **variance partition**, not a significance test. No F, no p, no per-cell CI from the ANOVA itself. This is not a defect — it is what a designed full factorial is — but it must be stated, not discovered by a reviewer.
2. η²p = SS_term/(SS_term + SS_error) with SS_error = 0 gives **η²p ≡ 1 for every term**; ω² is undefined (MS_error with 0 df). **Do not compute either.** The SS share IS classical η² in this balanced design — say that once in §4.2 and use "share" everywhere else.
3. The inference is the pre-registered disjunction rule (§5.8) plus the catchment bootstrap (§5.5). This is WHY the bootstrap exists; say so.
4. If DECOMP_10 ever emits more than one row per (gcm, structure, tail) combination per cell (e.g., annual values instead of window aggregates), the design gains an error term, residual diagnostics and effect sizes become meaningful, and v1's §4.3–4.4 machinery applies again — re-derive, record the change in `AGENT_LOG.md`, then proceed.

### 5.1 Model, per cell

```r
options(contrasts = c("contr.sum", "contr.poly"))  # inert in a balanced design; conventional
m   <- aov(value ~ gcm * structure * tail_policy, data = cell_df)
tab <- anova(m)                                    # Type I; I = II = III here (balanced, orthogonal, saturated)
ss  <- setNames(tab$"Sum Sq", rownames(tab))
ss  <- ss[names(ss) != "Residuals"]                # 0 df, SS ≈ 0: reported as exactly zero, never fitted around
share <- ss / sum(ss)                              # partitions to 1.0 over the 7 terms
```

- **Balanced full factorial is mandatory.** If a cell is unbalanced, log it to `h4_dropped_cells.csv` with a reason code and DO NOT fit. Never fit an unbalanced cell "for completeness."
- **Terms reported:** `gcm`, `structure`, `tail_policy`, `gcm:structure`, `gcm:tail_policy`, `structure:tail_policy`, `gcm:structure:tail_policy`. The 3-way interaction is a reported term — do not bury it in residual (there is no residual to bury it in; the hazard is dropping it from the table).
- Do not route the saturated model through `car::Anova(type = 3)`: the Type III machinery returns NaN F/p with 0 residual df and can break the render. Type I `anova(m)` gives identical SS here; if a reviewer asks, the answer is "balanced and orthogonal, so Type I = II = III, and the design is saturated so the partition is exact."

### 5.2 Variance shares (the decision statistic)

- `share[structure]` is the decision statistic for the pre-registered 5% rule.
- Report **all** seven term shares, not just main effects. The 2-way and 3-way interaction shares are the evidence for "the three uncertainty sources are not additive."
- Do **not** average shares across metrics or across cells (guardrail 5).

### 5.3 Effect sizes

- The SS share is classical η² in this balanced design. Use it; call it "variance share" in the text and note the η² equivalence once in §4.2.
- η²p and ω² are **forbidden per cell** (degenerate under saturation, §5.0). Do not print them.
- Effect-size vocabulary beyond shares belongs only to the `lmer` sensitivity (§5.6), which is the one model in the H4 chain with an error term.

### 5.4 Assumption checks

- There are no residuals in the saturated per-cell model, so residual normality and homoscedasticity checks **do not apply per cell**. Do not fabricate QQ plots or Shapiro–Wilk tests for a model with no residuals.
- Diagnostics (QQ on residuals, residuals-vs-fitted) apply only to the `lmer` sensitivity if it is run.
- The robustness argument in the paper is the catchment bootstrap CI; the absence of per-cell significance tests follows from the design and is stated in §4.2, not apologised for in a footnote.

### 5.5 Bootstrap

```r
set.seed(20261118)
# resample CATCHMENTS, not rows — catchments are the independent unit
for (b in 1:1000) {
  ids <- sample(unique(df$catchment), replace = TRUE)
  # recompute tercile-median structure share on the resampled catchment set
}
```

- 1,000 resamples, seed 20261118 (already in DECOMP_00).
- 95% percentile CI on the tercile-median structure share per metric × SSP × window × tercile.
- Bootstrap resamples **catchments**, never rows. Resampling rows would understate the CI because GCM/structure/tail levels within a catchment are not independent draws.

### 5.6 Fixed vs random effects (state this explicitly)

- GCM is a **fixed** factor: the shortlist is stated, not sampled. The ANOVA answers "how much of the variance among _these_ GCMs is attributable to GCM choice," not "how much would generalise to all CMIP6." Per-SSP coverage is 14 GCMs (ssp126, ssp585) and 13 (ssp245, ssp370, HadGEM3-GC31-MM absent) — say "14/13/13/14" wherever the GCM count appears in §4.2, never a flat "14".
- **Recommended sensitivity (not primary):** `lme4::lmer(value ~ structure * tail_policy + (1 | gcm), ...)`. This model has residual df (≈47–51 per cell depending on SSP) and is therefore the ONLY place in H4 where residual diagnostics and classical effect sizes are meaningful — run it, report the random-effects GCM share next to the fixed-effects GCM share. If they are within ~5 pp, robustness confirmed; if not, report both in the supplement and explain in §6. Do not replace the primary result.
- Structure and tail_policy are also fixed (2 levels each); no random-effects version needed for them.

### 5.7 Tercile is a stratification, not a factor

- The pre-registered design fits one ANOVA per catchment and then takes tercile medians of the shares. Tercile is **not** a factor in the ANOVA.
- Consequence: "structure share is higher in dry catchments" is a **descriptive** statement (tercile medians + bootstrap CIs), not a formal test. Write it that way in §5.5.
- Optional sensitivity: a meta-regression of shares on tercile across catchments (shares ~ tercile, weighted by inverse bootstrap variance). Label as sensitivity, not primary. If run, BH-correct its p-values across the 180-cell family.

### 5.8 Multiplicity (state this in §6)

- The pre-registered rule is a disjunction: "structure share ≥ 5% in at least one aridity tercile × metric × SSP × window" — 180 summary cells. Under a global null, the chance of at least one cell's bootstrap CI excluding 5% is non-trivial; say so in §6.
- There are **no per-cell p-values to correct** (§5.0) — do not manufacture any. The rule's safeguard is that it triggers on the tercile-MEDIAN share (not a single catchment) and that it was pre-registered on 18 Nov 2026, before any H4 number existed.
- If any significance test is ever introduced (lmer sensitivity, tercile meta-regression), BH-correct within its own family and label it sensitivity.

### 5.9 What the agent must NOT do in the ANOVA

- Do not fit unbalanced cells.
- Do not drop the 3-way interaction from the reported table.
- Do not average shares across metrics, SSPs, windows, or terciles.
- Do not bootstrap rows.
- Do not compute η²p or ω² per cell (saturated: η²p ≡ 1, ω² undefined).
- Do not fabricate residual diagnostics for the saturated model.
- Do not route saturated cells through `car::Anova`.
- Do not report per-cell p-values at all — they do not exist.
- Do not claim the shares generalise beyond the shortlisted GCMs.
- Do not print "239" anywhere.
- Do not replace the 5% pre-registered threshold after seeing results. If the threshold ever needs to change, record a dated pre-registration change in `AGENT_LOG.md` before re-running.

---

## 6. What to write in the paper (section-by-section)

### Abstract (new in v2 — the current one still carries the pilot number)

- Replace "Spearman ρ = 0.14" with **ρ = −0.027, 95% CI [−0.095, 0.038]** and mark the re-estimation (pilot 0.14 → −0.027) in §5.1, not the abstract.
- Insert the H1–H5 verdict numbers once H4 lands: H1 ρ = −0.027; H2 dry-tercile mam7 divergence −449 pp; H3 prop_share 0.91–0.96 with ρ(forcing rank, prop_share) = −0.350; H4 → from `h4_verdict.md` only; H5 LSTM wins magnitudes 0.71–0.95, loses dry-spell duration 0.39.
- Keep the headline claim as the framing sentence; "first low-flow-aware CMIP6 selection framework", never "first streamflow projection" (Sharma 2026 owns that).

### §1 (Objective framing)

- Lead with the headline sentence (§1 of this file).
- State the two-track rule and why CAMELS-IND-Proj is audit-only (their forcings inherit the Mishra 2020 coarse-scale correction — evidence-backed per the data-description PDF acknowledgements).
- The novelty is a _combination_: low-flow lens + GR4J/GR6J axis + propagation selection + three-factor decomposition. Say "combination novelty" explicitly so a reviewer does not read the paper as claiming a new method.
- Use the §2 roster table for every count.

### §2 (Prior-art positioning)

- Use the table in §4 of this file. Sharma 2026 is the closest prior art — cite it as such and differentiate in the same row.
- Kim & Chung 2026 (HESS) and Park et al. 2025 must both appear; conceding the borrowed ANOVA while claiming the axes and application is stronger than overclaiming.
- Concede the borrowed machinery (ANOVA, SPI/SRI, low-flow metrics) in the same table or a footnote.

### §4.2 (O4 methods — write this paragraph, in this order)

1. Full factorial design (GCM × structure × tail_policy), balanced within cell; 11,520 cells (192 catchments × 5 metrics × 4 SSPs × 3 windows); GCM coverage 14/13/13/14.
2. **Saturation statement:** 56 (52) observations per cell equal the full parameter count, so the design has no residual df; the per-cell analysis is an exact variance partition and inference rests on the pre-registered rule plus the catchment bootstrap — not per-cell F-tests.
3. Variance shares = SS_term / SS_total over the seven terms (= classical η² in this balanced design); the 3-way interaction is reported.
4. Tail-policy levels defined precisely: `linear` = per-tail linear extension beyond the training CDF range (per-tail applier for pr, corrected 23 Nov, QED_50 §0b), `constant` = clamp at the reference tail. Anchor with Cannon et al. 2015 and Themeßl et al. 2012; one factual sentence on the 23 Nov defect (drizzle-interval slope → 4.0×10⁹ mm/d pre-fix) as evidence that tail design is consequential; state the fix preceded any H4 result and the historical leg used `constant`, so H1–H3 are unaffected.
5. Catchment bootstrap (1,000 resamples, seed 20261118) for 95% CIs on the tercile-median structure share; catchments resampled because factor levels within a catchment are not independent draws.
6. Pre-registered 5% threshold for "structure non-negligible" (dated 18 Nov 2026, unchanged).
7. Fixed-GCM caveat: shares describe the stated shortlist, not the CMIP6 population.
8. Tercile is a stratification, not a factor in the ANOVA.
9. Multiplicity of the disjunction rule (180 summary cells) noted as a limitation.
10. If the `lmer` sensitivity is run: one sentence — GCM random intercept, residual df ≈ 47–51, reported as supplement; fixed-effects result remains primary.

### §5.5 (H4 verdict)

- Replace the current "Status of the projection leg" text with the verdict, written strictly from `h4_verdict.md`. Do not write this section before that file exists (hard stop).
- Report: GCM, structure, tail, all interaction shares, per tercile × metric × SSP × window, with bootstrap CIs.
- Report the number of cells where structure share ≥ 5% and where it does not.
- Report the 3-way interaction share explicitly.
- If structure < 5% everywhere: report as a negative result, exactly as the pre-registered rule says. Do not soften it.

### §6 (Limitations)

- Fixed-GCM caveat (shares do not generalise beyond the stated shortlist; 13 vs 14 coverage for ssp245/ssp370).
- Tercile as stratification, not factor (no formal tercile × factor test in the primary design).
- Multiplicity of the disjunction decision rule (180 cells).
- Saturation: no per-cell significance tests by design; the bootstrap is the inference (this reads as methodological clarity, not weakness, if stated in §4.2 first).
- Single members only (no internal-variability spread) — already present.
- Anthropogenic modulation not modelled — already present; keep the roadmap pointer.
- The 23 Nov tail-policy defect and fix: the fix preceded any H4 result; the historical leg used `constant` for precipitation, so H1–H3 are unaffected.

### §8 (Literature TODO)

- Add with full citations (§8 reference block below): Park 2025, Kim & Chung 2026, Cannon 2015, Themeßl 2012. Mark each "cite in §2" or "cite in §4.2".
- Verify at camera-ready: Senatore 2022 full citation; Meresa 2023 and Wang 2025 full citations; Park 2025's exact factor list (does it include a bias-correction factor?); Naresh & Mathew 2026 journal attribution (Hydrol. Proc. vs PCE); Betwa quantitative details (80% decrease, 42→63%); Liu 2025 complete author list.
- Also: bump the paper.md version header — the file says "draft v0.2, 18 November 2026" but its content is at v0.5 (21 Nov); keep the version line truthful.

---

## 7. Guardrails (hard stops for the agent)

1. Do not claim ANOVA, SPI/SRI, cross-correlation lag, or the low-flow metric suite as novel. Concede borrowed machinery.
2. Do not claim the variance shares generalise beyond the shortlisted GCMs.
3. Do not print "239" anywhere (failed the in-data check 19 Nov; the flag construct is not used).
4. Do not report per-cell significance — none exist (saturated design), and any test introduced by a sensitivity must be BH-corrected and labelled sensitivity.
5. Do not average shares across metrics, SSPs, windows, or terciles.
6. Do not fit unbalanced cells.
7. Do not change the 5% threshold after seeing results. If a change is ever needed, record a dated pre-registration change in `AGENT_LOG.md` first.
8. Do not frame GR6J as "better" — only as divergent, with direction reported.
9. Do not frame the LSTM as "worse" — only as winning magnitudes and losing drought duration, with the split reported.
10. Do not soften a negative H4 result. A structure share < 5% everywhere is a reportable result — report it.
11. Do not attach "472" to any decomposition, divergence, or correlation claim (§2 roster table).
12. Do not write §5.5 before `h4_verdict.md` exists.

---

## 8. Reference block (verified 23 Nov 2026 — paste into the reference list)

1. Park, J., Kim, J.H., Sung, J.H., Chung, E.S. (2025). Quantifying uncertainty contributions of hydrologic modeling process to hydrologic drought projection in South Korea. *Journal of Hydrology: Regional Studies*, 62, 102991. doi:10.1016/j.ejrh.2025.102991
2. Kim, J.H., Chung, E.-S. (2026). Insights into uncertainties in future drought analysis using hydrological simulation model. *Hydrology and Earth System Sciences*, 30, 227–247. doi:10.5194/hess-30-227-2026
3. Cannon, A.J., Sobie, S.R., Murdock, T.Q. (2015). Bias correction of GCM precipitation by quantile mapping: How well do methods preserve changes in quantiles and extremes? *Journal of Climate*, 28(17), 6938–6959. doi:10.1175/JCLI-D-14-00754.1
4. Themeßl, M.J., Gobiet, A., Heinrich, G. (2012). Empirical-statistical downscaling and error correction of regional climate models and its impact on the climate change signal. *Climatic Change*, 112(2), 449–468.
5. Liu, T., et al. (2025). Future streamflow and hydrological drought under CMIP6 climate projections. *Atmosphere*, 16(6), 691. doi:10.3390/atmos16060691 *(complete author list at camera-ready)*

Existing verified set (carry over from the manuscript): Perrin et al. 2003; Oudin et al. 2005; Eyring et al. 2016; Gupta et al. 2009; Mangukiya et al. 2025 (ESSD 17:461–491); Chuphal et al. 2024; Mishra et al. 2020; Singh et al. 2026 (Zenodo 21775597); Mangukiya et al. 2026 (WRR 2026WR044753); Sharma et al. 2026 (HP 40(3) e70476); Wilby & Harris 2006.

---

## 9. One-line summary for the agent

> The paper's novelty is a combination — low-flow-aware selection with a formal ρ-divergence test, the GR4J/GR6J structural axis for Peninsular India, propagation reproduction as a selection dimension, and a three-factor decomposition that treats bias-correction tail design as an explicit uncertainty source. ANOVA (Park 2025; Kim & Chung 2026; Senatore 2022), the low-flow metrics, and the SPI/SRI index are borrowed; the axes, the selection logic, and the application are new. Lead with P2 (GR4J/GR6J) and P4 (three-factor decomposition, tail-design axis anchored by Cannon 2015 and Themeßl 2012); use P1 (ρ-divergence) as the empirical motivation; position P3 and P5 as supporting dimensions. The per-cell factorial is saturated — the partition is exact, there are no per-cell p-values, and the inference is the pre-registered 5% disjunction plus the catchment bootstrap. Use the roster numbers exactly (472 setting, 192 decomposition, 78 composite). Concede borrowed machinery explicitly — reviewers will check.
