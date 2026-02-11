FILE <- "censo2000_survey_expansion"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_survey_expansion <-
  subset_censo2000 |>
  # finalização da tabela de análises
  transmute(
    row_id, 
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=areap,
    peso_amostral=as.numeric(p001)/1e8
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_survey_expansion |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_survey_expansion.csv"),
    na = ""
  )
toc()

gc()
