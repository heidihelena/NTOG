port <- suppressWarnings(as.integer(Sys.getenv("PORT", unset = "3838")))
if (is.na(port) || port < 1L || port > 65535L) {
  stop("PORT must be an integer between 1 and 65535.")
}
app_dir <- Sys.getenv("APP_DIR", unset = "/srv/shiny-server")

message("Starting NTOG Trends from ", app_dir, " on 0.0.0.0:", port)
shiny::runApp(
  app_dir,
  host = "0.0.0.0",
  port = port,
  launch.browser = FALSE
)
