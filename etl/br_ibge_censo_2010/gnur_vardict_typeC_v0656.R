## gnur_vardict_typeC_v0656.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "em julho de 2010, tinha rendimento mensal
## habitual de aposentadoria ou pensão de instituto de previdência
## oficial (federal, estadual ou municipal)?"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0656',     '1', 'Sim',
  'v0656',     '0', 'Não',
  'v0656',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0656.txt'
    ),
    delim = '|'
  )
