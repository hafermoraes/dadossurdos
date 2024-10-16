## gnur_vardict_typeC_v0202.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "material predominante, paredes externas"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0202',     '1', 'Alvenaria com revestimento',
  'v0202',     '2', 'Alvenaria sem revestimento',
  'v0202',     '3', 'Madeira apropriada para construção (aparelhada)',
  'v0202',     '4', 'Taipa revestida',
  'v0202',     '5', 'Taipa não revestida',
  'v0202',     '6', 'Madeira aproveitada',
  'v0202',     '7', 'Palha',
  'v0202',     '8', 'Outro material',
  'v0202',     '9', 'Sem parede',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0202.txt'
    ),
    delim = '|'
  )
