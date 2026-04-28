

tic("importando dados do censo2010 para as análises espaciais...")
censo2010_abt <-
  open_dataset(
    censo2010_abt_parquet
  ) |>
  to_duckdb()
toc()


tic("agregando totais populacionais por área de ponderação...")
censo2010_df <-
  censo2010_abt %>%
  transmute(
    area_ponderacao,
    peso_amostral,
    categ_surdo,
    categ_difouvir_incapaz = ifelse(dif_ouvir == 'incapaz', 1, 0)
  ) %>%
  mutate(
    across(c(peso_amostral, categ_surdo, categ_difouvir_incapaz), as.numeric)
  ) %>%
  group_by(area_ponderacao) %>%
  summarise(
    N = sum(peso_amostral, na.rm=TRUE),
    N_incapaz = sum( categ_difouvir_incapaz * peso_amostral, na.rm = TRUE),
    N_surdo = sum( categ_surdo * peso_amostral, na.rm = TRUE),
    .groups = 'drop'
  ) %>%
  collect()
toc()
