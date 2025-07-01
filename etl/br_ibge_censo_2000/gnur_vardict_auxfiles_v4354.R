## gnur_vardict_auxfiles_v4354.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'código do curso mais elevado concluído
## (concla)'
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # %>%, transmute, rename, filter
library(readr)    # write_delim
library(stringr)  # str_trim

## ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2000/Microdados/1_Documentacao_20170908.zip
## era o endereço da fonte primária no momento em que este script
## foi programado em 19.10.2024.
##
## Este arquivo é então descompactado no diretório salvo na variável
## 'base_dir' a seguir
##
base_dir <- '/tmp/etl/br_ibge_censo_2000/'

## o tibble 'input' guarda o código (a_code) e o nome por extenso (a_desc)
## das respostas da variável no censo demográfico de 2000
input <-
  read_excel(
    path = paste0(
      base_dir,
      'raw/',
      'Arquivos Auxiliares/',
      'Cursos Superiores - Estrutura V4534.xls'
    ),                               # caminho até o arquivo
    sheet = 'Plan1',                 # aba no qual os dados estão disponíveis
    range = 'C7:C120',               # intervalo de células dos dados
    col_types = 'text',              # ignora tipos de dados
    col_names = FALSE                # ignora nomes de colunas
  ) %>%
  rename(areadet = 1) %>%
  filter(!is.na(areadet)) %>%
  transmute(
    base = 'pes',
    q_code = 'v4354',
    a_code = substr(areadet, start = 1, stop = 3),
    a_desc = substr(areadet, start = 4, stop = 1024),
    a_desc = str_trim(a_desc)
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v4354.txt'
    ),
    delim = '|'
  )
