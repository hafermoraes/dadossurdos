## gnur_vardict_understanding.R
##
## entendimento do dicionário de variáveis do censo demográfico brasileiro de 2010 (br_ibge_censo_2010)

library(readxl)   # read_excel
library(dplyr)    # mutate, transmute, filter, rename, bind_rows, arrange
library(stringr)  # str_split, str_to_lower, str_trim, str_locate
library(tidyr)    # unnest
library(glue)     # glue
library(readr)    # write_delim

src_dir <- '/tmp/etl/br_ibge_censo_2010/'
raw_data <- paste0(src_dir, 'raw/')
proc_data <- paste0(src_dir, 'data/')

layout_xls_file <- paste0(raw_data, 'DocumentaЗ╞o/Layout/Layout_microdados_Amostra.xls')

vdict <-
  bind_rows( # Agregação dos dicionários de variáveis de cada base do censo
    ## Dicionário de variáveis dos microdados de Domicílios
    read_excel(
      path = layout_xls_file,
      sheet = 'DOMI',
      range = 'A3:L78',
      col_types = 'text',
      col_names = FALSE
    ) %>%
    mutate(base = 'domi'),
    ## Dicionário de variáveis dos microdados de Pessoas
    read_excel(
      path = layout_xls_file,
      sheet = 'PESS',
      range = 'A3:L246',
      col_types = 'text',
      col_names = FALSE
    ) %>%
    mutate(base = 'pess'),
    ## Dicionário de variáveis dos microdados de Emigração
    read_excel(
      path = layout_xls_file,
      sheet = 'EMIG',
      range = 'A3:L21',
      col_types = 'text',
      col_names = FALSE
    ) %>%
    mutate(base = 'emig'),
    ## Dicionário de variáveis dos microdados de Mortalidade
    read_excel(
      path = layout_xls_file,
      sheet = 'MORT',
      range = 'A3:L21',
      col_types = 'text',
      col_names = FALSE
    ) %>%
    mutate(base = 'mort')
  ) %>%
  ## Troca dos nomes de colunas
  rename(
    var = 1, desc = 2, pos_ini = 8, pos_fin = 9, int_part = 10, dec_part = 11, tipo = 12
  ) %>%
  ## remove as quebras de linha da coluna 'tipo'
  mutate(
    tipo = str_remove_all(string = tipo, pattern = '\n')
  ) %>%
  ## seleção somente das colunas necessárias para análise
  select(
    base, var, desc, pos_ini, pos_fin, int_part, dec_part, tipo
  )


## tipo == A
##      refere-se a dados auxiliares, disponíveis em outros arquivos
##      presentes no arquivo compactado =Documentacao.zip=, para
##      variáveis como área de ponderação, código de municípios,
##      códigos de cursos superiores (graduação, mestrado e doutorado)
##      entre outras.
vdict_typeA <-
  vdict %>%
  filter(
    grepl(pattern = 'a', tipo, ignore.case = TRUE)
  ) %>%
  arrange(var)


## tipo == C
##      refere-se aos dados categóricos, para os quais o dicionário
##      de variáveis está disponível diretamente no layout
##      (arquivo excel)
vdict_typeC <-
  vdict %>%
  filter(
    grepl(pattern = 'c', tipo, ignore.case = TRUE)
  ) %>%
  arrange(var)


## tipo == N
##      refere-se provavelmente aos dados numéricos, para os quais
##      não é necessário um dicionário de variáveis já que a variável
##      está pronta para uso, sendo somente necessário convertê-la
##      para o tipo de dados (inteiro, data, número decimal, etc...)
##      necessário para análises
vdict_typeN <-
  vdict %>%
  filter(
    grepl(pattern = 'n', tipo, ignore.case = TRUE)
  ) %>%
  arrange(var)


