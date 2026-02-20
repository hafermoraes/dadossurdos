
tic()
message("importanto dados do censo2000 para as análises de mortalidade...")
censo2000_abt <-
  open_dataset(
    censo2000_abt_parquet
  ) |>
  to_duckdb()
toc()

tic()
message("importanto dados do censo2010 para as análises de mortalidade...")
censo2010_abt <-
  open_dataset(
    censo2010_abt_parquet
  ) |>
  to_duckdb()
toc()
