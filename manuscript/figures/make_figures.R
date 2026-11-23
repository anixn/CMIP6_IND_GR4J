# make_figures.R -- publication figures for paper.md
#
# Two families, deliberately separated:
#   * CONCEPTUAL diagrams (fig1 framework, fig2 data flow, figGA graphical
#     abstract) -> rendered with pele (Mermaid -> SVG) and included as SVG/PNG.
#   * DATA figures (fig3-fig7) -> ggplot2 with ONE house style:
#     source("theme_academic.R") and use theme_academic() / pal_academic /
#     save_fig_academic() only. Never restyle a single plot.
#
# Run: Rscript manuscript/figures/make_figures.R

root <- "D:/Datasets/CIMP6_India"
fig  <- file.path(root, "manuscript", "figures")
dp   <- file.path(root, "data_processed")
source(file.path(fig, "theme_academic.R"))
library(data.table); library(patchwork)

# ---------------------------------------------------------------------------
# Fig 3 -- H1: forcing rank vs low-flow rank
# ---------------------------------------------------------------------------
h1 <- fread(file.path(dp, "lowflow", "h1_rank_pairs.csv"))

p3 <- ggplot(h1, aes(forcing_rank, lowflow_rank)) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed",
              colour = pal_academic[["grey"]], linewidth = 0.4) +
  geom_smooth(method = "lm", formula = y ~ x, se = TRUE,
              colour = pal_academic[["blue"]], fill = pal_academic[["blue"]],
              alpha = 0.12, linewidth = 0.6) +
  geom_point(size = 2.4, colour = pal_academic[["orange"]], alpha = 0.9) +
  annotate("text", x = 6.2, y = 23.4, hjust = 0, vjust = 1,
           size = 3.6, colour = "grey20", family = "sans",
           label = paste("Spearman rho = -0.027",
                         "95% CI [-0.095, 0.038]",
                         "pre-registered failure: rho > 0.6", sep = "\n")) +
  scale_x_continuous(breaks = pretty_breaks(6), expand = expansion(0.03)) +
  scale_y_continuous(breaks = pretty_breaks(6), expand = expansion(0.03)) +
  labs(x = "Forcing-skill rank\n(22 CMIP6 models, out-of-sample 2001-2014)",
       y = "Low-flow-skill rank (composite, 78 catchments)",
       title = "Forcing skill and low-flow skill are essentially orthogonal") +
  theme_academic()
save_fig_academic(p3, fig, "fig3_h1_rank_divergence", width = 6.4, height = 3.9)

# ---------------------------------------------------------------------------
# Fig 4 -- H2: GR4J vs GR6J divergence by aridity tercile
# Built from the per-catchment structural metrics (struct_metrics.csv) so the
# figure shows the full divergence distribution, not a summary that hides the
# inter-catchment spread. divergence = GR6J - GR4J per catchment and metric.
# ---------------------------------------------------------------------------
sm <- fread(file.path(dp, "gr6j", "struct_metrics.csv"))
sm <- sm[window == "valid"]
div <- dcast(sm, catchment + arid_tercile + metric ~ structure, value.var = "value")
div[, divergence := GR6J - GR4J]
div[, arid_tercile := factor(arid_tercile, levels = c("dry", "intermediate", "wet"),
                             labels = c("dry", "intermediate", "wet"))]
div[, metric := factor(metric,
   levels = c("mam7_bias", "q95_bias", "lf_volume_bias", "dry_spell_bias"),
   labels = c("7-day minimum bias (pp)", "Q95 bias (pp)",
              "Low-flow volume bias (pp)", "Dry-spell bias (pp)"))]
div <- div[!is.na(metric)]          # drop logNSE rows (omitted from the figure)