## tipo == C
##      Observações:
##        1. variáveis do tipo C no dicionário de variáveis trazem,
##           na grande maioria dos casos, os códigos e as respostas
##           por escrito dentro de uma mesma célula, com quebras de
##           linha -- caracter \n -- no conteúdo da célula.
##        2. é necessário portanto tratar os dados para separar o
##           enunciado da questão do censo, geralmente a primeira
##           na célula, da lista de respostas (código e resposta por
##           escrito).
##        3. o código a seguir gera o conteúdo, ou corpo, da função
##           tribble que traz o dicionário de variáveis tratado
##           para todas as variáveis do tipo =C=
vdict %>%
  filter(
    grepl(pattern = 'c', tipo, ignore.case = TRUE)
  ) %>%
  transmute(
    ## converte 'var' para somente letras minúsculas
    var = str_to_lower(var),
    ## cria, na coluna 'answer', a lista formada pelos conteúdos
    ## entre as quebras de linha \n presentes dentro da célula da
    ## coluna 'desc'
    answer = str_split( string = desc, pattern='\n') #
  ) %>%
  ## cada conteúdo entre as quebras de linha \n nas células da
  ## coluna 'answer' torna-se uma linha própria e repete o
  ## conteúdo da coluna 'var'
  unnest(answer) %>%
  ## o conjunto de alterações a seguir precisa ocorrer no nível
  ## das linhas da tabela, por isso é necessário explicitamente
  ## chamar o comando rowwise()
  rowwise() %>%
  ## tratamento das respostas de questões do tipo =C=
  mutate(
    ## as respostas têm o código e o conteúdo por escrito
    ## separados pelo hífen, então a coluna 'sep' traz a posição
    ## do caracter '-' no string contida na coluna 'answer'
    ## exemplo: se o conteúdo de 'answer' fosse
    ##   "01 - teste"
    ## a função str_locate( string = answer, pattern = '-')[1]
    ## retorna 4, pois o hífen está na quarta posição
    sep = str_locate( string = answer, pattern = '-')[1],
    ## a_code, o código da resposta, está antes do hífen
    a_code = substr(answer, start = 1, stop = sep-1 ),
    ## e a_desc, a resposta por escrito, depois do hífen
    a_desc = substr(answer, start = sep + 1, stop = str_length(answer)),
    ## remove espaços redundantes de ambas as novas variáveis
    ## tratadas 'a_code' e 'a_desc'
    a_code = str_trim(a_code),
    a_desc = str_trim(a_desc)
  ) %>%
  ## NAs são introduzidos geralmente nas linhas de enunciados
  ## da pergunta já que elas não contém o caracter '-' separando
  ## código e resposta por escrito.
  ## essas linhas são portanto ignoradas com o comando na.omit()
  na.omit() %>%
  ## com os dados tratados, o corpo da função tribble, contendo
  ## as colunas 'var', 'a_code' e 'a_desc' é construído seguindo
  ## o padrão
  ##      'var', 'a_code', 'a_desc',
  transmute(
    res = glue("'{var}',     '{a_code}', '{a_desc}',")
  ) %>%
  ## e escrito em disco, como arquivo de texte delimitado por
  ## pipe, caracter '|', para uso posterior diretamente na longa
  ## seção de variáveis tratadas do tipo =C=
  write_delim(
    file = glue('{proc_data}/typeC_tribble_bodies.txt'),
    quote = 'none',
    delim = '|',
    col_names = FALSE
  )



cut_qdesc_aux <-
  ## tabela auxiliar para determinação de
  ##  1. argumentos da ferramenta de linha de commando 'cut' usada
  ##     para 'recortar' as colunas dos microdados, transformando
  ##     o arquivo do tipo 'largura fixa' para o tipo 'delimitado'
  ##  2. enunciados de questões (q_desc), ignorando as demais
  ##     informações da célula 'desc' como quebras de linhas, bem
  ##     como códigos e nomes por escrito das respostas
  vdict %>%
  ## é necessário 'ativar' o modo rowwise() para que o próximo
  ## bloco (mutate) opere no nível de linhas. Logo em seguida o
  ## modo rowwise() será 'desativado' com o comando 'ungroup()'
  rowwise() %>%
  mutate(
    ## converte 'var' para somente letras minúsculas
    var = str_to_lower(var),
    ## identificando a posição da quebra de linha '\n' na string
    ## e salvando-a na coluna 'newline_pos'
    newline_pos = str_locate( string = desc, pattern = '\n')[1],
    ## criando a variável 'substr_stop_arg' para guardar a posição
    ## de parada a ser usada na função substr(). Isso é necessário
    ## já que a str_locate() devolve NA nos casos em que a string
    ## 'desc' não contém a quebra de linha '\n'. Nesses casos, a
    ## 'substr_stop_arg' retorna o comprimento da string 'desc'
    substr_stop_arg = ifelse( is.na(newline_pos), str_length(desc), newline_pos),
    ## a nova variável 'q_desc' guarda então somente o enunciado
    ## da pergunta do censo, ignorando todo o resto do conteúdo da
    ## célula.
    q_desc = substr( desc, start = 1, stop = substr_stop_arg),
    ## adicionalmente em alguns casos é necessário remover os
    ## caracteres ':' e '\n' remanescentes de enunciados de
    ## questões do censo,
    q_desc = str_remove_all(string = q_desc, pattern = ':|\n'),
    ## converter a 'q_desc' para letras minúsculas
    q_desc = str_to_lower(q_desc),
    ## e remover espaços redundantes do enunciado
    q_desc = str_trim(q_desc)
    ) %>%
  ## 'desativa' o modo de operação linha-a-linha do comando
  ## rowwise() 'ativado' acima.
  ungroup() %>%
  ## seleciona as colunas relevantes para os próximos passos
  ## de exportação dos argumentos do comando 'cut' bem como
  ## da expoertação dos enunciados tratados das questões do
  ## censo
  transmute(
    base,
    ## renomeia 'var' para 'q_code', o código da variável
    q_code = var,
    q_desc,
    pos_ini,
    pos_fin,
    ## quantos dígitos tem a parte inteira da variável cujo
    ## tipo é N?
    int_part,
    ## quantas casas decimais tem a parte decimal da variável
    ## cujo tipo é N?
    ##   Note: quando (1) o tipo da variável é A ou C e (2) a
    ##         variável do tipo N é inteira, a variável 'dec'
    ##         no dicionário de variáveis original do IBGE
    ##         é indefinida e no GNU R tem o valor NA. Nestes
    ##         casos substitui-se NA pelo número zero (0).
    dec_part = ifelse( is.na(dec_part), 0, dec_part),
    ## qual é a extensão de cada variável nos microdados? Em
    ## outras palavras, de qual a qual caracter estão as
    ## respostas de cada variável do censo?
    cut_character_args = paste0(
      pos_ini,
      '-',
      as.numeric(pos_ini) + as.numeric(int_part) + as.numeric(dec_part) -1
    ),
    check = paste0(pos_ini,'-',pos_fin) == cut_character_args
  )


