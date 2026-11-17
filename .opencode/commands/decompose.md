---
description: Phase 4 - multi-way ANOVA uncertainty decomposition of low-flow projection variance (H4)
agent: general
---

Run Phase 4 of the phase map in `AGENTS.md`: the uncertainty decomposition. New module
only; existing notebooks untouched. Prerequisites: Phase 1 (metrics), Phase 2 (GR6J
divergence), and the EQM tail-policy variants must exist.

## Step 1 — Assemble the design grid

Factors:

| Factor | Levels |
|---|---|
| GCM | 22 (historical evaluation) or 14 (SSP projections) |
| Model structure | GR4J, GR6J |
| EQM tail policy | constant tail, linear pr tail |
| Catchment type | blocking factor (aridity classes, or aridity × baseflow-index proxy — state which) |

Response variables (separately, never averaged together): projected **Q95 change**,
**7-day minimum flow change**, **low-flow volume change** — each expressed as a
relative change vs the historical baseline, per model × structure × tail × catchment
× SSP.

If the two EQM tail-policy runs do not exist yet, check `data_processed/` for
tail-policy variants; if missing, run the EQM refit for the alternative tail policy
first as a prerequisite step and log it — do not skip the factor silently.

## Step 2 — Write `DECOMP_00_anova.R`

1. Fit a **multi-way ANOVA** (or variance-components model) per response variable:
   `response ~ GCM + structure + tail_policy + Error(catchment_type)` style design.
2. Compute **variance shares** per factor with **bootstrap CIs** (resample catchments,
   ≥1000 replicates, fixed `set.seed()` recorded).
3. Report GCM × structure interaction share explicitly — a 2026 Central India result
   shows stationarity validity depends on GCM + preprocessing + scenario, i.e.
   interactions are expected; don't collapse them into main effects.
4. Do this separately for each SSP and for Q95 / min7 / lowvol; never blend responses.

Output `data_processed/decomp/variance_shares.csv` (columns: `response, ssp, factor,
share, ci_low, ci_high, n_catchments, seed`) and a figure per response:
`data_processed/decomp/fig_shares_<response>.png` (stacked or grouped bars with CIs).

## Step 3 — H4 decision gate

Write `data_processed/decomp/H4_verdict.md` applying the decision rule from `AGENTS.md`:

- GCM share largest AND structure share ≥ 5% → H4 supported. State both numbers with
  CIs, per response and SSP.
- Structure share < 5% everywhere → H4 falsified as stated, but report it as a useful
  negative result: the decomposition becomes GCM-only and the GR4J/GR6J axis is
  decorative for adaptation decisions. That is still publishable.

## Guardrails

- The classical ordering to compare against is GCM > downscaling > hydrological model
  structure > parameters > emission scenario (Wilby & Harris 2006, Thames low flows).
  Report where your ordering agrees and differs — do not force agreement.
- Never average the three response variables into one composite score for the ANOVA.
- Session-info file next to outputs; seeds recorded in the variance table.

Report back: the variance-share table (GCM / structure / tail / interaction shares per
response × SSP), the bootstrap CI widths, and the H4 verdict.
