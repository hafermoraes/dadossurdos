## gnur_vardict_typeA_micro.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável relacionada ao código da microrregião
## cujo conteúdo nos microdados é formado por 3 caracteres
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # transmute, unique, rename,
library(readr)    # write_delim

## ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2010/Resultados_Gerais_da_Amostra/Microdados/Documentacao.zip
## era o endereço da fonte primária no momento em que este script
## foi programado em 10.10.2024.
##
## Este arquivo é então descompactado no diretório salvo na variável
## 'base_dir' a seguir
##
base_dir <- '/tmp/etl/br_ibge_censo_2010/'

## IMPORTANTE: Ao descompactar o arquivo 'Documentacao.zip' usando o
##             'unzip' no container docker 'rocker/tidyverse:4.4.1 os
##             nomes de diretórios, subdiretórios e arquivos perdem sua
##             codificação de origem e ficam com caracteres externos
##             àqueles utilizados na língua portuguesa.

## v1003 Código da Microrregião (3 caracteres)
input <-
  read_excel(
    path = paste0(
      base_dir,
      'raw/',
      'DocumentaЗ╞o/',
      'Divis╞o Territorial do Brasil/',
      'Unidades da FederaЗ╞o, Mesorregiфes, microrregiфes e municбpios 2010.xls'
    ),
    sheet = 'Município',
    range = 'E4:F5568',
    col_types = 'text',
    col_names = FALSE
  ) %>%
  rename(cod_3 = 1, micro = 2) %>%
  unique () %>%
  transmute(
    var = 'v1003',
    a_code = cod_3,
    a_desc = micro
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_v1003.txt'
    ),
    delim = '|'
  )
