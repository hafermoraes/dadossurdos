## gnur_vardict_auxfiles_v1003.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'código da microrregião'
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # %>%, transmute, rename
library(readr)    # write_delim
library(tibble)   # tribble
library(tidyr)    # expand_grid

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
      'Divisao Territorial Brasileira.xls'
    ),                      # caminho até o arquivo
    sheet = 'Microrregião', # aba no qual os dados estão disponíveis
    range = 'A2:B559',      # intervalo de células dos dados
    col_types = 'text',     # ignora tipos de dados
    col_names = FALSE       # ignora nomes de colunas
  ) %>%
  rename(
    cod_4 = 1,              # primeira coluna traz o código da microrregião
    micro = 2               # segunda coluna traz o nome da microrregião
  ) %>%
  transmute(
    q_code = 'v1003',
    a_code = cod_4,
    a_desc = micro
  )

expand_grid(
  base = c('domi', 'pess', 'fami'),
  input
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v1003.txt'
    ),
    delim = '|'
  )
