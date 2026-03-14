
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
    ),
    ano = ANO_CENSO
  ) |> 
  filter(
    sexo == 'feminino',
    !is.na(fx_idade)
  )
toc()


# censo2010_fecundidade_subset |>
#   group_by(ano, filhos_nascidos_vivos, fx_idade_elb) |>
#   summarise( 
#     n = sum(peso_amostral, na.rm=TRUE)
#   ) |> 
#   pivot_wider(
#     id_cols = c(ano, filhos_nascidos_vivos),
#     names_from = fx_idade_elb,
#     values_from = n,
#     values_fill = 0
#   ) |>
#   arrange(ano, filhos_nascidos_vivos) |>
#   select( ano, filhos_nascidos_vivos, P0, P1, P2, P3, P4, P5, P6, P7) |>
#   collect() |>   View()



tic()
message("subgrupo 'total' no censo", ANO_CENSO,"...")

censo2010_fert_total <-
  censo2010_fecundidade_subset |>
  group_by(
    ano,
    fx_idade,
    fx_idade_elb,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE)
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
    fx_idade_elb,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE)
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
    fx_idade_elb,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE)
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
    fx_idade_elb,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE)
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
    fx_idade_elb,
    filhos_nascidos_vivos,
    filhos_ultimos_12meses
  ) |>
  summarise(
    nr_mulheres = sum(peso_amostral, na.rm = TRUE)
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

censo2010_fecundidade <-
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
