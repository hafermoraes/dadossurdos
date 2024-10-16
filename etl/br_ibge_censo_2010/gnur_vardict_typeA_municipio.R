## gnur_vardict_typeA_municipio.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação das variáveis relacionadas ao código do município,
## cujo conteúdo nos microdados é formado por 5 caracteres em cada
## variável a seguir
##
##   v0002 Código do Município
##   v6254 Município de residência anterior
##   v6264 Município de residência em 31 de julho de 2005
##   v6364 Município que frequentava escola (ou creche)
##   v6604 Em que município trabalhava
##
## Observações: 1. Originalmente na divisão territorial brasileira, o
##                 código do município é formado por 7 caracteres.
##                 Por este motivo não se pode fazer análises corretas
##                 somente com os 5 caracteres, pois há duplicação
##                 (exemplo:
##                   1200054 Assis Brasil no Acre e
##                   2600054 Abreu e Lima em Pernambuco
##                 correspondem ambos ao 'código do município' 00054
##                 )
##               2. o código de município conforme indicado na divisão
##                  territorial brasileira é formado, no censo, pelas
##                  variáveis v0001 e v0002. No exemplo:
##                   v0001=12 v0002=00054 >> 1200054 Assis Brasil/AC
##                   v0001=26 v0002=00054 >> 2600054 Abreu e Lima/PE
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readxl)   # read_excel
library(dplyr)    # transmute, unique, rename,
library(readr)    # write_lines
library(glue)     # glue_data

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
## dos municípios utilizados no censo demográfico
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
    range = 'G4:H5568',  # importa somente dados dos municípios
    col_types = 'text',  # ignora tipos de dados
    col_names = FALSE    # ignora nomes de colunas
  ) %>%
  rename(
    cod_7 = 1,           # primeira coluna traz o código do município (7 caracteres)
    municipio = 2        # segunda coluna traz o nome do município
  ) %>%
  transmute(
    cod_7,
    a_code = substr(cod_7, start = 3, stop = 7),
    a_desc = municipio
  )

input %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_common_municipio.txt'
    ),
    delim = '|'
  )
