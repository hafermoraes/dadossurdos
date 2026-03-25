
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
    piramides_mortalidade |>
    pivot_longer(
      cols = -c(subgrp, fx_idade),
      names_pattern = "(.*)_(.*)",
      names_to = c("sexo", "ano"),
      values_to = "n"
    ) |>
    # filter(ano!=2019) |> # removendo PNS 2019 dos gráficos...
    mutate(
      ano = case_when(
        ano == 2000 ~ 'Censo 2000',
        ano == 2010 ~ 'Censo 2010',
        ano == 2019 ~ 'PNS 2019'
      )
    ) |>
    group_by(ano, subgrp, fx_idade, sexo) |>
    summarise(n = sum(n, na.rm = TRUE), .groups = "drop") |>
    group_by(ano, subgrp) |> 
    mutate(pct = n / sum(n)) |> 
    ungroup() |>
    mutate(n_plot = ifelse(sexo == "feminino", -pct, pct))
  
  
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
      labels = function(x) scales::percent(abs(x), accuracy = 0.1, decimal.mark = ",")
    ) +
    labs(
      x = "Idade", 
      y = "População", 
      fill = ""
    ) +
    theme_bw() +
    theme(
      legend.position = "top",
      panel.spacing = unit(2, "lines")
    )
  
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
    summarise(total_mortes = sum(total_obitos, na.rm = TRUE)) |>
    arrange(desc(total_mortes)) |>
    mutate(
      percent_acumulada = cumsum(total_mortes) / sum(total_mortes) * 100,
      capitulo_wrap = str_wrap(CAPITULO_CID10, width = 15),
      capitulo_wrap = factor(capitulo_wrap, levels = unique(capitulo_wrap))
    )
  
  max_mortes <- max(plt_data$total_mortes)
  ratio <- max_mortes / 100
  
  plt <-
    plt_data |>
    ggplot(aes(x = capitulo_wrap)) +
    geom_col(
      aes(y = total_mortes),
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
        label = paste0(format(round(percent_acumulada, 1), decimal.mark=","), "%")
      ),
      vjust = -2,
      color = "black",
      size = 4
    ) +
    scale_y_continuous(
      name = "Total de óbitos na década",
      labels = label_number(scale = 1e-6, suffix = " mi."),
      expand = expansion(mult = c(0, 0.3))#,
      # sec.axis = sec_axis(
      #   ~ . / ratio, 
      #   name = "Porcentagem Acumulada", 
      #   breaks = seq(0, 100, by = 20),
      #   labels = label_percent(scale = 1, suffix = "%")
      # )
    ) +
    labs(
      x = "Capítulo da Classificação Internacional de Doenças, Catálogo de 2010 (CID-10)"
    ) +
    theme(
      axis.title.x = element_text(size = 13),
      axis.title.y = element_text(size = 13),
      axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 12),
      axis.text.y = element_text(size = 13),
      panel.grid.minor = element_blank()
    )
  
  plt |>
    ggsave(
      filename = output_file,
      width=plot_width,
      height=plot_height
    )
  
} # export_plot_pareto <- function(input_df, plot_width, plot_height, output_file)



formatar_br <- function(x, decimais = 0) {
  res <- ifelse(
    is.na(x) | x == 0, 
    "-", 
    format(
      round(as.numeric(x), decimais), 
      big.mark = ".",
      decimal.mark = ",", 
      nsmall = decimais,
      scientific = FALSE
    )
  )
  return(trimws(res))
}

