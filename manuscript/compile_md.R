# compile_md.R -- build a PDF from any manuscript markdown file.
# Usage:  Rscript manuscript/compile_md.R manuscript/INTRODUCTION_BACKGROUND.md
#         (default: manuscript/paper.md)
# Pipeline: pandoc --citeproc (references.bib stays separate) -> xelatex (TinyTeX).

args <- commandArgs(trailingOnly = TRUE)
md <- if (length(args)) args[1] else file.path("manuscript", "paper.md")
if (!file.exists(md)) stop("input not found: ", md)
dir <- dirname(normalizePath(md))
base <- tools::file_path_sans_ext(basename(md))
tex <- file.path(dir, paste0(base, ".tex"))
bib <- file.path(dir, "references.bib")

p <- tryCatch(rmarkdown::find_pandoc(), error = function(e) NULL)
if (is.null(p)) stop("pandoc not found")
bin <- file.path(p$dir, if (.Platform$OS.type == "windows") "pandoc.exe" else "pandoc")

cmd <- c(shQuote(normalizePath(md, winslash = "/")), "--standalone", "--to", "latex",
         "--output", shQuote(normalizePath(tex, winslash = "/")),
         "--citeproc",
         "--bibliography", shQuote(normalizePath(bib, winslash = "/")),
         "--resource-path", shQuote(normalizePath("manuscript", winslash = "/")),
         "-V", "geometry:margin=2.3cm", "-V", "colorlinks=true", "-V", "fontsize=11pt")
st <- system2(bin, cmd)
if (st != 0) stop("pandoc failed: ", st)

old <- setwd(dir)
on.exit(setwd(old), add = TRUE)
st <- tryCatch(tinytex::xelatex(paste0(base, ".tex"), clean = TRUE), error = function(e) e)
pdf <- paste0(base, ".pdf")
if (!file.exists(pdf)) st <- tinytex::pdflatex(paste0(base, ".tex"), clean = TRUE)
if (!file.exists(pdf)) stop("PDF not produced")
cat("built", file.path(dir, pdf), "-", file.size(file.path(dir, pdf)), "bytes\n")
