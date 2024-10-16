## gnur_vardict_typeC_v0616.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "dificuldade permanente de caminhar ou
## subir degraus"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0616',     '1', 'Sim, não consegue de modo algum',
  'v0616',     '2', 'Sim, grande dificuldade',
  'v0616',     '3', 'Sim, alguma dificuldade',
  'v0616',     '4', 'Não, nenhuma dificuldade',
  'v0616',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0616.txt'
    ),
    delim = '|'
  )
