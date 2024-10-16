## gnur_vardict_typeC_v0201.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "domicílio, condição de ocupação"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0201',     '1', 'Próprio de algum morador - já pago',
  'v0201',     '2', 'Próprio de algum morador - ainda pagando',
  'v0201',     '3', 'Alugado',
  'v0201',     '4', 'Cedido por empregador',
  'v0201',     '5', 'Cedido de outra forma',
  'v0201',     '6', 'Outra condição',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0201.txt'
    ),
    delim = '|'
  )
