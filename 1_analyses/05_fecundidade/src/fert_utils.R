
# input_df <-
#   censos_elbadry |>
#   filter(subgrp=='surdo', ano == 2000)


fert_period_measures <- function(input_df){
  
  # garante que dataframe contém a estrutura necessária...
  for(col_name in c('subgrp', 'ano', 'fx_idade', 'filhos_nascidos_vivos', 'nr_mulheres')){
    assert_that(
      col_name %in% names(input_df), msg = paste0('coluna ', col_name, ' ausente da tabela.')
    )
  }
  
  basis_df <-
    input_df |>
    filter(fx_idade != '10-14') |>
    mutate(
      fnv_12m = if_else(is.na(filhos_ultimos_12meses),0,filhos_ultimos_12meses) * nr_mulheres,
      semfilhos = if_else( filhos_nascidos_vivos == 0 | is.na(filhos_nascidos_vivos) ,1,0) * nr_mulheres,
      idade_central = map_dbl(
        str_extract_all(fx_idade, "\\d+"), 
        ~ {
          nums <- as.numeric(.x)
          (min(nums) + max(nums) + 1) / 2
        }
      )
    ) |> 
    group_by(ano, subgrp, fx_idade, idade_central) |>
    summarise(
      # age specific fertility rate
      tef = sum(fnv_12m, na.rm = TRUE) / sum(nr_mulheres, na.rm = TRUE),
      pct_semfilhos = sum(semfilhos, na.rm=TRUE) / sum(nr_mulheres, na.rm=TRUE),
      .groups='drop'
    ) |>
    mutate(
      num_imf = tef * idade_central
    )
  
  
  tef_df <- 
    basis_df |>
    transmute(
      key = fx_idade,
      value = tef
    )
  
  semfilhos_df <-
    basis_df |>
    transmute(
      key = fx_idade,
      value = pct_semfilhos
    )
  
  tft_periodo <-
    basis_df |>
    summarise(5.0 * sum(tef, na.rm=TRUE)) |> 
    pull()
  
  
  imf <-
    basis_df |>
    summarise(sum(num_imf, na.rm = TRUE) / sum(tef, na.rm=TRUE)) |> 
    pull()
  
  return(
    list(
      tef_df = tef_df,
      semfilhos_df = semfilhos_df,
      tft_periodo = tft_periodo,
      imf = imf
    )
  )
} # fert_period_measures <- function(input_df)







fert_cohort_measures <- function(input_df){
  # garante que dataframe contém a estrutura necessária...
  for(col_name in c('subgrp', 'ano', 'fx_idade', 'filhos_nascidos_vivos', 'nr_mulheres')){
    assert_that(
      col_name %in% names(input_df), msg = paste0('coluna ', col_name, ' ausente da tabela.')
    )
  }
  
  # correção de valores implausíveis de 'filhos_nascidos_vivos'
  plausible_df <- 
    input_df |>
      mutate(
        aux = as.numeric(sub(".*-", "", fx_idade)) + 1,
        nr_mulheres_elbadry = if_else( 
          filhos_nascidos_vivos > 2.0/3.0 * aux - 8.0, 
          0, 
          round(nr_mulheres, 0)
        )
      )
  
  ppr_df <- 
    plausible_df |>
    mutate(
      fnv_reclass = case_when(
        filhos_nascidos_vivos >= 4 ~ '4+',
        TRUE ~ as.character(filhos_nascidos_vivos)
      ),
      fnv_reclass = factor(
        fnv_reclass,
        levels = c('0','1','2','3','4+'),
        ordered = TRUE
      )
    ) |>
    # agrupando por filhos nascidos vivos reclassificados 0-1-2-3-4+
    group_by(ano, subgrp, fx_idade, fnv_reclass) |>
    summarise(
      n = sum(nr_mulheres_elbadry, na.rm = TRUE), 
      .groups = 'drop'
    ) |>
    complete(ano, subgrp, fx_idade, fnv_reclass, fill = list(n = 0)) |>
    # calculando mulheres com pelo menos n filhos
    group_by(ano, subgrp, fx_idade) |> 
    mutate(
      n_reverso = rev(cumsum(rev(n)))
    ) |> 
    # calculando as razões de parturição
    mutate(
      razao = lead(n_reverso) / n_reverso
    ) |> 
    # calculando a TFT de coorte
    mutate(
      prod_acum = cumprod(razao),
      x_tick = paste0(fnv_reclass, "-", lead(fnv_reclass)),
      resultado_final = if_else(is.na(razao), NA, cumsum(prod_acum))
    ) |> 
    filter(fx_idade == '45-49') |>
    drop_na() |>
    ungroup() |>
    transmute(
      key = x_tick,
      value = prod_acum
    )
  
  tft_coorte <- ppr_df |>
    summarise(
      sum(value, na.rm = TRUE), 
      .groups = 'drop'
    ) |> pull()
  
  
  return(
    list(
      ppr_df = ppr_df,
      tft_coorte = tft_coorte
    )
  )
} # fert_cohort_measures <- function(input_df)




