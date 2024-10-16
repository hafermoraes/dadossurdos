## gnur_vardict_typeC_v0212.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "existência de medidor ou relógio, energia
## elétrica, companhia distribuidora"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0212',     '1', 'Sim, de uso exclusivo',
  'v0212',     '2', 'Sim, de uso comum',
  'v0212',     '3', 'Não tem medidor ou relógio',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0212.txt'
    ),
    delim = '|'
  )
