index_trends <- function(data) {
  data |>
    dplyr::group_by(.data$country, .data$sex, .data$measure) |>
    dplyr::arrange(.data$year, .by_group = TRUE) |>
    dplyr::mutate(
      baseline_year = dplyr::first(.data$year),
      baseline_rate = dplyr::first(.data$rate),
      index = dplyr::if_else(
        .data$baseline_rate > 0,
        100 * .data$rate / .data$baseline_rate,
        NA_real_
      )
    ) |>
    dplyr::ungroup() |>
    dplyr::filter(is.finite(.data$index))
}

filter_both_sexes <- function(
    data,
    measure,
    country,
    years,
    statistic,
    mir_cache = NULL) {
  dplyr::bind_rows(lapply(
    c("Female", "Male"),
    function(sex) {
      filter_trends(
        data,
        measure = measure,
        sex = sex,
        countries = country,
        years = years,
        statistic = statistic,
        mir_cache = mir_cache
      )
    }
  )) |>
    dplyr::arrange(.data$sex, .data$year)
}

sex_gap_series <- function(data) {
  female <- data |>
    dplyr::filter(.data$sex == "Female") |>
    dplyr::select(
      "country",
      "year",
      female_rate = "rate"
    )
  male <- data |>
    dplyr::filter(.data$sex == "Male") |>
    dplyr::select(
      "country",
      "year",
      male_rate = "rate"
    )

  dplyr::inner_join(female, male, by = c("country", "year")) |>
    dplyr::mutate(
      difference = .data$female_rate - .data$male_rate,
      female_to_male_ratio = dplyr::if_else(
        .data$male_rate > 0,
        .data$female_rate / .data$male_rate,
        NA_real_
      )
    ) |>
    dplyr::arrange(.data$country, .data$year)
}

latest_sex_summary <- function(data) {
  data |>
    dplyr::group_by(.data$sex) |>
    dplyr::slice_max(.data$year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup() |>
    dplyr::select("sex", "year", "rate")
}
