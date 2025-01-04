#' Shiny Dashboard User Interface Object
#'
#' @author N. Frerebeau
#' @keywords internal
#' @noRd
bslib::page_navbar(
  title = "Shiny Apps for the Archaeologist",
  sidebar = bslib::sidebar(
    title = "Welcome!",
    withTags(
      div(
        img(
          src = "static/tesselle.png",
          alt = "Logo of the tesselle project.",
          style = "width: 100%"
        ),
        p(
          "This portal provides access to a range of web applications built on the",
          a("R packages", href = "https://packages.tesselle.org", target = "_blank"),
          "of the",
          a(strong("tesselle"), href = "https://www.tesselle.org", target = "_blank"),
          "project."
        ),
        p(
          "These applications can be used to explore and analyze common data types in archaeology.",
          "They are distributed in the hope that they will be useful, but WITHOUT ANY WARRANTY."
        ),
        p(
          "Computing resources are provided by the CNRS",
          a("IR* Huma-Num", href = "https://www.huma-num.fr", target = "_blank"),
          "and",
          a("IN2P3 Computing Center", href = "https://www.in2p3.cnrs.fr/fr", target = "_blank"),
          "."
        )
      )
    )
  ),
  bslib::nav_spacer(),
  bslib::nav_panel(
    title = "Apps",
    class = "bslib-page-dashboard",
    uiOutput(outputId = "apps")
  ),
  bslib::nav_panel(
    title = "Stats",
    class = "bslib-page-dashboard",
    bslib::card(
      bslib::card_header("Number of connections per app"),
      plotOutput(outputId = "plot_app")
    ),
    bslib::card(
      bslib::card_header("Number of connections per day"),
      plotOutput(outputId = "plot_day")
    )
  ),
  footer = kinesis::footer_ui("footer"),
  theme = bslib::bs_theme(version = "5"),
  lang = "en",
  collapsible = TRUE
)
