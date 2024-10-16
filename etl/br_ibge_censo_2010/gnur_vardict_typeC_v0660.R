## gnur_vardict_typeC_v0660.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "em que município e unidade da federação
## ou país estrangeiro trabalha"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0660',     '1', 'No próprio domicílio',
  'v0660',     '2', 'Apenas neste município, mas não no próprio domicílio',
  'v0660',     '3', 'Em outro município',
  'v0660',     '4', 'Em país estrangeiro',
  'v0660',     '5', 'Em mais de um município ou país',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0660.txt'
    ),
    delim = '|'
  )
