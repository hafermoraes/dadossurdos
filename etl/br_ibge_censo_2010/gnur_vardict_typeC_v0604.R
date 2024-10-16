## gnur_vardict_typeC_v0604.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "tem mãe viva?"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0604',     '1', 'Sim e mora neste domicílio',
  'v0604',     '2', 'Sim e mora em outro domicílio',
  'v0604',     '3', 'Não',
  'v0604',     '4', 'Não sabe',
  'v0604',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0604.txt'
    ),
    delim = '|'
  )
