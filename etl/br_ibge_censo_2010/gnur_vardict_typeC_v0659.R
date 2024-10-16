## gnur_vardict_typeC_v0659.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "em julho de 2010, tinha rendimento mensal
## habitual de outras fontes (juros de poupança, aplicações
## financeiras, aluguel, pensão, aposentadoria de previdência privada,
## etc)?"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0659',     '1', 'Sim',
  'v0659',     '0', 'Não',
  'v0659',     '9', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0659.txt'
    ),
    delim = '|'
  )