## ----------------------------------------------------------
##  base de domicílios
## ----------------------------------------------------------
##
## exporta os argumentos 'character' da função 'cut'
cut_qdesc_aux %>%
  filter(base == 'domi') %>%
  summarise(
    args = str_flatten(cut_character_args, ',')
  ) %>%
  write_lines(
    file = glue('{proc_data}/cut_character_args_domi.txt')
  )
##
## exporta o código e enunciado da questão
cut_qdesc_aux %>%
  select(base, q_code, q_desc) %>%
  filter( base == 'domi') %>%
  write_delim(
    file = glue('{proc_data}/vdict_qdesc_domi.txt'),
    delim = '|',
    col_names = TRUE
  )



## ----------------------------------------------------------
##  base de pessoas
## ----------------------------------------------------------
##
## exporta os argumentos 'character' da função 'cut'
cut_qdesc_aux %>%
  filter(base == 'pess') %>%
  summarise(
    args = str_flatten(cut_character_args, ',')
  ) %>%
  write_lines(
    file = glue('{proc_data}/cut_character_args_pess.txt')
  )
##
## exporta o código e enunciado da questão
cut_qdesc_aux %>%
  select(base, q_code, q_desc) %>%
  filter( base == 'pess') %>%
  write_delim(
    file = glue('{proc_data}/vdict_qdesc_pess.txt'),
    delim = '|',
    col_names = TRUE
  )


## ----------------------------------------------------------
##  base de emigrantes
## ----------------------------------------------------------
##
## exporta os argumentos 'character' da função 'cut'
cut_qdesc_aux %>%
  filter(base == 'emig') %>%
  summarise(
    args = str_flatten(cut_character_args, ',')
  ) %>%
  write_lines(
    file = glue('{proc_data}/cut_character_args_emig.txt')
  )
##
## exporta o código e enunciado da questão
cut_qdesc_aux %>%
  select(base, q_code, q_desc) %>%
  filter( base == 'emig') %>%
  write_delim(
    file = glue('{proc_data}/vdict_qdesc_emig.txt'),
    delim = '|',
    col_names = TRUE
  )


## ----------------------------------------------------------
##  base de mortalidade
## ----------------------------------------------------------
##
## exporta os argumentos 'character' da função 'cut'
cut_qdesc_aux %>%
  filter(base == 'mort') %>%
  summarise(
    args = str_flatten(cut_character_args, ',')
  ) %>%
  write_lines(
    file = glue('{proc_data}/cut_character_args_mort.txt')
  )
##
## exporta o código e enunciado da questão
cut_qdesc_aux %>%
  select(base, q_code, q_desc) %>%
  filter( base == 'mort') %>%
  write_delim(
    file = glue('{proc_data}/vdict_qdesc_mort.txt'),
    delim = '|',
    col_names = TRUE
  )
