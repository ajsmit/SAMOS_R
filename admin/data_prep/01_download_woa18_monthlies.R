#!/usr/bin/env Rscript

# Download WOA18 monthly climatology CSVs (1-degree) for the SAMOS_R “core dataset family”.
#
# Variables downloaded:
#   - temperature (t)  : decav product
#   - salinity (s)     : decav product
#   - oxygen (o)       : all product
#   - nitrate (n)      : all product
#   - phosphate (p)    : all product
#   - silicate (i)     : all product
#
# Outputs (raw downloads; ignored by git):
#   data/SAMOS/raw/woa18/<var>/...
#
# Source landing page:
#   https://www.ncei.noaa.gov/access/world-ocean-atlas-2018/

options(warn = 1)

base_dir <- file.path("data", "SAMOS", "raw", "woa18")

# Base URL for all WOA18 CSV downloads
base_url <- "https://www.ncei.noaa.gov/data/oceans/woa/WOA18/DATA"

# In WOA18 CSV naming, the two digits after the variable letter are the *time slice*:
#   00 = annual
#   01..12 = Jan..Dec
#   13..16 = seasonal (JFM, AMJ, JAS, OND)
# The trailing mn01 indicates the statistical mean field.

vars <- list(
  temperature = list(product = "decav", letter = "t", folder = "temperature"),
  salinity    = list(product = "decav", letter = "s", folder = "salinity"),
  oxygen      = list(product = "all",   letter = "o", folder = "oxygen"),
  nitrate     = list(product = "all",   letter = "n", folder = "nitrate"),
  phosphate   = list(product = "all",   letter = "p", folder = "phosphate"),
  silicate    = list(product = "all",   letter = "i", folder = "silicate")
)

for (v in names(vars)) {
  dir.create(file.path(base_dir, vars[[v]]$folder), recursive = TRUE, showWarnings = FALSE)
}

woa_url <- function(var, tt) {
  cfg <- vars[[var]]
  sprintf(
    "%s/%s/csv/%s/1.00/woa18_%s_%s%02dmn01.csv.gz",
    base_url,
    cfg$folder,
    cfg$product,
    cfg$product,
    cfg$letter,
    tt
  )
}

woa_dest <- function(var, tt) {
  cfg <- vars[[var]]
  file.path(
    base_dir,
    cfg$folder,
    sprintf("woa18_%s_%s%02dmn01.csv.gz", cfg$product, cfg$letter, tt)
  )
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
  for (var in names(vars)) {
    fetch_one(
      url  = woa_url(var, tt),
      dest = woa_dest(var, tt)
    )
  }
}

message("Done.")
