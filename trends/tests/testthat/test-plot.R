test_that("presentation plot can be rendered as a 16:9 PNG", {
  result <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    NORDIC_COUNTRIES,
    c(1980, 2024),
    "asr_nordic_2000"
  )
  plot <- make_trend_plot(
    result,
    "Mortality",
    "Female",
    "ASR (Nordic 2000)",
    c(1980, 2024)
  )

  output <- tempfile(fileext = ".png")
  ggsave(output, plot = plot, width = 13.333, height = 7.5, dpi = 72)

  expect_s3_class(plot, "ggplot")
  expect_true(file.exists(output))
  expect_gt(file.info(output)$size, 1000)
})

test_that("vector PDF and citation exports retain presentation provenance", {
  result <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    NORDIC_COUNTRIES,
    c(1980, 2024),
    "asr_nordic_2000"
  )
  input <- list(
    measure = "Mortality",
    sex = "Female",
    countries = NORDIC_COUNTRIES,
    years = c(1980, 2024),
    statistic = "asr_nordic_2000"
  )
  output <- tempfile(fileext = ".pdf")

  export_plot(output, "pdf", result, input)
  methods <- build_methods_text(input)

  expect_true(file.exists(output))
  expect_gt(file.info(output)$size, 1000)
  expect_true(any(grepl("ICD-10 C33–C34", methods, fixed = TRUE)))
  expect_true(any(grepl("Nordic standard population 2000", methods, fixed = TRUE)))
  expect_true(any(grepl("accessed 30 July 2026", methods, fixed = TRUE)))
})

test_that("MIR plot and methods state the ratio and its limitations", {
  result <- filter_trends(
    trend_data,
    "MIR",
    "Female",
    NORDIC_COUNTRIES,
    c(2000, 2024),
    "asr_nordic_2000"
  )
  input <- list(
    measure = "MIR",
    sex = "Female",
    countries = NORDIC_COUNTRIES,
    years = c(2000, 2024),
    statistic = "asr_nordic_2000"
  )
  plot <- make_trend_plot(
    result,
    "MIR",
    "Female",
    "ASR (Nordic 2000)",
    c(2000, 2024)
  )
  methods <- build_methods_text(input)

  expect_s3_class(plot, "ggplot")
  expect_equal(plot$labels$title, "Mortality-to-incidence ratio for lung cancer")
  expect_match(plot$labels$caption, "not case-fatality")
  expect_true(any(grepl("MIR formula", methods, fixed = TRUE)))
  expect_true(any(grepl("not case-fatality", methods, fixed = TRUE)))
  expect_true(any(grepl("lead-time bias", methods, fixed = TRUE)))
})
