## gnur_vardict_typeC_v0658.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "em julho 2010, tinha rendimento mensal
## habitual de outros programas sociais ou de transferências"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0658',     '1', 'Sim',
  'v0658',     '0', 'Não',
  'v0658',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0658.txt'
    ),
    delim = '|'
  )
