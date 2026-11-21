# ssp_status.R -- exact SSP download status for the RESTRUCTURED layout
# (variable-major: D:/Datasets/Download_CMIP/SSP/<var>/<file>.nc)
# Reports per variable, per SSP, per model; validates netCDF magic bytes so
# server error pages saved as .nc are never counted as present.
root <- "D:/Datasets/Download_CMIP/SSP"
vars <- c("pr", "tasmax", "tasmin")
models <- c("EC-Earth3-Veg-LR", "MIROC-ES2L", "NorESM2-MM", "MIROC6", "FGOALS-g3",
            "HadGEM3-GC31-MM", "EC-Earth3", "INM-CM4-8", "BCC-CSM2-MR",
            "ACCESS-ESM1-5", "CanESM5", "CNRM-CM6-1", "MPI-ESM1-2-HR", "GFDL-ESM4")
ssps <- c("ssp126", "ssp245", "ssp370", "ssp585")
yrs  <- c(2015:2040, 2041:2060, 2081:2100)   # 66 years
HDF5 <- as.raw(c(0x89, 0x48, 0x44, 0x46, 0x0D, 0x0A, 0x1A, 0x0A))
CDF1 <- as.raw(c(0x43, 0x44, 0x46, 0x01))

rows <- list()
for (v in vars) {
   d <- file.path(root, v)
   fl <- if (dir.exists(d)) list.files(d, pattern = "\\.nc$", full.names = TRUE) else character(0)
   if (!length(fl)) {
      rows[[v]] <- data.table::data.table(var = v, model = models, ssp = "ALL",
                                          present = 0L, bad_magic = 0L, expected = length(yrs))
      next
   }
   bn <- basename(fl)
   # pr_day_<model>_<ssp>_<member>_<grid>_<year>_<ver>.nc
   parts <- strsplit(bn, "_", fixed = TRUE)
   md <- vapply(parts, function(p) if (length(p) >= 3) p[3] else NA_character_, "")
   ss <- vapply(parts, function(p) if (length(p) >= 4) p[4] else NA_character_, "")
   yy <- vapply(parts, function(p) {
      i <- which(grepl("^[0-9]{4}$", p))
      if (length(i)) p[max(i)] else NA_character_ }, "")
   ok <- logical(length(fl))
   for (i in seq_along(fl)) {
      h <- tryCatch(readBin(fl[i], "raw", n = 8L), error = function(e) raw(0))
      ok[i] <- length(h) >= 8L && identical(h[1:8], HDF5)
      if (!ok[i] && length(h) >= 4L) ok[i] <- identical(h[1:4], CDF1)
   }
   dt <- data.table::data.table(var = v, model = md, ssp = ss, year = yy, good = ok)
   dt <- dt[!is.na(model) & !is.na(ssp) & !is.na(year)]
   agg <- dt[, .(present = data.table::uniqueN(year[good]),
                 bad_magic = sum(!good)), by = .(var, model, ssp)]
   full <- data.table::CJ(var = v, model = models, ssp = ssps)
   agg <- merge(full, agg, by = c("var", "model", "ssp"), all.x = TRUE)
   agg[is.na(present), present := 0L]
   agg[is.na(bad_magic), bad_magic := 0L]
   agg[, expected := length(yrs)]
   rows[[v]] <- agg
}
st <- data.table::rbindlist(rows)

cat("=== per variable ===\n")
print(st[, .(files = sum(present), expected = sum(expected),
             pct = round(100 * sum(present) / sum(expected), 1),
             bad_magic = sum(bad_magic)), by = var][order(var)])

cat("\n=== per SSP x variable (files present / expected) ===\n")
print(data.table::dcast(st[, .(present = sum(present), expected = sum(expected)), by = .(ssp, var)],
                        ssp ~ var, value.var = "present"))

cat("\n=== per model (all vars/ssps) ===\n")
print(st[, .(present = sum(present), expected = sum(expected),
             pct = round(100 * sum(present) / sum(expected), 1)), by = model][order(pct)])

cat("\n=== incomplete combos (var/model/ssp), worst first ===\n")
inc <- st[present < expected][order(present)]
print(utils::head(inc[, .(var, model, ssp, present, expected, missing = expected - present)], 25))
cat("\nincomplete combos:", nrow(inc), "of", nrow(st), "\n")
cat("total files still missing:", sum(st$expected - st$present), "\n")
cat("files with bad magic (error pages), by var:\n")
print(st[bad_magic > 0, .(bad_magic = sum(bad_magic)), by = var])
