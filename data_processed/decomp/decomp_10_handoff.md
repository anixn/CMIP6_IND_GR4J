# DECOMP_10 hand-off

**Run:** 2026-11-23 19:13:44 | metric_version v1_proj
**Rows:** 622080
**Catchments:** 192
**Policies:** constant, linear
**Structures:** GR4J, GR6J
**Windows:** 2021-2040, 2041-2060, 2082-2100

**GCM coverage (explicit, not balanced away):**
- ssp126: 14 GCMs
- ssp245: 13 GCMs
- ssp370: 13 GCMs
- ssp585: 14 GCMs
- HadGEM3-GC31-MM ssp245/ssp370 are unpublished on ESGF
  (`logs/ssp_unavailable.csv`, `gcm_scenario_not_published`); H4 therefore
  runs a 13-GCM factorial for those two SSPs and a 14-GCM factorial for
  ssp126/ssp585. Each is balanced; neither is padded.

Next: `rmarkdown::render('DECOMP_00_anova.Rmd')` consumes
`data_processed/decomp/input_metrics.csv`.
