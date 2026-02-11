
censo2000_abt <-
  open_dataset(
    paste0(
      data_dir,
      "censo2000_abt.parquet"
    )
  ) |>
  to_duckdb()

censo2000_abt |>
  head(10) |>
  collect() |>
  View()

censo2000_abt |>
  count(dif_ouvir) 


censo2000_abt |>
  glimpse()

censo2000_abt |>
  group_by(dif_ouvir) |>
  count(sabe_libras)
