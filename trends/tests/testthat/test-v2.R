test_that("release manifest pins all reviewed lung-cancer datasets", {
  expect_equal(release_manifest$schema_version, "2.0.0")
  expect_equal(release_manifest$scope$icd10, "C33-C34")
  expect_setequal(
    vapply(release_manifest$datasets, `[[`, character(1), "id"),
    RELEASE_DATASET_IDS
  )
  expect_silent(
    validate_release_manifest(
      release_manifest,
      root = "../.."
    )
  )
})

test_that("release manifest rejects a changed dataset checksum", {
  changed <- release_manifest
  changed$datasets[[1]]$sha256 <- paste(rep("0", 64), collapse = "")

  expect_error(
    validate_release_manifest(changed, root = "../.."),
    "checksum changed"
  )
})

test_that("context snapshots retain reviewed scope and definitions", {
  expect_equal(nrow(who_context), 150)
  expect_equal(nrow(eurostat_context), 195)
  expect_setequal(unique(who_context$country), NORDIC_COUNTRIES)
  expect_setequal(unique(eurostat_context$country), NORDIC_COUNTRIES)
  expect_true(all(who_context$lower_bound <= who_context$value))
  expect_true(all(who_context$value <= who_context$upper_bound))
  expect_true(any(who_context$status == "projected"))
  expect_equal(range(eurostat_context$year), c(2011L, 2023L))
})

test_that("precomputed MIR is identical to on-demand calculation", {
  cached <- filter_trends(
    trend_data,
    "MIR",
    "Female",
    c("Finland", "Sweden"),
    c(2000, 2024),
    "asr_nordic_2000",
    mir_cache = mir_cache
  )
  direct <- filter_trends(
    trend_data,
    "MIR",
    "Female",
    c("Finland", "Sweden"),
    c(2000, 2024),
    "asr_nordic_2000"
  )

  expect_equal(cached, direct)
})

test_that("relative index and sex gap retain explicit scales", {
  female <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    NORDIC_COUNTRIES,
    c(2000, 2024),
    "asr_nordic_2000"
  )
  indexed <- index_trends(female)
  starts <- indexed |>
    group_by(.data$country) |>
    slice_min(.data$year, n = 1, with_ties = FALSE) |>
    pull(.data$index)
  both <- filter_both_sexes(
    trend_data,
    "Mortality",
    "Finland",
    c(2000, 2024),
    "asr_nordic_2000",
    mir_cache
  )
  gaps <- sex_gap_series(both)

  expect_equal(starts, rep(100, length(starts)), tolerance = 1e-12)
  expect_equal(nrow(gaps), 25)
  expect_true(all(is.finite(gaps$female_to_male_ratio)))
})

test_that("WHO filtering preserves uncertainty and source status", {
  result <- filter_who_context(
    who_context,
    "Female",
    c("Finland", "Sweden"),
    c(2020, 2025)
  )

  expect_setequal(unique(result$country), c("Finland", "Sweden"))
  expect_true(all(result$sex == "female"))
  expect_true(all(result$year >= 2020))
  expect_true(all(result$lower_bound <= result$value))
})

test_that("Eurostat source check uses a shared ESP 2013 year", {
  result <- compare_mortality_sources(
    trend_data,
    eurostat_context,
    "Female",
    NORDIC_COUNTRIES,
    c(2011, 2025)
  )

  expect_equal(nrow(result), 5)
  expect_true(all(result$year == 2023))
  expect_true(all(is.finite(result$difference)))
  expect_true(all(is.finite(result$difference_pct)))
})

test_that("v2 comparison and context plots render", {
  mortality <- filter_trends(
    trend_data,
    "Mortality",
    "Female",
    NORDIC_COUNTRIES,
    c(2000, 2024),
    "asr_nordic_2000"
  )
  sexes <- filter_both_sexes(
    trend_data,
    "Mortality",
    "Finland",
    c(2000, 2024),
    "asr_nordic_2000",
    mir_cache
  )
  tobacco <- filter_who_context(
    who_context,
    "Female",
    NORDIC_COUNTRIES,
    c(2000, 2025)
  )

  expect_s3_class(
    make_index_plot(
      mortality,
      "Mortality",
      "Female",
      "ASR (Nordic 2000)",
      c(2000, 2024)
    ),
    "ggplot"
  )
  expect_s3_class(
    make_sex_plot(
      sexes,
      "Finland",
      "Mortality",
      "ASR (Nordic 2000)",
      c(2000, 2024)
    ),
    "ggplot"
  )
  expect_s3_class(
    make_who_context_plot(tobacco, "Female", c(2000, 2025)),
    "ggplot"
  )
})

test_that("research metadata carries selection and immutable release", {
  input <- list(
    measure = "Mortality",
    sex = "Female",
    countries = NORDIC_COUNTRIES,
    years = c(2000, 2024),
    statistic = "asr_nordic_2000"
  )
  metadata <- selection_metadata(input, release_manifest)
  output <- tempfile(fileext = ".json")
  write_selection_metadata(output, input, release_manifest)

  expect_equal(metadata$cancer$icd10, "C33-C34")
  expect_equal(metadata$release$release_id, release_manifest$release_id)
  expect_true(file.exists(output))
  expect_match(paste(readLines(output), collapse = "\n"), release_manifest$release_id)
})
