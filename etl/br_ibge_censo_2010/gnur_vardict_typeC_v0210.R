## gnur_vardict_typeC_v0210.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "lixo, destino"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0210',     '1', 'Coletado diretamente por serviço de limpeza',
  'v0210',     '2', 'Colocado em caçamba de serviço de limpeza',
  'v0210',     '3', 'Queimado (na propriedade)',
  'v0210',     '4', 'Enterrado (na propriedade)',
  'v0210',     '5', 'Jogado em terreno baldio ou logradouro',
  'v0210',     '6', 'Jogado em rio, lago ou mar',
  'v0210',     '7', 'Tem outro destino',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0210.txt'
    ),
    delim = '|'
  )
