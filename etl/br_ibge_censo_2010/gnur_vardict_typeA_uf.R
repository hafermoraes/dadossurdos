## gnur_vardict_typeA_uf.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação das variáveis relacionadas à Unidade da Federação (UF),
## cujo conteúdo é formado por 2 caracteres em cada variável a seguir
##
##   v0001 Unidade da federação
##   v6222 Unidade da federação de nascimento
##   v6252 Unidade da federação de residência anterior
##   v6262 Unidade da federação de residência em 31 de julho de 2005
##   v6362 Unidade da federação que frequentava escola (ou creche)
##   v6602 Em que unidade da federação trabalhava
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # transmute, unique, rename,
library(readr)    # write_lines
library(glue)     # glue_data
library(tidyr)    # expand_grid

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

## o tibble 'input' guarda o código (a_code) e o nome por extenso (a_desc)
## das unidades da federação utilizadas no censo demográfico
input <-
  read_excel(
    path = paste0(
      base_dir,
      'raw/',
      'DocumentaЗ╞o/',
      'Divis╞o Territorial do Brasil/',
      'Unidades da FederaЗ╞o, Mesorregiфes, microrregiфes e municбpios 2010.xls'
    ),                   # caminho até o arquivo
    sheet = 'Município', # aba no qual os dados estão disponíveis
    range = 'A4:B5568',  # importa somente dados de UF
    col_types = 'text',  # ignora tipos de dados
    col_names = FALSE    # ignora nomes de colunas
  ) %>%
  rename(
    cod_2 = 1,           # primeira coluna traz o código da uf (2 caracteres)
    uf = 2               # segunda coluna traz o nome da uf
  ) %>%
  unique() %>% # obs: os pares (cod_2, uf) repetem-se muitas vezes no arquivo
  transmute(
    a_code = cod_2,
    a_desc = uf
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_common_uf.txt'
    ),
    delim = '|'
  )
