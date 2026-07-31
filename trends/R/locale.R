UTF8_LOCALE_CANDIDATES <- c("C.UTF-8", "en_US.UTF-8", "UTF-8")

# The app, its exports and its tests all carry characters outside ASCII: the
# en dash in "C33-C34", the middle dot in chart headings, Nordic place names.
# In a session without a UTF-8 LC_CTYPE those characters are mangled on output
# and comparisons between a UTF-8-declared string and a native one silently
# return FALSE, so callers must reach a UTF-8 locale before anything else runs.
ensure_utf8_locale <- function(candidates = UTF8_LOCALE_CANDIDATES) {
  if (isTRUE(l10n_info()[["UTF-8"]])) {
    return(invisible(TRUE))
  }

  for (candidate in candidates) {
    applied <- suppressWarnings(Sys.setlocale("LC_CTYPE", candidate))
    if (nzchar(applied) && isTRUE(l10n_info()[["UTF-8"]])) {
      return(invisible(TRUE))
    }
  }

  warning(
    "No UTF-8 locale available; non-ASCII labels and exports may be mangled.",
    call. = FALSE
  )
  invisible(FALSE)
}
