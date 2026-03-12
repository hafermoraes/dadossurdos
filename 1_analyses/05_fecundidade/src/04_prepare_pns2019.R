
tic()
message("importando base tratada na PNS 2019 de ", pns2019_parsed_csv)
pns2019_parsed_data <-
  read_csv(
    file=pns2019_parsed_csv,
    show_col_types = FALSE
  ) |>
  mutate(
    categ_ouvinte = case_when(
      dif_ouvir == 'nenhuma' ~ 1,
      dif_ouvir == 'alguma'  ~ 1,
      TRUE ~ 0
    ),
    categ_deficiente_auditivo = case_when(
      dif_ouvir == 'grande'  ~ 1,
      dif_ouvir == 'incapaz' ~ 1,
      TRUE ~ 0
    ),
    categ_surdo = case_when(
      dif_ouvir == 'grande'  & libras == 'sim' ~ 1,
      dif_ouvir == 'incapaz' & libras == 'sim' ~ 1,
      TRUE ~ 0
    ),
    categ_surdocego = case_when(
      dif_ouvir == 'grande'  & dif_enxergar == 'grande'  ~ 1,
      dif_ouvir == 'grande'  & dif_enxergar == 'incapaz' ~ 1,
      dif_ouvir == 'incapaz' & dif_enxergar == 'grande'  ~ 1,
      dif_ouvir == 'incapaz' & dif_enxergar == 'incapaz' ~ 1,
      TRUE ~ 0
    ),
    sabe_libras_nao0sim1 = case_when(
      libras == 'sim' ~ 1,
      TRUE ~ 0
    ),
    fx_idade = case_when(
      idade >= 10 & idade <= 14 ~ "10-14",
      idade >= 15 & idade <= 19 ~ "15-19",
      idade >= 20 & idade <= 24 ~ "20-24",
      idade >= 25 & idade <= 29 ~ "25-29",
      idade >= 30 & idade <= 34 ~ "30-34",
      idade >= 35 & idade <= 39 ~ "35-39",
      idade >= 40 & idade <= 44 ~ "40-44",
      idade >= 45 & idade <= 49 ~ "45-49",
      TRUE ~ NA_character_
    ),
    fx_idade_elb = case_when(
      idade >= 10 & idade <= 14 ~ "P0", # 10-14
      idade >= 15 & idade <= 19 ~ "P1", # 15-19
      idade >= 20 & idade <= 24 ~ "P2", # 20-24
      idade >= 25 & idade <= 29 ~ "P3", # 25-29
      idade >= 30 & idade <= 34 ~ "P4", # 30-34
      idade >= 35 & idade <= 39 ~ "P5", # 35-39
      idade >= 40 & idade <= 44 ~ "P6", # 40-44
      idade >= 45 & idade <= 49 ~ "P7", # 45-49
      TRUE ~ NA_character_
    )
  )  
toc()





tic()
message("expandindo probabilisticamente a amostra nos microdados...")

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <-
  survey::svydesign(
    ids = ~upa_pns, 
    strata = ~v0024, 
    data = subset( pns2019_parsed_data, v0028 != 0),
    weights = ~v0028, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00283=as.character(unique(pns2019_parsed_data$v00283)), 
    Freq=as.numeric(unique(pns2019_parsed_data$v00282))
  )
popc.types <- popc.types[order(popc.types$v00283),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00283, 
    population=popc.types
  )
toc()



tic()
message("preparando os dados da PNS 2019 para as análises adicionais de fecundidade...")


pns2019_posterior %>%
  as_survey() %>%
  filter(categ_surdo == 1) %>%
  summarise(
    p = survey_mean(
      fec_evita_gravidez_atualmente,
      proportion = TRUE,
      prop_method='xlogit',
      na.rm = TRUE,
      vartype = "ci"
    )
  )

toc()



