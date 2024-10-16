## gnur_vardict_typeC_v6400.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "nível de instrução"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v6400',     '1', 'Sem instrução e fundamental incompleto',
  'v6400',     '2', 'Fundamental completo e médio incompleto',
  'v6400',     '3', 'Médio completo e superior incompleto',
  'v6400',     '4', 'Superior completo',
  'v6400',     '5', 'Não determinado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v6400.txt'
    ),
    delim = '|'
  )
