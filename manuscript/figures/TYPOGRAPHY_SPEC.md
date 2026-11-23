# TYPOGRAPHY_SPEC.md — font and spacing specification for the data figures

Produced before (re)building the figures, per the ggplot2-typography brief.
Applies to the five DATA figures (fig3–fig7); the conceptual figures (fig1,
fig2, figGA) are Mermaid/pele exports and are specified separately in
`FIGURES.md`.

## Inputs used for the calculation

| Constraint | Value |
|---|---|
| Font family | **Roboto** (static Regular + Bold shipped in `manuscript/figures/fonts/`, registered through showtext/sysfonts); Arial fallback if the files are absent. Sizes are font-independent. |
| Final output | vector PDF (`cairo_pdf`) with 300-dpi PNG preview |
| Width | 7.2 in (double column) — 6.6–7.0 in for two figures |
| Heights | 4.0 / 5.4 / 6.2 / 7.0 / 4.2 in (fig3–fig7) |
| Viewing context | **print paper** |
| Minimum rendered text | **10 pt** at final size |
| Tick labels vs axis titles | ticks ≤ 2 pt smaller than titles; axis titles **bold** |

## 1. Recommended `base_size`

**`base_size = 12`** for a `theme_minimal()`/`theme_bw()` derivative.
Rationale: ggplot2's default multipliers make the smallest element (`axis.text`,
`legend.text`, `strip.text` ≈ 0.8 × base) equal 9.6 pt — below the 10 pt floor.
Setting `base_size = 12` and then **overriding every element with absolute
sizes** (table below) removes the dependence on multipliers altogether.

## 2. Element specification

| Element | size_pt | face | margin / angle / other |
|---|---|---|---|
| `plot.title` | 13 | plain | left-aligned (`hjust = 0`), bottom margin 4 pt |
| `plot.subtitle` | 11 | plain | left-aligned, bottom margin 2 pt, grey 25 |
| `axis.title.x` | 12 | **bold** | top margin 4 pt; wrap long labels to ≤ 60 characters |
| `axis.title.y` | 12 | **bold** | right margin 4 pt; wrap to ≤ 40 characters |
| `axis.text.x` | 10.5 | plain | 0° for ≤ 6 short labels; otherwise 30–45° with `hjust = 1` |
| `axis.text.y` | 10.5 | plain | 0°; for ≥ 15 categorical rows keep 10 pt and increase panel height rather than shrink |
| `legend.title` | 11 | plain | bottom legend, horizontal |
| `legend.text` | 10 | plain | key size 10 pt |
| `strip.text` | 10.5 | plain | strip on white, 0.4-pt black rule, no fill |
| `caption` | 10 | plain | left-aligned, grey 35, top margin 3 pt |

## 3. Ticks and frame

| Property | Value |
|---|---|
| `axis.ticks` linewidth | 0.45 pt |
| `axis.ticks.length` | 1.6 mm (4.5 pt) |
| panel border | 0.5 pt black; no top/right-only frames |
| major grid | horizontal only, 0.3 pt, grey 88; no minor grid |

## 4. Output geometry and overlap control

| Figure | width × height (in) | overlap adjustments |
|---|---|---|
| fig3 (H1 scatter) | 7.2 × 4.0 | x-title wrapped to two lines; annotation block at 10 pt in the empty top-left |
| fig4 (H2 distributions) | 7.2 × 5.4 | 4 facets × 3 terciles; pseudo-log y to keep medians visible; no x rotation |
| fig5 (H3 lags + reproduction) | 6.6 × 6.2 | 22 model labels at 10 pt need the 2.2× panel height; lag panel keeps integer breaks 0–12 |
| fig6 (H4 decomposition) | 7.2 × 7.0 | strip labels horizontal on the right; legend 2 rows × 4 keys at 10 pt |
| fig7 (H5 win rates) | 7.0 × 4.2 | metric labels hard-wrapped on two lines; n= labels at 10 pt offset 0.45 em above bars |

`ggsave` calls: `cairo_pdf` (vector) + `png(dpi = 300)` preview, same
width/height so the two outputs match exactly.

## 5. Pass/fail check

```
Smallest text = 10.0 pt (legend.text, caption)
               10.5 pt (axis.text, strip.text)
Requirement   = 10 pt
=> PASS at final saved size on all five figures.
```

Repeat of the check with ggplot2 defaults (`base_size = 9.5`, no overrides)
would give 7.6 pt — **FAIL**, which is why every element is set explicitly
rather than inherited.
