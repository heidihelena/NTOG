COUNTRY_COLOURS <- c(
  Denmark = "#c8102e",
  Finland = "#003580",
  Iceland = "#7257a5",
  Norway = "#0057b8",
  Sweden = "#d9a900"
)

make_trend_plot <- function(data, measure, sex, statistic_label, year_range) {
  is_mir <- identical(measure, "MIR")
  latest <- data |>
    dplyr::group_by(.data$country) |>
    dplyr::slice_max(.data$year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  reference_line <- if (is_mir) {
    geom_hline(
      yintercept = 1,
      colour = "#8a99a6",
      linewidth = 0.55,
      linetype = "dashed"
    )
  }

  ggplot(data, aes(
    x = .data$year,
    y = .data$rate,
    colour = .data$country,
    group = .data$country
  )) +
    reference_line +
    geom_line(linewidth = 1.15, lineend = "round") +
    geom_point(
      data = latest,
      size = 2.8,
      stroke = 0.8,
      shape = 21,
      fill = "white"
    ) +
    scale_colour_manual(values = COUNTRY_COLOURS, drop = FALSE) +
    scale_x_continuous(
      breaks = scales::breaks_pretty(n = 8),
      limits = year_range,
      expand = expansion(mult = c(0.01, 0.02))
    ) +
    scale_y_continuous(
      labels = label_number(accuracy = if (is_mir) 0.1 else 1),
      breaks = breaks_pretty(n = 6),
      expand = expansion(mult = c(0, 0.08))
    ) +
    labs(
      x = NULL,
      y = if (is_mir) {
        paste0("Mortality-to-incidence ratio\nusing ", statistic_label)
      } else {
        paste0(statistic_label, "\nper 100,000 person-years")
      },
      colour = NULL,
      title = if (is_mir) {
        "Mortality-to-incidence ratio for lung cancer"
      } else {
        paste(measure, "from lung cancer")
      },
      subtitle = paste(sex, "·", min(data$year), "to", max(data$year)),
      caption = if (is_mir) {
        paste(
          "MIR = mortality rate / incidence rate",
          "population indicator, not case-fatality",
          "NORDCAN 9.6, accessed 30 July 2026",
          sep = "  ·  "
        )
      } else {
        paste(
          "Lung (ICD-10 C33-C34)  |  NORDCAN 9.6",
          "accessed 30 July 2026  |  nordcan.iarc.fr",
          sep = "  ·  "
        )
      }
    ) +
    theme_minimal(base_family = "sans", base_size = 12) +
    theme(
      plot.background = element_rect(fill = "white", colour = NA),
      panel.background = element_rect(fill = "white", colour = NA),
      plot.title = element_text(
        family = "sans",
        face = "bold",
        size = 20,
        colour = "#14283b",
        margin = margin(b = 5)
      ),
      plot.subtitle = element_text(size = 12, colour = "#5d7184"),
      plot.caption = element_text(
        size = 9,
        colour = "#6a7d8d",
        hjust = 0,
        margin = margin(t = 14)
      ),
      axis.title.y = element_text(
        size = 10,
        colour = "#40566a",
        margin = margin(r = 12)
      ),
      axis.text = element_text(colour = "#52677a"),
      panel.grid.major.x = element_blank(),
      panel.grid.minor = element_blank(),
      panel.grid.major.y = element_line(colour = "#e5ebef", linewidth = 0.45),
      legend.position = "bottom",
      legend.justification = "left",
      legend.box.margin = margin(t = 10),
      legend.text = element_text(size = 10, face = "bold"),
      plot.margin = margin(16, 20, 8, 10)
    ) +
    guides(colour = guide_legend(nrow = 1, byrow = TRUE))
}
