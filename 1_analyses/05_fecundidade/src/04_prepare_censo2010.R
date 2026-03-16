
DIFF_TOLERANCE <- 1e-5  # diferença máxima para assert_that


ANO_CENSO <- 2010

message("preparando os dados do censo", ANO_CENSO," para as análises de fecundidade...")

tic()
message("selecionando subconjunto mínimo de variáveis do censo", ANO_CENSO,"...")
censo2010_fecundidade_subset <-
  censo2010_abt |> 
  mutate(
    across(
      c(
        peso_amostral,
        categ_ouvinte, categ_deficiente_auditivo, categ_surdo, categ_surdocego,
        idade, idade_ultimo_filho, filhos_nascidos_vivos
      ),
      \(x) ifelse( x == "" | is.na(x), NA_real_, as.numeric(x))
    ),
    filhos_ultimos_12meses = case_when(
      !is.na(idade_ultimo_filho) & idade_ultimo_filho >= 1 ~ 0,
      !is.na(idade_ultimo_filho) & idade_ultimo_filho == 0 ~ 1,
      TRUE ~ NA_real_
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
    ano = ANO_CENSO
  ) |> 
  # ajuste el badry na coluna filhos nascidos vivos
  mutate(
    fnv_elbadry = case_when( 
      idade >= 10 & idade <= 14 & filhos_nascidos_vivos > 2.0/3.0 * 15 - 8.0 ~ 0, 
      idade >= 15 & idade <= 19 & filhos_nascidos_vivos > 2.0/3.0 * 20 - 8.0 ~ 0, 
      idade >= 20 & idade <= 24 & filhos_nascidos_vivos > 2.0/3.0 * 25 - 8.0 ~ 0, 
      idade >= 25 & idade <= 29 & filhos_nascidos_vivos > 2.0/3.0 * 30 - 8.0 ~ 0, 
      idade >= 30 & idade <= 34 & filhos_nascidos_vivos > 2.0/3.0 * 35 - 8.0 ~ 0, 
      idade >= 35 & idade <= 39 & filhos_nascidos_vivos > 2.0/3.0 * 40 - 8.0 ~ 0, 
      idade >= 40 & idade <= 44 & filhos_nascidos_vivos > 2.0/3.0 * 45 - 8.0 ~ 0, 
      idade >= 45 & idade <= 49 & filhos_nascidos_vivos > 2.0/3.0 * 50 - 8.0 ~ 0, 
      TRUE ~ filhos_nascidos_vivos
    )
  ) |>
  filter(
    sexo == 'feminino',
    !is.na(fx_idade)
  )
toc()



tic()
message("subgrupo 'total' no censo", ANO_CENSO,"...")

censo2010_fert_total <-
  censo2010_fecundidade_subset |>
  group_by(
    ano,
    fx_idade,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE),
    .groups = 'drop'
  ) |>
  mutate(
    subgrp = 'total'
  ) |>
  collect()

assert_that(
  abs(
    sum(censo2010_fert_total$nr_mulheres) -
      censo2010_fecundidade_subset |>
      summarise(sum(peso_amostral, na.rm=TRUE)) |>
      pull()  
  ) <= DIFF_TOLERANCE,
  msg = "peso_amostral deve coincidir"
)

toc()





tic()
message("subgrupo 'ouvinte' no censo", ANO_CENSO,"...")

censo2010_fert_ouvinte <-
  censo2010_fecundidade_subset |>
  filter( categ_ouvinte == 1) |>
  group_by(
    ano,
    fx_idade,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE),
    .groups = 'drop'
  ) |>
  mutate(
    subgrp = 'ouvinte'
  ) |>
  collect()

assert_that(
  abs(
    sum(censo2010_fert_ouvinte$nr_mulheres) -
      censo2010_fecundidade_subset |> 
      filter(categ_ouvinte == 1 ) |>
      summarise(sum(peso_amostral, na.rm=TRUE)) |> 
      pull()
   ) <= DIFF_TOLERANCE,
  msg = "peso_amostral deve coincidir"
)


toc()




tic()
message("subgrupo 'deficiente_auditivo' no censo", ANO_CENSO,"...")

censo2010_fert_deficiente_auditivo <-
  censo2010_fecundidade_subset |>
  filter( categ_deficiente_auditivo == 1) |>
  group_by(
    ano,
    fx_idade,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE),
    .groups = 'drop'
  ) |>
  mutate(
    subgrp = 'deficiente_auditivo'
  ) |>
  collect()

assert_that(
  abs(
    sum(censo2010_fert_deficiente_auditivo$nr_mulheres) -
      censo2010_fecundidade_subset |> 
      filter(categ_deficiente_auditivo == 1 ) |>
      summarise(sum(peso_amostral, na.rm=TRUE)) |> 
      pull()
   ) <= DIFF_TOLERANCE,
  msg = "peso_amostral deve coincidir"
)

toc()




tic()
message("subgrupo 'surdo' no censo", ANO_CENSO,"...")

censo2010_fert_surdo <-
  censo2010_fecundidade_subset |>
  filter( categ_surdo == 1) |>
  group_by(
    ano,
    fx_idade,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE),
    .groups = 'drop'
  ) |>
  mutate(
    subgrp = 'surdo'
  ) |>
  collect()

assert_that(
  abs(
    sum(censo2010_fert_surdo$nr_mulheres) -
      censo2010_fecundidade_subset |> 
      filter(categ_surdo == 1 ) |>
      summarise(sum(peso_amostral, na.rm=TRUE)) |> 
      pull()
  ) <= DIFF_TOLERANCE,
  msg = "peso_amostral deve coincidir"
)


toc()




tic()
message("subgrupo 'surdocego' no censo", ANO_CENSO,"...")

censo2010_fert_surdocego <-
  censo2010_fecundidade_subset |>
  filter( categ_surdocego == 1) |>
  group_by(
    ano,
    fx_idade,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE),
    .groups = 'drop'
  ) |>
  mutate(
    subgrp = 'surdocego'
  ) |>
  collect()

assert_that(
  abs(
    sum(censo2010_fert_surdocego$nr_mulheres) -
      censo2010_fecundidade_subset |> 
      filter(categ_surdocego == 1 ) |>
      summarise(sum(peso_amostral, na.rm=TRUE)) |> 
      pull()
  ) <= DIFF_TOLERANCE,
  msg = "peso_amostral deve coincidir"
)


toc()



tic()
message("consolidando informações de fecundidade do censo", ANO_CENSO,"...")

censo2010_elbadry <-
  bind_rows(
    censo2010_fert_total,
    censo2010_fert_ouvinte,
    censo2010_fert_deficiente_auditivo,
    censo2010_fert_surdo,
    censo2010_fert_surdocego
  )

rm(
  censo2010_fert_total,
  censo2010_fert_ouvinte,
  censo2010_fert_deficiente_auditivo,
  censo2010_fert_surdo,
  censo2010_fert_surdocego
  )

rm(
  censo2010_abt,
  censo2010_abt_parquet
)

toc()