export_mort_razao_sobrevivencia <- function(categ, output_file) {
  
  tbl <-
    piramides_mortalidade |>
    filter(subgrp == categ) |>
    transmute(
      fx_idade,
      f_2000 = feminino_2000, 
      f_2010 = feminino_2010,
      f_rs = case_when(
        feminino_2000 == 0 ~ NA_real_,
        TRUE ~ lead(feminino_2010, n = 2) / feminino_2000
      ),
      m_2000 = masculino_2000, 
      m_2010 = masculino_2010,
      m_rs = case_when(
        masculino_2000 == 0 ~ NA_real_,
        TRUE ~ lead(masculino_2010, n = 2) / masculino_2000
      )
    ) |>
    mutate(
      across(c(f_2000, f_2010, m_2000, m_2010), ~ formatar_br(.x, 0)),
      across(c(f_rs, m_rs), ~ formatar_br(.x, 4))
    )
  
  res_latex <- capture.output(
    print(
      xtable(tbl),
      sanitize.text.function = identity, 
      only.contents = TRUE,
      include.rownames = FALSE, 
      include.colnames = FALSE,
      hline.after = NULL,
      comment = FALSE
    )
  )
  
  texto_completo <- paste(res_latex, collapse = "\n")
  
  texto_final <- sub("\\\\\\\\(?=[^\\\\\\\\]*$)", "", texto_completo, perl = TRUE)
  
  writeLines(
    texto_final,
    con = output_file
  )
}


# ===============================

prevalence_all_ages <- function(arg_var, arg_output_file, arg_append){

  message("calculando prevalência de ",arg_var, "...")

  # (re)inicializa tabela de resultados em branco
  outer_table <-
    tibble(
      sexo = character(),     # resultados por sexo
      n = numeric(),          # número de pessoas com arg_var == 1
      n_low = numeric(),      # limite inferior do número de pessoas com arg_var == 1
      n_upp = numeric(),      # limite superior do número de pessoas com arg_var == 1
      p = numeric(),          # percentual de pessoas com arg_var == 1
      p_low = numeric(),      # limite inferior do percentual de pessoas com arg_var == 1
      p_upp = numeric(),      # limite superior do número de pessoas com arg_var == 1
      subgrp = character(),   # categoria (total/ouvinte/deficiente_auditivo/surdo/surdocego)
      var = character()       # arg_var (atributo mensurado na PNS 2019)
    )

  # itera cada subgrupo de interesse da tese
  SUBGRPS <-
    c(
      "categ_total",
      "categ_ouvinte",
      "categ_surdo",
      "categ_surdocego",
      "categ_deficiente_auditivo"
    )

  svy_proportion <- TRUE
  if(arg_var == 'antrop_imc'){
    svy_proportion <- FALSE
  }
  
  svy_prop_method <- 'xlogit'

  for(arg_subgrp in SUBGRPS){

    tic()

    message("   para o grupo ", arg_subgrp, "...")

    if(arg_subgrp == 'categ_total'){

      inner_table <-
        pns2019_posterior |>
        as_survey() |>
        group_by(sexo) |>
        summarise(
          n = survey_total(
            .data[[arg_var]],
            na.rm=TRUE,
            vartype='ci'
          ),
          p = survey_mean(
            .data[[arg_var]],
            na.rm=TRUE,
            proportion = svy_proportion,
            prop_method = svy_prop_method,
            vartype='ci'
          )
        ) |>
        mutate(
          n_low = pmax(0, n_low),
          subgrp = arg_subgrp,
          var = arg_var
        )

    } else {

      inner_table <-
        pns2019_posterior |>
        as_survey() |>
        filter( .data[[arg_subgrp]] == 1) |>
        group_by(sexo) |>
        summarise(
          n = survey_total(
            .data[[arg_var]],
            na.rm=TRUE,
            vartype='ci'
          ),
          p = survey_mean(
            .data[[arg_var]],
            na.rm=TRUE,
            proportion = svy_proportion,
            prop_method = svy_prop_method,
            vartype='ci'
          )
        ) |>
        mutate(
          n_low = pmax(0, n_low),
          subgrp = arg_subgrp,
          var = arg_var
        )

    } # if(arg_subgrp == 'categ_total')

    outer_table <-
      bind_rows(
        outer_table,
        inner_table
      )

    toc()

    message("     salvando dados de ", arg_var, " em disco em ", arg_output_file, "...")
    inner_table |>
      write_csv(
        file = arg_output_file,
        append = arg_append
      )
    arg_append <- TRUE # sobrescreve arg_append daqui pra frente...
    
  } # for(arg_subgrp in SUBGRPS)

  return(outer_table)

} # prevalence_all_ages <- function(arg_var, output_file, append)

# ===================

