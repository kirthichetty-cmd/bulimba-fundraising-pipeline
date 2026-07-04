# Bulimba Community Centre — Fundraising Intelligence Pipeline

A reproducible R pipeline (built with targets + data.table) that joins
ABS socio-demographic data to the ACNC charity register to identify
high-potential donor-outreach suburbs for a Brisbane not-for-profit.

## Overview

Small not-for-profits often lack the data infrastructure to target
fundraising outreach effectively. This pipeline profiles suburbs by
combining ABS Census socio-demographic indicators (median income, age,
SEIFA index of socio-economic advantage) with ACNC charity register data,
and classifies each suburb into a donor-outreach priority tier.

## Data

data/raw/ contains sample data structured to match the real ABS Census
(G02 — Selected Medians and Averages) and ACNC Charity Register schemas,
for demonstration purposes. To run this against real data:

1. 2021Census_G02_QLD_SAL.csv — ABS Census DataPacks -> General
   Community Profile -> Suburbs and Localities -> G02. Columns:
   SAL_CODE_2021, Median_age_persons, Median_tot_hhd_inc_weekly.
2. sal_suburb_lookup.csv — the geographic correspondence file from
   the same DataPack, giving SAL_CODE_2021 -> SAL_NAME_2021.
3. seifa_index_by_suburb.csv — from the ABS SEIFA release:
   https://www.abs.gov.au/statistics/people/people-and-communities/socio-economic-indexes-areas-seifa-australia/latest-release
4. acnc_sample.csv — ACNC Charity Register data from
   https://data.gov.au or https://www.acnc.gov.au/charity-register,
   aggregated to suburb, charity_count, total_registered_charitie