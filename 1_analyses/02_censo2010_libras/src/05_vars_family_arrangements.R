
FILE <- "censo2010_family_arrangements"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_family_arrangements <-
  subset_censo2010 |>
  transmute(
    row_id,
    # ......... Variáveis referentes ao Arranjo Domiciliar .........
    relacao_resp_domicilio = v0402,
    nr_ordem_pessoa = v0400,
    id_domicilio = v0300
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_family_arrangements |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_family_arrangements.csv"),
    na = ""
  )
toc()

gc()

