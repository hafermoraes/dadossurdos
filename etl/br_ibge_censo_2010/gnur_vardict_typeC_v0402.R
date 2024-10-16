## gnur_vardict_typeC_v0402.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "a responsabilidade pelo domicílio é de"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0402',     '1', 'Apenas um morador',
  'v0402',     '2', 'Mais de um morador',
  'v0402',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0402.txt'
    ),
    delim = '|'
  )
