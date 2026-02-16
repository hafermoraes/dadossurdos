FILE <- "censo2010_fertility"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_fertility <-
  subset_censo2010 |>
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes à Fecundidade .........
    # TODO incluir filhos nascidos ultimos 12 meses
    filhos_nascidos_vivos = ifelse(v6633=='', NA, as.numeric(v6633)),
    filhos_nascidos_vivos_vivos = ifelse(v6643=='', NA, as.numeric(v6643)),
    filhos_nascidos_mortos = ifelse(v6633=='' && v6643=='', NA, filhos_nascidos_vivos - filhos_nascidos_vivos_vivos),
    filhos_nascidos = ifelse(v6800=='', NA, as.numeric(v6800)),
    idade_ultimo_filho = ifelse(v6660=='', NA, as.numeric(v6660))
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_fertility |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_fertility.csv"),
    na = ""
  )
toc()

gc()
