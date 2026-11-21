# ssp_combo_report.R -- compact progress report for the SSP leg.
# Reads only QED_40's own status table (no re-scan of the nc archive).
root <- "D:/Datasets/CIMP6_India"
st <- data.table::fread(file.path(root, "data_processed/ssp/qed_40_combo_status.csv"))
agg <- list.files(file.path(root, "data_processed/ssp"), pattern = "^agg_.*\\.csv$")
cat("combos complete :", sum(st$complete), "of", nrow(st), "\n")
cat("window years missing:", sum(st$n_expected - st$n_years), "\n")
cat("agg CSVs written:", length(agg), "\n")
print(st[, .(complete = sum(complete), combos = .N,
             years_missing = sum(n_expected - n_years)), by = var])
inc <- st[complete == FALSE][order(n_years)]
if (nrow(inc)) {
   cat("\nincomplete combos (worst first):\n")
   print(utils::head(inc[, .(var, model, ssp, n_years, missing = n_expected - n_years)], 12))
}
