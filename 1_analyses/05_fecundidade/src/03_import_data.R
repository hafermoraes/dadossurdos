
tic()
message("importanto dados do censo2000 para as análises de fecundidade...")
censo2000_abt <-
  open_dataset(
    censo2000_abt_parquet
  ) |>
  to_duckdb()
toc()

tic()
message("importanto dados do censo2010 para as análises de fecundidade...")
censo2010_abt <-
  open_dataset(
    censo2010_abt_parquet
  ) |>
  to_duckdb()
toc()

tic()
message("importanto dados da pns2019 para as análises de morbidade...")
pns2019_abt <-
  open_dataset(
    censo2010_abt_parquet
  ) |>
  to_duckdb()
toc()
