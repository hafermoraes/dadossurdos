## gnur_vardict_typeC_v0663.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "quantos filhos e filhas nascidos vivos
## teve até 31 de julho de 2010"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0663',     '1', 'Teve filhos nascidos vivos',
  'v0663',     '2', 'Não teve nenhum filho nascido vivo',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0663.txt'
    ),
    delim = '|'
  )