prevalence_by_agegrp <- function(arg_var, arg_output_file, arg_append){

  message("calculando prevalência de ",arg_var, "...")

  # (re)inicializa tabela de resultados em branco
  outer_table <-
    tibble(
      sexo = character(),     # resultados por sexo
      n = numeric(),          # número de pessoas com arg_var == 1
      n_low = numeric(),      # limite inferior do número de pessoas com arg_var == 1
      n_upp = numeric(),      # limite superior do número de pessoas com arg_var == 1
      p = numeric(),          # percentual de pessoas com arg_var == 1
      p_low = numeric(),      # limite inferior do percentual de pessoas com arg_var == 1
      p_upp = numeric(),      # limite superior do número de pessoas com arg_var == 1
      subgrp = character(),   # categoria (total/ouvinte/deficiente_auditivo/surdo/surdocego)
      var = character(),      # arg_var (atributo mensurado na PNS 2019)
      fx_idade = character()  # faixa etária
    )

  # itera cada subgrupo de interesse da tese
  SUBGRPS <-
    c(
      "categ_total",
      "categ_ouvinte",
      "categ_surdo",
      "categ_surdocego",
      "categ_deficiente_auditivo"
    )

  svy_proportion <- TRUE
  if(arv_var == 'antrop_imc'){
    svy_proportion <- FALSE
  }
  svy_prop_method <- 'xlogit'

  for(arg_subgrp in SUBGRPS){

    tic()

    message("   para o grupo ", arg_subgrp, "...")

    if(arg_subgrp == 'categ_total'){

      inner_table <-
        pns2019_posterior |>
        as_survey() |>
        group_by(sexo, fx_idade) |>
        summarise(
          n = survey_total(
            .data[[arg_var]],
            na.rm=TRUE,
            vartype='ci'
          ),
          p = survey_mean(
            .data[[arg_var]],
            na.rm=TRUE,
            proportion = svy_proportion,
            prop_method = svy_prop_method,
            vartype='ci'
          )
        ) |>
        transmute(
          sexo,
          n,
          n_low = pmax(0,n_low),
          n_upp,
          p,
          p_low,
          p_upp,
          subgrp = arg_subgrp,
          var = arg_var,
          fx_idade
        )

    } else {

      inner_table <-
        pns2019_posterior |>
        as_survey() |>
        filter( .data[[arg_subgrp]] == 1) |>
        group_by(sexo, fx_idade) |>
        summarise(
          n = survey_total(
            .data[[arg_var]],
            na.rm=TRUE,
            vartype='ci'
          ),
          p = survey_mean(
            .data[[arg_var]],
            na.rm=TRUE,
            proportion = svy_proportion,
            prop_method = svy_prop_method,
            vartype='ci'
          )
        ) |>
        transmute(
          sexo,
          n,
          n_low = pmax(0,n_low),
          n_upp,
          p,
          p_low,
          p_upp,
          subgrp = arg_subgrp,
          var = arg_var,
          fx_idade
        )

    } # if(arg_subgrp == 'categ_total')

    outer_table <-
      bind_rows(
        outer_table,
        inner_table
      )

    toc()

    message("     salvando dados de ", arg_var, " em disco em ", arg_output_file, "...")
    inner_table |>
      write_csv(
        file = arg_output_file,
        append = arg_append
      )
    arg_append <- TRUE # sobrescreve arg_append daqui pra frente...
    
  } # for(arg_subgrp in SUBGRPS)

  return(outer_table)

} # prevalence_by_agegrp <- function(arg_var, output_file, append)


# ===================

get_gradient_color <- function(val) {
  if (is.na(val) || val == "-") return(val)
  v <- as.numeric(val)
  v_fmt <- format(round(v, 2), decimal.mark = ",", nsmall = 2)
  if (v > 1) {
    intensity <- min(round((v - 1) * 100), 100)
    return(paste0("\\cellcolor{myblue!", intensity, "!white}", v_fmt))
  } else if (v < 1) {
    intensity <- min(round((1 - v) * 100), 100)
    return(paste0("\\cellcolor{myred!", intensity, "!white}", v_fmt))
  } else {
    return(v_fmt)
  }
} # get_gradient_color


# ===================

formata_br <- function(num){
  N_DIGITS <- 3
  return( 
    format( round(num, N_DIGITS), decimal.mark = ",", nsmall = N_DIGITS)
    )
}
