#' Shiny Dashboard Server Function
#'
#' @param input Provided by \pkg{Shiny}.
#' @param output Provided by \pkg{Shiny}.
#' @param session Provided by \pkg{Shiny}.
#' @author N. Frerebeau
#' @keywords internal
#' @noRd
function(input, output, session) {
  ## Helpers -----
  build_card <- function(x) {
    bslib::card(
      bslib::card_header(
        htmltools::a(
          x$title,
          href=sprintf("https://analytics.huma-num.fr/tesselle/%s", tolower(x$name)),
          target="_blank",
          class="card-link stretched-link"
        )
      ),
      bslib::card_body(
        htmltools::img(
          src=sprintf("static/%s.png", tolower(x$name)),
          alt=x$title,
          class="card-img-bottom"
        )
      ),
      fill = FALSE
    )
  }

  ## Apps -----
  app_paths <- system.file("app", package = "kinesis")
  app_names <- list.dirs(app_paths, full.names = FALSE, recursive = FALSE)
  apps <- lapply(X = app_names, FUN = kinesis::get_config)

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
    path <- "../log/"
    if (!dir.exists(path)) return(NULL)
    logs <- list.files(path, pattern = ".log", full.names = FALSE)
    if (length(logs) == 0) return(NULL)
    info <- do.call(rbind, strsplit(logs, split = "-"))
    x <- as.data.frame(table(info[, 1], info[, 3], dnn = list("App", "Date")))
    x$Date <- as.Date(x$Date, format = "%Y%m%d")
    x
  })

  output$plot_app <- renderPlot({
    req(usage())
    x <- aggregate(Freq ~ App, data = usage(), FUN = sum)
    x <- x[order(x$Freq), ]
    ggplot2::ggplot(data = x) +
      ggplot2::aes(x = Freq, y = App) +
      ggplot2::geom_col(orientation = "y") +
      ggplot2::theme_bw() +
      ggplot2::theme(
        axis.title = ggplot2::element_blank()
      )
  })

  output$plot_day <- renderPlot({
    req(usage())
    x <- aggregate(Freq ~ Date, data = usage(), FUN = sum)
    x <- x[order(x$Date), ]
    ggplot2::ggplot(data = x) +
      ggplot2::aes(x = Date, y = Freq) +
      ggplot2::geom_col(orientation = "x") +
      ggplot2::theme_bw() +
      ggplot2::theme(
        axis.title = ggplot2::element_blank()
      )
  })

  kinesis::footer_server("footer")
  session$onSessionEnded(stopApp)
}
