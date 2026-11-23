# FIGURES.md — publication figure set

Seven main figures + one graphical abstract. Conceptual diagrams use **pele**
(Mermaid → SVG, flattened and exported as vector PDF/PNG); data figures use
**ggplot2** with one house style (`theme_academic.R`, specified in
`TYPOGRAPHY_SPEC.md`, Roboto, 10 pt minimum at final print size).

| Fig | Type | File | Built from | Tool |
|---|---|---|---|---|
| 1 | conceptual | `fig1_framework.*` | programme logic (5 hypotheses, 2 stages) | pele |
| 2 | conceptual | `fig2_dataflow.*` | acquisition/simulation counts + roster funnel | pele |
| GA | conceptual | `figGA_story.*` | the one-sentence story (submitted as graphical abstract) | pele |
| 3 | data | `fig3_h1_rank_divergence.*` | `lowflow/h1_rank_pairs.csv` | ggplot2 |
| 4 | data | `fig4_h2_structural_divergence.*` | `gr6j/struct_metrics.csv` (per catchment) | ggplot2 |
| 5 | data | `fig5_h3_propagation.*` | `prop/observed_lags.csv`, `prop/prop_model_scores.csv` | ggplot2 |
| 6 | data | `fig6_h4_variance_decomposition.*` | `decomp/variance_shares.csv` (true per-catchment partition) | ggplot2 |
| 7 | data | `fig7_h5_lstm_win_rates.*` | `bench/h5_lstm_win_rates_pooled.csv` | ggplot2 |

## Study breakdown (what each figure is for)

1. **Figure 1 — the framework.** One glance answers "what was built": two
   stages, two structures, five hypotheses as gates. Use in §4 Methods and as
   the basis of the graphical abstract.
2. **Figure 2 — data flow and roster.** Separates the *setting* (472) from the
   *analysis* numbers (192 / 172 / 78 / 167) and shows the 162/168 acquisition
   reality plus the 6 unpublished HadGEM3 combos. Use in §4.3.
3. **Figure 3 — H1.** The empirical wedge: rank orthogonality.
4. **Figure 4 — H2.** Structure diverges at low flows only, most in dry
   catchments; distributions, not just medians.
5. **Figure 5 — H3.** Propagation lags are reproduced by every model, yet
   uncorrelated with forcing skill.
6. **Figure 6 — H4 (centrepiece).** The seven-term partition; the visual
   argument that structure owns low-flow variance and tail policy does not.
7. **Figure 7 — H5.** The LSTM audit's magnitude/duration split.

## Reproduction

```r
# data figures (writes PDF + 300-dpi PNG into manuscript/figures/)
Rscript manuscript/figures/make_figures.R
```

Conceptual figures: write the Mermaid source (`fig*.mmd`), render it in the
app browser with pele
(`https://cdn.jsdelivr.net/npm/pele@1/dist/pele.global.js`), flatten the
computed styles (pele emits CSS variables that raster converters such as rsvg
cannot resolve, so the arrows disappear otherwise), download the flattened SVG,
then convert:

```r
rsvg::rsvg_pdf("fig1_framework.svg", "fig1_framework.pdf")
rsvg::rsvg_png("fig1_framework.svg", "fig1_framework.png", width = 2200)
```

## House style rules (data figures)

- `source("theme_academic.R")` and use `theme_academic()`; never restyle a
  single plot. Palette: `pal_academic` (Okabe-Ito) and `pal_stack`.
- Font Roboto (static TTFs in `fonts/`, registered via showtext); Arial
  fallback if the files are missing.
- Minimum 10 pt at final print size; axis titles 12 pt bold; ticks 10.5 pt
  (see `TYPOGRAPHY_SPEC.md` for the full table and the pass/fail check).
- Vector PDF for the manuscript, 300-dpi PNG for review; same geometry.
- Stacked shares must come from a **true partition** (`variance_shares.csv`),
  never from per-term medians (`h4_summary.csv`), because medians are not
  additive.
