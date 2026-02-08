# SAMOS‑R upgrade report (Intro R first)

Date: 2026‑02‑08  
Local site folder: `SAMOS_R/`

## Goal
Replace biology‑centric examples in **Intro R** and **Tasks A–D** with examples that make immediate sense to oceanographers across **biological, chemical, and physical** sub‑disciplines, while keeping:

1. The same learning outcomes (R basics → data structures → workflows → plotting → mapping → tidy data).
2. The same technical complexity (avoid heavy netCDF until students are ready).
3. Reproducibility and low friction (fast downloads, stable sources, cached local files).

This report is deliberately **itemised** so changes can be implemented one by one.

---

## A. Data strategy (recommended before editing any teaching text)

### A1) Adopt a “core dataset family” used repeatedly across chapters
A recurring dataset reduces cognitive load and helps students see continuity.

**Recommendation:** Build a small, curated set of oceanography datasets (CSV/Parquet) in `SAMOS_R/data/SAMOS/` derived from open sources. Use them repeatedly in Intro R.

Proposed dataset set (small, tidy tables):

1. **WOA climatology extracts (physical + chemical)**
   - Variables: temperature, salinity, dissolved oxygen, nitrate, phosphate, silicate.
   - Dimensions: `lon`, `lat`, `depth_m`, `month` (or season), `value`, `variable`, `unit`.
   - Source: World Ocean Atlas (NOAA NCEI).
   - Pedagogy: perfect for grouping, faceting, and spatial plots.

2. **Argo profiles (physical)**
   - Variables: pressure/depth, temperature, salinity, profile id, float id, time, position.
   - Source: Argo GDAC (access via ERDDAP is easiest).
   - Pedagogy: time series, vertical profiles, “tidy” reshaping (profile ↔ long).

3. **Bottle / nutrient transect (chemical + biological)**
   - If no easy API: include a *small, course‑owned* dataset (e.g., a few CTD stations + nutrients + chlorophyll).
   - Pedagogy: repeated‑measures structure, missing values, QC flags.

4. **Satellite SST subset (physical)**
   - Optional for later: a pre‑downloaded subset for the Benguela/Agulhas region (daily or weekly), stored as tidy table.

**Implementation note:** For Intro R, prefer CSV/tibble. NetCDF can appear later as an “advanced data formats” aside.

### A2) Provide a single helper script to fetch/cache datasets
**Recommendation:** add `scripts/data_fetch_introR.R` that:

- downloads (or queries ERDDAP),
- saves into `data/SAMOS/` with date‑stamped filenames,
- writes a small `data/SAMOS/README.md` describing provenance.

This keeps Quarto pages clean and makes the site render reliably (no heavy API calls during render).

### A3) R packages to standardise on for ocean data
Keep dependencies minimal in Intro R.

- Core: `tidyverse`, `lubridate`, `here`
- For maps: `sf`, `rnaturalearth`, `ggspatial`
- For ocean data access (optional): `rerddap` (ERDDAP), `oce` (profiles), `tidync`/`ncdf4` (later)

---

## B. Intro R chapters: replace biology‑centric examples with oceanography

Below I list the key files in `intro_r/` and concrete replacement ideas.

### B1) `intro_r/01-RStudio.qmd` (RStudio basics)
**Keep mostly as is**, but change screenshots/mini examples to ocean context.

1. Replace any “biology lab / species” language in quick examples with:
   - station names, cruise ids, mooring ids, float ids.
2. Add a one‑paragraph motivation: “Ocean data are multi‑dimensional (space × depth × time) so reproducible workflows matter.”

### B2) `intro_r/02-working-with-data.qmd` (files, formats, reproducibility)
This chapter already mentions NetCDF/GRIB/HDF—good for oceanographers.

**Recommendations:**

1. Replace biology examples in file paths:
   - from `kelp.csv` → `woa_temp_subset.csv` or `argo_profiles_subset.csv`.
2. In the “Types of data files” section, add a short ocean‑specific note:
   - CSV good for analysis extracts; NetCDF for gridded/climatology; QC flags matter.
3. Replace the Excel exercise dataset columns (`species`, `site`, `temp_C`, …) with ocean‑relevant columns:
   - `station_id`, `datetime_utc`, `lat`, `lon`, `depth_m`, `temp_C`, `sal_psu`, `oxygen_umolkg`, `notes`.
   - Keep the deliberate “commas/semicolons in notes” pitfall.

### B3) `intro_r/04-data-in-R.qmd` (data classes/structures)
This is the most biology‑specific in the narrative (explicit “biostatistician/biologists”).

