
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


