tic()
message("importanto dados da pns2019 para a comparação...")
pns2019 <-
  read_csv(
    file = pns2019_csv,
    show_col_types=FALSE
  )
toc()

tic()
message("importanto dados do censo2000 para a comparação...")
censo2000 <-
  open_dataset(
    censo2000_parquet
  ) |>
  to_duckdb()
toc()

tic()
message("importanto dados do censo2010 para a comparação...")
censo2010 <-
  open_dataset(
    censo2010_parquet
  ) |>
  to_duckdb()
toc()
