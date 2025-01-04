.onLoad <- function(libname, pkgname) {
  path <- system.file("static", package = "analytics")
  shiny::addResourcePath(prefix = "static", directoryPath = path)

  invisible()
}

.onUnload <- function(libname, pkgname) {
  shiny::removeResourcePath("static")

  invisible()
}
