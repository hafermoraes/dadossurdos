## gnur_vardict_auxfiles_v1004.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'região metropolitana'
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(readr)    # read_lines, write_delim
library(dplyr)    # %>%, transmute, rename
library(stringr)  # str_remove_all
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
  read_fwf(
    file = paste0(
      base_dir,
      'raw/',
      'Arquivos Auxiliares/',
      'V1004.txt'
    ),          # caminho até o arquivo
    col_positions = fwf_widths(
      c(
        4,      # 1-4   >> código da região metropolitana    =col1=
        1024    # 5-    >> nome da região metropolitana      =col2=
      ),
      c('col1', 'col2')
    ),
    ## ignora as 6 primeiras linhas do arquivo de texto
    skip = 6,
    show_col_types = FALSE,
    ## importa 100% dos dados como texto
    col_types = cols(.default = 'c'),
    ## muito provavelmente foi utilizado o sistema operacional
    ## Microsoft Windows para salvar o arquivo. Isso introduz
    ## divergências na codificação do arquivo, motivo pelo
    ## qual é necessário ler no sistema operacional GNU/Linux
    ## o arquivo com a codificação mais próxima da original
    locale = readr::locale(encoding = "ISO-8859-1")
  ) %>%
  as_tibble() %>%
  rename(
    col1 = 1,            # primeira coluna traz o código
    col2 = 2             # segunda coluna traz o nome
  ) %>%
  mutate(
    col1 = str_remove_all(string = col1, pattern = '-')
  ) %>%
  filter(
    !grepl(pattern = 'br', col1, ignore.case = TRUE)
  ) %>%
  transmute(
    q_code = 'v1004',
    a_code = col1,
    a_desc = col2
  )

expand_grid(
  base = c('dom', 'pes', 'fami'),
  input
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v1004.txt'
    ),
    delim = '|'
  )
