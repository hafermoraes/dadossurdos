## gnur_parse_variables_dictionary.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação do dicionário de variáveis e dos microdados
## -------------------------------------------------------------------
##

library(dplyr)    # bind_rows, %>%, transmute
library(readr)    # read_delim
library(tidyr)    # expand_grid

base_dir <- '/tmp/etl/br_ibge_censo_2010/'
proc_data <- paste0(base_dir, 'data/')

## Cria tabela vazia para preenchimento incremental posterior
## com o dicionário de variáveis formado pelas colunas
##   - var, o código da variável
##   - a_code, o código da resposta
##   - a_desc, a resposta por extenso
vdict_right <- tibble()

## Aqui começa uma longa construção da tabela vdict_right,
## contra a qual será feita um left join. Essa tabela
## vdict_right tem por objetivo guardar as combinações
## de var, a_code e a_desc, descritas acima. Estas são
## as variáveis e respostas tratadas em scripts próprios.
## O processo consiste em ler o arquivo do disco e fazer
## a escrita incremental (append) na tabela vdict_right.

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## Primeiro bloco de variáveis: tipo A, com respostas
## comuns a diferentes variáveis.
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

## UF
vdict_right <-
  bind_rows(
    vdict_right,
    expand_grid(
      var = c(
        'v0001',  #  v0001 Unidade da federação
        'v6222',  #  v6222 Unidade da federação de nascimento
        'v6252',  #  v6252 Unidade da federação de residência anterior
        'v6262',  #  v6262 Unidade da federação de residência em 31 de julho de 2005
        'v6362',  #  v6362 Unidade da federação que frequentava escola (ou creche)
        'v6602'   #  v6602 Em que unidade da federação trabalhava
      ),
      read_delim( # pares de código (a_code) e nome (a_desc) das UFs
        file = paste0( proc_data, 'vdict_typeA_common_uf.txt'),
        delim = '|',
        col_types = cols(.default = "c")
      )
    ) # expand_grid
  ) # bind_rows

## Municípios
vdict_right <-
  bind_rows(
    vdict_right,
    expand_grid(
      var = c(
        'v0002', #  v0002 código do município
        'v6254', #  v6254 município de residência anterior
        'v6264', #  v6264 município de residência em 31 de julho de 2005
        'v6364', #  v6364 município que frequentava escola (ou creche)
        'v6604'  #  v6604 em que município trabalhava
      ),
      read_delim( # pares de código (a_code) e nome (a_desc) dos municípios
        file = paste0( proc_data, 'vdict_typeA_common_municipio.txt'),
        delim = '|',
        col_types = cols(.default = "c")
      ) %>% transmute( a_code = cod_7, a_desc)
    ) # expand_grid
  ) # bind_rows

## Países
vdict_right <-
  bind_rows(
    vdict_right,
    expand_grid(
      var = c(
        'v6224', # v6224 Qual é o país estrangeiro de nascimento
        'v3061', # v3061 País de residência em 31 de julho de 2010           >>> Base de Emigração
        'v6256', # v6256 País de residência anterior
        'v6266', # v6266 País de residência em 31 de julho de 2005
        'v6366', # v6366 País estrangeiro que frequentava escola (ou creche)
        'v6606'  # v6606 Em que país estrangeiro trabalhava
      ),
      read_delim( # pares de código (a_code) e nome (a_desc) dos países
        file = paste0( proc_data, 'vdict_typeA_common_pais.txt'),
        delim = '|',
        col_types = cols(.default = "c")
      )
    ) # expand_grid
  ) # bind_rows

## Ocupação
vdict_right <-
  bind_rows(
    vdict_right,
    expand_grid(
      var = c(
        'v6461', # v6461 Ocupação
        'v6462'  # v6462 Qual era a ocupação que exercia no trabalho que tinha?
      ),
      read_delim( # pares de código (a_code) e nome (a_desc) da ocupação
        file = paste0( proc_data, 'vdict_typeA_common_ocupacao.txt'),
        delim = '|',
        col_types = cols(.default = "c")
      )
    ) # expand_grid
  ) # bind_rows

