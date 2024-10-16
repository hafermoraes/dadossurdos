## gnur_vardict_typeC_v0639.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "natureza da união"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0639',     '1', 'Casamento civil e religioso',
  'v0639',     '2', 'Só casamento civil',
  'v0639',     '3', 'Só casamento religioso',
  'v0639',     '4', 'União consensual',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0639.txt'
    ),
    delim = '|'
  )
