## gnur_vardict_sasfiles.R
##
## entendimento do dicionário de variáveis do censo demográfico brasileiro de 2000 (br_ibge_censo_2000)

library(readxl)   # read_excel
library(dplyr)    # mutate, transmute, filter, rename, bind_rows, arrange
library(stringr)  # str_split, str_to_lower, str_trim, str_locate
library(tidyr)    # unnest
library(glue)     # glue
library(readr)    # write_delim, write_lines

## caminhos até os dados do censo 2000
src_dir <- '/tmp/etl/br_ibge_censo_2000/'
raw_data <- paste0(src_dir, 'raw/')
proc_data <- paste0(src_dir, 'data/')


## variáveis auxiliares disponíveis em arquivos próprios,
## fora dos scripts/macros do SAS
aux_vars_common <- c(
  ## variáveis comuns aos microdados de domicílios,
  ## pessoas e famílias
  'v1002', 'v1003', 'v0103', 'v0104', 'v0105', 'v1004', 'areap'
  )
aux_vars_pess <- c(
  ## variáveis exclusivas dos microdados de pessoas
  'v4090', 'v4210', 'v4230', 'v4250', 'v4260', 'v4276', 'v4355',
  'v4452', 'v4462', 'v4354', 'v4219', 'v4239', 'v4269', 'v4279',
  'v4451', 'v4461', 'v1103'
)
aux_vars <- c(aux_vars_common, aux_vars_pess)



## -------------------------------------------------------------
##    base de domicílios
## -------------------------------------------------------------

## importação do dicionário de variáveis
input_domi <-
  ## o dicionário de variáveis do Censo 2000 decorre diretamente
  ## do script/macro de leitura do software SAS, não restando
  ## outra alternativa, para trabalhar com o GNU R, a não ser
  ## tratar o dicionário de variáveis como um arquivo de formato
  ## largura fixa.
  ## Originalmente o arquivo contém caracteres binários, aspas
  ## comentários (/* e */), tabulação (\t), por isso um script
  ## shell o trata antes da importação no GNU R que ocorre nas
  ## próximas linhas.
  read_fwf(
    file = paste0(raw_data, 'SAS/LE_DOMIC.sas'),
    col_positions = fwf_widths(
      c(
        6,     # 1-6   >> contador de linha               =col1=
        13,    # 7-19  >> variável e número de caracteres =col2=
        1024   # 20-   >> dicionário de variáveis         =col3=
      ),
      c('col1', 'col2', 'col3')
    ),
    ## as primeiras 20 linhas são relevantes somente para a
    ## leitura dos microdados no software SAS, motivo pelo
    ## qual essas linhas são ignoradas (puladas) na importação
    ## no GNU R.
    skip = 20,
    show_col_types = FALSE,
    ## importa 100% dos dados como texto
    col_types = cols(.default = 'c'),
    ## muito provavelmente o software SAS utilizado pelo IBGE
    ## foi utilizado no sistema operacional Microsoft Windows
    ## para salvar o script de importação. Isso introduz
    ## divergências na codificação do arquivo, motivo pelo
    ## qual é necessário ler no sistema operacional GNU/Linux
    ## o arquivo com a codificação mais próxima da original
    locale = readr::locale(encoding = "ISO-8859-1")
  )


output_domi <-
  input_domi %>%
  filter(row_number() <= n() -7) %>%
  rowwise() %>%
  mutate(
    ## q: enunciado da questão
    ## a: dicionário da resposta
    qa = ifelse( is.na(col1), 'a', 'q'),
    ## posição do espaço ' ' que separa q_code e q_desc
    col2_space = str_locate(string = col2, pattern = ' ')[1],
    ## posições inicial e final e número de caracteres nos microdados
    pos_ini = str_remove_all(string = col1, pattern = '@'),
    nchars = str_sub(string = col2, start = col2_space + 1),
    dot = str_locate(string = nchars, pattern = '[.]')[1],
    nchars = ifelse(
      is.na(dot),
      nchars,
      str_sub(string = nchars, start = 1, end = dot - 1)
    ),
    pos_fin = as.numeric(pos_ini) + as.numeric(nchars) - 1,
    ## argumento character do commando cut
    cut_arg = glue('{pos_ini}-{pos_fin}'),
    ## código e enunciado da variável
    q_code = str_sub(string = col2, start = 1, end = col2_space - 1),
    q_code = str_trim(q_code),
    q_code = str_to_lower(q_code),
    q_desc = ifelse(is.na(col1), NA, col3),
    q_desc = ifelse( !grepl('^[.]', q_desc), q_desc, str_sub( string = q_desc, start = 3)),
    q_desc = str_trim(q_desc),
    q_desc = str_to_lower(q_desc),
    ## código e descrição da resposta
    col3_hifen = str_locate(string = col3, pattern = '-')[1],
    a_code = ifelse(qa=='a', str_sub(string = col3, start = 1, end = col3_hifen - 1), NA),
    a_code = str_to_lower(a_code),
    a_desc = ifelse(qa=='a', str_sub(string = col3, start = col3_hifen + 1), NA),
    a_desc = str_trim(a_desc),
    a_desc = str_to_lower(a_desc),
    ## inclui um marcador para o caso de a variável ter seu
    ## dicionário localizado como um arquivo auxiliar. Isso
    ## ocorre sempre que há a palavra 'arquivo' na coluna 3
    tipo = case_when(
      q_code %in% aux_vars ~ 'auxiliar',
      TRUE ~ NA
    )
  ) %>%
  ungroup()


