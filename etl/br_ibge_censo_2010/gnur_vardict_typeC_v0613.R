## gnur_vardict_typeC_v0613.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "registro de nascimento"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0613',     '1', 'Do cartório',
  'v0613',     '2', 'Declaração de nascido vivo (DNV) do hospital ou da maternidade',
  'v0613',     '3', 'Registro administrativo de nascimento indígena (RANI)',
  'v0613',     '4', 'Não tem',
  'v0613',     '5', 'Não sabe',
  'v0613',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0613.txt'
    ),
    delim = '|'
  )
