# Data dictionary: `woa18_sa_core_1deg_monthly.csv`

A small, tidy subset of **World Ocean Atlas 2018 (WOA18)** climatologies for the broader Southern Africa region.

## File

- `data/SAMOS/processed/woa18_sa_core_1deg_monthly.csv`

## Source

- NOAA NCEI World Ocean Atlas 2018 (WOA18)
- Gridded climatology at **1.00°** resolution
- Annual + monthly mean fields

## Rows

Each row is one value for a given:

- grid cell (`lon`, `lat`)
- depth (`depth_m`)
- time-slice (`month`)
- variable (`variable`)

## Columns

- `lon` (numeric)
  - Longitude in degrees East (WOA convention is -180..180).

- `lat` (numeric)
  - Latitude in degrees North (negative = South).

- `depth_m` (numeric)
  - Standard WOA depth level in metres.

- `month` (integer)
  - `0` = annual climatology
  - `1..12` = January..December climatology

- `variable` (character)
  - One of:
    - `temperature`
    - `salinity`
    - `dissolved_oxygen`
    - `nitrate`
    - `phosphate`
    - `silicate`

- `value` (numeric)
  - The climatological mean value.

- `unit` (character)
  - `degC` for temperature
  - `psu` for salinity (practical salinity; unitless in strict SI, but commonly reported as PSU)
  - `umol/kg` for oxygen and nutrients

- `source` (character)
  - Short provenance string.

## Notes for teaching

- This is a **teaching extract** designed to be fast to load and easy to plot.
- WOA values are climatological means. They are not synoptic observations.
- Oxygen/nutrients have strong structure with depth and region; expect non-linear patterns.
