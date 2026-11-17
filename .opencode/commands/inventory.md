---
description: Read repo conventions and produce a function inventory before writing any code (mandatory first move)
agent: general
---

Read `AGENTS.md` (root), `QED_README.md`, and the existing `QED_*` and `HYD_*` R Markdown
notebooks in this repository. Then produce a **function inventory** — no code changes.

Report, in a structured list:

1. **Metric functions**: which functions compute KGE / NSE / PBIAS, with file and
   line references, their exact signatures, and how they handle zero-flow days
   (logNSE divide-by-zero guards).
2. **Rank/composite functions**: where model-level composites are assembled
   (`QED_30_rank_and_report.Rmd` and any equivalents), the exact ranking key columns,
   and how ties are broken.
3. **Screening conventions**: how `HYD_*` notebooks apply Tier-1/Tier-2 screening,
   which catchments are excluded and why (log columns and reason codes).
4. **Flag conventions**: where `within_range` / `extrapolation` and `n_gap_filled`
   flags are created and where they propagate downstream.
5. **Calibration setup**: the exact calibration/validation window split, warm-up
   handling, objective function, and optimizer used by the GR4J setup.
6. **Data schema**: the column names and units of `data_processed/hyd/model_shortlist_final.csv`
   and the discharge-evaluation outputs that the new low-flow module will consume.

Store the inventory as `LOWFLOW_00_inventory.md` in the repository root (a tracked
markdown file, not a chat answer), with a table of function → file:line → signature →
notes. Flag any convention you could not determine from the code, as an open question
list at the end.

Do not modify any existing notebook or output. Read-only except for
`LOWFLOW_00_inventory.md`.