export_eda_period_tef <- function(arg_ano, arg_var, output_file, plot_width, plot_height){
  
  if(arg_ano == 2000) { subset_df <- censo2000_fecundidade_subset}
  if(arg_ano == 2010) { subset_df <- censo2010_fecundidade_subset}
  
  plt_data <-
    subset_df |>
    filter( 
      fx_idade != '10-14',
      !!sym(arg_var) != 'ignorado'
    ) |>
    transmute(
      var = arg_var,
      level = .data[[arg_var]],
      ano,
      fx_idade,
      filhos_nascidos_vivos,
      tef_num = if_else(
        is.na(filhos_ultimos_12meses),
        0,
        filhos_ultimos_12meses * peso_amostral
      ),
      peso_amostral
    ) 
  
  plt <-
    plt_data |>
    group_by(var, level, ano, fx_idade) |>
    summarise(
      tef = sum(tef_num, na.rm = TRUE) / sum(peso_amostral, na.rm=TRUE),
      .groups = 'drop'
    ) |>
    collect() |>
    mutate(
      level = factor(
        level,
        levels = c('nenhuma','alguma','grande','incapaz')
      )
    ) |>
    ggplot( 
      aes(x = fx_idade, y=tef, group = level, color=level)) + 
    geom_line() +
    theme(
      legend.position = 'top'
    ) +
    labs(
      x = "Faixa etária das mulheres",
      y = "TEF",
      color = ""
    )
  
  ggsave(
    filename = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )
  
  
} # export_eda_period_tef <- function(arg_ano, arg_var, output_file, plot_width, plot_height)





export_ppr_plot <- function(input_file, arg_ano, arg_categ, output_file, plot_width, plot_height){

  plt_data <-
    read_csv(
      file = input_file,
      show_col_types = FALSE
    ) |>
    mutate(fx_idade = factor(fx_idade)) |>
    filter(ano == arg_ano, subgrp == arg_categ) |>
    group_by(subgrp, ano, fx_idade) |>
    summarise(
      ppr = median(value),
      ppr_low = hdi(value, credMass = 0.95)[1],
      ppr_upp = hdi(value, credMass = 0.95)[2],
      .groups = 'drop'
    )

  plt <-
    plt_data |>
    ggplot(
      aes(x = fx_idade, group = subgrp)
    ) +
    geom_ribbon(
      aes(
        ymin = ppr_low,
        ymax = ppr_upp,
        ),
      alpha = 0.2
    ) +
    geom_line(
      aes(y = ppr), 
      size = 1
    ) +
    labs(
      fill = "",
      title = "",
      x = "Progressão de parturição",
      y = "Razão"
    )

  ggsave(
    file = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )
  
} # export_ppr_plot <- function(input_file, arg_ano, arg_categ, output_file, plot_width, plot_height)




export_cohort_tfr_plot <- function(input_file,arg_ano,arg_categ,output_file,plot_width,plot_height){
  
  plt_data <-
    read_csv(
      file = input_file, 
      show_col_types = FALSE
    ) |>
    filter(ano == arg_ano, subgrp == arg_categ) |>
    mutate(ano = factor(ano))

  dens <- density(plt_data$value)
  df_dens <- data.frame(x = dens$x, y = dens$y)
  
  low_val  <- hdi(plt_data$value, credMass = 0.95)[1]
  high_val <- hdi(plt_data$value, credMass = 0.95)[2]

  med_val <- median(plt_data$value)
  med_dens <- approx(dens$x, dens$y, xout = med_val)$y
  

  plt <-
    plt_data |>
    ggplot(aes(x = value)) +
    geom_density() +
    geom_ribbon(
      data = df_dens[df_dens$x >= low_val & df_dens$x <= high_val, ],
      aes(x = x, ymin = 0, ymax = y),
      fill = "black", 
      alpha = 0.2
    ) +
    # 3. Linha da densidade (contorno)
    geom_density(color = "black") +
    # 4. Apenas a linha da mediana tracejada parando na curva
    annotate(
      "segment", 
      x = med_val, xend = med_val, 
      y = 0, yend = med_dens, 
      linetype = "dashed", 
      color = "black"
    ) +
    scale_x_continuous(
      breaks = sort(c(pretty(plt_data$value), low_val, med_val, high_val)),
      labels = function(x) round(x, 2),
      guide = guide_axis(n.dodge = 2)
    ) + 
    labs(
      title = "",
      x = "TFT de Coorte",
      y = "Densidade de probabilidade"
    )

  ggsave(
    file = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )

} # export_cohort_tfr_plot <- function(input_file,arg_ano,arg_categ,output_file,plot_width,plot_height)







