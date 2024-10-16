## gnur_vardict_typeC_v0667.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "este(a) filho(a) estava vivo(a) em 31 de
## julho de 2010"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0667',     '1', 'Sim',
  'v0667',     '2', 'Não',
  'v0667',     '9', 'Não sabe',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0667.txt'
    ),
    delim = '|'
  )
