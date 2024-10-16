## gnur_vardict_typeC_v0628.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "frequenta escola ou creche"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0628',     '1', 'Sim, pública',
  'v0628',     '2', 'Sim, particular',
  'v0628',     '3', 'Não, já frequentou',
  'v0628',     '4', 'Não, nunca frequentou',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0628.txt'
    ),
    delim = '|'
  )