export_period_tfr_plot <- function(input_file,arg_ano,arg_categ,output_file,plot_width,plot_height){
  
  plt_data <-
    read_csv(
      file = input_file, 
      show_col_types = FALSE
    ) |>
    filter(ano == arg_ano, subgrp == arg_categ) |>
    ## filter(value < mean(value) + 3*sd(value)) |>
    mutate(ano = factor(ano))

  dens <- density(plt_data$value)
  df_dens <- data.frame(x = dens$x, y = dens$y)
  
  low_val  <- hdi(plt_data$value, credMass = 0.95)[1]
  high_val <- hdi(plt_data$value, credMass = 0.95)[2]

  med_val <- median(plt_data$value)
  med_dens <- approx(dens$x, dens$y, xout = med_val)$y
  

  plt <-
    plt_data |>
    ggplot(aes(x = value)) +
    geom_density() +
    geom_ribbon(
      data = df_dens[df_dens$x >= low_val & df_dens$x <= high_val, ],
      aes(x = x, ymin = 0, ymax = y),
      fill = "black", 
      alpha = 0.2
    ) +
    # 3. Linha da densidade (contorno)
    geom_density(color = "black") +
    # 4. Apenas a linha da mediana tracejada parando na curva
    annotate(
      "segment", 
      x = med_val, xend = med_val, 
      y = 0, yend = med_dens, 
      linetype = "dashed", 
      color = "black"
    ) +
    scale_x_continuous(
      breaks = sort(c(pretty(plt_data$value), low_val, med_val, high_val)),
      labels = function(x) round(x, 2),
      guide = guide_axis(n.dodge = 2)
    ) + 
    labs(
      title = "",
      x = "TFT de Período",
      y = "Densidade de probabilidade"
    )

  ggsave(
    file = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )

} # export_period_tfr_plot <- function(input_file,arg_ano,arg_categ,output_file,plot_width,plot_height)








export_period_avg_fert_age_plot <- function(input_file,arg_ano,arg_categ,output_file,plot_width,plot_height){
  
  plt_data <-
    read_csv(
      file = input_file, 
      show_col_types = FALSE
    ) |>
    filter(ano == arg_ano, subgrp == arg_categ) |>
    mutate(ano = factor(ano)) |>
    drop_na()

  dens <- density(plt_data$value)
  df_dens <- data.frame(x = dens$x, y = dens$y)
  
  low_val  <- hdi(plt_data$value, credMass = 0.95)[1]
  high_val <- hdi(plt_data$value, credMass = 0.95)[2]

  med_val <- median(plt_data$value)
  med_dens <- approx(dens$x, dens$y, xout = med_val)$y
  

  plt <-
    plt_data |>
    ggplot(aes(x = value)) +
    geom_density() +
    geom_ribbon(
      data = df_dens[df_dens$x >= low_val & df_dens$x <= high_val, ],
      aes(x = x, ymin = 0, ymax = y),
      fill = "black", 
      alpha = 0.2
    ) +
    # 3. Linha da densidade (contorno)
    geom_density(color = "black") +
    # 4. Apenas a linha da mediana tracejada parando na curva
    annotate(
      "segment", 
      x = med_val, xend = med_val, 
      y = 0, yend = med_dens, 
      linetype = "dashed", 
      color = "black"
    ) +
    scale_x_continuous(
      breaks = sort(c(pretty(plt_data$value), low_val, med_val, high_val)),
      labels = function(x) round(x, 2),
      guide = guide_axis(n.dodge = 2)
    ) + 
    labs(
      title = "",
      x = "Idade média à fecundidade",
      y = "Densidade de probabilidade"
    )

  ggsave(
    file = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )

} # export_period_avg_fert_age_plot <- function(input_file,arg_ano,arg_categ,output_file,plot_width,plot_height)




