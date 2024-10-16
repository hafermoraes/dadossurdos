## gnur_vardict_typeC_v0648.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "nesse trabalho era"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0648',     '1', 'Empregado com carteira de trabalho assinada',
  'v0648',     '2', 'Militar do exército, marinha, aeronáutica, policia militar ou corpo de bombeiros',
  'v0648',     '3', 'Empregado pelo regime jurídico dos funcionários públicos',
  'v0648',     '4', 'Empregado sem carteira de trabalho assinada',
  'v0648',     '5', 'Conta própria',
  'v0648',     '6', 'Empregador',
  'v0648',     '7', 'Não remunerado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0648.txt'
    ),
    delim = '|'
  )