**Recommendations (itemised):**

1. Replace section title text “Types of Variables Common in Biology and Ecology” with “Types of Variables Common in Ocean Science”.
2. Replace examples:
   - `ChickWeight`, “rats in drains”, vegetation types →
     - **physical:** SST, salinity, mixed layer depth
     - **chemical:** nitrate, oxygen, pH
     - **biological:** chlorophyll‑a, plankton counts
3. Replace the discrete/continuous examples:
   - Discrete: number of profiles per float per month; number of stations per cruise.
   - Continuous: temperature/salinity/oxygen.
4. For factors/nominal variables:
   - `basin` (Atlantic/Indian/Southern), `water_mass` (AAIW, NADW), `platform` (CTD/Argo/Mooring/Satellite).
5. For logical variables:
   - QC pass/fail, “is_coastal”, “is_upwelling_season”.

### B4) `intro_r/06-graphics.qmd` (ggplot2)
Currently uses `ChickWeight` (fine pedagogically, wrong domain).

**Recommendations:**

1. Replace `ChickWeight` with an **ocean time series** dataset.
   - Minimal friction: include a small built dataset like `sst_monthly_sa_coast` (CSV) or use `rerddap` cached output.
2. Keep the same teaching arc:
   - scatter/lines, grouping, colour mapping, `geom_smooth(lm)`.
3. Suggested worked example:
   - `ggplot(sst, aes(date, temp_C)) + geom_line(aes(group=site))`
   - Colour by `site` or `region`, smooth by `lm` or `loess`.
4. Replace the “If you were a chicken…” punchline with something ocean‑relevant:
   - “If you were planning a sampling cruise, which month minimises sea‑state risk?” (if using wind/wave)
   - or “Which region warms fastest?”

### B5) `intro_r/07-faceting.qmd` and `intro_r/08-brewing.qmd`
**Recommendation:** shift faceting examples to:

1. WOA climatology: facet by `month` or `season` and by `depth_m` bands.
2. Argo: facet by float id or by basin.
3. Brewer palettes: use bathymetry/SST colour scales, and explicitly discuss **perceptual uniformity** and colourblind safety.

### B6) Mapping sequence (`09-mapping.qmd`, `10-mapping_style.qmd`, `11-mapping_rnaturalearth.qmd`)
Mapping is already region‑appropriate (Southern Africa). What’s missing is a distinctly ocean data layer.

**Recommendations:**

1. Add an ocean data overlay in at least one mapping chapter:
   - Argo float positions (points) in the Agulhas/Benguela region.
   - or WOA surface temperature contours/tiles (coarse grid) + coastlines.
2. Replace “South Africa provincial capitals” exercise with:
   - major ports/research facilities (Cape Town, Gqeberha, Durban, Walvis Bay, Maputo)
   - or oceanographic features (Agulhas Current core line, Benguela upwelling cells—if you can justify coordinates).

### B7) `intro_r/12-mapping_quakes.qmd` (Fiji earthquakes)
This is visually nice, but domain‑mismatched.

**Recommendation:** replace with one of:

1. **Drifter tracks** (surface currents) for a week/month; map as paths.
2. **Ship track** + station casts (CTD) as points; label station numbers.
3. **Argo trajectories** (float positions over time), with colour mapped to time.

### B8) Tidy data trilogy (`13-tidy.qmd`, `14-tidier.qmd`, `15-tidiest.qmd`)
Currently uses `SACTN` temperature time series (already ocean‑adjacent). Strengthen this.

**Recommendations:**

1. Keep `SACTN` (great local relevance), but explicitly frame it as:
   - different “data sources/platforms” (DEA/SAWS/KZNSB) with QC issues.
2. Add one worked example that demonstrates:
   - wide → long for **multiple variables** (temp + salinity + oxygen), not just multiple sources.

---

## C. Tasks A–D: new oceanography‑targeted questions + worked examples

### C1) Task A (`tasks/BCB744_Task_A.qmd`): R/RStudio + basics + file handling
Currently heavily generic/biostats phrasing.

**Replace/extend with ocean context (itemised):**

1. Keep Q1 (R vs RStudio), but adjust exemplar Methods text to ocean science.
2. Add a question on **units** and **metadata** (critical in oceanography):
   - e.g., “Why must you report units and reference scales (ITS‑90, PSS‑78)?”
3. Replace toy variables `mass`, `age` with:
   - `temp_C`, `sal_psu`, `oxygen_umolkg` and compute a simple index (e.g., density proxy isn’t appropriate without teaching—so keep arithmetic like anomalies: `temp_anom = temp - mean(temp)`.)
