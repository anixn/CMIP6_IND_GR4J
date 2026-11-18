---
description: Phase 3 - drought propagation module, SPI-12/SRI-12, propagation time as a CMIP6 selection metric (H3)
agent: general
---

Run Phase 3 of the phase map in `AGENTS.md`: the drought-propagation selection test.
New modules only; existing notebooks untouched.

## Step 0 — Pre-register the tolerance band FIRST

Before computing anything on CMIP6 models, compute the **observed** propagation-time
distribution from observed forcings + GR4J/GR6J historical runs, and fix a tolerance
band (e.g. ±20% of the observed inter-catchment median, or the interquartile range —
choose and justify one). Write `data_processed/prop/PROP_preregistration.md` recording
the band, its derivation, and today's date. **This file must exist before any model
propagation comparison is run.** If it does not exist, stop and create it first.

## Step 1 — Write `PROP_00_indices.R`

Per CMIP6 model × catchment × period (historical 1981–2014 and future windows
2021–2060, 2061–2100):

1. **SPI-12**: standardised index on 12-month accumulated precipitation (gamma fit;
   state the fitting window — pooled across catchments or per-catchment, and be
   consistent).
2. **SRI-12**: the same standardised-index logic on simulated discharge, per
   structure (GR4J and GR6J).

## Step 2 — Write `PROP_10_lag.R`

For each model × catchment × period × structure:

1. **Propagation time** = the lag in 0–12 months that maximises the cross-correlation
   between SPI-12 and SRI-12. Compute it explicitly; never infer propagation from
   SPI–SRI near-identity (a mean |SRI−SPI| ≈ 0.013 is a model-structure artefact —
   too-tight precipitation–runoff coupling — not a climate finding).
2. **Propagation rate** = fraction of SPI-12 drought months (SPI ≤ −1) followed by a
   SRI-12 drought month (SRI ≤ −1) within the propagation window.
3. Cross-correlation significance: report the correlation at the peak lag, and the
   number of months available (SPI-12/SRI-12 lose 11 months to the rolling window —
   account for it).

## Step 3 — Selection-relevance test (`LOWFLOW_11_propagate.R`)

1. Benchmark each model's propagation time against the pre-registered tolerance band
   from Step 0. Flag models outside it.
2. Cross-tab: models that pass the tolerance band vs models in the existing top ranks
   (forcing composite and low-flow composite from `LOWFLOW_10_ranks.R`). Key question:
   **does mean-flow/forcing selection miss propagation skill?** Report the overlap
   explicitly (which well-ranked models fail propagation, which poorly-ranked models
   pass).
3. Project propagation-time change under SSP1-2.6 / 2-4.5 / 3-7.0 / 5-8.5 for the 14
   shortlisted models: sign, magnitude, and model agreement.

Outputs: `data_processed/prop/propagation_time_by_model.csv`,
`data_processed/prop/propagation_change_ssp.csv`.

## Step 4 — H3 decision gate

Write `data_processed/prop/H3_verdict.md`:

- Models differ materially in propagation reproduction AND selection on other metrics
  misses it → H3 supported; list the discriminating models.
- All 22 models reproduce observed propagation time within the pre-registered band →
  H3 falsified; propagation time is not a discriminating selection metric. Say so,
  cite the pre-registration file, and do not widen the band post hoc.

## Guardrails

- Observed benchmark uses observed forcings (not CMIP6 historical) through the
  calibrated GR4J/GR6J.
- Every catchment exclusion is logged with a reason code.
- Zero-flow months: SRI fitting needs a log- or power-transform choice for discharge
  (state it, keep it fixed across all structures).

Report back: the pre-registered band, the observed propagation-time distribution
(median + IQR), the number of models inside/outside the band, the cross-tab vs
existing ranks, and the H3 verdict.