## código e enunciado das variáveis
output_domi %>%
  filter(qa=='q') %>%
  transmute(
    base = 'domi',
    q_code,
    q_desc
  ) %>%
  write_delim(
    file = paste0(proc_data, 'vdict_qdesc_dom.txt' ),
    delim = '|',
    col_names = TRUE
  )


## argumento character do comando cut
output_domi %>%
  filter(qa=='q') %>%
  summarise(
    args = str_flatten(cut_arg, ',')
  ) %>%
  write_lines(
    file = paste0( proc_data, 'cut_character_args_dom.txt')
  )


## vdict_sasfiles.txt
output_domi %>%
  fill(q_code) %>%
  filter(
    qa=='a',
    !(q_code %in% aux_vars),
    !is.na(a_code),
    !grepl(pattern = 'branc', a_code, ignore.case = TRUE)
  ) %>%
  transmute(
    base = 'domi',
    q_code,
    a_code,
    a_desc
  ) %>%
  write_delim(
    file = paste0( proc_data, 'vdict_sasfiles.txt'),
    delim = '|',
    append = FALSE
  )


tribble(
    ~base,   ~q_code, ~a_code, ~a_desc,
    'domi',  'v0220',     '2',   'não',
  ) %>%
  write_delim(
    file = paste0( proc_data, 'vdict_sasfiles.txt'),
    delim = '|',
    append = TRUE
  )



## -------------------------------------------------------------
##    base de pessoas
## -------------------------------------------------------------
input_pess <-
  ## o dicionário de variáveis do Censo 2000 decorre diretamente
  ## do script/macro de leitura do software SAS, não restando
  ## outra alternativa, para trabalhar com o GNU R, a não ser
  ## tratar o dicionário de variáveis como um arquivo de formato
  ## largura fixa.
  ## Originalmente o arquivo contém caracteres binários, aspas
  ## comentários (/* e */), tabulação (\t), por isso um script
  ## shell o trata antes da importação no GNU R que ocorre nas
  ## próximas linhas.
  read_fwf(
    file = paste0(raw_data, 'SAS/LE_PESSOAS.sas'),
    col_positions = fwf_widths(
      c(
        6,     # 1-6   >> contador de linha               =col1=
        10,    # 7-16  >> variável e número de caracteres =col2=
        1024   # 17-   >> dicionário de variáveis         =col3=
      ),
      c('col1', 'col2', 'col3')
    ),
    ## as primeiras 20 linhas são relevantes somente para a
    ## leitura dos microdados no software SAS, motivo pelo
    ## qual essas linhas são ignoradas (puladas) na importação
    ## no GNU R.
    skip = 20,
    show_col_types = FALSE,
    ## importa 100% dos dados como texto
    col_types = cols(.default = 'c'),
    ## muito provavelmente o software SAS utilizado pelo IBGE
    ## foi utilizado no sistema operacional Microsoft Windows
    ## para salvar o script de importação. Isso introduz
    ## divergências na codificação do arquivo, motivo pelo
    ## qual é necessário ler no sistema operacional GNU/Linux
    ## o arquivo com a codificação mais próxima da original
    locale = readr::locale(encoding = "ISO-8859-1")
  )


