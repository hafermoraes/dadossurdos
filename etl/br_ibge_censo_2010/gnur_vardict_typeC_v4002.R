## gnur_vardict_typeC_v4002.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "tipo de espécie"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v4002',    '11', 'Casa',
  'v4002',    '12', 'Casa de vila ou em condomínio',
  'v4002',    '13', 'Apartamento',
  'v4002',    '14', 'Habitação em: casa de cômodos, cortiço ou cabeça de porco',
  'v4002',    '15', 'Oca ou maloca',
  'v4002',    '51', 'Tenda ou barraca',
  'v4002',    '52', 'Dentro de estabelecimento',
  'v4002',    '53', 'Outro (vagão, trailer, gruta, etc)',
  'v4002',    '61', 'Asilo, orfanato e similares  com morador',
  'v4002',    '62', 'Hotel, pensão e similares com morador',
  'v4002',    '63', 'Alojamento de trabalhadores com morador',
  'v4002',    '64', 'Penitenciária, presídio ou casa de detenção com morador',
  'v4002',    '65', 'Outro com morador'
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v4002.txt'
    ),
    delim = '|'
  )
