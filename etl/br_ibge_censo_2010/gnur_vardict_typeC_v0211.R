## gnur_vardict_typeC_v0211.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "energia elétrica, existência"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0211',     '1', 'Sim, de companhia distribuidora',
  'v0211',     '2', 'Sim, de outras fontes',
  'v0211',     '3', 'Não existe energia elétrica',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0211.txt'
    ),
    delim = '|'
  )
