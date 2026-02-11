
censo2010_abt <-
  open_dataset(
    paste0(
      data_dir,
      "censo2010_abt.parquet"
    )
  ) |>
  to_duckdb()

censo2010_abt |>
  head(10) |>
  collect() |>
  View()

censo2010_abt |>
  glimpse()

censo2010_abt |>
  group_by(dif_ouvir) |>
  count(sabe_libras)
