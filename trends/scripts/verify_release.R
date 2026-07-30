#!/usr/bin/env Rscript

source("R/release.R")
source("R/data.R")
source("R/context.R")

manifest <- load_release_manifest()
nordcan <- load_trend_data(
  release_dataset(manifest, "nordcan_lung_trends")$path
)
who <- load_who_context(
  release_dataset(manifest, "who_gho_tobacco_use")$path
)
eurostat <- load_eurostat_context(
  release_dataset(manifest, "eurostat_lung_mortality")$path
)

stopifnot(
  nrow(nordcan) == release_dataset(manifest, "nordcan_lung_trends")$rows,
  nrow(who) == release_dataset(manifest, "who_gho_tobacco_use")$rows,
  nrow(eurostat) == release_dataset(manifest, "eurostat_lung_mortality")$rows
)

message("Verified ", release_label(manifest))
