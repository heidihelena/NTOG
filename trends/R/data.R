NORDIC_COUNTRIES <- c("Denmark", "Finland", "Iceland", "Norway", "Sweden")

RATE_LABELS <- c(
  "ASR (Nordic 2000)" = "asr_nordic_2000",
  "ASR (World)" = "asr_world",
  "ASR (European 1976)" = "asr_europe_1976",
  "ASR (European 2013)" = "asr_europe_2013",
  "Crude rate" = "crude_rate"
)

rate_label <- function(statistic) {
  label <- names(RATE_LABELS)[match(statistic, RATE_LABELS)]
  if (is.na(label)) {
    stop("Unsupported rate definition: ", statistic)
  }
  label
}

NORDCAN_TREND_URL <- paste0(
  "https://nordcan.iarc.fr/en/dataviz/trends?",
  "cancers=160&key=asr_n&populations=208_246_352_578_752&",
  "sexes=1_2&types=0_1&years=1960_2024"
)

REQUIRED_COLUMNS <- c(
  "country_code", "country", "sex_code", "sex", "measure_code", "measure",
  "year", "cancer_id", "cancer", "icd10", unname(RATE_LABELS), "count",
  "population", "unit", "standard_population", "source_version", "source_url",
  "retrieved_at"
)

load_trend_data <- function(path) {
  data <- readr::read_csv(
    path,
    col_types = readr::cols(
      country_code = readr::col_integer(),
      country = readr::col_character(),
      sex_code = readr::col_integer(),
      sex = readr::col_character(),
      measure_code = readr::col_integer(),
      measure = readr::col_character(),
      year = readr::col_integer(),
      cancer_id = readr::col_integer(),
      cancer = readr::col_character(),
      icd10 = readr::col_character(),
      asr_world = readr::col_double(),
      asr_europe_1976 = readr::col_double(),
      asr_europe_2013 = readr::col_double(),
      asr_nordic_2000 = readr::col_double(),
      crude_rate = readr::col_double(),
      count = readr::col_double(),
      population = readr::col_double(),
      unit = readr::col_character(),
      standard_population = readr::col_character(),
      source_version = readr::col_character(),
      source_url = readr::col_character(),
      retrieved_at = readr::col_date()
    )
  )

  validate_trend_data(data)
  data
}

validate_trend_data <- function(data) {
  missing <- setdiff(REQUIRED_COLUMNS, names(data))
  if (length(missing) > 0) {
    stop("Trend data is missing columns: ", paste(missing, collapse = ", "))
  }
  if (!all(unique(data$country) %in% NORDIC_COUNTRIES)) {
    stop("Trend data contains an unexpected country.")
  }
  if (!setequal(unique(data$sex), c("Male", "Female"))) {
    stop("Trend data must contain Male and Female series.")
  }
  if (!setequal(unique(data$measure), c("Incidence", "Mortality"))) {
    stop("Trend data must contain Incidence and Mortality series.")
  }
  if (!all(data$cancer_id == 160 & data$icd10 == "C33-C34")) {
    stop("Trend data contains an unexpected cancer definition.")
  }
  if (!all(data$unit == "per 100,000 person-years")) {
    stop("Trend data contains an unexpected unit.")
  }
  if (any(is.na(data[unname(RATE_LABELS)])) ||
      any(unlist(data[unname(RATE_LABELS)]) < 0)) {
    stop("Trend data contains a missing or negative rate.")
  }
  if (!all(grepl("^https://", data$source_url)) ||
      any(is.na(data$retrieved_at))) {
    stop("Trend data contains incomplete provenance.")
  }
  if (anyDuplicated(data[c("country", "sex", "measure", "year")])) {
    stop("Trend data contains duplicate observations.")
  }
  invisible(TRUE)
}

filter_trends <- function(
    data,
    measure,
    sex,
    countries,
    years,
    statistic = "asr_nordic_2000") {
  if (!statistic %in% unname(RATE_LABELS)) {
    stop("Unsupported rate definition: ", statistic)
  }

  data |>
    dplyr::filter(
      .data$measure == .env$measure,
      .data$sex == .env$sex,
      .data$country %in% .env$countries,
      dplyr::between(.data$year, .env$years[[1]], .env$years[[2]])
    ) |>
    dplyr::mutate(
      rate = .data[[statistic]],
      rate_definition = rate_label(statistic),
      standard_population = standard_population_for(statistic)
    ) |>
    dplyr::filter(!is.na(.data$rate)) |>
    dplyr::arrange(.data$country, .data$year)
}

standard_population_for <- function(statistic) {
  switch(
    statistic,
    asr_nordic_2000 = "Nordic standard population 2000",
    asr_world = "World standard population",
    asr_europe_1976 = "European standard population 1976",
    asr_europe_2013 = "European standard population 2013",
    crude_rate = NA_character_,
    stop("Unsupported rate definition: ", statistic)
  )
}

rate_unit <- function(statistic) {
  if (identical(statistic, "crude_rate")) {
    "Crude rate per 100,000 person-years"
  } else {
    paste(rate_label(statistic), "per 100,000 person-years")
  }
}

latest_common_year <- function(data) {
  if (nrow(data) == 0) {
    return("—")
  }

  countries <- unique(data$country)
  counts <- data |>
    dplyr::distinct(.data$country, .data$year) |>
    dplyr::count(.data$year, name = "country_count")
  common <- counts$year[counts$country_count == length(countries)]

  if (length(common) == 0) "—" else max(common)
}

summarise_latest <- function(data) {
  if (nrow(data) == 0) {
    return(data.frame())
  }

  data |>
    dplyr::group_by(.data$country) |>
    dplyr::arrange(.data$year, .by_group = TRUE) |>
    dplyr::summarise(
      latest_year = dplyr::last(.data$year),
      latest_rate = dplyr::last(.data$rate),
      first_rate = dplyr::first(.data$rate),
      .groups = "drop"
    ) |>
    dplyr::mutate(
      year = .data$latest_year,
      rate = .data$latest_rate,
      change_pct = dplyr::if_else(
        .data$first_rate == 0,
        NA_real_,
        100 * (.data$latest_rate - .data$first_rate) / .data$first_rate
      )
    ) |>
    dplyr::select(
      "country",
      "year",
      "rate",
      "first_rate",
      "change_pct"
    ) |>
    dplyr::arrange(dplyr::desc(.data$rate))
}

format_change <- function(value) {
  dplyr::case_when(
    is.na(value) ~ "—",
    value > 0 ~ paste0("+", scales::number(value, accuracy = 0.1), "%"),
    TRUE ~ paste0(scales::number(value, accuracy = 0.1), "%")
  )
}
