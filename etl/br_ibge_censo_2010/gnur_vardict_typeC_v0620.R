## gnur_vardict_typeC_v0620.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "nacionalidade"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0620',     '1', 'Brasileiro nato',
  'v0620',     '2', 'Naturalizado brasileiro',
  'v0620',     '3', 'Estrangeiro',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0620.txt'
    ),
    delim = '|'
  )
