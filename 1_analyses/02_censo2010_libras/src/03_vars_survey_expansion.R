FILE <- "censo2010_survey_expansion"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_survey_expansion <-
  subset_censo2010 |>
  # finalização da tabela de análises
  transmute(
    row_id, 
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=v0011,
    peso_amostral=as.numeric(v0010)/1e13
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_survey_expansion |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_survey_expansion.csv"),
    na = ""
  )
toc()

gc()
