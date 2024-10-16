## gnur_vardict_typeC_v0630.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "série / ano que frequenta"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0630',    '01', 'Primeiro ano',
  'v0630',    '02', 'Primeira série / Segundo ano',
  'v0630',    '03', 'Segunda série / Terceiro ano',
  'v0630',    '04', 'Terceira série / Quarto ano',
  'v0630',    '05', 'Quarta série / Quinto ano',
  'v0630',    '06', 'Quinta série / Sexto ano',
  'v0630',    '07', 'Sexta série / Sétimo ano',
  'v0630',    '08', 'Sétima série / Oitavo ano',
  'v0630',    '09', 'Oitava série / Nono ano',
  'v0630',    '10', 'Não seriado',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0630.txt'
    ),
    delim = '|'
  )
