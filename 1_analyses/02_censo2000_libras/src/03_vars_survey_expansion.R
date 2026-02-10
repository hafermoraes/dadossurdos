
censo2000_survey_expansion <-
  subset_censo2000 |>
  transmute(
    row_id, 
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=areap,
    peso_amostral=as.numeric(p001)/1e8
  )
