## gnur_vardict_typeC_v0207.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "esgotamento sanitário, tipo"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0207',     '1', 'Rede geral de esgoto ou pluvial',
  'v0207',     '2', 'Fossa séptica',
  'v0207',     '3', 'Fossa rudimentar',
  'v0207',     '4', 'Vala',
  'v0207',     '5', 'Rio, lago ou mar',
  'v0207',     '6', 'Outro',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0207.txt'
    ),
    delim = '|'
  )
