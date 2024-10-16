## gnur_vardict_typeC_v0614.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "dificuldade permanente de enxergar"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0614',     '1', 'Sim, não consegue de modo algum',
  'v0614',     '2', 'Sim, grande dificuldade',
  'v0614',     '3', 'Sim, alguma dificuldade',
  'v0614',     '4', 'Não, nenhuma dificuldade',
  'v0614',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0614.txt'
    ),
    delim = '|'
  )
