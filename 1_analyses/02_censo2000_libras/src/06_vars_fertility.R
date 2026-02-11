
FILE <- "censo2000_fertility"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_fertility <-
  subset_censo2000 |>
  transmute(
    row_id,
    # ......... Variáveis referentes à Fecundidade .........
    filhos_nascidos_vivos = v4620,
    filhos_nascidos_vivos_vivos = v0463,
    filhos_nascidos_mortos = v4670,
    filhos_nascidos = v4690
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_fertility |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_fertility.csv")
  )
toc()

gc()

