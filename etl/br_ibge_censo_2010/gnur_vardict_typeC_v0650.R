## gnur_vardict_typeC_v0650.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "era contribuinte de instituto de
## previdência oficial em algum trabalho que tinha na semana de 25 a
## 31 de julho de 2010"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0650',     '1', 'Sim, no trabalho principal',
  'v0650',     '2', 'Sim, em outro trabalho',
  'v0650',     '3', 'Não',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0650.txt'
    ),
    delim = '|'
  )
