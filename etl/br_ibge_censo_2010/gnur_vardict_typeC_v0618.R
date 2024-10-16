## gnur_vardict_typeC_v0618.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "nasceu neste município"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0618',     '1', 'Sim e sempre morou',
  'v0618',     '2', 'Sim mas morou em outro município ou país estrangeiro',
  'v0618',     '3', 'Não',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0618.txt'
    ),
    delim = '|'
  )
