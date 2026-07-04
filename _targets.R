library(targets)

tar_option_set(packages = c("data.table"))

source("R/functions.R")

list(
  # --- Inputs (tracked as files, so the pipeline reruns if the data changes) ---
  tar_target(census_g02_file, "data/raw/2021Census_G02_QLD_SAL.csv", format = "file"),
  tar_target(suburb_lookup_file, "data/raw/sal_suburb_lookup.csv", format = "file"),
  tar_target(seifa_file, "data/raw/seifa_index_by_suburb.csv", format = "file"),
  tar_target(acnc_file, "data/raw/acnc_sample.csv", format = "file"),

  # --- Load + assemble the socio-demographic dataset ---
  tar_target(seifa_dt, load_seifa(census_g02_file, suburb_lookup_file, seifa_file)),
  tar_target(acnc_dt, load_acnc(acnc_file)),

  # --- Join ABS-style socio-demographic data to ACNC-style charity register data ---
  tar_target(joined_dt, join_datasets(seifa_dt, acnc_dt)),

  # --- Segment suburbs into donor-outreach priority tiers ---
  tar_target(donor_segments, segment_donors(joined_dt)),

  # --- Write the final report the charity would actually use ---
  tar_target(segment_report, write_segment_report(donor_segments), format = "file")
)
