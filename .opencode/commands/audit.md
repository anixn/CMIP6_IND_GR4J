---
description: Pre-commit audit - guardrail compliance, flag propagation, silent drops, window discipline
agent: general
---

Run the pre-commit audit from the contributor checklist in `AGENTS.md`. Read-only
analysis plus an audit report; fix nothing silently — report findings.

## Audit items

1. **Window discipline.** For every metrics/ranks table in
   `data_processed/lowflow|prop|decomp|bench/`: verify scoring rows fall in
   2001–2014 for historical evaluation (or the declared future windows for
   projections) and no scoring row overlaps a calibration window (1981–2000).
   Grep date columns and window flags.
2. **Flag propagation.** Every output CSV must carry `n_gap_filled` and
   `extrapolation_share` (or document why the table legitimately cannot have them —
   e.g. pure static-attribute tables). List tables that violate this.
3. **No silent drops.** Reconcile catchment counts: screened set → calibrated set →
   metrics table rows. Every difference must have a matching row in the relevant
   `data_processed/logs/*_exclusions.csv` with a reason code. List unreconciled
   drops.
4. **Metric composites.** Verify the low-flow composite dropped near-duplicate
   metrics (pairwise ρ > 0.9) and that the log records which and why.
5. **Pre-registration intact.** `data_processed/prop/PROP_preregistration.md` exists,
   is dated BEFORE the first propagation-comparison run, and the H3 verdict uses
   that band (not a post-hoc widened one). Compare file timestamps/mtime ordering
   and the band value inside both files.
6. **Notebooks untouched.** `git status` / `git diff --name-only` against the base
   commit: `QED_*.Rmd` and `HYD_*.Rmd` must not appear as modified.
7. **Seeds and session info.** Every script that resamples writes `set.seed()`
   and a session-info file; the seed value appears in the variance-shares table.
8. **No leftover placeholders.** Grep the new outputs and any manuscript edits for
   `TODO`, `XXX`, `FIXME`, `【`, `undefined`, `NaN` (in tables where NaN is not a
   legitimate missing-value marker).
9. **AGENT_LOG.md.** Every agent-driven change to results or conventions has a row.

## Output

Write `data_processed/audit/audit_<YYYYMMDD>.md` with a table: item → status
(PASS/FAIL) → evidence (file:line or row counts) → recommended fix. Report the table
inline in chat as well. Do not auto-apply fixes; list them.
