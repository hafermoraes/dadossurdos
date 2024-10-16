## gnur_vardict_typeA_curso_dout.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "curso de doutorado"
## cujo conteúdo nos microdados é formado por 3 caracteres
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # transmute, unique, rename,
library(readr)    # write_delim

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

## v6356 Curso de doutorado
input <-
  read_excel(
    path = paste0(
      base_dir,
      'raw/',
      'DocumentaЗ╞o/',
      'Anexos Auxiliares/',
      'Cursos Doutorado_Estrutura 2010.xls'
    ),
    sheet = 'Estrutura',
    range = 'A2:B132',
    col_types = 'text',
    col_names = FALSE
  ) %>%
  rename(a_code = 1, a_desc = 2) %>%
  na.omit() %>%
  transmute(
    var = 'v6356',
    a_code,
    a_desc
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_v6356.txt'
    ),
    delim = '|'
  )
