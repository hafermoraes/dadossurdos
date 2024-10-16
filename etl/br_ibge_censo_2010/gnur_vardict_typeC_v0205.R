## gnur_vardict_typeC_v0205.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "banheiros de uso exclusivo, número"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0205',     '0', 'Zero banheiros',
  'v0205',     '1', 'Um banheiro',
  'v0205',     '2', 'Dois banheiros',
  'v0205',     '3', 'Três banheiros',
  'v0205',     '4', 'Quatro banheiros',
  'v0205',     '5', 'Cinco banheiros',
  'v0205',     '6', 'Seis banheiros',
  'v0205',     '7', 'Sete banheiros',
  'v0205',     '8', 'Oito banheiros',
  'v0205',     '9', 'Nove ou mais banheiros',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0205.txt'
    ),
    delim = '|'
  )
