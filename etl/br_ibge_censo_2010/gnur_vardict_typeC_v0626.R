## gnur_vardict_typeC_v0626.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "residência em 31 de julho de 2005"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0626',     '1', 'UF/Município',
  'v0626',     '2', 'País estrangeiro',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0626.txt'
    ),
    delim = '|'
  )
