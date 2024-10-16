## gnur_vardict_typeA_atividade.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação das variáveis relacionadas à atividade,
## variável a seguir
##
##   v6471 Atividade
##   v6472 Qual era a atividade principal do empreendimento em que tinha esse trabalho?
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # transmute, unique, rename,
library(readr)    # write_lines
library(tidyr)    # fill

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


## v6471 Atividade
## v6472 Qual era a atividade principal do empreendimento em que tinha esse trabalho?
input <-
  read_excel(
    path = paste0(
      base_dir,
      'raw/',
      'DocumentaЗ╞o/',
      'Anexos Auxiliares/',
      'Atividade CNAE_DOM 2.0 2010.xls'
    ),
    sheet = 'CNAE DOM. 2.0 Divulgação',
    range = 'A3:D352',
    col_types = 'text',
    col_names = FALSE
  ) %>%
  rename( secao = 1, divisao = 2, classes = 3, denominacao = 4) %>%
  fill( secao, divisao) %>%
  transmute( a_code = classes, a_desc = denominacao) %>%
  na.omit()

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_common_atividade.txt'
    ),
    delim = '|'
  )
