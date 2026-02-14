
pns2019 <-
  read_csv(
    file = pns2019_csv,
    show_col_types=FALSE
  )

censo2000 <-
  open_dataset(
    censo2000_parquet
  ) |>
  to_duckdb()

censo2010 <-
  open_dataset(
    censo2010_parquet
  ) |>
  to_duckdb()

