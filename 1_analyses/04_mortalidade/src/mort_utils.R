
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
}


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
}

