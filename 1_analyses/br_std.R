
## pacotes
library(readr)    # read_delim
library(tidyr)    # pivot_wider
library(dplyr)    # |>, mutate, filter
library(arrow)    # open_dataset, to_duckdb, collect
library(duckdb)

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



censo2000_subset <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2000/parquet/pes" 
  ) |>
  rename_with(tolower) |>     # converte nomes de colunas para minúsculas
  mutate(
    p001=as.numeric(p001),
    v0102=as.numeric(v0102)
  ) |> 
  to_duckdb() |>
  transmute(
    # peso (peso atribuído à pessoa)
    peso_amostral=as.numeric(p001)/1e8,
    # área de ponderação
    area_ponderacao = areap,
    # unidade da federação
    cod_uf = v0102,
    # idade calculada em anos completos - a partir de 1 ano
    idade = as.numeric(v4572),
    # sexo
    sexo = case_when(
      v0401 == '1' ~ 'masculino',
      v0401 == '2' ~ 'feminino',
      TRUE ~ 'outros'
    ),
    # sabe ler e escrever
    alfabetizado = case_when(
      v0428 == '1' ~ 'sim',
      v0428 == '2' ~ 'nao',
      TRUE ~ 'outros'
    ),
    # estado civil
    estado_civil = case_when(
      v0438 == '1' ~ 'casado',
      v0438 == '2' ~ 'separado',  # desquitado(a) ou separado(a) judicialmente
      v0438 == '3' ~ 'separado',  # divorciado(a)
      v0438 == '5' ~ 'solteiro',
      v0438 == '4' ~ 'viuvo',
      TRUE ~ 'outros'
    ),
    # curso mais elevado que freqüentou, concluindo pelo menos uma série
    instrucao = case_when(
      v0432 == '2' ~ 'fundamental', # antigo primário
      v0432 == '3' ~ 'fundamental', # antigo ginásio
      v0432 == '4' ~ 'fundamental', # antigo clássico, científico, etc.
      v0432 == '5' ~ 'fundamental', # ensino fundamental ou 1º grau
      v0432 == '6' ~ 'medio',       # ensino médio ou 2º grau
      v0432 == '7' ~ 'superior',    # superior - graduação
      v0432 == '8' ~ 'superior',    # mestrado ou doutorado
      v0432 == '1' ~ 'outros',      # alfabetização de adultos
      v0432 == '9' ~ 'outros',      # nenhum
      TRUE ~ 'outros'
    ),
    # cor ou raça
    cor_raca = case_when(
      v0408 == '1' ~ 'branca',
      v0408 == '2' ~ 'preta',
      v0408 == '3' ~ 'amarela',
      v0408 == '4' ~ 'parda',
      v0408 == '5' ~ 'indigena',
      v0408 == '9' ~ 'outros',
      TRUE ~ 'outros'
      ),
    # capacidade de ouvir
    dif_ouvir = case_when(
      v0412 == '1' ~ 'incapaz',   # incapaz
      v0412 == '2' ~ 'grande',    # grande dificuldade permanente
      v0412 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0412 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0412 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # capacidade de enxergar
    dif_enxergar = case_when(
      v0411 == '1' ~ 'incapaz',   # incapaz
      v0411 == '2' ~ 'grande',    # grande dificuldade permanente
      v0411 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0411 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0411 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ 'outros'
    )
  ) |>
  collect()
  



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


censo2010_subset <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2010/parquet/pess" 
  ) |>
  rename_with(tolower) |>     # converte nomes de colunas para minúsculas
  mutate(
    v0010=as.numeric(v0010),
    v0001=as.numeric(v0001)
  ) |> 
  to_duckdb() |>
  transmute(
    # peso amostral
    peso_amostral=v0010/1e13,
    # área de ponderação
    area_ponderacao = v0011,
    # unidade da federação
    cod_uf = v0001,
    # idade calculada em anos completos - a partir de 1 ano
    idade = as.numeric(v6036),
    # sexo
    sexo = case_when(
      v0601 == '1' ~ 'masculino',
      v0601 == '2' ~ 'feminino',
      TRUE ~ 'outros'
    ),
    # sabe ler e escrever
    alfabetizado = case_when(
      v0627 == '1' ~ 'sim',
      v0627 == '2' ~ 'nao',
      TRUE ~ 'outros'
    ),
    # estado civil
    estado_civil = case_when(
      v0640 == '1' ~ 'casado',
      v0640 == '2' ~ 'separado',  # desquitado(a) ou separado(a) judicialmente
      v0640 == '3' ~ 'separado',  # divorciado(a)
      v0640 == '5' ~ 'solteiro',
      v0640 == '4' ~ 'viuvo',
      TRUE ~ 'outros'
    ),
    # curso mais elevado que freqüentou, concluindo pelo menos uma série
    instrucao = case_when(
      v0633 == '3' ~ 'fundamental', # Antigo primário (elementar)
      v0633 == '4' ~ 'fundamental', # Antigo ginásio (médio 1º ciclo)
      v0633 == '5' ~ 'fundamental', # Ensino fundamental ou 1º grau (da 1ª a 3ª série/ do 1º ao 4º ano)
      v0633 == '6' ~ 'fundamental', # Ensino fundamental ou 1º grau (4ª série/ 5º ano)
      v0633 == '7' ~ 'fundamental', # Ensino fundamental ou 1º grau (da 5ª a 8ª série/ 6º ao 9º ano)
      v0633 == '8' ~ 'fundamental', # Supletivo do ensino fundamental ou do 1º grau
      v0633 == '9' ~ 'medio',       # Antigo científico, clássico, etc.....(médio 2º ciclo)
      v0633 == '10' ~ 'medio',      # Regular ou supletivo do ensino médio ou do 2º grau
      v0633 == '11' ~ 'superior',   # Superior de graduação
      v0633 == '12' ~ 'superior',   # Especialização de nível superior ( mínimo de 360 horas )
      v0633 == '13' ~ 'superior',   # Mestrado
      v0633 == '14' ~ 'superior',   # Doutorado
      v0633 == '1' ~ 'outros',      # Creche, pré-escolar (maternal e jardim de infância), classe de alfabetização - CA
      v0633 == '2' ~ 'outros',      # Alfabetização de jovens e adultos
      TRUE ~ 'outros'
    ),
    # cor ou raça
    cor_raca = case_when(
      v0606 == '1' ~ 'branca',
      v0606 == '2' ~ 'preta',
      v0606 == '3' ~ 'amarela',
      v0606 == '4' ~ 'parda',
      v0606 == '5' ~ 'indigena',
      v0606 == '9' ~ 'outros',
      TRUE ~ 'outros'
      ),
    # capacidade de ouvir
    dif_ouvir = case_when(
      v0615 == '1' ~ 'incapaz',   # incapaz
      v0615 == '2' ~ 'grande',    # grande dificuldade permanente
      v0615 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0615 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0615 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # capacidade de enxergar
    dif_enxergar = case_when(
      v0614 == '1' ~ 'incapaz',   # incapaz
      v0614 == '2' ~ 'grande',    # grande dificuldade permanente
      v0614 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0614 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0614 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ 'outros'
    )
  ) |>
  collect()



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
  write_csv('/tmp/equiv.csv')
