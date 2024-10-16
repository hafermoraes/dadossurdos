## gnur_vardict_typeC_v0636.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "município e unidade da federação ou país
## estrangeiro que frequentava escola (ou creche)"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0636',     '1', 'Neste município',
  'v0636',     '2', 'Em outro município',
  'v0636',     '3', 'Em país estrangeiro',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0636.txt'
    ),
    delim = '|'
  )
