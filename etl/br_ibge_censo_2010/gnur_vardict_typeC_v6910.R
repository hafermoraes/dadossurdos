## gnur_vardict_typeC_v6910.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "condição de ocupação na semana de
## referência"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v6910',     '1', 'Ocupadas',
  'v6910',     '2', 'Desocupadas',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v6910.txt'
    ),
    delim = '|'
  )
