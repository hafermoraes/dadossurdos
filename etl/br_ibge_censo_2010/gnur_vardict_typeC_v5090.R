## gnur_vardict_typeC_v5090.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "tipo de composição familiar das famílias
## únicas e conviventes principais"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v5090',     '1', 'Casal sem filho(s)',
  'v5090',     '2', 'Casal sem filho(s) e com parente(s)',
  'v5090',     '3', 'Casal com filho(s)',
  'v5090',     '4', 'Casal com filho(s) e com parente(s)',
  'v5090',     '5', 'Mulher sem cônjuge com filho(s)',
  'v5090',     '6', 'Mulher sem cônjuge com filho(s) e com parente(s)',
  'v5090',     '7', 'Homem sem cônjuge com filho(s)',
  'v5090',     '8', 'Homem sem cônjuge com filho(s) e com parente(s)',
  'v5090',     '9', 'Outro',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v5090.txt'
    ),
    delim = '|'
  )
