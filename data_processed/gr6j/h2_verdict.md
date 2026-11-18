# H2 verdict -- GR4J vs GR6J low-flow divergence (observed forcings)

**Date:** 2026-11-18 11:20:03 | metric_version v1 | catchments: 172

**Rule (pre-registered 18 Nov 2026, GR6J_00_setup.Rmd):** material divergence = median |div| >= 0.10 (logNSE) or >= 10 pp (% bias metrics). H2 stands if >= 1 metric diverges materially in >= 1 aridity tercile; fails otherwise (negative result).

**Verdict: H2 STANDS**

Material divergences by tercile:

|metric         |arid_tercile |  n| median_div| wilcoxon_p|
|:--------------|:------------|--:|----------:|----------:|
|lf_volume_bias |intermediate | 36|     31.634|     0.4414|
|mam7_bias      |intermediate | 47|    -29.811|     0.2579|
|q95_bias       |intermediate | 31|     12.561|     0.8092|
|lf_volume_bias |wet          | 34|     51.698|     0.1087|
|mam7_bias      |wet          | 51|    -46.990|     0.3181|
|q95_bias       |wet          | 32|    -11.937|     0.3038|
|mam7_bias      |dry          | 29|   -449.463|     0.0655|
|dry_spell_bias |dry          |  8|     23.011|     0.1003|
|lf_volume_bias |dry          |  8|    157.893|     0.3828|
|q95_bias       |dry          |  7|   -111.235|     0.1094|

Direction is reported, never claimed as superiority (guardrail 3): 
positive div = GR6J larger (for biases: worse overestimation; for 
logNSE: better skill). See divergence_table.csv for the full grid.

NOTE: this is the observed-forcing divergence (base case of H2); the 
SSP-projection leg (14 GCMs x 4 SSPs) extends it in the projection phase.
