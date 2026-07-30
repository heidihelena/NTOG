library(bslib)
library(dplyr)
library(ggplot2)
library(readr)
library(scales)
library(shiny)

source("R/release.R", local = TRUE)
source("R/data.R", local = TRUE)
source("R/context.R", local = TRUE)
source("R/analysis.R", local = TRUE)
source("R/plot.R", local = TRUE)
source("R/exports.R", local = TRUE)

release_manifest <- load_release_manifest()
trend_data <- load_trend_data(
  release_dataset(release_manifest, "nordcan_lung_trends")$path
)
mir_cache <- build_mir_cache(trend_data)
who_context <- load_who_context(
  release_dataset(release_manifest, "who_gho_tobacco_use")$path
)
eurostat_context <- load_eurostat_context(
  release_dataset(release_manifest, "eurostat_lung_mortality")$path
)

country_choices <- setNames(NORDIC_COUNTRIES, NORDIC_COUNTRIES)
year_limits <- range(trend_data$year)

app_theme <- bs_theme(
  version = 5,
  bg = "#f5f7f8",
  fg = "#14283b",
  primary = "#0057b8",
  secondary = "#ffd21a",
  base_font = font_collection("system-ui", "Segoe UI", "sans-serif"),
  heading_font = font_collection("Avenir Next", "Segoe UI", "sans-serif"),
  "navbar-bg" = "#ffffff",
  "navbar-light-color" = "#002f63",
  "navbar-light-hover-color" = "#003580"
)

metric_card <- function(title, value_output, note) {
  div(
    class = "metric-card",
    div(class = "metric-label", title),
    div(class = "metric-value", value_output),
    div(class = "metric-note", note)
  )
}

