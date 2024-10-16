## gnur_vardict_typeA_pais.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação das variáveis relacionadas ao país,
## cujo conteúdo nos microdados é formado por 7 caracteres em cada
## variável a seguir
##
##   v3061 país de residência em 31 de julho de 2010
##   v6224 qual é o país estrangeiro de nascimento
##   v6256 país de residência anterior
##   v6266 país de residência em 31 de julho de 2005
##   v6366 país estrangeiro que frequentava escola (ou creche)
##   v6606 em que país estrangeiro trabalhava
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # transmute, unique, rename,
library(readr)    # write_lines
library(glue)     # glue_data

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


## País de nascimento (7 caracteres)
##
##  v6224 Qual é o país estrangeiro de nascimento
##  v3061 País de residência em 31 de julho de 2010           >>> Base de Emigração
##  v6256 País de residência anterior
##  v6266 País de residência em 31 de julho de 2005
##  v6366 País estrangeiro que frequentava escola (ou creche)
##  v6606 Em que país estrangeiro trabalhava
input <-
  read_excel(
    path = paste0(
      base_dir,
      'raw/',
      'DocumentaЗ╞o/',
      'Anexos Auxiliares/',
      'MigraЗ╞o e Deslocamento_Paises estrangeiros.xls'
    ),
    sheet = 'País estrangeiro',
    range = 'B8:C221',
    col_types = 'text',
    col_names = FALSE
  ) %>%
  rename(nome = 1, cod_7 = 2) %>%
  na.omit() %>%
  transmute(
    a_code = cod_7,
    a_desc = nome
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_common_pais.txt'
    ),
    delim = '|'
  )
