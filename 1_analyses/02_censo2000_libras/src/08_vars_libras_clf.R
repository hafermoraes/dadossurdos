#' @title Predição de Uso de Libras (Censo 2000) via Modelos PNS 2019
#' 
#' @description
#' Este script aplica classificadores treinados no projeto PNS 2019 aos microdados do 
#' Censo 2000. O processo é segmentado pelo nível de deficiência auditiva (\code{dif_ouvir}), 
#' utilizando modelos específicos (XGBoost, Naive Bayes, MARS) para cada estrato, 
#' visando imputar a variável \code{sabe_libras} em uma base histórica.
#'
#' @section Estratégia de Classificação:
#' \itemize{
#'   \item \bold{Segmentação}: A base é dividida em 5 subgrupos: \emph{nenhuma, alguma, grande, incapaz} e \emph{ignorado}.
#'   \item \bold{Modelos Carregados}: 
#'     \itemize{
#'       \item \code{grande}: Utiliza XGBoost (\code{xgb}).
#'       \item \code{incapaz}: Utiliza Naive Bayes (\code{nb}).
#'       \item \code{nenhuma/alguma}: Configuráveis via flags (atualmente desativadas).
#'     }
#'   \item \bold{Threshold Ótimo}: Aplica o ponto de corte específico de cada modelo 
#'     (\code{optimum_threshold}) para binarizar a predição de probabilidade em "sim/nao".
#' }
#'
#' @section Fluxo de Dados:
#' \enumerate{
#'   \item Coleta os dados do \code{duckdb} para memória (\code{collect}).
#'   \item Realiza a predição via \code{predict()} do ecossistema \code{tidymodels}.
#'   \item Consolida os resultados (\code{bind_rows}) e exporta para CSV.
#' }
#'
#' @name 08_vars_libras_clf_censo
NULL


gc()

FILE <- "censo2000_libras"

tic()
message("preparando ", FILE, " no duckdb...")

censo2000_oos <-
  censo2000_common |>
  select(
    row_id,
    idade, sexo, instrucao, dif_ouvir, dif_enxergar
  ) 

pns2019_clf_base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '01_pns2019_clf_libras/',
    'results/'
  )

PREDICT_NENHUMA <- FALSE
PREDICT_ALGUMA <- FALSE
PREDICT_GRANDE <- FALSE
PREDICT_INCAPAZ <- TRUE


dif_ouvir_nenhuma <-
  censo2000_oos |>
  filter(
    dif_ouvir == 'nenhuma'
  )

dif_ouvir_alguma <-
  censo2000_oos |>
  filter(
    dif_ouvir == 'alguma'
  )

dif_ouvir_grande <-
  censo2000_oos |>
  filter(
    dif_ouvir == 'grande'
  )

dif_ouvir_incapaz <-
  censo2000_oos |>
  filter(
    dif_ouvir == 'incapaz'
  )

dif_ouvir_ignorado <-
  censo2000_oos |>
  filter(
    dif_ouvir == 'ignorado'
  ) |>
  transmute(
    row_id,
    dif_ouvir,
    dif_enxergar,
    sabe_libras = ''
  ) |> 
  collect()



# predição da probabilidade de saber linhas 
#    dif_ouvir == 'nenhuma'
if(PREDICT_NENHUMA){
  
  clf <-
    read_rds(
      paste0(
        pns2019_clf_base_dir,
        'mod02_nenhuma/',
        'mlp/',
        'model.rds'
      )
    )

  dif_ouvir_nenhuma <-
    dif_ouvir_nenhuma |>
    collect()
    
  predict_probs <-
    predict(
      clf$clf_model, 
      new_data = dif_ouvir_nenhuma, 
      type = "prob" 
    ) 
  
  preds_nenhuma <-
    bind_cols(
      dif_ouvir_nenhuma,
      predict_probs
    ) |> 
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ifelse(
        .pred_sim >= clf$optimum_threshold,
        "sim",
        "nao"
      )
    )
  
} else {

  preds_nenhuma <- 
    dif_ouvir_nenhuma |>
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ''
    ) |>
    collect()
  
}

# predição da probabilidade de saber linhas 
#    dif_ouvir == 'alguma'
if(PREDICT_ALGUMA){
  
  clf <-
    read_rds(
      paste0(
        pns2019_clf_base_dir,
        'mod03_alguma/',
        'nb/',
        'model.rds'
      )
    )

  dif_ouvir_alguma <-
    dif_ouvir_alguma |>
    collect()
    
  predict_probs <-
    predict(
      clf$clf_model, 
      new_data = dif_ouvir_alguma, 
      type = "prob" 
    ) 
  
  preds_alguma <-
    bind_cols(
      dif_ouvir_alguma,
      predict_probs
    ) |> 
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ifelse(
        .pred_sim >= clf$optimum_threshold,
        "sim",
        "nao"
      )
    )
  
} else {
  
  preds_alguma <- 
    dif_ouvir_alguma |>
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ''
    ) |>
    collect()
  
}


