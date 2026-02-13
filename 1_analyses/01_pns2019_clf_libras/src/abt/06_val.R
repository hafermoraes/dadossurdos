

microdados_dt <- open_dataset(
  "/tmp/etl/br_ibge_pns_2019/parquet"
) |>
  rename_with(tolower) |>
  #filter(v0015 == '01', !is.na(v0015), m001 == '1', !is.na(m001)) |>
  select(
    v0024,v0029,upa_pns,v00292,v00293, # expansão da amostra probabilística
    v0028,v00282,v00283, # expansão da amostra probabilística
    v0001,  # uf de residência
    c006,   # sexo
    c008,   # idade
    c009,   # cor ou raça
    d001,   # alfabetizado
    c011,   # estado civil
    d00901, # instrução
    g046,   # dificuldade de enxergar
    g047,   # dificuldade de enxergar
    g057,   # dificuldade de ouvir
    g058,   # dificuldade de ouvir
    g070,   # dificuldade de locomover
    g071,   # dificuldade de locomover
    g05801  # sabe libras
  ) |>
  mutate(
    across(everything(), str_trim),
    across(
      c(v0024,v0029,v0028,upa_pns,v00292,v00282,v00293,v00283,c008), 
      ~as.numeric(if_else(.x == "", 0, .x))
    )
  ) |>
  collect() |>
  as.data.table()



# popc.types <- microdados_dt[, .(Freq = unique(v00292)), by = v00293]
# sum_weights <- microdados_dt[, .(sumw = sum(v0029)), by = v00293]
# strata_weights <- merge(popc.types, sum_weights, by = "v00293")
# strata_weights[, scale := as.numeric(Freq) / as.numeric(sumw)]
# microdados_dt <- merge(microdados_dt, strata_weights[, .(v00293, scale)], by = "v00293", all.x = TRUE)
# microdados_dt[, weight := v0029 * scale]


options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <-
  survey::svydesign(
    ids = ~upa_pns, 
    strata = ~v0024, 
    data = subset(microdados_dt, !is.na(v0029)), 
    weights = ~v0029, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00293=as.character(unique(microdados_dt$v00293)), 
    Freq=as.numeric(unique(microdados_dt$v00292))
  )
popc.types <- popc.types[order(popc.types$v00293),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00293, 
    population=popc.types
  )


pns2019_posterior |>
  as_survey() |>
  mutate(
    idade = as.numeric(c008),
    dif_ouvir = case_when(
      g057 == '' ~ g058,
      g058 == '' ~ g057,
      TRUE ~ NA
    ),
    libras_01 = case_when(
      g05801 == 1 ~ 1,
      g05801 == 2 ~ 0,
      TRUE ~ NA
    )
  ) |>
  filter(idade >=5 & idade < 40) |>
  group_by(dif_ouvir) |>
  summarise(
    n = survey_mean(libras_01, na.rm = TRUE, vartype=c('se','ci'))
  )












# popc.types <- microdados_dt[, .(Freq = unique(v00282)), by = v00283]
# sum_weights <- microdados_dt[, .(sumw = sum(v0028)), by = v00283]
# strata_weights <- merge(popc.types, sum_weights, by = "v00283")
# strata_weights[, scale := as.numeric(Freq) / as.numeric(sumw)]
# microdados_dt <- merge(microdados_dt, strata_weights[, .(v00283, scale)], by = "v00283", all.x = TRUE)
# microdados_dt[, weight := v0028 * scale]



pns2019_prior <-
  survey::svydesign(
    ids = ~upa_pns, 
    strata = ~v0024, 
    data = subset(microdados_dt, !is.na(v0028)), 
    weights = ~v0028, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00283=as.character(unique(microdados_dt$v00283)), 
    Freq=as.numeric(unique(microdados_dt$v00282))
  )
popc.types <- popc.types[order(popc.types$v00283),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00283, 
    population=popc.types
  )


pns2019_posterior |>
  as_survey() |>
  mutate(
    idade = as.numeric(c008),
    dif_ouvir = case_when(
      g057 == '' ~ g058,
      g058 == '' ~ g057
    ),
    libras_01 = case_when(
      g05801 == 1 ~ 1,
      g05801 == 2 ~ 0,
      TRUE ~ NA
    )
  ) |>
  filter(idade >=5 & idade <= 40) |>
  group_by(dif_ouvir) |>
  summarise(
    n = survey_mean(libras_01, na.rm = TRUE, vartype=c('se','ci'))
  )

