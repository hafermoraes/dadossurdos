## Script de leitura, tratamento e preparação do
## dicionário de variáveis da PNS 2013

library(readxl)   # read_excel
library(dplyr)    # mutate, filter, as_tibble, rename, fill, unique
library(readr)    # write_delim
library(tidyr)    # fill
library(stringr)  # str_pad, str_flatten, str_replace_all

src_dir <- '/tmp/etl/br_ibge_pns_2013/'
raw_data <- paste0(src_dir, 'raw/')
proc_data <- paste0(src_dir, 'data/')

dict <-
  read_excel(
    path = paste0(raw_data, 'dicionario_PNS_microdados_2013.xls'),
    sheet = 'PNS 2013',
    range = 'A4:G4096',
    col_types = 'text',
    col_names = FALSE
  ) %>%
  rename(
    pos = 1,
    len = 2,
    var = 3,
    q_code = 4,
    q_desc = 5,
    a_code = 6,
    a_desc = 7
  ) %>%
  mutate(
    part = '',
    module = '',
    .before = 'pos',
    q_desc = str_remove_all( q_desc, '[\r\n\"\\"]'),
    a_desc = str_remove_all( a_desc, '[\r\n\"\\"]')
  ) %>%
  fill(pos, len, var, q_code, q_desc) %>%
  as.data.frame()

aux_part <- ''
aux_module <- ''

for (i in seq_len(nrow(dict))){
  if (grepl('^parte|^variáv', dict[i,'pos'], ignore.case = TRUE)){
    aux_part <- dict[i,'pos']
  }
  if (grepl('^módulo', dict[i,'pos'], ignore.case = TRUE)){
    aux_module <- dict[i,'pos']
  }
  dict[i,'part'] <- aux_part
  dict[i,'module'] <- aux_module

  if (grepl('^variáv', dict[i,'part'], ignore.case = TRUE) ){
    dict[i,'module'] <- dict[i,'part']
  }
}

var_dict <-
  dict %>%
  filter(
    ## ignora linhas de título, parte e módulo da pesquisa
    !grepl('[a-zA-Z]+', pos, ignore.case = TRUE),
    ) %>% 
  mutate(
    var = tolower(var),
    ## delimitação dos campos (início-final) como argumento da função 'cut' chamada via shell
    characters = paste0(pos, "-", as.numeric(pos) + as.numeric(len) -1),
  ) %>%
  transmute(part, module, var, q_code, q_desc, a_code, a_desc, characters)

## dicionário de variáveis
var_dict %>%
  select(part, module, var, q_code, q_desc, a_code, a_desc) %>%
  write_delim(
    file = paste0(proc_data, 'variables_dictionary.txt'),
    delim = '|',
    quote = 'none',
    col_names = TRUE
  )

## argumento 'characters' da função 'cut' para delimitação do microdado
var_dict %>%
  select(characters) %>%
  unique() %>%
  summarise(
    args = str_flatten(characters, ",")
  ) %>%
  write_lines(
    file = paste0(proc_data, 'cut_characters_argument.txt')
  )

## nomes das colunas dos microdados (necessário para os arquivos .parquet)
var_dict %>%
  select(var) %>%
  unique() %>%
  write_delim(
    file = paste0(proc_data, 'col_names.txt'),
    delim = '',
    quote = 'none',
    col_names = TRUE
  )
