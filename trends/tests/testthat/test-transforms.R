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
})
