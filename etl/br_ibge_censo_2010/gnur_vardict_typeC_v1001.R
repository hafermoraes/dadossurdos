## gnur_vardict_typeC_v1001.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "região geográfica"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v1001',     '1', 'Região norte',
  'v1001',     '2', 'Região nordeste',
  'v1001',     '3', 'Região sudeste',
  'v1001',     '4', 'Região sul',
  'v1001',     '5', 'Região centro-oeste',
  )  %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v1001.txt'
    ),
    delim = '|'
  )
