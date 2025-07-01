## gnur_vardict_auxfiles_v4451.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'código antigo da ocupação'
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # %>%, transmute, rename, filter, bind_rows
library(readr)    # write_delim
library(stringr)  # str_length
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
      'Ocupacao91-Estrutura.xls'
    ),                               # caminho até o arquivo
    sheet = 'Ocupação91',            # aba no qual os dados estão disponíveis
    range = 'A4:B472',               # intervalo de células dos dados
    col_types = 'text',              # ignora tipos de dados
    col_names = FALSE                # ignora nomes de colunas
  ) %>%
  rename(
    cod_3 = 1,             # primeira coluna traz o código da ocupação
    nome = 2               # segunda coluna traz o nome da ocupação
  ) %>%
  filter(
    str_length(cod_3) == 3
  ) %>%
  transmute(
    base = 'pes',
    q_code = 'v4451',
    a_code = cod_3,
    a_desc = nome
  )

bind_rows(
  input,
  tribble(
    ~base,  ~q_code, ~a_code, ~a_desc,
    'pes', 'v4451',   '927', 'OUTRAS OCUPACOES OU OCUPACOES MAL DEFINIDAS',
    'pes', 'v4451',   '000', 'OUTRAS OCUPACOES OU OCUPACOES MAL DEFINIDAS'
  )
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v4451.txt'
    ),
    delim = '|'
  )
