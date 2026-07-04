# Bulimba Community Centre — Fundraising Intelligence Pipeline

A reproducible R pipeline (built with `targets` + `data.table`) that joins
ABS socio-demographic data to the ACNC charity register to identify
high-potential donor-outreach suburbs for a Brisbane not-for-profit.

## Data status: synthetic demo data (by design)

The data in `data/raw/` is **entirely synthetic** — realistic-looking numbers
generated to match the real ABS Census (G02) and ACNC schema, correlated
sensibly (higher SEIFA roughly tracks higher income), but not sourced from
any real dataset. This is a deliberate choice, not a placeholder you forgot
to swap out — treat it as a working prototype of the pipeline logic.

**How to talk about this honestly in the interview**, if asked:
"I built this as a prototype to demonstrate the pipeline logic and approach —
the R code, the targets orchestration, the data.table joins and segmentation
logic are all real and functional. I used synthetic data structured to match
the real ABS Census and ACNC schemas so I could build and test it quickly;
swapping in the live ABS/ACNC downloads is a mechanical next step, not a
redesign, since the column structure already matches what the real files
provide."

This is a legitimate and common way to prototype a data pipeline before
wiring up live sources — just don't describe the *findings* (e.g. "Bulimba
is a Priority 2 suburb") as if they reflect real donor potential, since
they don't yet.

If you do want to swap in real data later, the three real ABS files you'd
need are:

1. **`2021Census_G02_QLD_SAL.csv`** — ABS Census DataPacks → General
   Community Profile → Suburbs and Localities → G02. Real columns:
   `SAL_CODE_2021`, `Median_age_persons`, `Median_tot_hhd_inc_weekly`.
2. **`sal_suburb_lookup.csv`** — the geographic correspondence file from
   the same DataPack, giving `SAL_CODE_2021` → `SAL_NAME_2021`.
3. **`seifa_index_by_suburb.csv`** — from the separate SEIFA release:
   https://www.abs.gov.au/statistics/people/people-and-communities/socio-economic-indexes-areas-seifa-australia/latest-release

And real ACNC data for `acnc_sample.csv` from https://data.gov.au or
https://www.acnc.gov.au/charity-register.

Same file names, same column names — the pipeline needs no code changes.

## Requirements

- R (4.x)
- Packages: `targets`, `data.table`

```r
install.packages(c("targets", "data.table"))
```

## Project structure

```
bulimba_pipeline/
├── _targets.R              # pipeline definition (the dependency graph)
├── R/
│   └── functions.R         # load / join / segment / report functions
├── data/
│   ├── raw/                # input CSVs (replace with real ABS + ACNC data)
│   │   ├── 2021Census_G02_QLD_SAL.csv
│   │   ├── sal_suburb_lookup.csv
│   │   ├── seifa_index_by_suburb.csv
│   │   └── acnc_sample.csv
│   └── output/             # donor_segments.csv is written here
└── README.md
```

## Running it

```r
# from the project root, in R or RStudio
install.packages(c("targets", "data.table"))  # first time only
targets::tar_make()
```

This will:
1. Load the SEIFA and ACNC input files.
2. Join them by suburb.
3. Classify each suburb into a donor-outreach priority tier
   (Priority 1 / 2 / 3) based on income and socio-economic advantage.
4. Write the ranked result to `data/output/donor_segments.csv`.

To inspect the pipeline graph and see what depends on what:

```r
targets::tar_visnetwork()
```

To change a threshold and see targets only re-run what's affected, edit the
logic in `segment_donors()` in `R/functions.R`, save, and re-run
`tar_make()` — only `donor_segments` and `segment_report` will re-execute;
`seifa_dt` and `acnc_dt` are untouched since their inputs didn't change.

## Putting this on GitHub

```bash
cd bulimba_pipeline
git init
git add .
git commit -m "Initial fundraising intelligence pipeline for Bulimba Community Centre"
# create an empty repo on github.com first, then:
git remote add origin <your-repo-url>
git branch -M main
git push -u origin main
```

## Next steps to genuinely finish this project

1. Replace the sample CSVs with real ABS SEIFA and ACNC data (links above).
2. Tune the priority thresholds in `segment_donors()` against the real
   income/SEIFA distribution rather than the illustrative cutoffs here.
3. Optionally add a short `report.qmd` (Quarto) summarising the top suburbs
   in plain language, since that's the layer a coordinator would actually read.
4. Push to GitHub with a real commit history as you build it out —
   several small, honest commits look far better than one giant commit
   the night before an interview.
