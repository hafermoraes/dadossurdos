
life_table_structure <- function(OMEGA, STEP){
  mort_breaks <- c(seq(0, OMEGA, by=STEP), Inf)
  mort_labels <- c(
    paste(
      seq(0, OMEGA-STEP, by = STEP), 
      seq(STEP-1, OMEGA-1, by = STEP), 
      sep = "-"
    ), 
    paste0(OMEGA, "+")
  )
  return(
    list(
      breaks = mort_breaks,
      labels = mort_labels
    )
  )
} # life_table_structure <- function(OMEGA, STEP)


export_plot_age_pyramid_comparison <- function(arg_subgrp, plot_width, plot_height, output_file){
  
  plt_data <-
    censo_mortalidade |>
    pivot_longer(
      cols = -c(subgrp, fx_idade),
      names_pattern = "(.*)_(.*)",
      names_to = c("sexo", "ano"),
      values_to = "n"
    ) |>
    group_by(ano, subgrp, fx_idade, sexo) |>
    summarise(n = sum(n, na.rm = TRUE), .groups = "drop") |>
    mutate(n_plot = ifelse(sexo == "feminino", -n, n)) |>
    ungroup()
  
  
  plt <- 
    plt_data |>
    filter(subgrp == arg_subgrp) |>
    ggplot(
      aes(
        x = fx_idade, 
        y = n_plot, 
        fill = sexo
      )
    ) +
    geom_col(width = 0.8) + 
    coord_flip() +
    facet_wrap(. ~ ano)+#, scales = "free") +
    #scale_fill_brewer(palette = "Greys") +
    scale_fill_grey(start = 0.5, end = 0.3) +
    scale_y_continuous(
      labels = function(x) label_number(
        scale_cut = c(0, " mil" = 1e3, " mi" = 1e6), # Espaço dentro do nome
        decimal.mark = ",",
        big.mark = "."
      )(abs(x))
    ) +
    labs(
      x = "Idade", 
      y = "População", 
      fill = ""
    ) +
    theme_bw() +
    theme(legend.position = "top")
  
  ggsave(
    filename = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )
} # export_plot_age_pyramid_comparison <- function(arg_subgrp, plot_width, plot_height, output_file)

export_plot_pareto <- function(input_df, plot_width, plot_height, output_file){
  plt_data <-
    input_df |>
    group_by(CAPITULO_CID10) |>
    summarise(total_mortes = sum(obitos, na.rm = TRUE)) |>
    arrange(desc(total_mortes)) |>
    mutate(
      percent_acumulada = cumsum(total_mortes) / sum(total_mortes) * 100,
      capitulo_wrap = str_wrap(CAPITULO_CID10, width = 15),
      capitulo_wrap = factor(capitulo_wrap, levels = unique(capitulo_wrap))
    )
  
  max_mortes <- max(pareto_data$total_mortes)
  ratio <- max_mortes / 100
  
  plt <-
    plt_data |>
    ggplot(aes(x = capitulo_wrap)) +
    geom_col(
      aes(
        y = total_mortes),
      fill = "grey40",
      alpha = 0.8
    ) +
    geom_line(
      aes(
        y = percent_acumulada * ratio,
        group = 1
      ),
      color = "black",
      size = 0.5
    ) +
    geom_point(
      aes(
        y = percent_acumulada * ratio
      ),
      color = "black",
      size = 1
    ) +
    geom_text(
      aes(
        y = percent_acumulada * ratio, 
        label = paste0(round(percent_acumulada, 1), "%")
      ),
      vjust = -1.5,
      color = "black",
      size = 3
    ) +
    scale_y_continuous(
      name = "Total de Óbitos",
      labels = label_number(scale = 1e-6, suffix = " mi."),
      expand = expansion(mult = c(0, 0.2)),
      sec.axis = sec_axis(
        ~ . / ratio, 
        name = "Porcentagem Acumulada", 
        breaks = seq(0, 100, by = 20),
        labels = label_percent(scale = 1, suffix = "%")
      )
    ) +
    labs(
      x = "Capítulo da CID-10"
    ) +
    theme(
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 9),
      axis.title.y.right = element_text(color = "black"),
      axis.text.y.right = element_text(color = "black"),
      panel.grid.minor = element_blank()
    )
  
  plt |>
    ggsave(
      filename = output_file,
      width=plot_width,
      height=plot_height
    )
  
} # export_plot_pareto <- function(input_df, plot_width, plot_height, output_file)
