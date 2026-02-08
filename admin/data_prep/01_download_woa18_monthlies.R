#!/usr/bin/env Rscript

# Download WOA18 monthly climatology CSVs (1-degree, decav) for a small core set.
#
# Outputs:
#   data/SAMOS/raw/woa18/temperature/woa18_decav_t00mnMM.csv.gz
#   data/SAMOS/raw/woa18/salinity/woa18_decav_s00mnMM.csv.gz
#
# Source landing page:
#   https://www.ncei.noaa.gov/access/world-ocean-atlas-2018/
#
# Temperature listing (example):
#   https://www.ncei.noaa.gov/access/world-ocean-atlas-2018/bin/woa18.pl?parameter=t

options(warn = 1)

base_dir <- file.path("data", "SAMOS", "raw", "woa18")

dir.create(file.path(base_dir, "temperature"), recursive = TRUE, showWarnings = FALSE)
dir.create(file.path(base_dir, "salinity"), recursive = TRUE, showWarnings = FALSE)

base_url <- "https://www.ncei.noaa.gov/data/oceans/woa/WOA18/DATA"

# In WOA18 CSV naming, the two digits after the variable letter are the *time slice*:
#   00 = annual
#   01..12 = Jan..Dec
#   13..16 = seasonal (JFM, AMJ, JAS, OND)
# The trailing mn01 indicates the statistical mean field.

t_url <- function(tt) {
  sprintf("%s/temperature/csv/decav/1.00/woa18_decav_t%02dmn01.csv.gz", base_url, tt)
}

s_url <- function(tt) {
  sprintf("%s/salinity/csv/decav/1.00/woa18_decav_s%02dmn01.csv.gz", base_url, tt)
}

fetch_one <- function(url, dest) {
  if (file.exists(dest)) {
    message("[skip] ", dest)
    return(invisible(TRUE))
  }

  tmp <- paste0(dest, ".part")
  if (file.exists(tmp)) unlink(tmp)

  message("[download] ", url)

  ok <- FALSE
  for (i in 1:3) {
    try({
      utils::download.file(url, tmp, mode = "wb", quiet = TRUE)
      ok <- file.exists(tmp) && file.info(tmp)$size > 1000
    }, silent = TRUE)

    if (ok) break
    message("  retry ", i, "/3 failed; sleeping 2s")
    Sys.sleep(2)
  }

  if (!ok) stop("Failed to download: ", url)

  file.rename(tmp, dest)
  message("[ok] saved ", dest)
  invisible(TRUE)
}

# Download annual (00) plus monthly (01..12)
for (tt in c(0, 1:12)) {
  fetch_one(
    url  = t_url(tt),
    dest = file.path(base_dir, "temperature", sprintf("woa18_decav_t%02dmn01.csv.gz", tt))
  )
  fetch_one(
    url  = s_url(tt),
    dest = file.path(base_dir, "salinity", sprintf("woa18_decav_s%02dmn01.csv.gz", tt))
  )
}

message("Done.")
