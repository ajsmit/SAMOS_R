# SAMOS_R: course datasets

This folder contains datasets used in the teaching material.

## Structure

- `raw/` — raw downloads (not edited by hand)
- `processed/` — small, tidy tables used in Intro R / Basic Statistics

## Reproducibility

All datasets in `processed/` must be reproducible from scripts in:

- `admin/data_prep/`

For WOA18 (World Ocean Atlas 2018) monthly climatology subsets, run:

```bash
Rscript admin/data_prep/01_download_woa18_monthlies.R
Rscript admin/data_prep/02_build_woa18_sa_core_dataset.R
```

This creates:

- `processed/woa18_sa_core_1deg_monthly.csv`
- `processed/woa18_sa_core_1deg_monthly_PROVENANCE.md`
