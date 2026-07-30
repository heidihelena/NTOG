#!/usr/bin/env Rscript

suppressPackageStartupMessages({
  library(dplyr)
  library(jsonlite)
  library(readr)
})

api_url <- paste0(
  "https://gco-api.iarc.fr/api/nordcan/v2/96/data/population/",
  "0_1/1_2/208_246_352_578_752/160/",
  "?ages_group=0_17&year_start=1960&year_end=2024"
)

source_url <- paste0(
  "https://nordcan.iarc.fr/en/dataviz/trends?",
  "cancers=160&key=asr_n&populations=208_246_352_578_752&",
  "sexes=1_2&types=0_1&years=1960_2024"
)

args <- commandArgs(trailingOnly = TRUE)
output_path <- if (length(args) >= 1) {
  args[[1]]
} else {
  "data/nordcan_lung_trends_9_6.csv"
}

payload <- jsonlite::fromJSON(api_url, simplifyDataFrame = TRUE)

if (length(payload$error) > 0) {
  stop("NORDCAN returned an error: ", paste(payload$error, collapse = "; "))
}

data <- payload$dataset |>
  as_tibble() |>
  transmute(
    country_code = .data$country,
    country = .data$label,
    sex_code = .data$sex,
    sex = recode(as.character(.data$sex), `1` = "Male", `2` = "Female"),
    measure_code = .data$type,
    measure = recode(as.character(.data$type), `0` = "Incidence", `1` = "Mortality"),
    year = .data$year,
    cancer_id = .data$cancer,
    cancer = "Lung",
    icd10 = "C33-C34",
    asr_world = .data$asr,
    asr_europe_1976 = .data$asr_e,
    asr_europe_2013 = .data$asr_e2013,
    asr_nordic_2000 = .data$asr_n,
    crude_rate = .data$crude_rate,
    count = .data$total,
    population = .data$total_pop,
    unit = "per 100,000 person-years",
    standard_population = "Multiple rate definitions; see rate columns",
    source_version = "NORDCAN 9.6 (30 June 2026)",
    source_url = source_url,
    retrieved_at = as.Date("2026-07-30")
  ) |>
  arrange(.data$measure_code, .data$sex_code, .data$country_code, .data$year)

stopifnot(
  nrow(data) == 1298,
  setequal(unique(data$country), c("Denmark", "Finland", "Iceland", "Norway", "Sweden")),
  setequal(unique(data$sex), c("Male", "Female")),
  setequal(unique(data$measure), c("Incidence", "Mortality")),
  all(data$cancer_id == 160),
  !anyDuplicated(data[c("country", "sex", "measure", "year")])
)

dir.create(dirname(output_path), recursive = TRUE, showWarnings = FALSE)
write_csv(data, output_path, na = "")

message("Wrote ", nrow(data), " observations to ", output_path)