p4 <- ggplot(div, aes(x = arid_tercile, y = divergence)) +
  geom_hline(yintercept = 0, colour = pal_academic[["grey"]], linewidth = 0.4) +
  geom_boxplot(aes(fill = arid_tercile), width = 0.55, outlier.shape = NA,
               colour = "grey20", linewidth = 0.3, alpha = 0.6) +
  geom_jitter(width = 0.12, size = 0.6, alpha = 0.4, colour = "grey15") +
  facet_wrap(~metric, scales = "free_y", ncol = 2) +
  scale_fill_manual(values = c(dry = pal_academic[["orange"]],
                               intermediate = pal_academic[["yellow"]],
                               wet = pal_academic[["green"]]), guide = "none") +
  scale_y_continuous(trans = scales::pseudo_log_trans(sigma = 10),
                     breaks = c(-1e5, -1e4, -1e3, -1e2, -10, 0, 10, 1e2, 1e3, 1e4, 1e5),
                     labels = scales::label_number(scale_cut = scales::cut_short_scale())) +
  labs(x = NULL, y = "GR6J minus GR4J divergence (per catchment; pseudo-log scale)",
       title = "Structural divergence is low-flow-specific and largest in dry catchments",
       caption = paste("box = interquartile range and median; whiskers = 1.5 x IQR;",
                       "points = catchments; pseudo-log scale compresses the",
                       "near-zero-denominator bias outliers; logNSE (whole-flow) is not",
                       "material (median -0.01 to 0.05, p = 0.41-0.45) and is omitted")) +
  theme_academic() +
  theme(panel.grid.major.y = element_blank())
save_fig_academic(p4, fig, "fig4_h2_structural_divergence", width = 6.4, height = 5.4)

# ---------------------------------------------------------------------------
# Fig 5 -- H3: observed propagation lags + per-model reproduction
# ---------------------------------------------------------------------------
lag <- fread(file.path(dp, "prop", "observed_lags.csv"))
ps  <- fread(file.path(dp, "prop", "prop_model_scores.csv"))

pa <- ggplot(lag[, .N, by = L_obs], aes(factor(L_obs), N)) +
  geom_col(fill = pal_academic[["blue"]], width = 0.7) +
  geom_text(aes(label = N), vjust = -0.35, size = 3.4, colour = "grey25") +
  scale_y_continuous(expand = expansion(mult = c(0, 0.12))) +
  labs(x = "Observed SPI-12 to SRI-12 lag (months)", y = "Catchments",
       subtitle = "observed lags frozen for 167 catchments") +
  theme_academic()

pb <- ggplot(ps, aes(prop_share, reorder(model, prop_share))) +
  geom_vline(xintercept = 0.80, linetype = "dashed",
             colour = pal_academic[["orange"]], linewidth = 0.4) +
  geom_point(size = 2.0, colour = pal_academic[["green"]]) +
  scale_x_continuous(labels = pct_axis(), limits = c(0.5, 1.02)) +
  labs(x = "Propagation share reproduced", y = NULL,
       subtitle = "dashed line: pre-registered 0.80 falsification band") +
  theme_academic() +
  theme(panel.grid.major.y = element_blank())

p5 <- pa / pb + plot_layout(heights = c(1, 2.2))
save_fig_academic(p5, fig, "fig5_h3_propagation", width = 6.2, height = 6.9)

# ---------------------------------------------------------------------------
# Fig 6 -- H4: seven-term variance decomposition (centrepiece)
# Built from variance_shares.csv (per catchment x metric x ssp x window), where
# each row is a TRUE partition; averages are therefore additive. h4_summary.csv
# stores per-term medians and cannot be used for a stacked bar.
# ---------------------------------------------------------------------------
vs <- fread(file.path(dp, "decomp", "variance_shares.csv"))
term_lv <- c("GCM", "Structure", "GCM x structure", "Tail policy",
             "GCM x tail", "Structure x tail", "3-way")
