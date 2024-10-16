## gnur_vardict_typeC_v6940.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "subgrupo e categoria do emprego no
## trabalho principal"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v6940',     '1', 'Trabalhadores domésticos com carteira de trabalho assinada',
  'v6940',     '2', 'Trabalhadores domésticos sem carteira de trabalho assinada',
  'v6940',     '3', 'Demais empregados com carteira de trabalho assinada',
  'v6940',     '4', 'Militares e funcionários públicos estatutários',
  'v6940',     '5', 'Demais empregados sem carteira de trabalho assinada',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v6940.txt'
    ),
    delim = '|'
  )
