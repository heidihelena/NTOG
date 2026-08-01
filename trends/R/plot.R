COUNTRY_IDENTITIES <- data.frame(
  country = c("Denmark", "Finland", "Iceland", "Norway", "Sweden"),
  colour = c("#C8102E", "#0057B8", "#24987C", "#7A71E1", "#B3731E"),
  marker = c("circle", "square", "triangle", "diamond", "star"),
  shape = c(16, 15, 17, 18, 8),
  linetype = c("solid", "dashed", "dotted", "dotdash", "longdash"),
  stringsAsFactors = FALSE
)

COUNTRY_COLOURS <- setNames(
  COUNTRY_IDENTITIES$colour,
  COUNTRY_IDENTITIES$country
)
COUNTRY_SHAPES <- setNames(
  COUNTRY_IDENTITIES$shape,
  COUNTRY_IDENTITIES$country
)
COUNTRY_LINETYPES <- setNames(
  COUNTRY_IDENTITIES$linetype,
  COUNTRY_IDENTITIES$country
)

country_identity_metadata <- function() {
  records <- lapply(seq_len(nrow(COUNTRY_IDENTITIES)), function(index) {
    identity <- COUNTRY_IDENTITIES[index, , drop = FALSE]
    list(
      colour = identity$colour[[1]],
      marker = identity$marker[[1]],
      ggplot_shape = identity$shape[[1]],
      linetype = identity$linetype[[1]]
    )
  })
  setNames(records, COUNTRY_IDENTITIES$country)
}

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
    geom_line(
      aes(linetype = .data$country),
      linewidth = 1.15,
      lineend = "round"
    ) +
    geom_point(
      data = latest,
      aes(shape = .data$country),
      size = 3.1,
      stroke = 0.9
    ) +
    scale_colour_manual(values = COUNTRY_COLOURS, drop = FALSE) +
    scale_shape_manual(values = COUNTRY_SHAPES, drop = FALSE) +
    scale_linetype_manual(values = COUNTRY_LINETYPES, drop = FALSE) +
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
      shape = NULL,
      linetype = NULL,
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
    )
}