ui <- function(request) {
  page_navbar(
  title = div(
    class = "brand-lockup",
    tags$img(
      class = "brand-logo",
      src = "ntog-logo.svg",
      alt = "",
      width = "42",
      height = "42",
      `aria-hidden` = "true"
    ),
    span(class = "brand-name", "NTOG"),
    span(class = "brand-title", "Nordic Lung Cancer Trends")
  ),
  id = "page",
  fillable = FALSE,
  theme = app_theme,
  header = tagList(
    tags$head(
      tags$meta(
        name = "description",
        content = paste(
          "Explore Nordic lung cancer incidence, mortality and MIR trends",
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
            choices = c(
              "Mortality" = "Mortality",
              "Incidence" = "Incidence",
              "M:I ratio" = "MIR"
            ),
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
          bookmarkButton(
            label = "Create shareable URL",
            icon = icon("link"),
            class = "btn-share"
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
              textOutput("spread_note", inline = TRUE)
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
                  downloadButton("download_csv", "Data", class = "btn-download"),
                  downloadButton("download_pptx", "PPTX", class = "btn-download"),
                  downloadButton(
                    "download_bundle",
                    "Research pack",
                    class = "btn-download"
                  )
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
    "Compare",
    div(
      class = "research-page",
      div(
        class = "section-intro",
        span(class = "eyebrow", "RESEARCH COMPARISON"),
        h1("Separate relative change from absolute burden."),
        p(
          "Index each country to its first selected year, then inspect female",
          "and male trajectories without collapsing the underlying rates."
        )
      ),
      layout_sidebar(
        sidebar = sidebar(
          width = 300,
          open = "always",
          radioButtons(
            "compare_measure",
            "Measure",
            choices = c(
              "Mortality" = "Mortality",
              "Incidence" = "Incidence",
              "M:I ratio" = "MIR"
            ),
            selected = "Mortality",
            inline = TRUE
          ),
          radioButtons(
            "compare_sex",
            "Indexed country comparison",
            choices = c("Female", "Male"),
            selected = "Female",
            inline = TRUE
          ),
          checkboxGroupInput(
            "compare_countries",
            "Countries",
            choices = country_choices,
            selected = NORDIC_COUNTRIES
          ),
          selectInput(
            "compare_country",
            "Sex comparison country",
            choices = country_choices,
            selected = "Finland"
          ),
          sliderInput(
            "compare_years",
            "Year range",
            min = year_limits[[1]],
            max = year_limits[[2]],
            value = c(2000, year_limits[[2]]),
            step = 1,
            sep = ""
          ),
          selectInput(
            "compare_statistic",
            "Rate definition",
            choices = RATE_LABELS,
            selected = "asr_nordic_2000"
          )
        ),
        div(
          class = "content-stack",
          div(
            class = "method-note",
            div(class = "note-icon", "i"),
            div(
              strong("Two different questions"),
              p(
                "The index shows proportional change from a baseline of 100.",
                "The sex chart retains the original rate or ratio scale."
              )
            )
          ),
          card(
            class = "chart-card",
            card_header(
              span(class = "eyebrow", "RELATIVE CHANGE"),
              h2("Country trajectories indexed to 100")
            ),
            plotOutput("index_plot", height = "510px")
          ),
          layout_columns(
            col_widths = c(8, 4),
            card(
              class = "chart-card",
              card_header(
                span(class = "eyebrow", "SEX COMPARISON"),
                h2("Female and male trajectories")
              ),
              plotOutput("sex_plot", height = "450px")
            ),
            card(
              class = "data-card",
              card_header(
                span(class = "eyebrow", "LATEST GAP"),
                h2("Difference and ratio")
              ),
              tableOutput("sex_gap_table")
            )
          )
        )
      )
    )
  ),
  nav_panel(
    "Country profile",
    div(
      class = "research-page",
      div(
        class = "section-intro",
        span(class = "eyebrow", "COUNTRY PROFILE"),
        h1("One country, its definitions and context."),
        p(
          "Keep NORDCAN outcomes primary while carrying WHO uncertainty and",
          "Eurostat source distinctions alongside the selected country."
        )
      ),
      layout_sidebar(
        sidebar = sidebar(
          width = 300,
          open = "always",
          selectInput(
            "profile_country",
            "Country",
            choices = country_choices,
            selected = "Finland"
          ),
          radioButtons(
            "profile_measure",
            "Measure",
            choices = c(
              "Mortality" = "Mortality",
              "Incidence" = "Incidence",
              "M:I ratio" = "MIR"
            ),
            selected = "Mortality",
            inline = TRUE
          ),
          sliderInput(
            "profile_years",
            "Year range",
            min = year_limits[[1]],
            max = year_limits[[2]],
            value = c(1980, year_limits[[2]]),
            step = 1,
            sep = ""
          ),
          selectInput(
            "profile_statistic",
            "Rate definition",
            choices = RATE_LABELS,
            selected = "asr_nordic_2000"
          )
        ),
        div(
          class = "content-stack",
          card(
            class = "chart-card",
            card_header(
              span(class = "eyebrow", "NORDCAN OUTCOME"),
              h2(textOutput("profile_heading", inline = TRUE))
            ),
            plotOutput("profile_plot", height = "520px")
          ),
          layout_columns(
            col_widths = c(6, 6),
            card(
              class = "data-card",
              card_header(
                span(class = "eyebrow", "LATEST BY SEX"),
                h2("NORDCAN observations")
              ),
              tableOutput("profile_latest_table")
            ),
            card(
              class = "data-card",
              card_header(
                span(class = "eyebrow", "SOURCE CONTEXT"),
                h2("WHO and Eurostat")
              ),
              tableOutput("profile_context_table")
            )
          )
        )
      )
    )
  ),
  nav_panel(
    "Context & sources",
    div(
      class = "research-page",
      div(
        class = "section-intro",
        span(class = "eyebrow", "CONTEXT, NOT CAUSATION"),
        h1("Risk-factor context and an independent source check."),
        p(
          "WHO tobacco estimates and Eurostat mortality remain separate from",
          "the NORDCAN outcome series and retain their own definitions."
        )
      ),
      layout_sidebar(
        sidebar = sidebar(
          width = 300,
          open = "always",
          radioButtons(
            "context_sex",
            "Sex",
            choices = c("Female", "Male"),
            selected = "Female",
            inline = TRUE
          ),
          checkboxGroupInput(
            "context_countries",
            "Countries",
            choices = country_choices,
            selected = NORDIC_COUNTRIES
          ),
          sliderInput(
            "context_years",
            "Year range",
            min = 2000,
            max = 2025,
            value = c(2000, 2025),
            step = 1,
            sep = ""
          ),
          div(
            class = "sidebar-help",
            span(class = "status-dot"),
            div(
              strong("Reviewed release data"),
              p(textOutput("release_label", inline = TRUE))
            )
          )
        ),
        div(
          class = "content-stack",
          div(
            class = "method-note warning",
            div(class = "note-icon", "!"),
            div(
              strong("Do not read this as a causal overlay"),
              p(
                "Smoking and cancer outcomes can differ in timing by decades.",
                "These ecological national series do not estimate individual risk",
                "or the effect of tobacco use on mortality."
              )
            )
          ),
          card(
            class = "chart-card",
            card_header(
              span(class = "eyebrow", "WHO GHO"),
              h2("Current tobacco-use prevalence")
            ),
            plotOutput("who_context_plot", height = "540px")
          ),
          card(
            class = "data-card",
            card_header(
              span(class = "eyebrow", "EUROSTAT × NORDCAN"),
              h2("Latest common European-2013-standardised mortality rates")
            ),
            p(
              class = "card-explainer",
              "Differences may reflect source scope, production and revision",
              "workflows. Agreement is a source check, not proof of equivalence."
            ),
            tableOutput("source_check_table")
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
            ),
            tags$dt("Mortality-to-incidence ratio (MIR)"),
            tags$dd(
              "The mortality rate divided by the incidence rate for the same",
              "country, sex, year, cancer entity and rate definition. Values near",
              "1.0 indicate deaths are nearly as frequent as diagnoses; lower",
              "values may be consistent with better survival, earlier diagnosis",
              "or more effective treatment, but MIR cannot distinguish the cause."
            )
          )
        ),
        card(
          h2("Responsible comparison"),
          p(
            "NORDCAN advises using mortality rather than incidence when",
            "comparing Sweden with other Nordic countries for lung cancer.",
            "The incidence and MIR views remain available for exploration and",
            "display this limitation prominently."
          ),
          p(
            "National coding, classification and registration practices can vary",
            "over time. Statistical patterns do not by themselves establish causes."
          ),
          p(
            "MIR is a crude population indicator, not an individual risk measure",
            "and not case-fatality. People dying in one year are not necessarily",
            "the people diagnosed in that year. Age structure, screening, registry",
            "quality, lead-time bias and competing mortality can distort comparisons."
          )
        )
      ),
      card(
        h2("Sources, release and reuse"),
        p(
          "Data: NORDCAN, Association of the Nordic Cancer Registries and",
          "International Agency for Research on Cancer. Version 9.6, accessed",
          "30 July 2026."
        ),
        p(
          "Context: WHO Global Health Observatory age-standardised current",
          "tobacco-use estimates and Eurostat HLTH_CD_ASDR2 standardised",
          "lung-cancer mortality. These sources are displayed separately and",
          "are not substituted for NORDCAN outcomes."
        ),
        p(
          strong("Data release: "),
          release_label(release_manifest),
          ". The app reads reviewed snapshots and never changes published",
          "figures through a live upstream request."
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
          ),
          " · ",
          a(
            "WHO indicator metadata",
            href = release_dataset(
              release_manifest,
              "who_gho_tobacco_use"
            )$citation_url,
            target = "_blank",
            rel = "noopener"
          ),
          " · ",
          a(
            "Eurostat causes-of-death metadata",
            href = release_dataset(
              release_manifest,
              "eurostat_lung_mortality"
            )$citation_url,
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
  footer = tags$footer(
    class = "app-footer",
    div(
      class = "app-footer-inner",
      a(
        class = "footer-logo-link",
        href = "https://ntog.org/",
        `aria-label` = "NTOG home",
        tags$img(
          src = "ntog-logo.svg",
          alt = "Nordic Thoracic Oncology Group logo",
          width = "56",
          height = "56"
        )
      ),
      p("Tools © 2026 Heidi Andersén / Vahtian. Hosted by NTOG for educational use."),
      p(
        class = "footer-links",
        a("Copyright & Licensing", href = "https://ntog.org/copyright.html"),
        a("Privacy Policy", href = "https://ntog.org/privacy-policy.html"),
        a("Terms of Service", href = "https://ntog.org/terms-of-service.html")
      ),
      p(
        class = "footer-research-note",
        "Research use · Verify outputs against the cited source"
      )
    )
  )
  )
}

server <- function(input, output, session) {
  onBookmarked(function(url) {
    updateQueryString(url, mode = "replace", session = session)
    showNotification(
      "This view is now encoded in the browser URL and can be copied.",
      type = "message",
      duration = 5
    )
  })

  debounced_years <- debounce(reactive(input$years), 250)

  selected_data <- reactive({
    req(input$countries)

    filter_trends(
      trend_data,
      measure = input$measure,
      sex = input$sex,
      countries = input$countries,
      years = debounced_years(),
      statistic = input$statistic,
      mir_cache = mir_cache
    )
  }) |>
    bindCache(
      input$measure,
      input$sex,
      input$countries,
      debounced_years(),
      input$statistic,
      cache = "app"
    )

  output$method_note <- renderUI({
    if (identical(input$measure, "MIR")) {
      div(
        class = "method-note warning",
        div(class = "note-icon", "i"),
        div(
          strong("Population indicator — interpret cautiously"),
          p(
            "MIR = mortality rate ÷ incidence rate. A value near 1.0 means deaths",
            "are nearly as frequent as new diagnoses in that period, but MIR is",
            "not survival, individual risk or case-fatality."
          ),
          p(
            "A lower MIR may be consistent with better survival, earlier diagnosis",
            "or more effective treatment, but cannot identify which. MIR also",
            "inherits limitations in both component rates, including NORDCAN's",
            "Swedish incidence comparability caveat."
          )
        )
      )
    } else if (identical(input$measure, "Incidence")) {
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
    paste(measure_label(input$measure), "·", input$sex, "·", rate_label(input$statistic))
  })

  output$trend_plot <- renderPlot({
    validate(need(nrow(selected_data()) > 0, "No observations match this view."))
    make_trend_plot(
      selected_data(),
      measure = input$measure,
      sex = input$sex,
      statistic_label = rate_label(input$statistic),
      year_range = debounced_years()
    )
  }, res = 120) |>
    bindCache(
      input$measure,
      input$sex,
      input$countries,
      debounced_years(),
      input$statistic,
      cache = "app"
    )

  latest_summary <- reactive({
    summarise_latest(selected_data())
  }) |>
    bindCache(
      input$measure,
      input$sex,
      input$countries,
      debounced_years(),
      input$statistic,
      cache = "app"
    )

  output$latest_year <- renderText({
    latest_common_year(selected_data())
  })

  output$rate_spread <- renderText({
    latest <- latest_summary()
    if (nrow(latest) < 2) {
      return("—")
    }
    accuracy <- if (identical(input$measure, "MIR")) 0.01 else 0.1
    number(max(latest$rate) - min(latest$rate), accuracy = accuracy)
  })

  output$spread_note <- renderText({
    if (identical(input$measure, "MIR")) {
      "Highest minus lowest ratio"
    } else {
      "Highest minus lowest rate"
    }
  })

  output$series_count <- renderText({
    n_distinct(selected_data()$country)
  })

  output$unit_text <- renderText({
    rate_unit(input$statistic, input$measure)
  })

  output$latest_table <- renderTable({
    accuracy <- if (identical(input$measure, "MIR")) 0.01 else 0.1
    table <- latest_summary() |>
      transmute(
        Country = country,
        Year = year,
        Value = number(rate, accuracy = accuracy),
        `Change from first selected year` = format_change(change_pct)
      )
    names(table)[[3]] <- if (identical(input$measure, "MIR")) "MIR" else "Rate"
    table
  }, striped = TRUE, bordered = FALSE, spacing = "s", align = "lrrr")

  compare_years <- debounce(reactive(input$compare_years), 250)

  compare_data <- reactive({
    req(input$compare_countries)
    filter_trends(
      trend_data,
      measure = input$compare_measure,
      sex = input$compare_sex,
      countries = input$compare_countries,
      years = compare_years(),
      statistic = input$compare_statistic,
      mir_cache = mir_cache
    )
  }) |>
    bindCache(
      input$compare_measure,
      input$compare_sex,
      input$compare_countries,
      compare_years(),
      input$compare_statistic,
      cache = "app"
    )

  output$index_plot <- renderPlot({
    validate(need(nrow(compare_data()) > 0, "No observations match this view."))
    make_index_plot(
      compare_data(),
      measure = input$compare_measure,
      sex = input$compare_sex,
      statistic_label = rate_label(input$compare_statistic),
      year_range = compare_years()
    )
  }, res = 110) |>
    bindCache(
      input$compare_measure,
      input$compare_sex,
      input$compare_countries,
      compare_years(),
      input$compare_statistic,
      cache = "app"
    )

  both_sex_data <- reactive({
    filter_both_sexes(
      trend_data,
      measure = input$compare_measure,
      country = input$compare_country,
      years = compare_years(),
      statistic = input$compare_statistic,
      mir_cache = mir_cache
    )
  }) |>
    bindCache(
      input$compare_measure,
      input$compare_country,
      compare_years(),
      input$compare_statistic,
      cache = "app"
    )

  output$sex_plot <- renderPlot({
    validate(need(nrow(both_sex_data()) > 0, "No observations match this view."))
    make_sex_plot(
      both_sex_data(),
      country = input$compare_country,
      measure = input$compare_measure,
      statistic_label = rate_label(input$compare_statistic),
      year_range = compare_years()
    )
  }, res = 110) |>
    bindCache(
      input$compare_measure,
      input$compare_country,
      compare_years(),
      input$compare_statistic,
      cache = "app"
    )

  output$sex_gap_table <- renderTable({
    gap <- sex_gap_series(both_sex_data()) |>
      slice_max(.data$year, n = 1, with_ties = FALSE)
    validate(need(nrow(gap) == 1, "No paired female and male observation."))
    data.frame(
      Metric = c(
        "Year",
        "Female",
        "Male",
        "Female − male",
        "Female ÷ male"
      ),
      Value = c(
        gap$year,
        number(gap$female_rate, accuracy = 0.1),
        number(gap$male_rate, accuracy = 0.1),
        number(gap$difference, accuracy = 0.1),
        number(gap$female_to_male_ratio, accuracy = 0.01)
      ),
      check.names = FALSE
    )
  }, striped = TRUE, bordered = FALSE, spacing = "s")

  profile_years <- debounce(reactive(input$profile_years), 250)

  profile_data <- reactive({
    filter_both_sexes(
      trend_data,
      measure = input$profile_measure,
      country = input$profile_country,
      years = profile_years(),
      statistic = input$profile_statistic,
      mir_cache = mir_cache
    )
  }) |>
    bindCache(
      input$profile_measure,
      input$profile_country,
      profile_years(),
      input$profile_statistic,
      cache = "app"
    )

  output$profile_heading <- renderText({
    paste(
      input$profile_country,
      measure_label(input$profile_measure),
      "by sex"
    )
  })

  output$profile_plot <- renderPlot({
    validate(need(nrow(profile_data()) > 0, "No observations match this profile."))
    make_sex_plot(
      profile_data(),
      country = input$profile_country,
      measure = input$profile_measure,
      statistic_label = rate_label(input$profile_statistic),
      year_range = profile_years()
    )
  }, res = 110) |>
    bindCache(
      input$profile_measure,
      input$profile_country,
      profile_years(),
      input$profile_statistic,
      cache = "app"
    )

  output$profile_latest_table <- renderTable({
    accuracy <- if (identical(input$profile_measure, "MIR")) 0.01 else 0.1
    latest_sex_summary(profile_data()) |>
      transmute(
        Sex = .data$sex,
        Year = .data$year,
        Value = number(.data$rate, accuracy = accuracy)
      )
  }, striped = TRUE, bordered = FALSE, spacing = "s", align = "lrr")

  output$profile_context_table <- renderTable({
    country <- input$profile_country
    who <- who_context |>
      filter(
        .data$country == .env$country,
        .data$sex %in% c("female", "male")
      ) |>
      latest_context() |>
      transmute(
        Source = "WHO tobacco use",
        Sex = recode(.data$sex, female = "Female", male = "Male"),
        Year = .data$year,
        Value = paste0(number(.data$value, accuracy = 0.1), "%"),
        Definition = if_else(
          .data$status == "projected",
          "Projected modelled estimate",
          "Modelled estimate"
        )
      )
    eurostat <- eurostat_context |>
      filter(
        .data$country == .env$country,
        .data$sex %in% c("female", "male")
      ) |>
      latest_context() |>
      transmute(
        Source = "Eurostat mortality",
        Sex = recode(.data$sex, female = "Female", male = "Male"),
        Year = .data$year,
        Value = number(.data$value, accuracy = 0.1),
        Definition = "ESP 2013 rate per 100,000"
      )
    bind_rows(who, eurostat)
  }, striped = TRUE, bordered = FALSE, spacing = "s", align = "llrrl")

  context_years <- debounce(reactive(input$context_years), 250)

  selected_who_context <- reactive({
    req(input$context_countries)
    filter_who_context(
      who_context,
      sex = input$context_sex,
      countries = input$context_countries,
      years = context_years()
    )
  }) |>
    bindCache(
      input$context_sex,
      input$context_countries,
      context_years(),
      cache = "app"
    )

  output$who_context_plot <- renderPlot({
    validate(need(nrow(selected_who_context()) > 0, "No WHO estimates match this view."))
    make_who_context_plot(
      selected_who_context(),
      sex = input$context_sex,
      year_range = context_years()
    )
  }, res = 110) |>
    bindCache(
      input$context_sex,
      input$context_countries,
      context_years(),
      cache = "app"
    )

  output$source_check_table <- renderTable({
    req(input$context_countries)
    compare_mortality_sources(
      trend_data,
      eurostat_context,
      sex = input$context_sex,
      countries = input$context_countries,
      years = context_years()
    ) |>
      transmute(
        Country = .data$country,
        Year = .data$year,
        NORDCAN = number(.data$nordcan_rate, accuracy = 0.1),
        Eurostat = number(.data$eurostat_rate, accuracy = 0.1),
        `Eurostat − NORDCAN` = number(.data$difference, accuracy = 0.1),
        `Difference (%)` = paste0(
          number(.data$difference_pct, accuracy = 0.1),
          "%"
        )
      )
  }, striped = TRUE, bordered = FALSE, spacing = "s", align = "lrrrrr")

  output$release_label <- renderText({
    release_label(release_manifest)
  })

  export_state <- reactive({
    list(
      measure = input$measure,
      sex = input$sex,
      countries = input$countries,
      years = debounced_years(),
      statistic = input$statistic
    )
  })

  output$download_png <- downloadHandler(
    filename = function() export_filename(export_state(), "png"),
    content = function(file) {
      export_plot(file, "png", selected_data(), export_state())
    }
  )

  output$download_pdf <- downloadHandler(
    filename = function() export_filename(export_state(), "pdf"),
    content = function(file) {
      export_plot(file, "pdf", selected_data(), export_state())
    }
  )

  output$download_csv <- downloadHandler(
    filename = function() export_filename(export_state(), "csv"),
    content = function(file) {
      write_csv(selected_data(), file, na = "")
    }
  )

  output$download_pptx <- downloadHandler(
    filename = function() export_filename(export_state(), "pptx"),
    content = function(file) {
      export_pptx(file, selected_data(), export_state())
    }
  )

  output$download_bundle <- downloadHandler(
    filename = function() {
      export_filename(export_state(), "zip", prefix = "ntog-research-pack")
    },
    content = function(file) {
      export_research_bundle(
        file,
        selected_data(),
        export_state(),
        release_manifest
      )
    }
  )

  output$download_citation <- downloadHandler(
    filename = function() {
      export_filename(export_state(), "txt", prefix = "methods")
    },
    content = function(file) {
      writeLines(
        build_methods_text(export_state(), release_manifest),
        file,
        useBytes = TRUE
      )
    }
  )
}

shinyApp(ui, server, enableBookmarking = "url")
