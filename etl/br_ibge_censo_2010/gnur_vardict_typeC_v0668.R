## gnur_vardict_typeC_v0668.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "qual foi o mês e o ano que este(a)
## filho(a) faleceu"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0668',     '1', 'Sabe o mês e ano ou somente o ano',
  'v0668',     '2', 'Não sabe',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0668.txt'
    ),
    delim = '|'
  )
