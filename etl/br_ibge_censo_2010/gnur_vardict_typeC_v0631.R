## gnur_vardict_typeC_v0631.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "série que frequenta"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0631',     '1', 'Primeira série',
  'v0631',     '2', 'Segunda série',
  'v0631',     '3', 'Terceira série',
  'v0631',     '4', 'Quarta série',
  'v0631',     '5', 'Não seriado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0631.txt'
    ),
    delim = '|'
  )
