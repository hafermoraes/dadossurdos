## gnur_vardict_typeC_v0625.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "unidade da federação e município ou país
## estrangeiro de moradia antes de mudar-se para este município"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0625',     '1', 'UF/Município',
  'v0625',     '2', 'País estrangeiro',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0625.txt'
    ),
    delim = '|'
  )
