## gnur_vardict_typeC_v0209.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "abastecimento de água, canalização"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0209',     '1', 'Sim, em pelo menos um cômodo',
  'v0209',     '2', 'Sim, só na propriedade ou terreno',
  'v0209',     '3', 'Não',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0209.txt'
    ),
    delim = '|'
  )
