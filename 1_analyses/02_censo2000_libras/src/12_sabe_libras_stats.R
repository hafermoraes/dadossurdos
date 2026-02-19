
ANO_CENSO <- 2000

tic()
message("estimação dos usuários de libras no censo", ANO_CENSO)
  censo2000 |>
  filter(dif_ouvir %in% c('grande', 'incapaz')) |>
  transmute(
    dif_ouvir,
    peso_amostral = as.numeric(peso_amostral),
    sabe_libras_01 = case_when(
      sabe_libras == 'sim' ~ 1,
      TRUE ~ 0
    )
  ) |>
  as_survey_design(
    ids = 1,
    weights = peso_amostral
  ) |>
  group_by(dif_ouvir) |>
  summarise(
    # total de pessoas no grupo
    N = survey_total(na.rm=TRUE, vartype = 'ci'),
    # total de usuários de libras (preditivo) no grupo
    n = survey_total(sabe_libras_01, na.rm = TRUE, vartype = 'ci'),
    # percentual de usuários de libras (preditivo) no grupo
    p = survey_mean(sabe_libras_01, na.rm = TRUE, vartype = 'ci')
  ) |>
  collect()
toc()
