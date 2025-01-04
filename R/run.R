# SHINY

#' Run the Dashboard
#'
#' A wrapper for [shiny::shinyAppDir()].
#' @param ... Currently not used.
#' @param log_path A [`character`] string giving the path to the log files.
#' @param options A [`list`] of named options that should be passed to the
#'  [`shiny::shinyAppDir()`] call.
#' @examples
#' \dontrun{
#' run_dashboard()
#' }
#' @return A \pkg{shiny} application object.
#' @family shiny apps
#' @author N. Frerebeau
#' @export
run_dashboard <- function(..., log_path = NULL,
                          options = list(launch.browser = interactive())) {
  app_dir <- system.file("dashboard", package = "analytics")
  obj <- shiny::shinyAppDir(appDir = app_dir, options = options)
  obj$appOptions$log_path <- log_path
  obj
}
