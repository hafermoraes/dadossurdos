
tic()
message("importando base tratada na PNS 2019 de ", pns2019_parsed_csv)
pns2019_mortalidade_parsed_data <-
  read_csv(
    file=pns2019_parsed_csv,
    show_col_types = FALSE
  ) |>
  transmute(
    upa_pns, v0024, v0028, v00282, v00283,
    sexo,
    idade,
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
    data = subset(pns2019_mortalidade_parsed_data, v0028 != 0), 
    weights = ~v0028, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00283=as.character(unique(pns2019_mortalidade_parsed_data$v00283)), 
    Freq=as.numeric(unique(pns2019_mortalidade_parsed_data$v00282))
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
message("preparando os dados da PNS 2019 para as pirâmides etárias...")
pns2019_mortalidade_subset <-
  svytable(
    formula=~categ_ouvinte+categ_surdo+categ_surdocego+categ_deficiente_auditivo+sexo+idade,
    design=pns2019_posterior
  ) |>
  as_tibble() |>
  filter(n>0) |>
  group_by(across(-n)) |>
  summarise(n=sum(n)) |>
  arrange(desc(n)) |>
  ungroup() |>
  rename(case_weights=n) |>
  mutate(
    across( 
      c(categ_ouvinte, categ_surdo, categ_surdocego, categ_deficiente_auditivo,idade),
      as.numeric
    ),
    ano=2019
  )
toc()



tic()
message("subgrupo 'total' na PNS 2019...")
pns2019_mort_total <-
  pns2019_mortalidade_subset |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(case_weights, na.rm = TRUE)) |>
  transmute(
    subgrp = 'total',
    ano, sexo, idade, n
  )

assert_that(
  sum(pns2019_mort_total$n) == 
    pns2019_mortalidade_subset |> 
    summarise(sum(case_weights, na.rm=TRUE)) |> 
    pull(),
  msg = "peso_amostral deve coincidir"
)
toc()


tic()
message("subgrupo 'ouvinte' na PNS 2019...")
pns2019_mort_ouvinte <-
  pns2019_mortalidade_subset |>
  filter(categ_ouvinte == 1) |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(case_weights, na.rm = TRUE)) |>
  transmute(
    subgrp = 'ouvinte',
    ano, sexo, idade, n
  )

assert_that(
  sum(pns2019_mort_ouvinte$n) == 
    pns2019_mortalidade_subset |> 
    filter(categ_ouvinte == 1) |>
    summarise(sum(case_weights, na.rm=TRUE)) |> 
    pull(),
  msg = "peso_amostral deve coincidir"
)
toc()



tic()
message("subgrupo 'deficiente_auditivo' na PNS 2019...")
pns2019_mort_deficiente_auditivo <-
  pns2019_mortalidade_subset |>
  filter(categ_deficiente_auditivo == 1) |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(case_weights, na.rm = TRUE)) |>
  transmute(
    subgrp = 'deficiente_auditivo',
    ano, sexo, idade, n
  )

assert_that(
  sum(pns2019_mort_deficiente_auditivo$n) == 
    pns2019_mortalidade_subset |> 
    filter(categ_deficiente_auditivo == 1) |>
    summarise(sum(case_weights, na.rm=TRUE)) |> 
    pull(),
  msg = "peso_amostral deve coincidir"
)
toc()


tic()
message("subgrupo 'surdo' na PNS 2019...")
pns2019_mort_surdo <-
  pns2019_mortalidade_subset |>
  filter(categ_surdo == 1) |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(case_weights, na.rm = TRUE)) |>
  transmute(
    subgrp = 'surdo',
    ano, sexo, idade, n
  )

assert_that(
  sum(pns2019_mort_surdo$n) == 
    pns2019_mortalidade_subset |> 
    filter(categ_surdo == 1) |>
    summarise(sum(case_weights, na.rm=TRUE)) |> 
    pull(),
  msg = "peso_amostral deve coincidir"
)
toc()




tic()
message("subgrupo 'surdocego' na PNS 2019...")
pns2019_mort_surdocego <-
  pns2019_mortalidade_subset |>
  filter(categ_surdocego == 1) |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(case_weights, na.rm = TRUE)) |>
  transmute(
    subgrp = 'surdocego',
    ano, sexo, idade, n
  )

assert_that(
  sum(pns2019_mort_surdocego$n) == 
    pns2019_mortalidade_subset |> 
    filter(categ_surdocego == 1) |>
    summarise(sum(case_weights, na.rm=TRUE)) |> 
    pull(),
  msg = "peso_amostral deve coincidir"
)
toc()


tic()
message("consolidando informações de mortalidade da PNS 2019...")
pns2019_mortalidade <-
  bind_rows(
    pns2019_mort_total,
    pns2019_mort_ouvinte,
    pns2019_mort_deficiente_auditivo,
    pns2019_mort_surdo,
    pns2019_mort_surdocego
  )

toc()
