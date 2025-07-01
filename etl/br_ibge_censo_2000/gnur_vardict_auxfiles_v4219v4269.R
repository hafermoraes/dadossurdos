## gnur_vardict_auxfiles_v4219v4269.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'código do uf/país de nascimento'
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # %>%, transmute, rename
library(readr)    # write_delim
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
      'Estrutura ONU V4219, V4269.xls'
    ),                            # caminho até o arquivo
    sheet = 'Estrutra ONU',       # aba no qual os dados estão disponíveis
    range = 'A6:B280',            # intervalo de células dos dados
    col_types = 'text',           # ignora tipos de dados
    col_names = FALSE             # ignora nomes de colunas
  ) %>%
  rename(
    nome = 1,              # primeira coluna traz o nome da uf/país
    cod_3 = 2              # segunda coluna traz o código da uf/país
  ) %>%
  filter(
    grepl( pattern = '[0-9]{3}', cod_3)
  ) %>%
  transmute(
    a_code = cod_3,
    a_desc = nome
  )

expand_grid(
  base = 'pes',
  q_code = c('v4219', 'v4269'),
  input
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v4219v4269.txt'
    ),
    delim = '|'
  )
