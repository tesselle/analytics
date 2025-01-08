#' Shiny Dashboard Server Function
#'
#' @param input Provided by \pkg{Shiny}.
#' @param output Provided by \pkg{Shiny}.
#' @param session Provided by \pkg{Shiny}.
#' @author N. Frerebeau
#' @keywords internal
#' @noRd
function(input, output, session) {
  ## Add resources -----
  path <- system.file("static", package = "analytics")
  addResourcePath(prefix = "static", directoryPath = path)

  ## List apps -----
  apps <- yaml::read_yaml(
    file = system.file("dashboard", "config.yml", package = "analytics")
  )

  ## Helpers -----
  build_card <- function(x) {
    bslib::card(
      bslib::card_header(
        tags$a(
          x$title,
          href = sprintf("https://analytics.huma-num.fr/tesselle/%s", tolower(x$name)),
          target = "_blank",
          class = "card-link stretched-link"
        )
      ),
      bslib::card_body(
        tags$img(
          src = sprintf("static/%s.png", tolower(x$name)),
          alt = x$title,
          class = "card-img-bottom"
        )
      ),
      fill = FALSE
    )
  }

  ## Apps -----
  output$apps <- renderUI({
    breaks <- bslib::breakpoints(
      xs = 12,
      sm = c(6, 6),
      md = c(4, 4, 4),
      lg = c(3, 3, 3, 3)
    )
    app_cards <- lapply(X = apps, FUN = build_card)
    do.call(
      bslib::layout_columns,
      args = c(app_cards, list(col_widths = breaks))
    )
  })

  ## Logs -----
  usage <- reactive({
    ## List files
    path <- getShinyOption("log_path")
    if (is.null(path) || !dir.exists(path)) return(NULL)
    logs <- list.files(path, pattern = ".log", full.names = FALSE)
    if (length(logs) == 0) return(NULL)

    ## Get info
    info <- do.call(rbind, strsplit(logs, split = "-"))
    app_names <- vapply(X = apps, FUN = getElement, FUN.VALUE = character(1),
                        name = "name")
    info <- info[info[, 1] %in% app_names, , drop = FALSE]

    ## Compute usage statistics
    info <- table(info[, 1], info[, 3], dnn = list("App", "Date"))
    info <- as.data.frame(info)
    info$Date <- as.Date(info$Date, format = "%Y%m%d")
    info
  }) |>
    bindCache(Sys.Date(), cache = "app")

  output$plot_app <- renderPlot({
    req(usage())
    x <- aggregate(Freq ~ App, data = usage(), FUN = sum)
    x$App <- factor(x$App, levels = x$App[order(x$Freq)])
    ggplot2::ggplot(data = x) +
      ggplot2::aes(x = Freq, y = App) +
      ggplot2::geom_col(orientation = "y") +
      ggplot2::scale_x_continuous(limits = c(0, NA), expand = c(0, 0.05)) +
      ggplot2::theme_bw() +
      ggplot2::theme(
        axis.title = ggplot2::element_blank()
      )
  })

  output$plot_day <- renderPlot({
    req(usage())
    x <- aggregate(Freq ~ Date, data = usage(), FUN = sum)
    ggplot2::ggplot(data = x) +
      ggplot2::aes(x = Date, y = Freq) +
      ggplot2::geom_col(orientation = "x") +
      ggplot2::theme_bw() +
      ggplot2::theme(
        axis.title = ggplot2::element_blank()
      )
  })

  session$onSessionEnded(stopApp)
}