output_pess <-
  input_pess %>%
  filter(row_number() <= n() -8) %>%
  rowwise() %>%
  mutate(
    ## q: enunciado da questão
    ## a: dicionário da resposta
    qa = ifelse( is.na(col1), 'a', 'q'),
    col2_space = str_locate(string = col2, pattern = ' ')[1],
    ## posições inicial e final e número de caracteres nos microdados
    pos_ini = str_remove_all(string = col1, pattern = '@'),
    nchars = str_sub(string = col2, start = col2_space + 1),
    dot = str_locate(string = nchars, pattern = '[.]')[1],
    nchars = ifelse(
      is.na(dot),
      nchars,
      str_sub(string = nchars, start = 1, end = dot - 1)
    ),
    pos_fin = as.numeric(pos_ini) + as.numeric(nchars) - 1,
    ## argumento character do commando cut
    cut_arg = glue('{pos_ini}-{pos_fin}'),
    ## código e enunciado da variável
    q_code = str_sub(string = col2, start = 1, end = col2_space - 1),
    q_code = str_to_lower(q_code),
    q_desc = ifelse(is.na(col1), NA, col3),
    q_desc = ifelse( !grepl('^[.]', q_desc), q_desc, str_sub( string = q_desc, start = 3)),
    q_desc = str_trim(q_desc),
    q_desc = str_to_lower(q_desc),
    ## código e descrição da resposta
    col3_hifen = str_locate(string = col3, pattern = '-')[1],
    a_code = ifelse(qa=='a', str_sub(string = col3, start = 1, end = col3_hifen - 1), NA),
    a_code = str_to_lower(a_code),
    a_desc = ifelse(qa=='a', str_sub(string = col3, start = col3_hifen + 1), NA),
    a_desc = str_trim(a_desc),
    a_desc = str_to_lower(a_desc),
    ## se 'branco' faz parte da coluna 3, a_code e a_desc devem ser NA
    a_code = ifelse(col3_hifen > 5, NA, a_code),
    a_desc = ifelse(col3_hifen > 5, NA, a_desc),
    ## inclui um marcador para o caso de a variável ter seu
    ## dicionário localizado como um arquivo auxiliar. Isso
    ## ocorre sempre que há a palavra 'arquivo' na coluna 3
    tipo = case_when(
      q_code %in% c(
        ## variáveis comuns aos microdados de domicílios,
        ## pessoas e famílias
        'v1002', 'v1003', 'v0103', 'v0104', 'v0105', 'v1004', 'areap',
        ## variáveis exclusivas dos microdados de pessoas
        'v4090', 'v4210', 'v4230', 'v4250', 'v4260', 'v4276', 'v4355',
        'v4452', 'v4462', 'v4354', 'v4219', 'v4239', 'v4269', 'v4279',
        'v4451', 'v4461', 'v1103'
      ) ~ 'auxiliar',
      TRUE ~ NA
    )
  ) %>%
  ungroup()


## código e enunciado das variáveis
output_pess %>%
  filter(qa=='q') %>%
  transmute(
    base = 'pess',
    q_code,
    q_desc
  ) %>%
  write_delim(
    file = paste0(proc_data, 'vdict_qdesc_pes.txt' ),
    delim = '|',
    col_names = TRUE
  )

## argumento character do comando cut
output_pess %>%
  filter(qa=='q') %>%
  summarise(
    args = str_flatten(cut_arg, ',')
  ) %>%
  write_lines(
    file = paste0( proc_data, 'cut_character_args_pes.txt')
  )


## vdict_sasfiles.txt
tribble(
    ~base,   ~q_code, ~a_code, ~a_desc,
    'pess',  'v0455',     '1',   'sim',
  ) %>%
  write_delim(
    file = paste0( proc_data, 'vdict_sasfiles.txt'),
    delim = '|',
    append = TRUE
  )

output_pess %>%
  fill(q_code) %>%
  filter(
    qa=='a',
    !(q_code %in% aux_vars),
    !is.na(a_code),
    !grepl(pattern = 'branc|00', a_code, ignore.case = TRUE)
  ) %>%
  transmute(
    base = 'pess',
    q_code,
    a_code,
    a_desc
  ) %>%
  write_delim(
    file = paste0( proc_data, 'vdict_sasfiles.txt'),
    delim = '|',
    append = TRUE
  )


## -------------------------------------------------------------
##    base de famílias
## -------------------------------------------------------------
input_fami <-
  ## o dicionário de variáveis do Censo 2000 decorre diretamente
  ## do script/macro de leitura do software SAS, não restando
  ## outra alternativa, para trabalhar com o GNU R, a não ser
  ## tratar o dicionário de variáveis como um arquivo de formato
  ## largura fixa.
  ## Originalmente o arquivo contém caracteres binários, aspas
  ## comentários (/* e */), tabulação (\t), por isso um script
  ## shell o trata antes da importação no GNU R que ocorre nas
  ## próximas linhas.
  read_fwf(
    file = paste0(raw_data, 'SAS/LE_FAMILIAS.sas'),
    col_positions = fwf_widths(
      c(
        6,     # 1-6   >> contador de linha               =col1=
        14,    # 7-16  >> variável e número de caracteres =col2=
        1024   # 17-   >> dicionário de variáveis         =col3=
      ),
      c('col1', 'col2', 'col3')
    ),
    ## as primeiras 20 linhas são relevantes somente para a
    ## leitura dos microdados no software SAS, motivo pelo
    ## qual essas linhas são ignoradas (puladas) na importação
    ## no GNU R.
    skip = 20,
    show_col_types = FALSE,
    ## importa 100% dos dados como texto
    col_types = cols(.default = 'c'),
    ## muito provavelmente o software SAS utilizado pelo IBGE
    ## foi utilizado no sistema operacional Microsoft Windows
    ## para salvar o script de importação. Isso introduz
    ## divergências na codificação do arquivo, motivo pelo
    ## qual é necessário ler no sistema operacional GNU/Linux
    ## o arquivo com a codificação mais próxima da original
    locale = readr::locale(encoding = "ISO-8859-1")
  )


