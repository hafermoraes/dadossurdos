
microdados_svy <-
  open_dataset(
    "/tmp/etl/br_ibge_pns_2019/parquet"
  ) |>
  rename_with(tolower) |>
  filter(v0015 == '01', !is.na(v0015), m001 == '1', !is.na(m001)) |>
  select(
    v0024,v0029,upa_pns,v00292,v00293, # expansão da amostra probabilística
    v0001,  # uf de residência
    c006,   # sexo
    c008,   # idade
    c009,   # cor ou raça
    d001,   # alfabetizado
    c011,   # estado civil
    d00901, # instrução
    g047,   # dificuldade de enxergar
    g058,   # dificuldade de ouvir
    g071,   # dificuldade de locomover
    g05801  # sabe libras
  ) |>
  mutate(v0029=as.numeric(v0029)) |>
  collect()

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <- survey::svydesign(
  ids = ~upa_pns,
  strata = ~v0024,
  data = microdados_svy,
  weights = ~v0029,
  nest = TRUE
)

# Post-stratification
popc.types <-
  data.frame(
    v00293=as.character(unique(microdados_svy$v00293)),
    Freq=as.numeric(unique(microdados_svy$v00292))
  )
popc.types <- popc.types[order(popc.types$v00293),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior,
    strata=~v00293,
    population=popc.types
  )

gc()

## matriz de modelo preditivo libras
tic()
rawdata <-
  svytable(
    formula=~v0001+c006+c008+c009+d001+c011+d00901+g047+g071+g058+g05801,
    design=pns2019_posterior
  ) |>
  as_tibble() |>
  filter(n>0) |>
  group_by(across(-n)) |>
  summarise(n=sum(n)) |>
  arrange(desc(n)) |>
  ungroup()
toc()

gc()

rawdata |>
  write_csv(
    paste0(
      data_dir,
      'pns2019_01_rawdata.csv'
    )
  )
