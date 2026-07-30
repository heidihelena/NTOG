test_that("frozen NORDCAN snapshot has the expected scope", {
  expect_equal(nrow(trend_data), 1298)
  expect_setequal(unique(trend_data$country), NORDIC_COUNTRIES)
  expect_setequal(unique(trend_data$sex), c("Male", "Female"))
  expect_setequal(unique(trend_data$measure), c("Incidence", "Mortality"))
  expect_equal(range(trend_data$year), c(1960L, 2024L))
  expect_true(all(trend_data$cancer_id == 160))
  expect_true(all(trend_data$icd10 == "C33-C34"))
})

test_that("invalid schemas and definitions fail loudly", {
  broken <- trend_data |> select(-source_url)
  expect_error(validate_trend_data(broken), "source_url")
  wrong_unit <- trend_data
  wrong_unit$unit[[1]] <- "percent"
  expect_error(validate_trend_data(wrong_unit), "unexpected unit")
  wrong_sex <- trend_data
  wrong_sex$sex[[1]] <- "Unknown"
  expect_error(validate_trend_data(wrong_sex), "Male and Female")
  expect_error(
    filter_trends(
      trend_data,
      "Mortality",
      "Female",
      "Finland",
      c(2000, 2024),
      "ambiguous_rate"
    ),
    "Unsupported rate definition"
  )
})
