## gnur_vardict_auxfiles_v4462.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'código novo da atividade'
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # %>%, transmute, rename
library(readr)    # write_delim

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
      'CnaeDom-Estrutura.xls'
    ),                               # caminho até o arquivo
    sheet = 'CNAEDOM-ESTRUTURAS',    # aba no qual os dados estão disponíveis
    range = 'A5:B360',                # intervalo de células dos dados
    col_types = 'text',              # ignora tipos de dados
    col_names = FALSE                # ignora nomes de colunas
  ) %>%
  rename(
    cod_5 = 1,              # primeira coluna traz o código da atividade
    cnae = 2                 # segunda coluna traz o nome da atividade
  ) %>%
  filter(
    grepl(pattern = '[0-9]{5}', cod_5)
  ) %>%
  transmute(
    base = 'pes',
    q_code = 'v4462',
    a_code = cod_5,
    a_desc = cnae
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v4462.txt'
    ),
    delim = '|'
  )
