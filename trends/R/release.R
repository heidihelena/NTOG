RELEASE_DATASET_IDS <- c(
  "nordcan_lung_trends",
  "who_gho_tobacco_use",
  "eurostat_lung_mortality"
)

load_release_manifest <- function(path = "data/release_manifest.json") {
  if (!requireNamespace("digest", quietly = TRUE)) {
    stop("Release validation requires the digest package.")
  }
  manifest <- jsonlite::read_json(path, simplifyVector = FALSE)
  validate_release_manifest(manifest, root = dirname(dirname(path)))
  manifest
}

validate_release_manifest <- function(manifest, root = ".") {
  required <- c(
    "schema_version", "release_id", "released_at", "scope",
    "sourcevahti_schema_version", "datasets"
  )
  missing <- setdiff(required, names(manifest))
  if (length(missing) > 0) {
    stop("Release manifest is missing fields: ", paste(missing, collapse = ", "))
  }
  if (!identical(manifest$schema_version, "2.0.0")) {
    stop("Unsupported release schema: ", manifest$schema_version)
  }
  if (!identical(manifest$scope$icd10, "C33-C34")) {
    stop("Release manifest is not restricted to lung cancer (C33-C34).")
  }
  ids <- vapply(manifest$datasets, `[[`, character(1), "id")
  if (!setequal(ids, RELEASE_DATASET_IDS) || anyDuplicated(ids)) {
    stop("Release manifest dataset identifiers are incomplete or duplicated.")
  }
  for (dataset in manifest$datasets) {
    dataset_path <- file.path(root, dataset$path)
    if (!file.exists(dataset_path)) {
      stop("Release dataset is missing: ", dataset$path)
    }
    if (!grepl("^[0-9a-f]{64}$", dataset$sha256)) {
      stop("Release dataset has an invalid SHA-256: ", dataset$id)
    }
    actual_sha256 <- digest::digest(
      dataset_path,
      algo = "sha256",
      file = TRUE,
      serialize = FALSE
    )
    if (!identical(actual_sha256, dataset$sha256)) {
      stop(
        "Release dataset checksum changed for ", dataset$id,
        ": expected ", dataset$sha256, ", found ", actual_sha256
      )
    }
    row_count <- length(readLines(dataset_path, warn = FALSE)) - 1L
    if (!identical(row_count, as.integer(dataset$rows))) {
      stop(
        "Release dataset row count changed for ", dataset$id,
        ": expected ", dataset$rows, ", found ", row_count
      )
    }
  }
  invisible(TRUE)
}

release_dataset <- function(manifest, id) {
  matches <- Filter(
    function(dataset) identical(dataset$id, id),
    manifest$datasets
  )
  if (length(matches) != 1) {
    stop("Unknown release dataset: ", id)
  }
  matches[[1]]
}

release_label <- function(manifest) {
  paste0(manifest$release_id, " · schema ", manifest$schema_version)
}
