test_that("Nordic countries keep a fixed colour and form identity", {
  expect_equal(
    COUNTRY_IDENTITIES$country,
    c("Denmark", "Finland", "Iceland", "Norway", "Sweden")
  )
  expect_equal(
    unname(COUNTRY_COLOURS),
    c("#C8102E", "#0057B8", "#24987C", "#7A71E1", "#B3731E")
  )
  expect_equal(unname(COUNTRY_SHAPES), c(16, 15, 17, 18, 8))
  expect_equal(
    unname(COUNTRY_LINETYPES),
    c("solid", "dashed", "dotted", "dotdash", "longdash")
  )
  expect_length(unique(COUNTRY_COLOURS), 5)
  expect_length(unique(COUNTRY_SHAPES), 5)
  expect_length(unique(COUNTRY_LINETYPES), 5)

  result <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    c("Finland", "Sweden"),
    c(2000, 2024),
    "asr_nordic_2000"
  )
  plot <- make_trend_plot(
    result,
    "Mortality",
    "Female",
    "ASR (Nordic 2000)",
    c(2000, 2024)
  )
  built <- ggplot_build(plot)

  expect_equal(
    built$plot$scales$get_scales("colour")$map(c("Finland", "Sweden")),
    c("#0057B8", "#B3731E")
  )
  expect_equal(
    built$plot$scales$get_scales("shape")$map(c("Finland", "Sweden")),
    c(15, 8)
  )
  expect_equal(
    built$plot$scales$get_scales("linetype")$map(c("Finland", "Sweden")),
    c("dashed", "longdash")
  )
})

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

test_that("vector SVG export preserves the plot", {
  skip_if_not_installed("svglite")
  result <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    NORDIC_COUNTRIES,
    c(2000, 2024),
    "asr_nordic_2000"
  )
  input <- list(
    measure = "Mortality",
    sex = "Female",
    countries = NORDIC_COUNTRIES,
    years = c(2000, 2024),
    statistic = "asr_nordic_2000"
  )
  output <- tempfile(fileext = ".svg")

  export_plot(output, "svg", result, input)

  expect_true(file.exists(output))
  expect_gt(file.info(output)$size, 1000)
  expect_match(readLines(output, n = 1), "xml")
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

test_that("editable PowerPoint export contains a presentation", {
  skip_if_not_installed("officer")
  skip_if_not_installed("rvg")
  result <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    c("Finland", "Sweden"),
    c(2000, 2024),
    "asr_nordic_2000"
  )
  input <- list(
    measure = "Mortality",
    sex = "Female",
    countries = c("Finland", "Sweden"),
    years = c(2000, 2024),
    statistic = "asr_nordic_2000"
  )
  output <- tempfile(fileext = ".pptx")

  export_pptx(output, result, input)

  expect_true(file.exists(output))
  expect_gt(file.info(output)$size, 1000)
  expect_s3_class(officer::read_pptx(output), "rpptx")
})

test_that("research pack carries figure, data, methods and provenance", {
  skip_if_not_installed("officer")
  skip_if_not_installed("rvg")
  skip_if_not_installed("svglite")
  skip_if_not_installed("zip")
  result <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    c("Finland", "Sweden"),
    c(2000, 2024),
    "asr_nordic_2000"
  )
  input <- list(
    measure = "Mortality",
    sex = "Female",
    countries = c("Finland", "Sweden"),
    years = c(2000, 2024),
    statistic = "asr_nordic_2000"
  )
  output <- tempfile(fileext = ".zip")

  export_research_bundle(output, result, input, release_manifest)
  contents <- utils::unzip(output, list = TRUE)$Name

  expect_setequal(
    contents,
    c(
      "figure-16x9.png",
      "figure-vector.pdf",
      "figure-vector.svg",
      "selected-observations.csv",
      "editable-chart.pptx",
      "methods-and-citation.txt",
      "selection-and-provenance.json",
      "data-release-manifest.json"
    )
  )
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
