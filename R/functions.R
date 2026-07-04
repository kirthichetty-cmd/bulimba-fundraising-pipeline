#' Load ABS Census G02 (Selected Medians and Averages) data by suburb (SAL),
#' joined to a code->name lookup, plus the separate SEIFA release.
#'
#' Expected raw ABS column names (from 2021Census_G02_..._SAL.csv):
#'   SAL_CODE_2021, Median_age_persons, Median_tot_hhd_inc_weekly
#' Expected suburb lookup columns (from the geographic descriptions /
#' correspondence file in the same DataPack):
#'   SAL_CODE_2021, SAL_NAME_2021
#' Expected SEIFA columns (from the separate SEIFA SA2/SAL release):
#'   suburb, seifa_index
#'
#' This function renames everything down to the clean schema the rest of the
#' pipeline expects: suburb, median_income (annual), seifa_index, median_age.
load_seifa <- function(census_g02_path, suburb_lookup_path, seifa_path) {
  g02 <- data.table::fread(census_g02_path)
  lookup <- data.table::fread(suburb_lookup_path)
  seifa <- data.table::fread(seifa_path)

  g02 <- merge(g02, lookup, by = "SAL_CODE_2021")

  dt <- g02[, .(
    suburb = trimws(SAL_NAME_2021),
    median_age = Median_age_persons,
    median_income = Median_tot_hhd_inc_weekly * 52  # weekly -> annual
  )]

  seifa[, suburb := trimws(suburb)]
  dt <- merge(dt, seifa[, .(suburb, seifa_index)], by = "suburb", all.x = TRUE)
  dt
}

#' Load ACNC-style charity register summary data by suburb.
#' Expected columns: suburb, charity_count, total_registered_charities_income.
#'
#' Source (real data): ACNC Charity Register --
#' https://www.acnc.gov.au/charity-register or the Data.gov.au ACNC dataset.
load_acnc <- function(path) {
  dt <- data.table::fread(path)
  dt[, suburb := trimws(suburb)]
  dt
}

#' Join the two datasets on suburb.
join_datasets <- function(seifa_dt, acnc_dt) {
  merge(seifa_dt, acnc_dt, by = "suburb", all.x = TRUE)
}

#' Segment suburbs into donor-outreach priority tiers based on income and
#' socio-economic advantage (SEIFA index). Thresholds are illustrative --
#' tune these against real distribution once real data is loaded.
segment_donors <- function(dt) {
  dt <- data.table::copy(dt)

  dt[, income_band := data.table::fifelse(
    median_income >= 90000, "High",
    data.table::fifelse(median_income >= 65000, "Medium", "Lower")
  )]

  dt[, donor_priority := data.table::fifelse(
    income_band == "High" & seifa_index >= 1000, "Priority 1 - lead with these suburbs",
    data.table::fifelse(
      income_band %in% c("High", "Medium") & seifa_index >= 950,
      "Priority 2 - secondary outreach",
      "Priority 3 - lower expected yield"
    )
  )]

  data.table::setorder(dt, -seifa_index)
  dt
}

#' Write the final donor-segment report to disk as a CSV a coordinator could
#' open directly in Excel.
write_segment_report <- function(dt) {
  out_path <- "data/output/donor_segments.csv"
  dir.create(dirname(out_path), showWarnings = FALSE, recursive = TRUE)
  data.table::fwrite(dt, out_path)
  out_path
}
