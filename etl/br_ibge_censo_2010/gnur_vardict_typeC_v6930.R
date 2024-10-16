## gnur_vardict_typeC_v6930.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "posição na ocupação e categoria do emprego
## no trabalho principal"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v6930',     '1', 'Empregados com carteira de trabalho assinada',
  'v6930',     '2', 'Militares e funcionários públicos estatutários',
  'v6930',     '3', 'Empregados sem carteira de trabalho assinada',
  'v6930',     '4', 'Conta própria',
  'v6930',     '5', 'Empregadores',
  'v6930',     '6', 'Não remunerados',
  'v6930',     '7', 'Trabalhadores na produção para o próprio consumo',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v6930.txt'
    ),
    delim = '|'
  )
