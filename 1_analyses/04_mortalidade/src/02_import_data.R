
tic()
message("importanto dados do censo2000 para as análises de mortalidade...")
censo2000 <-
  open_dataset(
    censo2000_parquet
  ) |>
  to_duckdb()
toc()

tic()
message("importanto dados do censo2010 para as análises de mortalidade...")
censo2010 <-
  open_dataset(
    censo2010_parquet
  ) |>
  to_duckdb()
toc()
