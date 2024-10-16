## gnur_vardict_typeC_v5100.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "tipo de composição familiar das famílias
## conviventes secundárias"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v5100',     '1', 'Casal sem filho(s)',
  'v5100',     '2', 'Casal com filho(s)',
  'v5100',     '3', 'Mulher sem cônjuge com filho(s)',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v5100.txt'
    ),
    delim = '|'
  )
