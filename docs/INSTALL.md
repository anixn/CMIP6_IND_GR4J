# OpenCode Kit — Install & Usage Guide

For the CMIP6_IND_GR4J low-flow projection uncertainty project (paper.md v0.1,
17 Nov 2026). The kit's novelty gate was passed — see `VERIFICATION_MEMO.md`.

## What is in this kit

```
opencode-kit/
├── AGENTS.md                  # Project instructions (repo map, guardrails, hypotheses, phase map)
├── VERIFICATION_MEMO.md       # The novelty-gate evidence (what was checked, 17 Nov 2026)
├── INSTALL.md                 # This file
└── commands/                  # Slash commands → copy into .opencode/commands/
    ├── inventory.md           # /inventory        — mandatory first move
    ├── lowflow-metrics.md     # /lowflow-metrics  — Phase 1 (H1)
    ├── gr6j-axis.md           # /gr6j-axis        — Phase 2 (H2)
    ├── propagation.md         # /propagation      — Phase 3 (H3)
    ├── decompose.md           # /decompose        — Phase 4 (H4)
    ├── benchmark-lstm.md     # /benchmark-lstm    — Phase 5 (H5)
    ├── write-paper.md         # /write-paper      — manuscript integration (last)
    └── audit.md               # /audit            — pre-commit guardrail audit
```

## Install (5 minutes)

From this download folder, with the repo checked out at `~/CMIP6_IND_GR4J`:

```bash
cd ~/CMIP6_IND_GR4J

# 1. Project instructions (AGENTS.md at repo root)
cp <path-to-kit>/AGENTS.md .

# 2. Slash commands (OpenCode discovers .opencode/commands/*.md automatically;
#    the legacy singular .opencode/command/ also works, but use commands/)
mkdir -p .opencode/commands
cp <path-to-kit>/commands/*.md .opencode/commands/

# 3. Commit them so the conventions travel with the repo
git add AGENTS.md .opencode/commands/
git commit -m "Add OpenCode agent instructions and phase commands"
```

Optional global guardrails (across all your OpenCode sessions):
`~/.config/opencode/AGENTS.md` — but the project `AGENTS.md` here is the source of
truth for this repo; keep scientific rules there, not in the global file.

Then in OpenCode, run `/inventory` first. Everything else depends on it.

## The intended order of use

| Step | Command | Produces | Hypothesis |
|---|---|---|---|
| 0 (mandatory first) | `/inventory` | `LOWFLOW_00_inventory.md` | — |
| 1 | `/lowflow-metrics` | `lowflow_metrics.csv`, `lowflow_vs_forcing_rank.csv`, `H1_verdict.md` | H1 |
| 2 | `/gr6j-axis` | `gr6j_*` outputs, `H2_verdict.md` | H2 |
| 3 | `/propagation` | `propagation_time_by_model.csv`, `H3_verdict.md` | H3 |
| 4 | `/decompose` | `variance_shares.csv`, `H4_verdict.md` | H4 |
| 5 | `/benchmark-lstm` | `lstm_vs_gr4j_lowflow_benchmark.csv`, `H5_verdict.md` | H5 |
| 6 (last) | `/write-paper` | revised `paper.md` sections | all |
| any time before commit | `/audit` | `data_processed/audit/audit_<date>.md` | — |

Phases 1–3 are sequential (each needs the previous). Phase 4 needs 1+2. Phase 5
needs 1+2 (and the CAMELS-IND-Proj download). The commands themselves enforce these
prerequisites — each one says what it needs and stops if it is missing.

## Design decisions baked into the kit (and why)

- **Commands carry the science guardrails inline** (windows 1981–2000 fit /
  2001–2014 score; no silent drops; flag propagation; pre-registration for H3;
  negative-results-are-results). OpenCode reloads `.opencode/commands/*.md` on save,
  so you can tune any command without restarting.
- **`agent: general` in every command's frontmatter** — these are build/analysis
  tasks in the working session, not background reviews. Change `model:` per command
  if you want a specific model for a phase; omitting it inherits the session model.
- **Verdict files (`H*_verdict.md`) are the contract between phases and the paper.**
  `/write-paper` refuses to write results for phases without verdicts — this is what
  stops the manuscript from drifting ahead of the analysis.
- **`/audit` never auto-fixes.** It reports PASS/FAIL with evidence; you decide.
- **The `LOWFLOW_00_inventory.md` first move** is deliberate: it forces the agent to
  read your conventions (function signatures, screening, flags) before writing code,
  and produces the metric layer everything else depends on.

## Two verification notes before you start

1. The "239 confidence-flagged catchments" figure for CAMELS-IND-Proj could not be
   confirmed from the public Zenodo record (the flags are documented in the dataset's
   data-description PDF). `/benchmark-lstm` verifies the actual number and flag
   semantics against the downloaded files before using them — trust what it finds,
   not the brief.
2. The Betwa quantitative details (80% propagation-time decrease; 42→63%
   propagation rates) are cited-from-brief; re-verify against the HSJ paper before
   camera-ready.