export_period_childless_plot <- function(input_file, arg_ano, arg_categ, output_file, plot_width, plot_height){

  plt_data <-
    read_csv(
      file = input_file,
      show_col_types = FALSE
    ) |>
    mutate(fx_idade = factor(fx_idade)) |>
    filter(ano == arg_ano, subgrp == arg_categ) |>
    group_by(subgrp, ano, fx_idade) |>
    summarise(
      ppr = median(value),
      ppr_low = hdi(value, credMass = 0.95)[1],
      ppr_upp = hdi(value, credMass = 0.95)[2],
      .groups = 'drop'
    )

  plt <-
    plt_data |>
    ggplot(
      aes(x = fx_idade, group = subgrp)
    ) +
    geom_ribbon(
      aes(
        ymin = ppr_low,
        ymax = ppr_upp,
        ),
      alpha = 0.2
    ) +
    geom_line(
      aes(y = ppr), 
      size = 1
    ) +
    labs(
      fill = "",
      title = "",
      x = "Faixa etária",
      y = "Proporção de mulheres sem filhos"
    )

  ggsave(
    file = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )
  
} # export_period_childless_plot <- function(input_file, arg_ano, arg_categ, output_file, plot_width, plot_height)




export_period_asfr_plot <- function(input_file, arg_ano, arg_categ, output_file, plot_width, plot_height){

  plt_data <-
    read_csv(
      file = input_file,
      show_col_types = FALSE
    ) |>
    mutate(fx_idade = factor(fx_idade)) |>
    filter(ano == arg_ano, subgrp == arg_categ) |>
    group_by(subgrp, ano, fx_idade) |>
    summarise(
      ppr = median(value),
      ppr_low = hdi(value, credMass = 0.95)[1],
      ppr_upp = hdi(value, credMass = 0.95)[2],
      .groups = 'drop'
    )

  plt <-
    plt_data |>
    ggplot(
      aes(x = fx_idade, group = subgrp)
    ) +
    geom_ribbon(
      aes(
        ymin = ppr_low,
        ymax = ppr_upp,
        ),
      alpha = 0.2
    ) +
    geom_line(
      aes(y = ppr), 
      size = 1
    ) +
    labs(
      fill = "",
      title = "",
      x = "Faixa etária",
      y = "Taxa Específica de Fecundidade (TEF)"
    )

  ggsave(
    file = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )
  
} # export_period_asfr_plot <- function(input_file, arg_ano, arg_categ, output_file, plot_width, plot_height)



export_bs_comp_density <- function(file, x_label, plot_width, plot_height){
  plt_data <-
    read_csv(
      file = paste0(results_dir, file, ".csv"),
      show_col_types = FALSE
    ) |>
    mutate(
      ano = factor(ano),
      subgrp = case_match(
        subgrp,
        "deficiente_auditivo" ~ "Deficiente Auditivo",
        "surdo" ~ "Surdo",
        "surdocego" ~ "Surdocego",
        "ouvinte" ~ "Ouvinte"
      )
    ) |>
    filter( value < mean(value, na.rm=TRUE) + 3*sd(value, na.rm=TRUE))

  plt <-
    plt_data |>
    ggplot(
      aes(x = subgrp, y = value, fill = subgrp, color=subgrp)
    ) +
    geom_boxplot(alpha=0.3) + 
    facet_wrap(~ ano, ncol=1) +
    labs(
      title = "",
      x = "",
      y = x_label,
      fill = ""
    ) +
    coord_flip() +
    theme(legend.position = "none")

  ggsave(
    filename = paste0(results_dir, file, ".pdf"),
    plot = plt,
    width = plot_width,
    height = plot_height
  )

} # export_bs_comp_density <- function(file, x_label, plot_width, plot_height)






export_bs_comp_lineplot <- function(file, x_label, y_label, plot_width, plot_height){

  plt_data <-
    read_csv(
      file = paste0(results_dir, file, ".csv"),
      show_col_types = FALSE
    ) |>
    mutate(
      ano = factor(ano),
      subgrp = case_match(
        subgrp,
        "deficiente_auditivo" ~ "Deficiente Auditivo",
        "surdo" ~ "Surdo",
        "surdocego" ~ "Surdocego",
        "ouvinte" ~ "Ouvinte"
      )
    ) |>
    group_by(subgrp, ano, fx_idade) |>
    summarise(
      avg = mean(value, na.rm=TRUE),
      low = hdi(value, credMass=0.95)[1],
      upp = hdi(value, credMass=0.95)[2],
      .groups = 'drop'
    )

  plt <-
    plt_data |>
    ggplot( 
      aes(
        x = fx_idade, 
        y = avg, 
        group = subgrp, 
        color = subgrp, 
        fill = subgrp
      )
    ) +
    geom_ribbon(
      aes(ymin = low, ymax = upp), alpha = 0.2, color = NA) +
    geom_line(size = 1) +
    facet_wrap(~ ano, ncol=1) +
    theme(
      legend.position = 'top'
    ) + 
    labs(
      x = x_label, 
      y = y_label, 
      color = "", 
      fill = ""
    )

  ggsave(
    filename = paste0(results_dir, file, ".pdf"),
    plot = plt,
    width = plot_width,
    height = plot_height
  )

  
} # export_bs_comp_lineplot <- function(file, x_label, y_label, plot_width, plot_height)