long <- melt(vs,
   id.vars = c("catchment", "arid_tercile", "metric", "ssp", "window"),
   measure.vars = c("share_gcm", "share_structure", "share_gcm_struct",
                    "share_tail", "share_gcm_tail", "share_struct_tail",
                    "share_three_way"),
   variable.name = "term", value.name = "share")
long[, term := factor(term, levels = c(
   "share_gcm", "share_structure", "share_gcm_struct",
   "share_tail", "share_gcm_tail", "share_struct_tail",
   "share_three_way"), labels = term_lv)]

agg <- long[, .(share = mean(share)), by = .(metric, arid_tercile, term)]
agg[, metric := factor(metric,
   levels = c("log10_q95", "log10_mam7", "lf_ratio_q95", "dry_spell_days", "log10_meanq"),
   labels = c("Q95", "7-day minimum", "Low-tail shape", "Dry-spell length", "Mean flow"))]
agg[, arid_tercile := factor(arid_tercile, levels = c("wet", "intermediate", "dry"))]

cols <- c("GCM" = pal_stack[["gcm"]], "Structure" = pal_stack[["structure"]],
          "GCM x structure" = pal_stack[["interaction"]],
          "Tail policy" = pal_stack[["tail"]], "GCM x tail" = pal_stack[["inter2"]],
          "Structure x tail" = pal_stack[["inter3"]], "3-way" = pal_stack[["threeway"]])

p6 <- ggplot(agg, aes(share, arid_tercile, fill = term)) +
  geom_bar(stat = "identity", width = 0.66, colour = "white", linewidth = 0.15) +
  facet_wrap(~metric, ncol = 1, strip.position = "right") +
  scale_fill_manual(values = cols, name = NULL, breaks = term_lv) +
  scale_x_continuous(labels = pct_axis(), expand = expansion(mult = c(0, 0.01))) +
  guides(fill = guide_legend(nrow = 2, byrow = TRUE)) +
  labs(x = "Mean variance share (seven-term exact partition)", y = NULL,
       title = "Structure owns 34-68% of low-flow variance, most of all in dry catchments") +
  theme_academic() +
  theme(panel.grid.major.y = element_blank(),
        strip.text.y.right = element_text(angle = 0, hjust = 0))
save_fig_academic(p6, fig, "fig6_h4_variance_decomposition", width = 6.4, height = 7.0)

# ---------------------------------------------------------------------------
# Fig 7 -- H5: LSTM win rates, magnitude vs duration
# ---------------------------------------------------------------------------
h5 <- fread(file.path(dp, "bench", "h5_lstm_win_rates_pooled.csv"))
h5[, metric := factor(metric,
   levels = c("logNSE", "lf_volume_bias", "mam7_bias", "q95_bias", "dry_spell_bias"),
   labels = c("logNSE", "Low-flow vol.", "7-day min.", "Q95", "Dry spell"))]

p7 <- ggplot(h5, aes(metric, lstm_win_share, fill = compared_with)) +
  geom_hline(yintercept = 0.5, linetype = "dashed",
             colour = pal_academic[["grey"]], linewidth = 0.4) +
  geom_col(position = position_dodge(width = 0.72), width = 0.64,
           colour = "grey20", linewidth = 0.15) +
  geom_text(aes(label = paste0("n=", n)), position = position_dodge(width = 0.72),
            vjust = -0.35, size = 3.4, colour = "grey25") +
  scale_fill_manual(values = c(GR4J = pal_academic[["sky"]], GR6J = pal_academic[["blue"]]),
                    name = "Compared with") +
  scale_y_continuous(labels = pct_axis(), limits = c(0, 1.06),
                     expand = expansion(mult = c(0, 0))) +
  labs(x = NULL, y = "LSTM win share (share of catchments)",
       title = "The LSTM wins magnitudes but loses drought duration",
       caption = "dashed line: equal skill (0.5)") +
  theme_academic()
save_fig_academic(p7, fig, "fig7_h5_lstm_win_rates", width = 6.4, height = 4.1)

cat("done\n")
