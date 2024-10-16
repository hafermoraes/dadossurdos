## gnur_vardict_typeC_v0635.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "espécie do curso mais elevado concluído"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0635',     '1', 'Superior de graduação',
  'v0635',     '2', 'Mestrado',
  'v0635',     '3', 'Doutorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0635.txt'
    ),
    delim = '|'
  )
