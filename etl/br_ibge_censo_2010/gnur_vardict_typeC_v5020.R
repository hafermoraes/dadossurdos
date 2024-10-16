## gnur_vardict_typeC_v5020.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "número da família"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v5020',    '01', 'Famílias únicas ou conviventes principais: Corresponde à família dos responsáveis pela unidade doméstica.',
  'v5020',    '02', 'Família convivente – segunda',
  'v5020',    '03', 'Família convivente – terceira',
  'v5020',    '04', 'Família convivente – quarta',
  'v5020',    '05', 'Família convivente – quinta',
  'v5020',    '06', 'Família convivente – sexta',
  'v5020',    '07', 'Família convivente – sétima',
  'v5020',    '08', 'Família convivente – oitava',
  'v5020',    '09', 'Família convivente – nona',
  'v5020',    'Branco', 'para pessoas residentes em domicílios coletivos e/ou em unidades domésticas localizadas em terras indígenas, onde não se fez a identificação de famílias.',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v5020.txt'
    ),
    delim = '|'
  )
