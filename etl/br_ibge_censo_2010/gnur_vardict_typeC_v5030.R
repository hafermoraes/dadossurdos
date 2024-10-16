## gnur_vardict_typeC_v5030.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "tipo de unidade doméstica"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v5030',     '1', 'Unipessoal',
  'v5030',     '2', 'Duas pessoas ou mais sem parentesco',
  'v5030',     '3', 'Duas pessoas ou mais com parentesco',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v5030.txt'
    ),
    delim = '|'
  )
