## gnur_vardict_typeC_v0664.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "dos filhos e filhas que teve, quantos
## estavam vivos em 31 de julho de 2010"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0664',     '1', 'Filhos vivos',
  'v0664',     '2', 'Não sabe',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0664.txt'
    ),
    delim = '|'
  )
