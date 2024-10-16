## gnur_vardict_typeC_v0703.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "mês e ano de falecimento"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0703',     '01', 'Agosto de 2009',
  'v0703',     '02', 'Setembro de 2009',
  'v0703',     '03', 'Outubro de 2009',
  'v0703',     '04', 'Novembro de 2009',
  'v0703',     '05', 'Dezembro de 2009',
  'v0703',     '06', 'Janeiro de 2010',
  'v0703',     '07', 'Fevereiro de 2010',
  'v0703',     '08', 'Março de 2010',
  'v0703',     '09', 'Abril de 2010',
  'v0703',     '10', 'Maio de 2010',
  'v0703',     '11', 'Junho de 2010',
  'v0703',     '12', 'Julho de 2010',
  'v0703',     '99', 'Ignorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0703.txt'
    ),
    delim = '|'
  )
