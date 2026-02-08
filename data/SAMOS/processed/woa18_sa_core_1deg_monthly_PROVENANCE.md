# Provenance: WOA18 Southern Africa core dataset

Created: 2026-02-08 06:31:51 SAST

## Inputs
- NOAA NCEI World Ocean Atlas 2018 (WOA18)
- Product: decav climatology, 1.00° grid, monthly means
- Temperature CSVs: woa18_decav_t00mnMM.csv.gz
- Salinity CSVs: woa18_decav_s00mnMM.csv.gz

## Scripts
- admin/data_prep/01_download_woa18_monthlies.R
- admin/data_prep/02_build_woa18_sa_core_dataset.R

## Spatial subset
- lon ∈ [5, 45] (degrees East; WOA uses -180..180)
- lat ∈ [-45, -5] (degrees North; negatives are South)

## Depth subset (m)
- 0, 50, 100, 200, 500, 1000

## Output
- data/SAMOS/processed/woa18_sa_core_1deg_monthly.csv

## Notes
- Values are stored in tidy long form with columns: lon, lat, depth_m, month, variable, value, unit, source.
- This is intended for teaching examples; it is not a replacement for full-resolution workflows.
