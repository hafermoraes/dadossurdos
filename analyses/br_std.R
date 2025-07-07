
## pacotes
library(readr)    # read_delim
library(tidyr)    # pivot_wider
library(dplyr)    # %>%, mutate, filter

## leitura dos dicionários de variáveis
censo2000 <-
  read_delim(
    file = "/tmp/etl/br_ibge_censo_2000/variables_dictionary.txt",
    delim="|"
  ) %>%
  transmute(
    fonte='censo2000',
    q_code,
    a_code,
    a_desc,
    nome_harmonizado = case_when(
      q_code == 'v0401' ~ 'sexo',
      q_code == 'v0408' ~ 'cor_raca',
      q_code == 'v0428' ~ 'ler_escrever',
      q_code == 'v0438' ~ 'estado_civil',
      q_code == 'v0432' ~ 'escolaridade',
      q_code == 'v0411' ~ 'dif_enxergar',
      q_code == 'v0412' ~ 'dif_ouvir',
      TRUE ~ NA
    )
  )

censo2010 <-
  read_delim(
    file = "/tmp/etl/br_ibge_censo_2010/variables_dictionary.txt",
    delim="|"
  ) %>%
  transmute(
    fonte='censo2010',
    q_code,
    a_code,
    a_desc,
    nome_harmonizado = case_when(
      q_code == 'v0601' ~ 'sexo',
      q_code == 'v0606' ~ 'cor_raca',
      q_code == 'v0627' ~ 'ler_escrever',
      q_code == 'v0640' ~ 'estado_civil',
      q_code == 'v0633' ~ 'escolaridade',
      q_code == 'v0614' ~ 'dif_enxergar',
      q_code == 'v0615' ~ 'dif_ouvir',
      TRUE ~ NA
    )
  )

pns2019 <-
  read_delim(
    file = "/tmp/etl/br_ibge_pns_2019/variables_dictionary.txt",
    delim="|"
  ) %>%
  transmute(
    fonte='pns2019',
    q_code,
    a_code,
    a_desc,
    nome_harmonizado = case_when(
      q_code == 'c006' ~ 'sexo',
      q_code == 'c009' ~ 'cor_raca',
      q_code == 'd001' ~ 'ler_escrever',
      q_code == 'c011' ~ 'estado_civil',
      q_code == 'd00901' ~ 'escolaridade',
      q_code == 'g047' ~ 'dif_enxergar',
      q_code == 'g058' ~ 'dif_ouvir',
      TRUE ~ NA
    )
  )


## Harmonização das variáveis
bind_rows(  
  censo2000 %>% na.omit(),
  censo2010 %>% na.omit(),
  pns2019 %>% na.omit()
) %>%
  mutate(
    a_code = as.numeric(a_code)
  ) %>%
  pivot_wider(
    id_cols = c('nome_harmonizado','a_code'),
    names_from = 'fonte',
    values_from = 'a_desc'
  ) %>%
  arrange(nome_harmonizado) %>%
  View
