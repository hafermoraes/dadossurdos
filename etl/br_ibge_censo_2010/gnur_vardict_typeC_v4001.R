## gnur_vardict_typeC_v4001.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "espécie de unidade visitada"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v4001',    '01', 'Domicílio particular permanente ocupado',
  'v4001',    '02', 'Domicílio particular permanente ocupado sem entrevista realizada',
  'v4001',    '05', 'Domicílio particular improvisado ocupado',
  'v4001',    '06', 'Domicílio coletivo com morador'
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v4001.txt'
    ),
    delim = '|'
  )
