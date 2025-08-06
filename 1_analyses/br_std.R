
## pacotes
library(readr)    # read_delim
library(tidyr)    # pivot_wider
library(dplyr)    # |>, mutate, filter

## leitura dos dicionários de variáveis
censo2000 <-
  read_delim(
    file = "/tmp/etl/br_ibge_censo_2000/variables_dictionary.txt",
    delim="|"
  ) |>
  transmute(
    fonte='censo2000',
    q_code,
    a_code,
    a_desc,
    nome_harmonizado = case_when(
      q_code == 'v0401' ~ 'sexo',
      q_code == 'v0408' ~ 'cor_raca',
      q_code == 'v0428' ~ 'ler_escrever',
      q_code == 'v0438' ~ 'estado_civil',
      q_code == 'v0432' ~ 'escolaridade',
      q_code == 'v0411' ~ 'dif_enxergar',
      q_code == 'v0412' ~ 'dif_ouvir',
      q_code == 'v0102' ~ 'uf',
      TRUE ~ NA
    )
  )


library(arrow)
censo2000_subset <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2000/parquet/pes" 
  ) |>
  rename_with(tolower) |>     # converte nomes de colunas para minúsculas
  mutate(across(everything(), as.numeric)) |>
  transmute(
    # peso (peso atribuído à pessoa)
    p001=p001/1e8,
    # área de ponderação
    area_ponderacao = areap,
    # unidade da federação
    cod_uf = v0102,
    # idade calculada em anos completos - a partir de 1 ano
    idade = v4572,
    # sexo
    sexo = case_when(
      v0401 == 1 ~ 'masculino',
      v0401 == 2 ~ 'feminino',
      TRUE ~ NA
    ),
    # sabe ler e escrever
    alfabetizado = case_when(
      v0428 == 1 ~ 'sim',
      v0428 == 2 ~ 'nao',
      TRUE ~ NA
    ),
    # estado civil
    estado_civil = case_when(
      v0438 == 1 ~ 'casado',
      v0438 == 5 ~ 'solteiro',
      v0438 == 4 ~ 'viuvo',
      TRUE ~ NA
    ),
    # curso mais elevado que freqüentou, concluindo pelo menos uma série
    instrucao = case_when(
      v0432 == 2 ~ 'fundamental', # antigo primário
      v0432 == 3 ~ 'fundamental', # antigo ginásio
      v0432 == 4 ~ 'fundamental', # antigo clássico, científico, etc.
      v0432 == 5 ~ 'fundamental', # ensino fundamental ou 1º grau
      v0432 == 6 ~ 'medio',       # ensino médio ou 2º grau
      v0432 == 7 ~ 'superior',    # superior - graduação
      v0432 == 8 ~ 'superior',    # mestrado ou doutorado
      v0432 == 1 ~ 'outros',      # alfabetização de adultos
      v0432 == 9 ~ 'outros',      # nenhum
      TRUE ~ NA
    ),
    # cor ou raça
    cor_raca = case_when(
      v0408 == 1 ~ 'branca',
      v0408 == 2 ~ 'preta',
      v0408 == 3 ~ 'amarela',
      v0408 == 4 ~ 'parda',
      v0408 == 5 ~ 'indigena',
      v0408 == 9 ~ 'ignorado',
      ),
    # capacidade de ouvir
    dif_ouvir = case_when(
      v0412 == 1 ~ 'incapaz',   # incapaz
      v0412 == 2 ~ 'grande',    # grande dificuldade permanente
      v0412 == 3 ~ 'alguma',    # alguma dificuldade permanente
      v0412 == 4 ~ 'nenhuma',   # nenhuma dificuldade
      v0412 == 9 ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # capacidade de enxergar
    dif_enxergar = case_when(
      v0411 == 1 ~ 'incapaz',   # incapaz
      v0411 == 2 ~ 'grande',    # grande dificuldade permanente
      v0411 == 3 ~ 'alguma',    # alguma dificuldade permanente
      v0411 == 4 ~ 'nenhuma',   # nenhuma dificuldade
      v0411 == 9 ~ 'ignorado',  # ignorado
      TRUE ~ NA
    )
  )
  



censo2010 <-
  read_delim(
    file = "/tmp/etl/br_ibge_censo_2010/variables_dictionary.txt",
    delim="|"
  ) |>
  transmute(
    fonte='censo2010',
    q_code,
    a_code,
    a_desc,
    nome_harmonizado = case_when(
      q_code == 'v0601' ~ 'sexo',
      q_code == 'v0606' ~ 'cor_raca',
      q_code == 'v0627' ~ 'ler_escrever',
      q_code == 'v0640' ~ 'estado_civil',
      q_code == 'v0633' ~ 'escolaridade',
      q_code == 'v0614' ~ 'dif_enxergar',
      q_code == 'v0615' ~ 'dif_ouvir',
      q_code == 'v0001' ~ 'uf',
      TRUE ~ NA
    )
  )

pns2019 <-
  read_delim(
    file = "/tmp/etl/br_ibge_pns_2019/variables_dictionary.txt",
    delim="|"
  ) |>
  transmute(
    fonte='pns2019',
    q_code,
    a_code,
    a_desc,
    nome_harmonizado = case_when(
      q_code == 'c006' ~ 'sexo',
      q_code == 'c009' ~ 'cor_raca',
      q_code == 'd001' ~ 'ler_escrever',
      q_code == 'c011' ~ 'estado_civil',
      q_code == 'd00901' ~ 'escolaridade',
      q_code == 'g047' ~ 'dif_enxergar',
      q_code == 'g058' ~ 'dif_ouvir',
      q_code == 'v0001' ~ 'uf',
      TRUE ~ NA
    )
  )


## Harmonização das variáveis
bind_rows(  
  censo2000 |> na.omit(),
  censo2010 |> na.omit(),
  pns2019 |> na.omit()
) |>
  mutate(
    a_code = as.numeric(a_code)
  ) |>
  pivot_wider(
    id_cols = c('nome_harmonizado','a_code'),
    names_from = 'fonte',
    values_from = 'a_desc'
  ) |>
  arrange(nome_harmonizado) |>
  View
  write_csv('./equiv.csv')
