#!/usr/bin/env Rscript

# Build a Southern Africa WOA18 core dataset (tidy long form) from downloaded CSVs.
#
# Inputs (created by 01_download_woa18_monthlies.R):
#   data/SAMOS/raw/woa18/temperature/woa18_decav_tTTmn01.csv.gz
#   data/SAMOS/raw/woa18/salinity/woa18_decav_sTTmn01.csv.gz
#   data/SAMOS/raw/woa18/oxygen/woa18_all_oTTmn01.csv.gz
#   data/SAMOS/raw/woa18/nitrate/woa18_all_nTTmn01.csv.gz
#   data/SAMOS/raw/woa18/phosphate/woa18_all_pTTmn01.csv.gz
#   data/SAMOS/raw/woa18/silicate/woa18_all_iTTmn01.csv.gz
#
# Output:
#   data/SAMOS/processed/woa18_sa_core_1deg_monthly.csv

options(warn = 1)

suppressPackageStartupMessages({
  library(tidyverse)
  library(data.table)
})

raw_dir <- file.path("data", "SAMOS", "raw", "woa18")
out_dir <- file.path("data", "SAMOS", "processed")
out_file <- file.path(out_dir, "woa18_sa_core_1deg_monthly.csv")

dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# --- Teaching region / bounding box ---
# (Adjust as you like; these are conservative “Southern Africa + adjacent oceans”.)
# Longitudes in WOA CSV are -180..180.
bbox <- list(
  lon_min = 5,   # 5°E
  lon_max = 45,  # 45°E
  lat_min = -45, # 45°S
  lat_max = -5   # 5°S
)

# --- Teaching depths ---
# The WOA CSVs contain many standard depths in the header.
# For Intro R we keep a small set that supports surface + upper ocean stories.
teaching_depths_m <- c(0, 50, 100, 200, 500, 1000)

read_woa_csv_gz <- function(path) {
  # First two lines are comments: keep the 2nd line to parse depth columns.
  # Data rows: lat, lon, then values for each depth.
  con <- gzfile(path, open = "rt")
  header1 <- readLines(con, n = 1)
  header2 <- readLines(con, n = 1)
  close(con)

  # header2 ends with: ... VALUES AT DEPTHS (M):0,5,10,...
  depths_chr <- sub(".*DEPTHS \\(M\\):", "", header2)
  depths <- suppressWarnings(as.numeric(strsplit(depths_chr, ",", fixed = TRUE)[[1]]))

  # Now read the CSV body robustly (rows can have trailing missing values).
  # Using data.table::fread(fill=TRUE) prevents dropped columns.
  dat <- data.table::fread(
    cmd = paste("gzip -dc", shQuote(path)),
    skip = 2,
    header = FALSE,
    sep = ",",
    fill = Inf,
    showProgress = FALSE,
    na.strings = c("", "NA")
  ) |> as_tibble()

  if (ncol(dat) != (2 + length(depths))) {
    stop(
      "Unexpected column count in ", path, "\n",
      "Got: ", ncol(dat), "; expected: ", 2 + length(depths)
    )
  }

  colnames(dat) <- c("lat", "lon", paste0("d_", depths))

  list(
    meta = list(header1 = header1, header2 = header2, depths = depths),
    data = dat
  )
}

woa_to_long <- function(x, variable, unit, month) {
  x$data %>%
    filter(
      lon >= bbox$lon_min, lon <= bbox$lon_max,
      lat >= bbox$lat_min, lat <= bbox$lat_max
    ) %>%
    pivot_longer(
      cols = starts_with("d_"),
      names_to = "depth_m",
      values_to = "value"
    ) %>%
    mutate(
      depth_m = as.numeric(sub("^d_", "", depth_m)),
      month = month,
      variable = variable,
      unit = unit,
      source = "WOA18 decav 1.00° CSV"
    ) %>%
    filter(depth_m %in% teaching_depths_m)
}

vars <- tibble::tribble(
  ~folder,      ~prefix,       ~letter, ~variable,           ~unit,
  "temperature", "woa18_decav", "t",     "temperature",       "degC",
  "salinity",    "woa18_decav", "s",     "salinity",          "psu",
  "oxygen",      "woa18_all",   "o",     "dissolved_oxygen",  "umol/kg",
  "nitrate",     "woa18_all",   "n",     "nitrate",           "umol/kg",
  "phosphate",   "woa18_all",   "p",     "phosphate",         "umol/kg",
  "silicate",    "woa18_all",   "i",     "silicate",          "umol/kg"
)

path_for <- function(folder, prefix, letter, tt) {
  file.path(raw_dir, folder, sprintf("%s_%s%02dmn01.csv.gz", prefix, letter, tt))
}

read_one <- function(folder, prefix, letter, variable, unit, tt, month_label) {
  path <- path_for(folder, prefix, letter, tt)
  if (!file.exists(path)) stop("Missing: ", path)

  x <- read_woa_csv_gz(path)
  woa_to_long(x, variable = variable, unit = unit, month = month_label)
}

message("Building WOA18 Southern Africa core dataset…")

# We include annual as month=0, and Jan..Dec as 1..12
out <- tidyr::expand_grid(tt = c(0, 1:12), vars) %>%
  mutate(month_label = tt) %>%
  # pmap passes columns in order: tt, folder, prefix, letter, variable, unit, month_label
  pmap_dfr(~ read_one(..2, ..3, ..4, ..5, ..6, ..1, ..7)) %>%
  arrange(variable, month, depth_m, lat, lon)

readr::write_csv(out, out_file)
message("[ok] wrote ", out_file)

# Also emit a lightweight provenance file next to the output
prov_file <- file.path(out_dir, "woa18_sa_core_1deg_monthly_PROVENANCE.md")
pkg_ver <- function(pkg) as.character(utils::packageVersion(pkg))

writeLines(
  c(
    "# Provenance: WOA18 Southern Africa core dataset",
    "",
    paste0("Created: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
    paste0("R: ", R.version.string),
    paste0("Packages: tidyverse ", pkg_ver("tidyverse"), "; data.table ", pkg_ver("data.table")),
    "",
    "## Inputs",
    "- NOAA NCEI World Ocean Atlas 2018 (WOA18)",
    "- Product: decav climatology, 1.00° grid, monthly means",
    "- Temperature CSVs: woa18_decav_t00mnMM.csv.gz",
    "- Salinity CSVs: woa18_decav_s00mnMM.csv.gz",
    "",
    "## Scripts",
    "- admin/data_prep/01_download_woa18_monthlies.R",
    "- admin/data_prep/02_build_woa18_sa_core_dataset.R",
    "",
    "## Spatial subset",
    paste0("- lon ∈ [", bbox$lon_min, ", ", bbox$lon_max, "] (degrees East; WOA uses -180..180)"),
    paste0("- lat ∈ [", bbox$lat_min, ", ", bbox$lat_max, "] (degrees North; negatives are South)"),
    "",
    "## Depth subset (m)",
    paste0("- ", paste(teaching_depths_m, collapse = ", ")),
    "",
    "## Output",
    "- data/SAMOS/processed/woa18_sa_core_1deg_monthly.csv",
    "",
    "## Notes",
    "- Values are stored in tidy long form with columns: lon, lat, depth_m, month, variable, value, unit, source.",
    "- This is intended for teaching examples; it is not a replacement for full-resolution workflows."
  ),
  con = prov_file
)
message("[ok] wrote ", prov_file)