## Atividade
vdict_right <-
  bind_rows(
    vdict_right,
    expand_grid(
      var = c(
        'v6471', # v6471 Atividade
        'v6472'  # v6472 Qual era a atividade principal do empreendimento em que tinha esse trabalho?
      ),
      read_delim( # pares de código (a_code) e nome (a_desc) da atividade
        file = paste0( proc_data, 'vdict_typeA_common_atividade.txt'),
        delim = '|',
        col_types = cols(.default = "c")
      )
    ) # expand_grid
  ) # bind_rows

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## Segundo bloco de variáveis: tipo C, com respostas
## comuns a diferentes variáveis.
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

## Variáveis com respostas comuns Sim/Nao do tipo C
vdict_right <-
  bind_rows(
    vdict_right,
      read_delim(
        file = paste0( proc_data, 'vdict_typeC_common_simnao.txt'),
        delim = '|',
        col_types = cols(.default = "c")
      )
  ) # bind_rows

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## Terceiro bloco de variáveis: tipo A, com respostas
## próprias de cada variável. Há diversos arquivos
## individuais que são iterados, lidos em memória e
## o conteúdo é incrementado à tabela vdict_right.
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!

list_typeA <- list.files( path = proc_data, pattern = 'vdict_typeA_v')
for (i in seq_along(list_typeA)){
  vdict_right <-
    bind_rows(
      vdict_right,
      read_delim(
        file = paste0( proc_data, list_typeA[i]),
        delim = '|',
        col_types = cols(.default = 'c')
      )
    )
}

## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
## Último bloco de variáveis: tipo C, com respostas
## próprias de cada variável. Igualmente, há diversos
## arquivos individuais que são iterados, lidos em
## memória e o conteúdo é incrementado à tabela
## vdict_right.
## !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
list_typeC <- list.files( path = proc_data, pattern = 'vdict_typeC_v')
for (i in seq_along(list_typeC)){
  vdict_right <-
    bind_rows(
      vdict_right,
      read_delim(
        file = paste0( proc_data, list_typeC[i]),
        delim = '|',
        col_types = cols(.default = 'c')
      )
    )
}

## >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>
## Dicionário tratado de variáveis
## >>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>

## Base de domicílios
read_delim(
  file = paste0(proc_data, 'vdict_qdesc_domi.txt'),
  delim = '|',
  col_types = cols(.default = 'c')
)  %>%
  left_join(
    vdict_right,
    by = c("q_code" = "var")
  ) %>%
  write_delim(
    file = paste0(proc_data, 'vdict_domi.txt'),
    delim = '|',
    col_names = TRUE
  )

## Base de Pessoas
read_delim(
  file = paste0(proc_data, 'vdict_qdesc_pess.txt'),
  delim = '|',
  col_types = cols(.default = 'c')
)  %>%
  left_join(
    vdict_right,
    by = c("q_code" = "var")
  ) %>%
  write_delim(
    file = paste0(proc_data, 'vdict_pess.txt'),
    delim = '|',
    col_names = TRUE
  )

## Base de Emigração
read_delim(
  file = paste0(proc_data, 'vdict_qdesc_emig.txt'),
  delim = '|',
  col_types = cols(.default = 'c')
)  %>%
  left_join(
    vdict_right,
    by = c("q_code" = "var")
  ) %>%
  write_delim(
    file = paste0(proc_data, 'vdict_emig.txt'),
    delim = '|',
    col_names = TRUE
  )

## Base de Mortalidade
read_delim(
  file = paste0(proc_data, 'vdict_qdesc_mort.txt'),
  delim = '|',
  col_types = cols(.default = 'c')
)  %>%
  left_join(
    vdict_right,
    by = c("q_code" = "var")
  ) %>%
  write_delim(
    file = paste0(proc_data, 'vdict_mort.txt'),
    delim = '|',
    col_names = TRUE
  )
