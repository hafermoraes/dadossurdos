## gnur_vardict_typeC_v0662.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "qual é o tempo habitual gasto de
## deslocamento de sua casa até o trabalho"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0662',     '1', 'Até 05 minutos',
  'v0662',     '2', 'De 06 minutos até meia hora',
  'v0662',     '3', 'Mais de meia hora até uma hora',
  'v0662',     '4', 'Mais de uma hora até duas horas',
  'v0662',     '5', 'Mais de duas horas',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0662.txt'
    ),
    delim = '|'
  )
