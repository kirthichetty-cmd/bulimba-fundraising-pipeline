# Bulimba Community Centre — Fundraising Intelligence Pipeline

A reproducible R pipeline (built with `targets` + `data.table`) that joins
ABS socio-demographic data to the ACNC charity register to identify
high-potential donor-outreach suburbs for a Brisbane not-for-profit.

## Overview

Small not-for-profits often lack the data infrastructure to target
fundraising outreach effectively. This pipeline profiles suburbs by
combining ABS Census socio-demographic indicators (median income, age,
SEIFA index of socio-economic advantage) with ACNC charity register data,
and classifies each suburb into a donor-outreach priority tier.

## Data

`data/raw/` contains sample data structured to match the real ABS Census
(G02 — Selected Medians and Averages) and ACNC Charity Register schemas,
for demonstration purposes. To run this against real data:

1. `2021Census_G02_QLD_SAL.csv` — ABS Census DataPacks -> General
   Community Profile -> Suburbs and Localities -> G02. Columns:
   SAL_CODE_2021, Median_age_persons, Median_tot_hhd_inc_weekly.
2. `sal_suburb_lookup.csv` — the geographic correspondence file from
   the same DataPack, giving SAL_CODE_2021 -> SAL_NAME_2021.
3. `seifa_index_by_suburb.csv` — from the ABS SEIFA release:
   https://www.abs.gov.au/statistics/people/people-and-communities/socio-economic-indexes-areas-seifa-australia/latest-release
4. `acnc_sample.csv` — ACNC Charity Register data from
   https://data.gov.au or https://www.acnc.gov.au/charity-register,
   aggregated to suburb, charity_count, total_registered_charities_income.

Same file names and column names as the samples — no code changes needed.

## Requirements

- R (4.x)
- Packages: targets, data.table

install.packages(c("targets", "data.table"))

## Project structure

bulimba_pipeline/
├── _targets.R              # pipeline definition (the dependency graph)
├── R/
│   └── functions.R         # load / join / segment / report functions
├── data/
│   ├── raw/                # input CSVs
│   └── output/             # donor_segments.csv is written here
└── README.md

## Running it

install.packages(c("targets", "data.table"))  # first time only
targets::tar_make()

This will:
1. Load the Census, SEIFA, and ACNC input files.
2. Join them by suburb.
3. Classify each suburb into a donor-outreach priority tier
   (Priority 1 / 2 / 3) based on income and socio-economic advantage.
4. Write the ranked result to data/output/donor_segments.csv.

To inspect the pipeline graph:

targets::tar_visnetwork()

