

ANO_CENSO <- 2000

message("preparando os dados do censo", ANO_CENSO," para as análises de mortalidade...")


tic()
message("selecionando subconjunto mínimo de variáveis do censo", ANO_CENSO,"...")
censo2000_mortalidade_subset <-
  censo2000 |> 
  mutate(
    across(
      c(idade, peso_amostral),
      as.numeric
    ),
    ouvinte = case_when(
      dif_ouvir == 'nenhuma' ~ 'sim',
      dif_ouvir == 'alguma'  ~ 'sim',
      TRUE ~ 'nao'
    ),
    deficiente_auditivo = case_when(
      dif_ouvir == 'grande'  ~ 'sim',
      dif_ouvir == 'incapaz' ~ 'sim',
      TRUE ~ 'nao'
    ),
    surdo = case_when(
      dif_ouvir == 'grande'  & sabe_libras == 'sim' ~ 'sim',
      dif_ouvir == 'incapaz' & sabe_libras == 'sim' ~ 'sim',
      TRUE ~ 'nao'
    ),
    surdocego = case_when(
      dif_ouvir == 'grande'  & dif_enxergar == 'grande'  ~ 'sim',
      dif_ouvir == 'grande'  & dif_enxergar == 'incapaz' ~ 'sim',
      dif_ouvir == 'incapaz' & dif_enxergar == 'grande'  ~ 'sim',
      dif_ouvir == 'incapaz' & dif_enxergar == 'incapaz' ~ 'sim',
      TRUE ~ 'nao'
    ),
    ano = ANO_CENSO
  ) |>
  select(
    ouvinte, deficiente_auditivo, surdo, surdocego,
    ano, sexo, idade, peso_amostral
  )
toc()





tic()
message("subgrupo 'total' no censo", ANO_CENSO,"...")

censo2000_mort_total <-
  censo2000_mortalidade_subset |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(peso_amostral, na.rm = TRUE)) |>
  transmute(
    subgrp = 'total',
    ano, sexo, idade, n
  ) |>
  collect()

toc()





tic()
message("subgrupo 'ouvinte' no censo", ANO_CENSO,"...")

censo2000_mort_ouvinte <-
  censo2000_mortalidade_subset |>
  filter( ouvinte == 'sim') |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(peso_amostral, na.rm = TRUE)) |>
  transmute(
    subgrp = 'ouvinte',
    ano, sexo, idade, n
  ) |>
  collect()

toc()




tic()
message("subgrupo 'deficiente_auditivo' no censo", ANO_CENSO,"...")

censo2000_mort_deficiente_auditivo <-
  censo2000_mortalidade_subset |>
  filter( deficiente_auditivo == 'sim') |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(peso_amostral, na.rm = TRUE)) |>
  transmute(
    subgrp = 'deficiente_auditivo',
    ano, sexo, idade, n
  ) |>
  collect()

toc()




tic()
message("subgrupo 'surdo' no censo", ANO_CENSO,"...")

censo2000_mort_surdo <-
  censo2000_mortalidade_subset |>
  filter( surdo == 'sim') |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(peso_amostral, na.rm = TRUE)) |>
  transmute(
    subgrp = 'surdo',
    ano, sexo, idade, n
  ) |>
  collect()

toc()




tic()
message("subgrupo 'surdocego' no censo", ANO_CENSO,"...")

censo2000_mort_surdocego <-
  censo2000_mortalidade_subset |>
  filter( surdocego == 'sim') |>
  group_by(ano, sexo, idade) |>
  summarise(n = sum(peso_amostral, na.rm = TRUE)) |>
  transmute(
    subgrp = 'surdocego',
    ano, sexo, idade, n
  ) |>
  collect()

toc()



tic()
message("consolidando informações de mortalidade do censo", ANO_CENSO,"...")

censo2000_mortalidade <-
  bind_rows(
    censo2000_mort_total,
    censo2000_mort_ouvinte,
    censo2000_mort_deficiente_auditivo,
    censo2000_mort_surdo,
    censo2000_mort_surdocego
  )

toc()
