# SAMOS_R data preparation (admin)

This folder contains **data-prep scripts** used to build the small, course-facing datasets in `data/SAMOS/`.

- These scripts are **not part of the teaching material** and are not referenced by any Quarto pages.
- They exist to make all downloaded/derived datasets **fully reproducible**.

## Quick start

From the **repo root** (`SAMOS_R/`):

```bash
# 1) (Optional) clean previous outputs
rm -rf data/SAMOS/raw/woa18
rm -f  data/SAMOS/processed/woa18_sa_core_1deg_monthly.csv

# 2) run the pipeline
Rscript admin/data_prep/01_download_woa18_monthlies.R
Rscript admin/data_prep/02_build_woa18_sa_core_dataset.R
```

## What gets created

Raw downloads (gzipped CSVs):

- `data/SAMOS/raw/woa18/temperature/woa18_decav_tTTmn01.csv.gz` (TT = 00 annual; 01..12 = Jan..Dec)
- `data/SAMOS/raw/woa18/salinity/woa18_decav_sTTmn01.csv.gz` (TT = 00 annual; 01..12 = Jan..Dec)

Processed “core dataset family” table (tidy long form):

- `data/SAMOS/processed/woa18_sa_core_1deg_monthly.csv`

This table is intended to be used repeatedly across Intro R chapters for:

- plotting (time/season, depth sections)
- faceting
- mapping (surface fields)
- tidy transformations

## Notes / caveats

- Source: NOAA NCEI World Ocean Atlas 2018 (WOA18), *decav* climatology, 1° grid, CSV exports.
- We download **monthly means** for the index level `00` files, which contain values at many standard depths.
- We then subset to a Southern Africa bounding box and a small set of teaching depths.

If NOAA changes URLs, update the base URL in `01_download_woa18_monthlies.R`.
