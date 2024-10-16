## gnur_vardict_typeC_v0208.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## preparação da variável "abastecimento de água, forma"
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0208',    '01', 'Rede geral de distribuição',
  'v0208',    '02', 'Poço ou nascente na propriedade',
  'v0208',    '03', 'Poço ou nascente fora da propriedade',
  'v0208',    '04', 'Carro-pipa',
  'v0208',    '05', 'Água da chuva armazenada em cisterna',
  'v0208',    '06', 'Água da chuva armazenada de outra forma',
  'v0208',    '07', 'Rios, açudes, lagos e igarapés',
  'v0208',    '08', 'Outra',
  'v0208',    '09', 'Poço ou nascente na aldeia',
  'v0208',    '10', 'Poço ou nascente fora da aldeia',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0208.txt'
    ),
    delim = '|'
  )
