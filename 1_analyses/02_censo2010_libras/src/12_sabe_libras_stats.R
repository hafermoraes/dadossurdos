ANO_CENSO <- 2010


tic()
message("estimação dos usuários de libras no censo", ANO_CENSO)
gc()
censo2010_stats_svydesign <-
  censo2010_abt |>
  filter(
    dif_ouvir %in% c('grande', 'incapaz') # reduz tempo de processamento consideravelmente...
  ) |>
  mutate(
    censo = ANO_CENSO,
    across(
      c(peso_amostral, sabe_libras_nao0sim1),
      as.numeric
    )
  ) |>
  as_survey_design(
    ids = 1,
    weights = peso_amostral
  )
toc()






tic()
gc()
message("estimação da quantidade de deficientes auditivos no censo", ANO_CENSO)
censo2010_stats_da <-
  censo2010_stats_svydesign |>
  filter(categ_deficiente_auditivo == 'Deficiente Auditivo') |>
  mutate(
    cat = categ_deficiente_auditivo
  ) |>
  group_by(
    censo,
    cat
  ) |>
  summarise(
    # total de pessoas no grupo
    N = survey_total(na.rm=TRUE, vartype = 'ci'),
    # total de usuários de libras (preditivo) no grupo
    l = survey_total(sabe_libras_nao0sim1, na.rm = TRUE, vartype = 'ci'),
    # percentual de usuários de libras (preditivo) no grupo
    lp = survey_mean(sabe_libras_nao0sim1, na.rm = TRUE, vartype = 'ci')
  ) |>
  collect()
toc()





tic()
gc()
message("estimação da quantidade de surdos no censo", ANO_CENSO)
censo2010_stats_surdo <-
  censo2010_stats_svydesign |>
  filter(categ_surdo == 'Surdo') |>
  mutate(
    cat = categ_surdo
  ) |>
  group_by(
    censo,
    cat
  ) |>
  summarise(
    # total de pessoas no grupo
    N = survey_total(na.rm=TRUE, vartype = 'ci'),
    # total de usuários de libras (preditivo) no grupo
    l = survey_total(sabe_libras_nao0sim1, na.rm = TRUE, vartype = 'ci'),
    # percentual de usuários de libras (preditivo) no grupo
    lp = survey_mean(sabe_libras_nao0sim1, na.rm = TRUE, vartype = 'ci')
  ) |>
  collect()
toc()






tic()
gc()
message("estimação da quantidade de surdos-cegos no censo", ANO_CENSO)
censo2010_stats_surdocego <-
  censo2010_stats_svydesign |>
  filter(categ_surdocego == 'Surdo-cego') |>
  mutate(
    cat = categ_surdocego
  ) |>
  group_by(
    censo,
    cat
  ) |>
  summarise(
    # total de pessoas no grupo
    N = survey_total(na.rm=TRUE, vartype = 'ci'),
    # total de usuários de libras (preditivo) no grupo
    l = survey_total(sabe_libras_nao0sim1, na.rm = TRUE, vartype = 'ci'),
    # percentual de usuários de libras (preditivo) no grupo
    lp = survey_mean(sabe_libras_nao0sim1, na.rm = TRUE, vartype = 'ci')
  ) |>
  collect()
toc()


tic()
gc()
message("consolidando as informações para a tese...")
censo2010_stats <-
  bind_rows(
    censo2010_stats_da,
    censo2010_stats_surdo,
    censo2010_stats_surdocego
  ) |>
  mutate(
    across(
      c(N,N_low,N_upp,l,l_low,l_upp),
      label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")
    ),
    across(
      c(lp, lp_low, lp_upp),
      \(x) 100.0*x
    ),
    across(
      c(lp, lp_low, lp_upp),
      label_number(accuracy = 0.1, big.mark = ".", decimal.mark = ",")
    )
  )
toc()
