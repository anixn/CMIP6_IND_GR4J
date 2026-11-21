# test_agg_one.R -- validate the QED_40 aggregation path on ONE complete combo
# before the production run: checks timing, unit scale (mm/day), date mapping,
# and consistency with the historical aggregate for the same model/catchment.
root <- "D:/Datasets/CIMP6_India"
knitr::purl(file.path(root, "QED_00_setup.Rmd"),
            file.path(tempdir(), "qed00_setup.R"), documentation = 2)
source(file.path(tempdir(), "qed00_setup.R"))

st <- data.table::fread(file.path(root, "data_processed/ssp/qed_40_combo_status.csv"))
cat("complete combos:", sum(st$complete), "of", nrow(st), "\n")
pick <- st[complete == TRUE][1]
cat("test combo:", pick$var, pick$model, pick$ssp, "\n")

fl <- list.files("D:/Datasets/Download_CMIP/SSP", pattern = "_day_.*_ssp[0-9]+_.*\\.nc$",
                 full.names = TRUE, recursive = TRUE)
tok <- strsplit(basename(fl), "_")
var_of <- vapply(tok, `[`, "", 1); model_of <- vapply(tok, `[`, "", 3)
ssp_of <- vapply(tok, `[`, "", 4)
yr_of  <- as.integer(sub("^.*_([0-9]{4})_v.*$", "\\1", basename(fl)))
files <- fl[var_of == pick$var & model_of == pick$model & ssp_of == pick$ssp]
files <- sort(files)
cat("files in combo:", length(files), "\n")

polys <- sf::st_as_sf(terra::vect(file.path(root, "data_raw/catchments/merged",
                                            "all_catchments.shp")))
polys$id <- qed_normalize_id(polys$gauge_id)
cat("polygons used:", nrow(polys), "\n")

unit_scale  <- c(pr = 86400, tasmax = -273.15, tasmin = -273.15)
unit_is_add <- c(pr = FALSE, tasmax = TRUE,  tasmin = TRUE)
v <- pick$var

t0 <- Sys.time()
res <- list()
for (f in files[1:3]) {
   yr <- as.integer(sub("^.*_([0-9]{4})_v.*$", "\\1", basename(f)))
   r  <- terra::rast(f)
   nl <- terra::nlyr(r)
   dt <- if (nl == 360) {
      m <- (seq_len(nl) - 1L) %/% 30L + 1L; d <- (seq_len(nl) - 1L) %% 30L + 1L
      as.Date(sprintf("%04d-%02d-%02d", yr, m, d))
   } else as.Date(terra::time(r))
   w  <- cos(terra::init(r, "y") * pi / 180)
   ex <- exactextractr::exact_extract(r, polys, "weighted_mean",
                                     weights = w, stack_apply = TRUE,
                                     progress = FALSE)
   vals <- as.matrix(ex)
   vals <- if (unit_is_add[[v]]) vals + unit_scale[[v]] else vals * unit_scale[[v]]
   res[[length(res) + 1L]] <- list(yr = yr, n = nl, dt1 = min(dt),
                                   dt2 = max(dt), vals = vals)
   cat(sprintf("  %s: layers=%d dates %s..%s range[%.3f, %.3f] median %.3f\n",
               basename(f), nl, min(dt), max(dt),
               min(vals, na.rm = TRUE), max(vals, na.rm = TRUE),
               stats::median(vals, na.rm = TRUE)))
}
cat("elapsed per file (s):",
    round(as.numeric(difftime(Sys.time(), t0, units = "secs")) / 3, 2), "\n")

# compare against the historical aggregate for the same model, same catchments
hist_fp <- file.path(root, "data_processed", paste0("agg_", v, "_", pick$model, ".csv"))
if (file.exists(hist_fp)) {
   h <- data.table::fread(hist_fp, colClasses = list(character = "id"))
   ids <- polys$id
   hm <- as.matrix(h[match(ids, h$id), -(1:2), with = FALSE])
   cat(sprintf("historical agg  %s %s: median %.3f  range[%.3f, %.3f]\n",
               v, pick$model, stats::median(hm, na.rm = TRUE),
               min(hm, na.rm = TRUE), max(hm, na.rm = TRUE)))
   cat(sprintf("ssp agg (3 yrs) %s %s: median %.3f\n", v, pick$model,
               stats::median(unlist(lapply(res, function(z) z$vals)), na.rm = TRUE)))
}
