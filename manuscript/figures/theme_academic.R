# theme_academic.R -- one house style for every data figure in the paper.
# Source this file from make_figures.R (and any future figure script) and use
# theme_academic(), pal_academic, and save_fig_academic() -- do not restyle
# individual plots.
#
# Sizes follow manuscript/figures/TYPOGRAPHY_SPEC.md exactly:
#   base_size = 12, every element set in absolute pt, minimum text 10 pt at
#   final print size, axis titles bold, ticks <= 2 pt smaller than titles.
#
# Font: Roboto (static Regular + Bold shipped in manuscript/figures/fonts/,
# registered through showtext/sysfonts), Arial fallback if the files are absent.
# Sizes are font-independent.

suppressPackageStartupMessages({
  library(ggplot2); library(scales)
})

# --- font -------------------------------------------------------------------
fig_font <- "Arial"
local({
  fdir <- file.path("D:/Datasets/CIMP6_India/manuscript/figures/fonts")
  reg  <- file.path(fdir, "Roboto-Regular.ttf")
  regb <- file.path(fdir, "Roboto-Bold.ttf")
  if (file.exists(reg) && requireNamespace("sysfonts", quietly = TRUE)) {
    sysfonts::font_add("Roboto", regular = reg,
                       bold = if (file.exists(regb)) regb else reg)
    if (requireNamespace("showtext", quietly = TRUE)) showtext::showtext_auto()
    assign("fig_font", "Roboto", inherits = TRUE)
    message("theme_academic: using Roboto (", basename(reg), ")")
  } else {
    message("theme_academic: Roboto TTF not found, using Arial")
  }
})

# Okabe-Ito derived, ordered for categorical use
pal_academic <- c(
  blue   = "#0072B2",
  orange = "#D55E00",
  green  = "#009E73",
  purple = "#CC79A7",
  sky    = "#56B4E9",
  yellow = "#E69F00",
  grey   = "#666666",
  black  = "#000000"
)

# Muted set for stacked / many-category figures
pal_stack <- c(
  gcm        = "#0072B2",
  structure  = "#009E73",
  interaction= "#9ECAE1",
  tail       = "#E69F00",
  inter2     = "#F5E1B0",
  inter3     = "#BFE3D6",
  threeway   = "#D9D9D9"
)

theme_academic <- function(base_size = 12, base_family = fig_font) {
  theme_bw(base_size = base_size, base_family = base_family) +
    theme(
      # frame
      panel.border       = element_rect(colour = "black", linewidth = 0.5),
      panel.grid.major.y = element_line(colour = "grey88", linewidth = 0.3),
      panel.grid.major.x = element_blank(),
      panel.grid.minor   = element_blank(),
      # axes (spec: ticks 10.5 pt, titles 12 pt bold, ticks 1.6 mm / 0.45 pt)
      axis.line    = element_blank(),
      axis.ticks   = element_line(colour = "black", linewidth = 0.45),
      axis.ticks.length = unit(1.6, "mm"),
      axis.text    = element_text(colour = "black", size = 11),
      axis.title   = element_text(colour = "black", size = 12.5, face = "bold"),
      axis.title.x = element_text(margin = margin(t = 4)),
      axis.title.y = element_text(margin = margin(r = 4)),
      # facet strips: white, thin rule, 10.5 pt
      strip.background = element_rect(fill = "white", colour = "black", linewidth = 0.4),
      strip.text       = element_text(face = "plain", size = 11, colour = "black"),
      # titles (13 / 11 pt)
      plot.title    = element_text(face = "plain", size = 13.5, hjust = 0,
                                   margin = margin(b = 4)),
      plot.subtitle = element_text(size = 11.5, hjust = 0, colour = "grey25",
                                   margin = margin(b = 2)),
      plot.caption  = element_text(size = 10, hjust = 0, colour = "grey35",
                                   margin = margin(t = 3)),
      # legends (title 11, text 10, key 10 pt)
      legend.position = "bottom",
      legend.title    = element_text(size = 11.5),
      legend.text     = element_text(size = 10.5),
      legend.key.size = unit(10, "pt"),
      legend.margin   = margin(t = 2),
      plot.margin     = margin(4, 6, 4, 4)
    )
}

# Standard saver: vector PDF (embedded fonts) + 300 dpi PNG, same geometry.
save_fig_academic <- function(plot, dir, name, width = 7.2, height = 4.2) {
  dir.create(dir, recursive = TRUE, showWarnings = FALSE)
  ggsave(file.path(dir, paste0(name, ".pdf")), plot,
         width = width, height = height, device = cairo_pdf, bg = "white")
  ggsave(file.path(dir, paste0(name, ".png")), plot,
         width = width, height = height, dpi = 300, bg = "white")
  cat("wrote", name, "\n")
  invisible(plot)
}

pct_axis <- function(accuracy = 1) scales::label_percent(accuracy = accuracy)
