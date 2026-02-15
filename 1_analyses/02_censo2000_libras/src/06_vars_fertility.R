FILE <- "censo2000_fertility"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_fertility <-
  subset_censo2000 |>
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes à Fecundidade .........
    # TODO incluir filhos nascidos ultimos 12 meses
    filhos_nascidos_vivos = ifelse(v4620=='', NA, as.numeric(v4620)),
    filhos_nascidos_vivos_vivos = ifelse(v0463=='', NA, as.numeric(v0463)),
    filhos_nascidos_mortos = ifelse(v4670=='', NA, as.numeric(v4670)),
    filhos_nascidos = ifelse(v4690=='', NA, as.numeric(v4690))
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_fertility |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_fertility.csv"),
    na = ""
  )
toc()

gc()
