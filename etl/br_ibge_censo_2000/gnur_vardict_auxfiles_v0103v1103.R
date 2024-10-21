## gnur_vardict_auxfiles_v0103v1103.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'código do município'
##    v0103 código do muncípio  >> base de domicílios
##    v1103 código do município >> base de pessoas
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # %>%, transmute, rename
library(readr)    # write_delim
library(tidyr)    # expand_grid
library(tibble)   # tribble

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
    sheet = 'Município',    # aba no qual os dados estão disponíveis
    range = 'A2:B5508',     # intervalo de células dos dados
    col_types = 'text',     # ignora tipos de dados
    col_names = FALSE       # ignora nomes de colunas
  ) %>%
  rename(
    cod_7 = 1,              # primeira coluna traz o código do município
    mun = 2                 # segunda coluna traz o nome do município
  ) %>%
  transmute(
    a_code = cod_7,
    a_desc = mun
  )

expand_grid(
  base = c('domi', 'fami'),
  q_code = c('v0103'),
  input
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v0103.txt'
    ),
    delim = '|'
  )

expand_grid(
  base = c('pess'),
  q_code = c('v1103'),
  input
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v1103.txt'
    ),
    delim = '|'
  )
