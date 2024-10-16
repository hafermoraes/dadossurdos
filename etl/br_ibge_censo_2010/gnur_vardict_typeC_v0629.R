## gnur_vardict_typeC_v0629.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "curso que frequenta"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0629',    '01', 'Creche',
  'v0629',    '02', 'Pré-escolar (maternal e jardim da infância)',
  'v0629',    '03', 'Classe de alfabetização - CA',
  'v0629',    '04', 'Alfabetização de jovens e adultos',
  'v0629',    '05', 'Regular do ensino fundamental',
  'v0629',    '06', 'Educação de jovens e adultos - EJA - ou supletivo do ensino fundamental',
  'v0629',    '07', 'Regular do ensino médio',
  'v0629',    '08', 'Educação de jovens e adultos - EJA - ou supletivo do ensino médio',
  'v0629',    '09', 'Superior de graduação',
  'v0629',    '10', 'Especialização de nível superior ( mínimo de 360 horas )',
  'v0629',    '11', 'Mestrado',
  'v0629',    '12', 'Doutorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0629.txt'
    ),
    delim = '|'
  )
