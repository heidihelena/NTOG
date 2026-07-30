test_that("default mortality view is complete and provenance rich", {
  result <- filter_trends(
    trend_data,
    measure = "Mortality",
    sex = "Female",
    countries = NORDIC_COUNTRIES,
    years = c(1980, 2024),
    statistic = "asr_nordic_2000"
  )

  expect_setequal(unique(result$country), NORDIC_COUNTRIES)
  expect_equal(unique(result$measure), "Mortality")
  expect_equal(unique(result$sex), "Female")
  expect_equal(nrow(result), 225)
  expect_true(all(result$rate_definition == "ASR (Nordic 2000)"))
  expect_true(all(result$standard_population == "Nordic standard population 2000"))
  expect_true(all(result$unit == "per 100,000 person-years"))
  expect_true(all(!is.na(result$source_url)))
  expect_equal(latest_common_year(result), 2024)
})

test_that("latest summaries use each country's available endpoint", {
  result <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    c("Finland", "Sweden"),
    c(2000, 2024),
    "asr_nordic_2000"
  )
  latest <- summarise_latest(result)

  expect_equal(nrow(latest), 2)
  expect_true(all(latest$year == 2024))
  expect_true(all(is.finite(latest$rate)))
  expect_true(all(is.finite(latest$change_pct)))
  expect_true(any(abs(latest$change_pct) > 1))
})

test_that("rate metadata distinguishes crude and standardised rates", {
  expect_equal(
    standard_population_for("asr_nordic_2000"),
    "Nordic standard population 2000"
  )
  expect_true(is.na(standard_population_for("crude_rate")))
  expect_match(rate_unit("crude_rate"), "Crude rate")
  expect_match(rate_unit("asr_nordic_2000", "MIR"), "mortality rate")
  expect_equal(measure_label("MIR"), "M:I ratio (MIR)")
})

test_that("MIR pairs matching mortality and incidence rates", {
  result <- filter_trends(
    trend_data,
    measure = "MIR",
    sex = "Female",
    countries = NORDIC_COUNTRIES,
    years = c(1980, 2024),
    statistic = "asr_nordic_2000"
  )
  finland_2024 <- result |>
    filter(.data$country == "Finland", .data$year == 2024)

  expected_incidence <- trend_data |>
    filter(
      .data$country == "Finland",
      .data$sex == "Female",
      .data$measure == "Incidence",
      .data$year == 2024
    ) |>
    pull(.data$asr_nordic_2000)
  expected_mortality <- trend_data |>
    filter(
      .data$country == "Finland",
      .data$sex == "Female",
      .data$measure == "Mortality",
      .data$year == 2024
    ) |>
    pull(.data$asr_nordic_2000)

  expect_equal(nrow(result), 225)
  expect_equal(unique(result$measure), "MIR")
  expect_equal(unique(result$unit), "ratio")
  expect_true(all(is.finite(result$rate)))
  expect_true(all(result$incidence_rate > 0))
  expect_equal(
    finland_2024$rate,
    expected_mortality / expected_incidence,
    tolerance = 1e-12
  )
  expect_equal(finland_2024$year, 2024)
  expect_equal(latest_common_year(result), 2024)
})

test_that("MIR uses the selected component rate definition", {
  nordic <- filter_trends(
    trend_data,
    "MIR",
    "Male",
    "Denmark",
    c(2024, 2024),
    "asr_nordic_2000"
  )
  crude <- filter_trends(
    trend_data,
    "MIR",
    "Male",
    "Denmark",
    c(2024, 2024),
    "crude_rate"
  )

  expect_false(isTRUE(all.equal(nordic$rate, crude$rate)))
  expect_match(nordic$rate_definition, "ASR \\(Nordic 2000\\)")
  expect_match(crude$rate_definition, "Crude rate")
  expect_true(is.na(crude$standard_population))
})