make_index_plot <- function(data, measure, sex, statistic_label, year_range) {
  indexed <- index_trends(data)
  latest <- indexed |>
    dplyr::group_by(.data$country) |>
    dplyr::slice_max(.data$year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  ggplot(indexed, aes(
    x = .data$year,
    y = .data$index,
    colour = .data$country,
    group = .data$country
  )) +
    geom_hline(
      yintercept = 100,
      colour = "#8a99a6",
      linewidth = 0.55,
      linetype = "dashed"
    ) +
    geom_line(
      aes(linetype = .data$country),
      linewidth = 1.15,
      lineend = "round"
    ) +
    geom_point(
      data = latest,
      aes(shape = .data$country),
      size = 3.1,
      stroke = 0.9
    ) +
    scale_colour_manual(values = COUNTRY_COLOURS, drop = FALSE) +
    scale_shape_manual(values = COUNTRY_SHAPES, drop = FALSE) +
    scale_linetype_manual(values = COUNTRY_LINETYPES, drop = FALSE) +
    scale_x_continuous(
      breaks = scales::breaks_pretty(n = 8),
      limits = year_range,
      expand = expansion(mult = c(0.01, 0.02))
    ) +
    scale_y_continuous(
      labels = label_number(accuracy = 1),
      breaks = breaks_pretty(n = 6),
      expand = expansion(mult = c(0.03, 0.08))
    ) +
    labs(
      x = NULL,
      y = "Index\n(first selected year = 100)",
      colour = NULL,
      shape = NULL,
      linetype = NULL,
      title = paste(measure_label(measure), "relative change"),
      subtitle = paste(
        sex,
        "·",
        statistic_label,
        "· each country starts at 100"
      ),
      caption = paste(
        "A relative index compares change, not absolute burden",
        "NORDCAN 9.6, accessed 30 July 2026",
        sep = "  ·  "
      )
    ) +
    research_plot_theme()
}

make_sex_plot <- function(data, country, measure, statistic_label, year_range) {
  latest <- data |>
    dplyr::group_by(.data$sex) |>
    dplyr::slice_max(.data$year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()
  sex_colours <- c(Female = "#d9a900", Male = "#0057b8")

  ggplot(data, aes(
    x = .data$year,
    y = .data$rate,
    colour = .data$sex,
    group = .data$sex
  )) +
    geom_line(linewidth = 1.2, lineend = "round") +
    geom_point(
      data = latest,
      size = 2.8,
      stroke = 0.8,
      shape = 21,
      fill = "white"
    ) +
    scale_colour_manual(values = sex_colours, drop = FALSE) +
    scale_x_continuous(
      breaks = scales::breaks_pretty(n = 8),
      limits = year_range,
      expand = expansion(mult = c(0.01, 0.02))
    ) +
    scale_y_continuous(
      labels = label_number(accuracy = if (identical(measure, "MIR")) 0.1 else 1),
      breaks = breaks_pretty(n = 6),
      expand = expansion(mult = c(0, 0.08))
    ) +
    labs(
      x = NULL,
      y = if (identical(measure, "MIR")) {
        "Mortality-to-incidence ratio"
      } else {
        paste0(statistic_label, "\nper 100,000 person-years")
      },
      colour = NULL,
      title = paste(country, measure_label(measure), "by sex"),
      subtitle = paste(min(data$year), "to", max(data$year)),
      caption = paste(
        "Descriptive national series; sex categories follow the source",
        "NORDCAN 9.6",
        sep = "  ·  "
      )
    ) +
    research_plot_theme()
}

make_who_context_plot <- function(data, sex, year_range) {
  latest <- data |>
    dplyr::group_by(.data$country) |>
    dplyr::slice_max(.data$year, n = 1, with_ties = FALSE) |>
    dplyr::ungroup()

  ggplot(data, aes(
    x = .data$year,
    y = .data$value,
    colour = .data$country,
    group = .data$country
  )) +
    geom_ribbon(
      aes(ymin = .data$lower_bound, ymax = .data$upper_bound, fill = .data$country),
      alpha = 0.08,
      colour = NA,
      show.legend = FALSE
    ) +
    geom_line(
      aes(linetype = .data$country),
      linewidth = 1.05,
      lineend = "round"
    ) +
    geom_point(
      data = latest,
      aes(shape = .data$country, alpha = .data$status),
      size = 3.1,
      stroke = 0.9
    ) +
    scale_colour_manual(values = COUNTRY_COLOURS, drop = FALSE) +
    scale_fill_manual(values = COUNTRY_COLOURS, drop = FALSE) +
    scale_linetype_manual(values = COUNTRY_LINETYPES, drop = FALSE) +
    scale_shape_manual(
      values = COUNTRY_SHAPES,
      drop = FALSE
    ) +
    scale_alpha_manual(
      values = c(modelled_estimate = 1, projected = 0.55),
      labels = c(modelled_estimate = "Modelled estimate", projected = "Projection")
    ) +
    scale_x_continuous(
      breaks = scales::breaks_pretty(n = 8),
      limits = year_range,
      expand = expansion(mult = c(0.01, 0.02))
    ) +
    scale_y_continuous(
      labels = label_number(accuracy = 1, suffix = "%"),
      breaks = breaks_pretty(n = 6),
      expand = expansion(mult = c(0, 0.08))
    ) +
    labs(
      x = NULL,
      y = "Current tobacco use\nage-standardised (%)",
      colour = NULL,
      shape = NULL,
      linetype = NULL,
      alpha = "Latest point status",
      title = "WHO tobacco-use context",
      subtitle = paste(sex, "· shaded bands are 95% uncertainty intervals"),
      caption = paste(
        "WHO GHO modelled estimates; selected values may use smoking as a substitute",
        "Context only — no causal comparison with cancer outcomes",
        sep = "  ·  "
      )
    ) +
    research_plot_theme()
}

research_plot_theme <- function() {
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
    )
}
