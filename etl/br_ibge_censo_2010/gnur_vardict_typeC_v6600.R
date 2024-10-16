## gnur_vardict_typeC_v6600.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "espécie da unidade doméstica"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v6600',     '1', 'Unipessoal',
  'v6600',     '2', 'Nuclear',
  'v6600',     '3', 'Estendida',
  'v6600',     '4', 'Composta',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v6600.txt'
    ),
    delim = '|'
  )