# predição da probabilidade de saber linhas 
#    dif_ouvir == 'grande'
if(PREDICT_GRANDE){
  
  clf <-
    read_rds(
      paste0(
        pns2019_clf_base_dir,
        'mod04_grande/',
        'mlp/',
        'model.rds'
      )
    )

  dif_ouvir_grande <-
    dif_ouvir_grande |>
    collect()
    
  predict_probs <-
    predict(
      clf$clf_model, 
      new_data = dif_ouvir_grande, 
      type = "prob" 
    ) 
  
  preds_grande <-
    bind_cols(
      dif_ouvir_grande,
      predict_probs
    ) |> 
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ifelse(
        .pred_sim >= clf$optimum_threshold,
        "sim",
        "nao"
      )
    )
    
} else {
  
  preds_grande <- 
    dif_ouvir_grande |>
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ''
    ) |>
    collect()
  
}



# predição da probabilidade de saber linhas 
#    dif_ouvir == 'incapaz'
if(PREDICT_INCAPAZ){
  
  clf <-
    read_rds(
      paste0(
        pns2019_clf_base_dir,
        'mod05_incapaz/',
        'rf/',
        'model.rds'
      )
    )

  dif_ouvir_incapaz <-
    dif_ouvir_incapaz |>
    collect()
    
  predict_probs <-
    predict(
      clf$clf_model, 
      new_data = dif_ouvir_incapaz, 
      type = "prob" 
    ) 
  
  preds_incapaz <-
    bind_cols(
      dif_ouvir_incapaz,
      predict_probs
    ) |> 
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ifelse(
        .pred_sim >= clf$optimum_threshold,
        "sim",
        "nao"
      )
    )  
  
} else {
  
  preds_incapaz <- 
    dif_ouvir_incapaz |>
    transmute(
      row_id,
      dif_ouvir,
      dif_enxergar,
      sabe_libras = ''
    ) |>
    collect()
  
}

censo2000_libras <-
  bind_rows(
    preds_nenhuma, 
    preds_alguma,
    preds_grande,
    preds_incapaz,
    dif_ouvir_ignorado
  ) |>
  mutate(
    categ_ouvinte = case_when(
      dif_ouvir == 'nenhuma' ~ 'Ouvinte',
      dif_ouvir == 'alguma'  ~ 'Ouvinte',
      TRUE ~ NA_character_
    ),
    categ_deficiente_auditivo = case_when(
      dif_ouvir == 'grande'  ~ 'Deficiente Auditivo',
      dif_ouvir == 'incapaz' ~ 'Deficiente Auditivo',
      TRUE ~ NA_character_
    ),
    categ_surdo = case_when(
      dif_ouvir == 'grande'  & sabe_libras == 'sim' ~ 'Surdo',
      dif_ouvir == 'incapaz' & sabe_libras == 'sim' ~ 'Surdo',
      TRUE ~ NA_character_
    ),
    categ_surdocego = case_when(
      dif_ouvir == 'grande'  & dif_enxergar == 'grande'  ~ 'Surdo-cego',
      dif_ouvir == 'grande'  & dif_enxergar == 'incapaz' ~ 'Surdo-cego',
      dif_ouvir == 'incapaz' & dif_enxergar == 'grande'  ~ 'Surdo-cego',
      dif_ouvir == 'incapaz' & dif_enxergar == 'incapaz' ~ 'Surdo-cego',
      TRUE ~ NA_character_
    ),
    sabe_libras_nao0sim1 = case_when(
      sabe_libras == 'sim' ~ 1,
      TRUE ~ 0
    )
  ) |>
  select(-dif_ouvir, -dif_enxergar) |>
  to_duckdb()

rm(preds_nenhuma, dif_ouvir_nenhuma, PREDICT_NENHUMA)
rm(preds_alguma, dif_ouvir_alguma, PREDICT_ALGUMA)
rm(preds_grande, dif_ouvir_grande, PREDICT_GRANDE)
rm(preds_incapaz, dif_ouvir_incapaz, PREDICT_INCAPAZ)
rm(dif_ouvir_ignorado)
rm(pns2019_clf_base_dir, clf, predict_probs)

toc()

gc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_libras |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_libras.csv"),
    na = ""
  )
toc()

gc()
