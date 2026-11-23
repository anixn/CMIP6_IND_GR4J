# compile_paper.R -- build manuscript/paper.pdf from manuscript/paper.md
# Pipeline: pandoc (via rmarkdown's bundled pandoc) -> paper.tex with
# --citeproc, bibliography read from the SEPARATE references.bib -> TinyTeX
# pdflatex. Run:  Rscript manuscript/compile_paper.R
# Requires: TinyTeX installed (tinytex::is_tinytex()), rmarkdown (for pandoc).

options(width = 120)
md  <- file.path("manuscript", "paper.md")
tex <- file.path("manuscript", "paper.tex")
bib <- file.path("manuscript", "references.bib")

stopifnot(file.exists(md), file.exists(bib))

# 1. pandoc ---------------------------------------------------------------
pandoc_path <- tryCatch(rmarkdown::find_pandoc(), error = function(e) NULL)
if (is.null(pandoc_path) || is.null(pandoc_path$version)) {
   stop("pandoc not found; install rmarkdown or set the path manually")
}
pandoc_bin <- file.path(pandoc_path$dir,
                        if (.Platform$OS.type == "windows") "pandoc.exe" else "pandoc")
if (!file.exists(pandoc_bin)) stop("pandoc binary not found at ", pandoc_bin)
cat("pandoc:", pandoc_bin, "version", as.character(pandoc_path$version), "\n")

args <- c(
   shQuote(normalizePath(md, winslash = "/")),
   "--standalone",
   "--to", "latex",
   "--output", shQuote(normalizePath(tex, winslash = "/")),
   "--citeproc",
   "--bibliography", shQuote(normalizePath(bib, winslash = "/")),
   "--metadata", "link-citations=true",
   "--resource-path", shQuote(normalizePath("manuscript", winslash = "/")),
   "-V", "geometry:margin=2.3cm",
   "-V", "colorlinks=true",
   "-V", "fontsize=11pt")
st <- system2(pandoc_bin, args)   # pandoc --citeproc reads references.bib
if (st != 0) stop("pandoc failed with status ", st)
cat("wrote", tex, "-", file.size(tex), "bytes\n")

# 2. TinyTeX xelatex (pdflatex chokes on the manuscript's Unicode: rho, x, >=, arrows)
if (!requireNamespace("tinytex", quietly = TRUE))
   stop("tinytex not installed")
if (!tinytex::is_tinytex()) cat("NOTE: using system LaTeX, not TinyTeX\n")

# compile from manuscript/ so the relative figure paths (figures/...) resolve;
# paper.md keeps manuscript-relative paths so GitHub renders them too
old_wd <- setwd(dirname(normalizePath(tex)))
st <- tryCatch(tinytex::xelatex(basename(tex), clean = TRUE), error = function(e) e)
pdf <- file.path("paper.pdf")
if (!file.exists(pdf)) {
   cat("xelatex path failed (", conditionMessage(if (inherits(st, "error")) st else "no pdf"),
       "); falling back to pdflatex...\n")
   st <- tinytex::pdflatex(basename(tex), clean = TRUE)
}
setwd(old_wd)
if (!file.exists(file.path("manuscript", "paper.pdf")))
   stop("PDF was not produced -- check the LaTeX log above")
pdf <- file.path("manuscript", "paper.pdf")
cat("built", pdf, "-", file.size(pdf), "bytes,", format(Sys.time()), "\n")

# 3. check for unresolved citations ---------------------------------------
log <- file.path("manuscript", "paper.log")
if (file.exists(log)) {
   l <- readLines(log, warn = FALSE)
   bad <- grep("(Citation|Reference).*undefined", l, value = TRUE)
   if (length(bad)) {
      cat("WARNING: undefined citations/references:\n")
      cat(head(bad, 10), sep = "\n")
   } else {
      cat("no undefined citations/references\n")
   }
}
