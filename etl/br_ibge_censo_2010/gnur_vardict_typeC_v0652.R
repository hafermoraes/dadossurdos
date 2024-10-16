## gnur_vardict_typeC_v0652.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "nos demais trabalhos, qual era o rendimento
## bruto (ou a retirada) mensal que ganhava habitualmente em julho de
## 2010"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0652',     '0', 'Não tem',
  'v0652',     '1', 'Em dinheiro, produtos ou mercadorias',
  'v0652',     '2', 'Somente em benefícios',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0652.txt'
    ),
    delim = '|'
  )
