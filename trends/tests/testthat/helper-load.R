library(dplyr)
library(ggplot2)
library(readr)
library(scales)

source("../../R/release.R")
source("../../R/data.R")
source("../../R/context.R")
source("../../R/analysis.R")
source("../../R/plot.R")
source("../../R/exports.R")

release_manifest <- load_release_manifest("../../data/release_manifest.json")
trend_data <- load_trend_data("../../data/nordcan_lung_trends_9_6.csv")
mir_cache <- build_mir_cache(trend_data)
who_context <- load_who_context("../../data/who_gho_tobacco_use_2026_01_15.csv")
eurostat_context <- load_eurostat_context(
  "../../data/eurostat_lung_mortality_2026_06_08.csv"
)
