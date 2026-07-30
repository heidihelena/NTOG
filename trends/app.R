library(bslib)
library(dplyr)
library(ggplot2)
library(readr)
library(scales)
library(shiny)

source("R/data.R", local = TRUE)
source("R/plot.R", local = TRUE)
source("R/exports.R", local = TRUE)

trend_data <- load_trend_data("data/nordcan_lung_trends_9_6.csv")

country_choices <- setNames(NORDIC_COUNTRIES, NORDIC_COUNTRIES)
year_limits <- range(trend_data$year)

app_theme <- bs_theme(
  version = 5,
  bg = "#f5f7f8",
  fg = "#14283b",
  primary = "#006b75",
  secondary = "#f26b4f",
  base_font = font_google("Open Sans"),
  heading_font = font_google("Montserrat"),
  "navbar-bg" = "#102a43",
  "navbar-light-color" = "#ffffff",
  "navbar-light-hover-color" = "#ffffff"
)

metric_card <- function(title, value_output, note) {
  div(
    class = "metric-card",
    div(class = "metric-label", title),
    div(class = "metric-value", value_output),
    div(class = "metric-note", note)
  )
}

ui <- page_navbar(
  title = div(
    class = "brand-lockup",
    span(class = "brand-mark", "NTOG"),
    span(class = "brand-title", "Nordic Lung Cancer Trends")
  ),
  id = "page",
  theme = app_theme,
  header = tagList(
    tags$head(
      tags$meta(
        name = "description",
        content = paste(
          "Explore Nordic lung cancer incidence and mortality trends",
          "with presentation-ready exports and explicit provenance."
        )
      ),
      tags$link(rel = "stylesheet", href = "styles.css")
    )
  ),
  nav_panel(
    "Explore",
    div(
      class = "app-shell",
      layout_sidebar(
        sidebar = sidebar(
          width = 318,
          open = "always",
          div(
            class = "control-heading",
            span(class = "eyebrow", "VIEW"),
            h2("Build a comparison")
          ),
          radioButtons(
            "measure",
            "Measure",
            choices = c("Mortality" = "Mortality", "Incidence" = "Incidence"),
            selected = "Mortality",
            inline = TRUE
          ),
          radioButtons(
            "sex",
            "Sex",
            choices = c("Female", "Male"),
            selected = "Female",
            inline = TRUE
          ),
          checkboxGroupInput(
            "countries",
            "Countries",
            choices = country_choices,
            selected = NORDIC_COUNTRIES
          ),
          sliderInput(
            "years",
            "Year range",
            min = year_limits[[1]],
            max = year_limits[[2]],
            value = c(1980, year_limits[[2]]),
            step = 1,
            sep = ""
          ),
          selectInput(
            "statistic",
            "Rate definition",
            choices = RATE_LABELS,
            selected = "asr_nordic_2000"
          ),
          div(
            class = "sidebar-help",
            span(class = "status-dot"),
            div(
              strong("Frozen, reproducible snapshot"),
              p("NORDCAN 9.6 · accessed 30 July 2026")
            )
          )
        ),
        div(
          class = "content-stack",
          div(
            class = "hero-panel",
            div(
              span(class = "eyebrow light", "NORDIC EVIDENCE EXPLORER"),
              h1("Lung cancer trends, ready to interrogate."),
              p(
                "Compare national trajectories, inspect exact definitions and",
                "export a clean figure with its citation attached."
              )
            ),
            div(
              class = "hero-badge",
              span("MCP companion"),
              a(
                "SourceVahti",
                href = "https://sourcevahti.vahtian.com/",
                target = "_blank",
                rel = "noopener"
              )
            )
          ),
          uiOutput("method_note"),
          div(
            class = "metric-grid",
            metric_card(
              "Latest common year",
              textOutput("latest_year", inline = TRUE),
              "Across selected countries"
            ),
            metric_card(
              "Nordic spread",
              textOutput("rate_spread", inline = TRUE),
              "Highest minus lowest rate"
            ),
            metric_card(
              "Series selected",
              textOutput("series_count", inline = TRUE),
              "Country trajectories"
            )
          ),
          card(
            class = "chart-card",
            card_header(
              div(
                div(
                  span(class = "eyebrow", "TREND"),
                  h2(textOutput("chart_heading", inline = TRUE))
                ),
                div(
                  class = "download-group",
                  downloadButton("download_png", "PNG 16:9", class = "btn-download"),
                  downloadButton("download_pdf", "PDF", class = "btn-download"),
                  downloadButton("download_csv", "Data", class = "btn-download")
                )
              )
            ),
            plotOutput("trend_plot", height = "560px")
          ),
          layout_columns(
            col_widths = c(7, 5),
            card(
              class = "data-card",
              card_header(
                span(class = "eyebrow", "LATEST OBSERVATIONS"),
                h2("Values and change")
              ),
              tableOutput("latest_table")
            ),
            card(
              class = "provenance-card",
              card_header(
                span(class = "eyebrow", "PROVENANCE"),
                h2("Carry the source with you")
              ),
              p(
                "Every export includes the cancer definition, rate definition,",
                "source version, URL and retrieval date."
              ),
              tags$dl(
                tags$dt("Cancer"),
                tags$dd("Lung · ICD-10 C33–C34"),
                tags$dt("Source"),
                tags$dd("NORDCAN 9.6 (30 June 2026)"),
                tags$dt("Unit"),
                tags$dd(textOutput("unit_text", inline = TRUE))
              ),
              downloadButton(
                "download_citation",
                "Download citation & methods",
                class = "btn-citation"
              )
            )
          )
        )
      )
    )
  ),
  nav_panel(
    "Methods & source",
    div(
      class = "methods-page",
      span(class = "eyebrow", "METHODS"),
      h1("A transparent view of public cancer statistics"),
      p(
        class = "lead",
        "This application presents tabulated national statistics. It does not",
        "contain patient-level data and is not a clinical decision tool."
      ),
      layout_columns(
        col_widths = c(6, 6),
        card(
          h2("Definitions"),
          tags$dl(
            tags$dt("Cancer entity"),
            tags$dd("Lung cancer, ICD-10 C33–C34."),
            tags$dt("Age-standardised rates"),
            tags$dd(
              "Rates per 100,000 person-years, standardised to the selected",
              "reference population."
            ),
            tags$dt("Crude rate"),
            tags$dd(
              "Observed events divided by the population, expressed per 100,000."
            )
          )
        ),
        card(
          h2("Responsible comparison"),
          p(
            "NORDCAN advises using mortality rather than incidence when",
            "comparing Sweden with other Nordic countries for lung cancer.",
            "The incidence view remains available for within-country exploration",
            "and displays this limitation prominently."
          ),
          p(
            "National coding, classification and registration practices can vary",
            "over time. Statistical patterns do not by themselves establish causes."
          )
        )
      ),
      card(
        h2("Source and reuse"),
        p(
          "Data: NORDCAN, Association of the Nordic Cancer Registries and",
          "International Agency for Research on Cancer. Version 9.6, accessed",
          "30 July 2026."
        ),
        p(
          a(
            "Open the matching NORDCAN trend view",
            href = NORDCAN_TREND_URL,
            target = "_blank",
            rel = "noopener"
          ),
          " · ",
          a(
            "Read NORDCAN's database notes",
            href = "https://nordcan.iarc.fr/en/database",
            target = "_blank",
            rel = "noopener"
          ),
          " · ",
          a(
            "SourceVahti MCP service",
            href = "https://sourcevahti.vahtian.com/mcp",
            target = "_blank",
            rel = "noopener"
          )
        ),
        p(
          "Application code is licensed under Apache-2.0 as part of the NTOG",
          "repository. Source data retain their source terms and attribution."
        )
      )
    )
  ),
  footer = div(
    class = "app-footer",
    span("Nordic Thoracic Oncology Group"),
    span("Research use · Verify outputs against the cited source")
  )
)

