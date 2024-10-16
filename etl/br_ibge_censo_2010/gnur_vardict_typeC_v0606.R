## gnur_vardict_typeC_v0606.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "cor ou raça"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0606',     '1', 'Branca',
  'v0606',     '2', 'Preta',
  'v0606',     '3', 'Amarela',
  'v0606',     '4', 'Parda',
  'v0606',     '5', 'Indígena',
  'v0606',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0606.txt'
    ),
    delim = '|'
  )
