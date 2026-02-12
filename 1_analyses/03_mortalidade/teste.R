
censo2010_abt <-
  open_dataset(
    paste0(
      '/home/rstudio/',
      '1_analyses/',
      '02_censo2010_libras/',
      'data/',
      "censo2010_abt.parquet"
    )
  ) |>
  to_duckdb()

censo2010_abt |>
  mutate(
    across(c(idade, peso_amostral), as.numeric),
    cat = case_when(
      (dif_enxergar %in% c('grande','incapaz')) & (dif_ouvir %in% c('grande','incapaz')) & sabe_libras == 'sim' ~ 'SC',
      TRUE ~ 'demais'
    )
  ) |>
  filter(cat == 'SC')|>
  group_by(sexo, idade) |>
  summarise(s=sum(peso_amostral)) |>
  arrange(sexo, idade)|>
  collect() |>
  View()


censo2010_abt |>
  mutate(
    across(c(idade, peso_amostral), as.numeric),
    cat_oficial = case_when(
      dif_ouvir %in% c('nenhuma', 'alguma') ~ 'OV',
      dif_ouvir %in% c('grande', 'incapaz') ~ 'DA'
    ),
    cat_tese = case_when(
      dif_ouvir %in% c('grande', 'incapaz') & sabe_libras == 'sim' ~ 'SS'
    )
  ) |>
  group_by(cat, sexo) |>
  summarise(n=sum(peso_amostral)) |>
  arrange(cat, sexo) |>
  collect() |>
  View()
