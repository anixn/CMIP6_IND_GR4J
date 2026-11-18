# H1 verdict -- forcing rank vs low-flow rank

**Date:** 2026-11-18 11:08:56 | **metric_version:** v1
**Rule (pre-registered 18 Nov 2026, AGENTS.md):** H1 fails if the pooled Spearman rho > 0.6; negative results are results.

**Pooled rho (forcing composite rank vs low-flow composite rank):** -0.027
**Bootstrap 95% CI (1000 catchment resamples, seed 20261118):** [-0.095, 0.038]
**Verdict: SUPPORTED**

Interpretation: a rho near zero means low-flow skill is nearly
uncorrelated with whole-flow/forcing skill -- the two-stage framework
carries information a forcing-only selection would miss. A rho > 
0.6
 would collapse the framework to one stage and the
paper must report that honestly.

Models ranked: 22 | catchments: 78 | metrics kept after de-dup: logNSE, lf_volume_bias, dry_spell_bias, mam7_bias
