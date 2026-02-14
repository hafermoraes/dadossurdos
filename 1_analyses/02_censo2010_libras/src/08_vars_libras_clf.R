
gc()

FILE <- "censo2010_libras"

tic()
message("preparando ", FILE, " no duckdb...")

censo2010_oos <-
  censo2010_common |>
  select(
    row_id,
    idade, sexo, instrucao, dif_ouvir
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
PREDICT_GRANDE <- TRUE
PREDICT_INCAPAZ <- TRUE


dif_ouvir_nenhuma <-
  censo2010_oos |>
  filter(
    dif_ouvir == 'nenhuma'
  )


dif_ouvir_alguma <-
  censo2010_oos |>
  filter(
    dif_ouvir == 'alguma'
  )

dif_ouvir_grande <-
  censo2010_oos |>
  filter(
    dif_ouvir == 'grande'
  )

dif_ouvir_incapaz <-
  censo2010_oos |>
  filter(
    dif_ouvir == 'incapaz'
  )

dif_ouvir_ignorado <-
  censo2010_oos |>
  filter(
    dif_ouvir == 'ignorado'
  ) |>
  transmute(
    row_id,
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
        'mars/',
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
        'xgb/',
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
        'nb/',
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
      sabe_libras = ''
    ) |>
    collect()
  
}

censo2010_libras <-
  bind_rows(
    preds_nenhuma, 
    preds_alguma,
    preds_grande,
    preds_incapaz,
    dif_ouvir_ignorado
  ) |>
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
censo2010_libras |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_libras.csv"),
    na = ""
  )
toc()

gc()