output_fami <-
  input_fami %>%
  filter(row_number() <= n() -7) %>%
  rowwise() %>%
  mutate(
    ## correção manual do nome da variável
    col2 = ifelse(
      grepl( pattern = '94', col1),
      'CODV4615_7400 2.',
      col2
    ),
    ## q: enunciado da questão
    ## a: dicionário da resposta
    qa = ifelse( is.na(col1), 'a', 'q'),
    col2_space = str_locate(string = col2, pattern = ' ')[1],
    ## posições inicial e final e número de caracteres nos microdados
    pos_ini = str_remove_all(string = col1, pattern = '@'),
    nchars = str_sub(string = col2, start = col2_space + 1),
    dot = str_locate(string = nchars, pattern = '[.]')[1],
    nchars = ifelse(
      is.na(dot),
      nchars,
      str_sub(string = nchars, start = 1, end = dot - 1)
    ),
    pos_fin = as.numeric(pos_ini) + as.numeric(nchars) - 1,
    ## argumento character do commando cut
    cut_arg = glue('{pos_ini}-{pos_fin}'),
    ## código e enunciado da variável
    q_code = str_sub(string = col2, start = 1, end = col2_space - 1),
    q_code = str_to_lower(q_code),
    q_desc = ifelse(is.na(col1), NA, col3),
    q_desc = ifelse( !grepl('^[.]', q_desc), q_desc, str_sub( string = q_desc, start = 3)),
    q_desc = str_trim(q_desc),
    q_desc = str_to_lower(q_desc),
    ## código e descrição da resposta
    col3_hifen = str_locate(string = col3, pattern = '-')[1],
    a_code = ifelse(qa=='a', str_sub(string = col3, start = 1, end = col3_hifen - 1), NA),
    a_code = str_to_lower(a_code),
    a_desc = ifelse(qa=='a', str_sub(string = col3, start = col3_hifen + 1), NA),
    a_desc = str_trim(a_desc),
    a_desc = str_to_lower(a_desc),
    ## se 'branco' faz parte da coluna 3, a_code e a_desc devem ser NA
    a_code = ifelse(col3_hifen > 5, NA, a_code),
    a_desc = ifelse(col3_hifen > 5, NA, a_desc),
    ## inclui um marcador para o caso de a variável ter seu
    ## dicionário localizado como um arquivo auxiliar. Isso
    ## ocorre sempre que há a palavra 'arquivo' na coluna 3
    tipo = case_when(
      q_code %in% c(
        ## variáveis comuns aos microdados de domicílios,
        ## pessoas e famílias
        'v1002', 'v1003', 'v0103', 'v0104', 'v0105', 'v1004', 'areap',
        ## variáveis exclusivas dos microdados de pessoas
        'v4090', 'v4210', 'v4230', 'v4250', 'v4260', 'v4276', 'v4355',
        'v4452', 'v4462', 'v4354', 'v4219', 'v4239', 'v4269', 'v4279',
        'v4451', 'v4461', 'v1103'
      ) ~ 'auxiliar',
      TRUE ~ NA
    )
  ) %>%
  ungroup()

## código e enunciado das variáveis
output_fami %>%
  filter(qa=='q') %>%
  transmute(
    base = 'fami',
    q_code,
    q_desc
  ) %>%
  write_delim(
    file = paste0(proc_data, 'vdict_qdesc_fami.txt' ),
    delim = '|',
    col_names = TRUE
  )

## argumento character do comando cut
output_fami %>%
  filter(qa=='q') %>%
  summarise(
    args = str_flatten(cut_arg, ',')
  ) %>%
  write_lines(
    file = paste0( proc_data, 'cut_character_args_fami.txt')
  )


## vdict_sasfiles.txt
output_fami %>%
  fill(q_code) %>%
  filter(
    qa=='a',
    !(q_code %in% aux_vars),
    !is.na(a_code),
    !grepl(pattern = 'branc|00', a_code, ignore.case = TRUE)
  ) %>%
  transmute(
    base = 'fami',
    q_code,
    a_code,
    a_desc
  ) %>%
  write_delim(
    file = paste0( proc_data, 'vdict_sasfiles.txt'),
    delim = '|',
    append = TRUE
  )
