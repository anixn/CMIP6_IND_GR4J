# H5 verdict -- LSTM benchmark vs GR4J and GR6J at low flows

**Date:** 2026-11-19 14:35:19 | metric_version v1

**Rule (AGENTS.md, pre-registered):** H5 fails iff LSTM dominates on ALL low-flow metrics; per-catchment per-metric medians across models, shared catchment set, 2001-2014.

**Shared catchments:** 192 | benchmark GCMs with a Track-A counterpart: 12 (ACCESS-CM2, ACCESS-ESM1-5, BCC-CSM2-MR, CanESM5, EC-Earth3, EC-Earth3-Veg-LR, INM-CM4-8, INM-CM5-0, MPI-ESM1-2-HR, MPI-ESM1-2-LR, MRI-ESM2-0, NorESM2-MM)
**Benchmark GCMs with no Track-A counterpart (excluded, logged):** NorESM2-LM

**Verdict: H5 STANDS -- LSTM does not uniformly beat GR4J/GR6J at low flows (metrics where LSTM wins overall: lf_volume_bias, logNSE, mam7_bias, q95_bias; the decisive exception is dry_spell_bias)**

**GR6J leg:** GR6J leg: EVALUATED (GR6J_40 CMIP-driven metric pass present).

Win rates per metric and structure -- **pooled (decision basis):**

|compared_with |metric         | lstm_win_share|   n|
|:-------------|:--------------|--------------:|---:|
|GR4J          |dry_spell_bias |          0.385|  78|
|GR4J          |lf_volume_bias |          0.923|  78|
|GR4J          |logNSE         |          0.855| 172|
|GR4J          |mam7_bias      |          0.811| 127|
|GR4J          |q95_bias       |          0.714|  70|
|GR6J          |dry_spell_bias |          0.385|  78|
|GR6J          |lf_volume_bias |          0.949|  78|
|GR6J          |logNSE         |          0.878| 172|
|GR6J          |mam7_bias      |          0.780| 127|
|GR6J          |q95_bias       |          0.714|  70|

Stratified by aridity tercile (supporting evidence for the semi-arid /
hard-rock claim, not part of the rule):

|compared_with |metric         |arid_tercile | lstm_win_share|  n|
|:-------------|:--------------|:------------|--------------:|--:|
|GR4J          |dry_spell_bias |intermediate |          0.361| 36|
|GR4J          |lf_volume_bias |intermediate |          0.917| 36|
|GR4J          |logNSE         |intermediate |          0.983| 59|
|GR4J          |mam7_bias      |intermediate |          0.830| 47|
|GR4J          |q95_bias       |intermediate |          0.710| 31|
|GR4J          |dry_spell_bias |wet          |          0.441| 34|
|GR4J          |lf_volume_bias |wet          |          0.971| 34|
|GR4J          |logNSE         |wet          |          0.933| 60|
|GR4J          |mam7_bias      |wet          |          0.804| 51|
|GR4J          |q95_bias       |wet          |          0.719| 32|
|GR4J          |logNSE         |dry          |          0.623| 53|
|GR4J          |mam7_bias      |dry          |          0.793| 29|
|GR4J          |dry_spell_bias |dry          |          0.250|  8|
|GR4J          |lf_volume_bias |dry          |          0.750|  8|
|GR4J          |q95_bias       |dry          |          0.714|  7|
|GR6J          |dry_spell_bias |intermediate |          0.444| 36|
|GR6J          |lf_volume_bias |intermediate |          0.917| 36|
|GR6J          |logNSE         |intermediate |          0.983| 59|
|GR6J          |mam7_bias      |intermediate |          0.787| 47|
|GR6J          |q95_bias       |intermediate |          0.645| 31|
|GR6J          |dry_spell_bias |wet          |          0.353| 34|
|GR6J          |lf_volume_bias |wet          |          1.000| 34|
|GR6J          |logNSE         |wet          |          0.950| 60|
|GR6J          |mam7_bias      |wet          |          0.804| 51|
|GR6J          |q95_bias       |wet          |          0.812| 32|
|GR6J          |logNSE         |dry          |          0.679| 53|
|GR6J          |mam7_bias      |dry          |          0.724| 29|
|GR6J          |dry_spell_bias |dry          |          0.250|  8|
|GR6J          |lf_volume_bias |dry          |          0.875|  8|
|GR6J          |q95_bias       |dry          |          0.571|  7|

Metric de-duplication check (AGENTS.md rule 5): pairwise Spearman rho among the five v1 metrics is reported in `bench_10_log.txt`; no composite score is formed here.

LSTM is never treated as observed; Track B is benchmark-only
(AGENTS.md two-track design).
