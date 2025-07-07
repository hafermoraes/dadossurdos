
## pacotes
library(readr)    # read_delim
library(tidyr)    # pivot_wider
library(dplyr)    # %>%, mutate, filter

## leitura dos dicionários de variáveis
censo2000 <-
  read_delim(
    file = "/tmp/etl/br_ibge_censo_2000/variables_dictionary.txt",
    delim="|"
  )

censo2010 <-
  read_delim(
    file = "/tmp/etl/br_ibge_censo_2010/variables_dictionary.txt",
    delim="|"
  )

pns2019 <-
  read_delim(
    file = "/tmp/etl/br_ibge_pns_2019/variables_dictionary.txt",
    delim="|"
  )


## Harmonização da variável 'sexo'
bind_rows(  
  censo2000 %>%
    filter(q_code == 'v0401') %>%
    transmute(
      fonte = 'censo2000',
      nome_harmonizado = 'sexo',
      q_code,
      a_code,
      a_desc
    ),
  censo2010 %>%
    filter(q_code == 'v0601') %>%
    transmute(
      fonte = 'censo2010',
      nome_harmonizado = 'sexo',
      q_code,
      a_code,
      a_desc
    ),
  pns2019 %>%
    filter(q_code == 'c006') %>%
    transmute(
      fonte = 'pns2019',
      nome_harmonizado = 'sexo',
      q_code,
      a_code,
      a_desc
    )
) %>% 
  pivot_wider(
    id_cols = c('nome_harmonizado','a_code'),
    names_from = 'fonte',
    values_from = 'a_desc'
  ) %>%
  View
