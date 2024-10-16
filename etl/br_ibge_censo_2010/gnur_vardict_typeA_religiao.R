## gnur_vardict_typeA_religiao.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável religião
##
##   v6121 Qual é a sua religião ou culto?
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # transmute, unique, rename, mutate, rowwise, as_tibble
library(readr)    # read_lines, write_delim
library(stringr)  # str_conv, str_extract, str_locate

## ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2010/Resultados_Gerais_da_Amostra/Microdados/Documentacao.zip
## era o endereço da fonte primária no momento em que este script
## foi programado em 12.10.2024.
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


## v6121 Qual é a sua religião ou culto?
input <-
  read_lines(
    file = paste0(
      base_dir,
      'raw/',
      'DocumentaЗ╞o/',
      'Anexos Auxiliares/',
      'Religi╞o 2010.txt'
    ),
    skip = 2,
    skip_empty_rows = TRUE
  ) %>%
  as_tibble() %>%
  rename( orig = 1) %>%
  rowwise() %>%
  mutate(
    orig = str_conv(orig, encoding = 'ISO-8859-1'),
    space_position = str_locate(orig, ' ')[1],
    a_code = str_extract(string = orig, pattern = '[0-9]+' ),
    a_desc = substr(orig, start = space_position + 1, stop = str_length(orig))
  ) %>%
  transmute(
    var = 'v6121',
    a_code,
    a_desc
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_v6121.txt'
    ),
    delim = '|'
  )
