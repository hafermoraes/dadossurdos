

ANO_CENSO <- 2000

message("preparando os dados do censo", ANO_CENSO," para as análises de mortalidade...")


tic()
message("selecionando subconjunto mínimo de variáveis do censo", ANO_CENSO,"...")
censo2000_mortalidade_subset <-
  censo2000_abt |> 
  mutate(
    across(
      c(
        peso_amostral,
        idade,
        categ_ouvinte, categ_deficiente_auditivo, categ_surdo, categ_surdocego
      ),
      as.numeric
    ),
    ano = ANO_CENSO
  ) |>
  select(
    categ_ouvinte, categ_deficiente_auditivo, categ_surdo, categ_surdocego,
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
  filter( categ_ouvinte == 1) |>
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
  filter( categ_deficiente_auditivo == 1) |>
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
  filter( categ_surdo == 1) |>
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
  filter( categ_surdocego == 1) |>
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
