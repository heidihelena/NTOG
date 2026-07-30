WHO_CONTEXT_COLUMNS <- c(
  "country_code", "country", "sex_code", "sex", "year", "value",
  "lower_bound", "upper_bound", "status", "note", "updated_at"
)

EUROSTAT_CONTEXT_COLUMNS <- c(
  "country_code", "country", "sex_code", "sex", "year", "value",
  "status_flag", "note", "updated_at"
)

load_who_context <- function(path) {
  data <- readr::read_csv(
    path,
    col_types = readr::cols(
      country_code = readr::col_character(),
      country = readr::col_character(),
      sex_code = readr::col_character(),
      sex = readr::col_character(),
      year = readr::col_integer(),
      value = readr::col_double(),
      lower_bound = readr::col_double(),
      upper_bound = readr::col_double(),
      status = readr::col_character(),
      note = readr::col_character(),
      updated_at = readr::col_character()
    ),
    na = c("", "NA"),
    show_col_types = FALSE
  )
  validate_who_context(data)
  data
}

validate_who_context <- function(data) {
  validate_context_scope(data, WHO_CONTEXT_COLUMNS)
  if (!all(data$status %in% c("modelled_estimate", "projected"))) {
    stop("WHO context contains an unsupported estimate status.")
  }
  if (any(data$lower_bound > data$value) || any(data$value > data$upper_bound)) {
    stop("WHO context estimate is outside its uncertainty interval.")
  }
  if (any(data$year < 2000 | data$year > 2025)) {
    stop("WHO context contains an unexpected year.")
  }
  invisible(TRUE)
}

load_eurostat_context <- function(path) {
  data <- readr::read_csv(
    path,
    col_types = readr::cols(
      country_code = readr::col_character(),
      country = readr::col_character(),
      sex_code = readr::col_character(),
      sex = readr::col_character(),
      year = readr::col_integer(),
      value = readr::col_double(),
      status_flag = readr::col_character(),
      note = readr::col_character(),
      updated_at = readr::col_character()
    ),
    na = c("", "NA"),
    show_col_types = FALSE
  )
  validate_eurostat_context(data)
  data
}

validate_eurostat_context <- function(data) {
  validate_context_scope(data, EUROSTAT_CONTEXT_COLUMNS)
  if (any(data$year < 2011 | data$year > 2023)) {
    stop("Eurostat context contains an unexpected year.")
  }
  invisible(TRUE)
}

validate_context_scope <- function(data, required_columns) {
  missing <- setdiff(required_columns, names(data))
  if (length(missing) > 0) {
    stop("Context data is missing columns: ", paste(missing, collapse = ", "))
  }
  if (!setequal(unique(data$country), NORDIC_COUNTRIES)) {
    stop("Context data contains an unexpected country scope.")
  }
  if (!setequal(unique(data$sex), c("female", "male", "all"))) {
    stop("Context data must contain female, male and all-sex series.")
  }
  if (any(is.na(data$value)) || any(data$value < 0)) {
    stop("Context data contains a missing or negative value.")
  }
  if (anyDuplicated(data[c("country", "sex", "year")])) {
    stop("Context data contains duplicate country-sex-year observations.")
  }
  if (any(is.na(data$updated_at))) {
    stop("Context data is missing source update metadata.")
  }
  invisible(TRUE)
}

context_sex <- function(sex) {
  match <- c(Female = "female", Male = "male", All = "all")[[sex]]
  if (is.null(match)) {
    stop("Unsupported context sex: ", sex)
  }
  match
}

filter_who_context <- function(data, sex, countries, years) {
  data |>
    dplyr::filter(
      .data$sex == context_sex(.env$sex),
      .data$country %in% .env$countries,
      dplyr::between(.data$year, .env$years[[1]], .env$years[[2]])
    ) |>
    dplyr::arrange(.data$country, .data$year)
}

filter_eurostat_context <- function(data, sex, countries, years) {
  data |>
    dplyr::filter(
      .data$sex == context_sex(.env$sex),
      .data$country %in% .env$countries,
      dplyr::between(.data$year, .env$years[[1]], .env$years[[2]])
    ) |>
    dplyr::arrange(.data$country, .data$year)
}

latest_context <- function(data) {
  data |>
    dplyr::group_by(.data$country, .data$sex) |>
    dplyr::slice_max(.data$year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::arrange(.data$country, .data$sex)
}

compare_mortality_sources <- function(
    trend_data,
    eurostat_data,
    sex,
    countries,
    years) {
  nordcan <- filter_trends(
    trend_data,
    measure = "Mortality",
    sex = sex,
    countries = countries,
    years = years,
    statistic = "asr_europe_2013"
  ) |>
    dplyr::select(
      "country",
      "sex",
      "year",
      nordcan_rate = "rate"
    )

  eurostat <- filter_eurostat_context(
    eurostat_data,
    sex = sex,
    countries = countries,
    years = years
  ) |>
    dplyr::mutate(
      sex = dplyr::recode(
        .data$sex,
        female = "Female",
        male = "Male",
        all = "All"
      )
    ) |>
    dplyr::select(
      "country",
      "sex",
      "year",
      eurostat_rate = "value"
    )

  dplyr::inner_join(
    nordcan,
    eurostat,
    by = c("country", "sex", "year")
  ) |>
    dplyr::mutate(
      difference = .data$eurostat_rate - .data$nordcan_rate,
      difference_pct = 100 * .data$difference / .data$nordcan_rate
    ) |>
    dplyr::group_by(.data$country) |>
    dplyr::slice_max(.data$year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::arrange(.data$country)
}
