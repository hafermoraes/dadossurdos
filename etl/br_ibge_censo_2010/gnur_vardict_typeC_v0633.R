## gnur_vardict_typeC_v0633.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "curso mais elevado que frequentou"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0633',    '01', 'Creche, pré-escolar (maternal e jardim de infância), classe de alfabetização - CA',
  'v0633',    '02', 'Alfabetização de jovens e adultos',
  'v0633',    '03', 'Antigo primário (elementar)',
  'v0633',    '04', 'Antigo ginásio (médio 1º ciclo)',
  'v0633',    '05', 'Ensino fundamental ou 1º grau (da 1ª a 3ª série/ do 1º ao 4º ano)',
  'v0633',    '06', 'Ensino fundamental ou 1º grau (4ª série/ 5º ano)',
  'v0633',    '07', 'Ensino fundamental ou 1º grau (da 5ª a 8ª série/ 6º ao 9º ano)',
  'v0633',    '08', 'Supletivo do ensino fundamental ou do 1º grau',
  'v0633',    '09', 'Antigo científico, clássico, etc.....(médio 2º ciclo)',
  'v0633',    '10', 'Regular ou supletivo do ensino médio ou do 2º grau',
  'v0633',    '11', 'Superior de graduação',
  'v0633',    '12', 'Especialização de nível superior ( mínimo de 360 horas )',
  'v0633',    '13', 'Mestrado',
  'v0633',    '14', 'Doutorado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0633.txt'
    ),
    delim = '|'
  )
