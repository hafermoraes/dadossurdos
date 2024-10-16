## gnur_vardict_typeC_v0670.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "assinale quem prestou as informações
## desta pessoa"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0670',     '1', 'A própria pessoa',
  'v0670',     '2', 'Outro morador',
  'v0670',     '3', 'Não morador',
  'v0670',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0670.txt'
    ),
    delim = '|'
  )