bootstrap_summary <- function(csv_file, measure){

  key_expression <- if (grepl('df', csv_file)) sym("fx_idade") else NA_character_

  aux <-
    read_csv(
      file = paste0(
        results_dir,
        csv_file
      ),
      show_col_types = FALSE
    ) |>
    mutate( 
      key = !!key_expression,
      measure = measure
    ) |>
    group_by(ano, subgrp, measure, key) |>
    summarise( 
      avg = mean(value, na.rm=TRUE),
      low = hdi(value, credMass = 0.95)[1],
      upp = hdi(value, credMass = 0.95)[2],
      .groups = 'drop'
    )

  return(aux)
} # bootstrap_summary <- function(csv_file, measure, key)


export_bs_latex <- function(bs_df, categ, output_file){
  
  bs_latex <- 
    bs_df |>
    filter(subgrp == categ) |>
    mutate(
      key = if_else( is.na(key), '', key)
    ) |>
    pivot_wider(
      names_from = ano,
      values_from = c(avg, low, upp),
      names_glue = "{.value}_{ano}"
    ) |> 
    select(subgrp, measure, key, avg_2000, low_2000, upp_2000, avg_2010, low_2010, upp_2010) |>
    mutate(
      measure = case_match(
        measure,
        'cohort_tfr' ~ 'Taxa de Fecundidade Total (TFT) de coorte',
        'period_tfr' ~ 'Taxa de Fecundidade Total (TFT) de período',
        'period_afa' ~ 'Idade média à fecundidade',
        'period_asfr' ~ 'Taxa Específica de Fecundidade (TEF)',
        'cohort_ppr' ~ 'Razão de progressão de parturição',
        'period_childless' ~ 'Proporção de mulheres sem filhos'
      ),
      across(where(is.numeric), \(x) format(round(x, 3), big.mark='.', decimal.mark=','))
    ) |>
    arrange(subgrp, measure, key) |>
    group_by(subgrp, measure) |>
    mutate(
      n_linhas = n(),
      row_idx = row_number(),
      measure = if_else(
        row_idx == 1, 
        if_else(
          n_linhas == 1,
          paste0("\\midrule ", measure),
          paste0("\\midrule \\multirow{", n_linhas, "}{=}{", measure, "}")
        ),
        ""
      )
    ) |>
    ungroup() |>
    # REMOVE O MIDRULE APENAS DA LINHA 1 DA TABELA
    mutate(
      measure = if_else(row_number() == 1, sub("\\\\midrule ", "", measure), measure)
    ) |>
    select(-n_linhas, -row_idx, -subgrp)

  res_table <- xtable::xtable(bs_latex)

  tab_out <- 
    capture.output(
      print(
        res_table, 
        include.rownames = FALSE, 
        include.colnames = FALSE,
        only.contents = TRUE,
        sanitize.text.function = identity,
        hline.after = NULL
      )
    )

  idx <- max(which(grepl("\\\\\\\\", tab_out)))

  tab_out[idx] <- sub("\\\\\\\\\\s*$", "", tab_out[idx])

  cat(
    tab_out, 
    sep = "\n", 
    file = output_file
  )

} # export_bs_latex <- function(bs_df, categ, output_file)




prevalence_all_ages <- function(arg_var, arg_output_file, arg_append){

  message("calculando prevalência de ",arg_var, "...")

  # (re)inicializa tabela de resultados em branco
  outer_table <-
    tibble(
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
  svy_prop_method <- 'xlogit'

  for(arg_subgrp in SUBGRPS){

    tic()

    message("   para o grupo ", arg_subgrp, "...")

    if(arg_subgrp == 'categ_total'){

      inner_table <-
        pns2019_posterior |>
        as_survey() |>
        ## filter(sexo=='feminino') |>
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
        ## filter(sexo=='feminino') |>
        filter( .data[[arg_subgrp]] == 1) |>
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
