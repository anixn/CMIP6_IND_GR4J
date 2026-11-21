# validate_ssp_nc.R -- purge files that are not netCDF (error pages saved as .nc)
# Why: the ESGF THREDDS/ncss backend on some nodes is returning a Java stack
# trace ("org.eclipse.store...StorageExceptionNotActive") instead of data.
# The R cmip6 downloader writes the HTTP body to disk without checking the
# content, so a 7 KB error page lands as <name>.nc and looks like a completed
# download. A real netCDF-4 file starts with the HDF5 magic \x89HDF\r\n\x1a\n
# (bytes 89 48 44 46 0D 0A 1A 0A); netCDF-3 classic starts with CDF\x01.
# Files whose magic matches neither are server error pages, never data.
# Guard: only files untouched for >= 5 minutes are touched (never race an
# in-flight write), and every deletion is logged -- no silent drops.
dir <- "D:/Datasets/Download_CMIP/data_raw/cmip6"
log_fp <- "D:/Datasets/CIMP6_India/data_processed/logs/validate_ssp_nc_purged.csv"
fl <- list.files(dir, pattern = "\\.nc$", full.names = TRUE)
sz <- file.size(fl)
mt <- file.mtime(fl)
HDF5 <- as.raw(c(0x89, 0x48, 0x44, 0x46, 0x0D, 0x0A, 0x1A, 0x0A))
CDF1 <- as.raw(c(0x43, 0x44, 0x46, 0x01))
magic_ok <- logical(length(fl))
for (i in which(sz > 0)) {
   h <- readBin(fl[i], what = "raw", n = 8L)
   magic_ok[i] <- identical(h[1:8], HDF5) || identical(h[1:4], CDF1)
}
magic_ok[sz == 0] <- FALSE
candidates <- which(!magic_ok & (Sys.time() - as.POSIXct(mt)) > 300)
cat("files scanned:", length(fl),
    "| bad magic:", sum(!magic_ok),
    "| purged now (quiet >= 5 min):", length(candidates), "\n")
if (length(candidates)) {
   log <- data.table::data.table(
      file = basename(fl[candidates]), size_bytes = sz[candidates],
      last_write = format(as.POSIXct(mt[candidates])), reason = "not_netCDF_error_page")
   data.table::fwrite(log, log_fp, append = file.exists(log_fp))
   file.remove(fl[candidates])
   cat("purged and logged to:", log_fp, "\n")
}
fl2 <- list.files(dir, pattern = "\\.nc$", full.names = TRUE)
cat("files remaining:", length(fl2), "\n")