server <- function(input, output, session) {
  selected_data <- reactive({
    req(input$countries)

    filter_trends(
      trend_data,
      measure = input$measure,
      sex = input$sex,
      countries = input$countries,
      years = input$years,
      statistic = input$statistic
    )
  })

  output$method_note <- renderUI({
    if (identical(input$measure, "Incidence")) {
      div(
        class = "method-note warning",
        div(class = "note-icon", "!"),
        div(
          strong("Cross-country incidence caveat"),
          p(
            "NORDCAN reports that Swedish lung-cancer incidence is not directly",
            "comparable with the other Nordic countries. Use mortality for the",
            "primary cross-country comparison."
          )
        )
      )
    } else {
      div(
        class = "method-note",
        div(class = "note-icon", "✓"),
        div(
          strong("Recommended comparison"),
          p(
            "Mortality avoids the known Swedish incidence-registration",
            "comparability issue identified by NORDCAN."
          )
        )
      )
    }
  })

  output$chart_heading <- renderText({
    paste(input$measure, "·", input$sex, "·", rate_label(input$statistic))
  })

  output$trend_plot <- renderPlot({
    validate(need(nrow(selected_data()) > 0, "No observations match this view."))
    make_trend_plot(
      selected_data(),
      measure = input$measure,
      sex = input$sex,
      statistic_label = rate_label(input$statistic),
      year_range = input$years
    )
  }, res = 120)

  latest_summary <- reactive({
    summarise_latest(selected_data())
  })

  output$latest_year <- renderText({
    latest_common_year(selected_data())
  })

  output$rate_spread <- renderText({
    latest <- latest_summary()
    if (nrow(latest) < 2) {
      return("—")
    }
    number(max(latest$rate) - min(latest$rate), accuracy = 0.1)
  })

  output$series_count <- renderText({
    n_distinct(selected_data()$country)
  })

  output$unit_text <- renderText({
    rate_unit(input$statistic)
  })

  output$latest_table <- renderTable({
    latest_summary() |>
      transmute(
        Country = country,
        Year = year,
        Rate = number(rate, accuracy = 0.1),
        `Change from first selected year` = format_change(change_pct)
      )
  }, striped = TRUE, bordered = FALSE, spacing = "s", align = "lrrr")

  output$download_png <- downloadHandler(
    filename = function() export_filename(input, "png"),
    content = function(file) {
      export_plot(file, "png", selected_data(), input)
    }
  )

  output$download_pdf <- downloadHandler(
    filename = function() export_filename(input, "pdf"),
    content = function(file) {
      export_plot(file, "pdf", selected_data(), input)
    }
  )

  output$download_csv <- downloadHandler(
    filename = function() export_filename(input, "csv"),
    content = function(file) {
      write_csv(selected_data(), file, na = "")
    }
  )

  output$download_citation <- downloadHandler(
    filename = function() export_filename(input, "txt", prefix = "methods"),
    content = function(file) {
      writeLines(build_methods_text(input), file, useBytes = TRUE)
    }
  )
}

shinyApp(ui, server)
