
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
      semfilhos = if_else( filhos_nascidos_vivos == 0,1,0) * nr_mulheres,
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
    filter(value < quantile(value, 0.999)) |>
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