4. Replace the “crops.xlsx” workflow with an ocean dataset:
   - `ctd_casts.xlsx` → export CSV → read → inspect → write `ctd_casts_clean.csv`.

**New worked example suggestion (short):**
- Read a small `woa_surface_sa.csv`, compute monthly mean SST by region.

### C2) Task B (`tasks/BCB744_Task_B.qmd`): ggplot + faceting + palettes
Currently uses `palmerpenguins` and `ToothGrowth`.

**Recommendation:** replace datasets with ocean equivalents:

1. Scatterplots:
   - Temperature vs salinity (classic T–S diagram) coloured by depth bin or water mass label.
2. Histograms + boxplots:
   - surface nitrate by season; chlorophyll by region.
3. Faceting:
   - facet by `season` and `basin` (or `region`).
4. “Best‑fit straight line”:
   - oxygen vs temperature (with clear caveat: correlation ≠ causation).
5. Replace `ToothGrowth` with:
   - a small “incubation experiment” dataset (biology) OR “carbonate chemistry” dataset (chem) OR “wind vs upwelling index” dataset (physics).

**Concrete new questions (keep same structure/marks):**

- Q1: “Create a scatterplot of `sal_psu` vs `temp_C` for profiles in the Agulhas region at 0–200 m.”
- Q2: “Create histograms of `temp_C` by season; save each plot object; combine with a boxplot by region.”
- Q3: “Plot `oxygen_umolkg` vs `temp_C`, facet by region, shape by platform (CTD/Argo), colour by depth.”
- Q7 replacement: “Use built‑in dataset X” → instead provide `samos_ts_demo` in `data/` so it’s deterministic.

### C3) Task C (`tasks/BCB744_Task_C.qmd`): mapping style
This is already mostly geographic/cartographic. Add ocean data layers.

**Recommendations:**

1. Keep the base map styling exercise.
2. Replace province capitals with:
   - ports + research hubs, or
   - mooring locations, or
   - MPA boundaries (if easily sourced).
3. Add one question requiring students to plot:
   - Argo float locations with labels for float id, or
   - stations from a cruise transect.

### C4) Task D (`tasks/BCB744_Task_D.qmd`): tidy data
Not reviewed in detail here (but the theme is clear).

**Recommendations:**

1. Use a dataset that is *meaningfully untidy* in a way oceanographers recognise:
   - profiles with variables in columns, depths in rows, QC flags in separate columns.
2. New worked example:
   - `pivot_longer()` to put `temp`, `sal`, `oxygen` into `variable/value`, then facet by `variable`.
3. New questions:
   - identify missingness by platform, season, depth bin.

---

## D. World Ocean Atlas (WOA) integration (practical suggestions)

WOA is an excellent anchor dataset, but direct netCDF ingestion can be heavy for Intro R.

### D1) Recommended approach
1. Pre‑extract a **regional subset** (Southern Africa + adjacent oceans) at a few depths (0, 50, 100, 200, 500 m) and monthly climatology.
2. Store as tidy CSV in `data/SAMOS/woa_sa_clim.csv`.
3. Provide a short appendix (or later lecture) showing how it was extracted from netCDF (for advanced students).

### D2) Suggested columns (tidy long form)
- `lon`, `lat`, `month`, `depth_m`, `variable`, `value`, `unit`, `source`

---

## E. Editing checklist (implementation order)

To make this tractable, implement in the following order:

1. **Create datasets + cache script** (`data/SAMOS/*`, `scripts/data_fetch_introR.R`).
2. Update `intro_r/06-graphics.qmd` first (highest visibility; quick win).
3. Update Task B next (largest student workload; biggest alignment gain).
4. Update mapping exercises to include an ocean layer (Task C + mapping chapters).
5. Update `intro_r/04-data-in-R.qmd` narrative language and examples.
6. Update Task A to match new datasets and ocean‑science reporting norms.
7. Replace the earthquakes vignette with drifters/Argo trajectories.
8. Finally, revisit tidy chapters/tasks to ensure the new datasets are used consistently.

---

## F. Notes on “Basic Statistics” (next phase)
Once Intro R is updated, the same dataset family should feed into Basic Statistics:

- t‑tests/ANOVA: compare `chlorophyll` by region/season; or nitrate by shelf/offshore.
- regression/correlation: SST vs wind; oxygen vs temperature; carefully framed.

(We will address this after Intro R is complete.)
