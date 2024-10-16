## gnur_vardict_typeC_v0637.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "vive em companhia de cônjuge ou
## companheiro(a)"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0637',     '1', 'Sim',
  'v0637',     '2', 'Não, mas viveu',
  'v0637',     '3', 'Não, nunca viveu',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0637.txt'
    ),
    delim = '|'
  )
