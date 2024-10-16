## gnur_vardict_typeC_v1005.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "situação do setor"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v1005',     '1', 'Área urbanizada',
  'v1005',     '2', 'Área não urbanizada',
  'v1005',     '3', 'Área urbanizada isolada',
  'v1005',     '4', 'Área rural de extensão urbana',
  'v1005',     '5', 'Aglomerado rural (povoado)',
  'v1005',     '6', 'Aglomerado rural (núcleo)',
  'v1005',     '7', 'Aglomerado rural (outros)',
  'v1005',     '8', 'Área rural exclusive aglomerado rural',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v1005.txt'
    ),
    delim = '|'
  )
