# library(arrow)    # open_dataset, collect
# library(duckdb)   # to_duckdb()
# library(dplyr)    # |>,  mutate, transmute, rename_with
# library(readr)    # write_csv

subset_censo2000 <-
  open_dataset("/tmp/etl/br_ibge_censo_2000/parquet/pes") |> 
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  to_duckdb() |>
  transmute(
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=areap,
    peso_amostral=as.numeric(p001)/1e8,
    # ......... Variáveis comuns ........................
    uf = v0102, # unidade da federação
    municipio = v1103, # código município
    # idade calculada em anos completos - a partir de 1 ano
    idade = as.numeric(v4572), 
    # sexo
    sexo = case_when(
      v0401 == '1' ~ 'masculino',
      v0401 == '2' ~ 'feminino',
      TRUE ~ NA
    ),
    # sabe ler e escrever
    alfabetizado = case_when(
      v0428 == '1' ~ 'sim',
      v0428 == '2' ~ 'nao',
      TRUE ~ NA
    ),
    # estado civil
    estado_civil = case_when(
      v0438 == '1' ~ 'casado',     # Casado(a)
      v0438 == '2' ~ 'separado',   # desquitado(a) ou separado(a) judicialmente
      v0438 == '3' ~ 'separado',   # divorciado(a)
      v0438 == '4' ~ 'viúvo',      # viúvo(a)
      v0438 == '5' ~ 'solteiro',   # Solteiro(a)
      TRUE ~ NA
    ),
    # curso mais elevado que freqüentou, concluindo pelo menos uma série
    instrucao = case_when(
      v0432 == '01' ~ 'outros',      # alfabetização de jovens e adultos
      v0432 == '02' ~ 'fundamental', # antigo primário
      v0432 == '03' ~ 'fundamental', # antigo ginásio
      v0432 == '04' ~ 'medio',       # antigo clássico, científico, etc.
      v0432 == '05' ~ 'fundamental', # ensino fundamental ou 1º grau
      v0432 == '06' ~ 'medio',       # ensino médio ou 2º grau
      v0432 == '07' ~ 'superior',    # superior - graduação
      v0432 == '08' ~ 'superior',    # mestrado ou doutorado
      v0432 == '09' ~ 'outros',      # nenhum
      TRUE ~ NA
    ),
    # cor ou raça
    cor_raca = case_when(
      v0408 == '1' ~ 'branca',
      v0408 == '2' ~ 'preta',
      v0408 == '3' ~ 'amarela',
      v0408 == '4' ~ 'parda',
      v0408 == '5' ~ 'indigena',
      v0408 == '9' ~ 'outros',
      TRUE ~ NA
      ),
    # capacidade de enxergar
    dif_enxergar = case_when(
      v0411 == '4' ~ 'incapaz',   # incapaz
      v0411 == '3' ~ 'grande',    # grande dificuldade permanente
      v0411 == '2' ~ 'alguma',    # alguma dificuldade permanente
      v0411 == '1' ~ 'nenhuma',   # nenhuma dificuldade
      v0411 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
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
    # capacidade de caminhar/subir escadas
    dif_locomover = case_when(
      v0413 == '1' ~ 'incapaz',   # incapaz
      v0413 == '2' ~ 'grande',    # grande dificuldade permanente
      v0413 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0413 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0413 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # ......... Variáveis referentes à Migração .........
    # mora neste município desde que nasceu?
    sempre_morou = case_when(
      v0415 == "1" ~ 1, # sim
      v0415 == "2" ~ 0, # não
      TRUE ~ NA
    ),
    # há quanto tempo mora sem interrupção neste município?
    anos_residencia_municipio = as.numeric(v0416), 
    # nasceu neste município?
    natural_municipio = case_when(
      v0417 == '1' ~ 1, # sim
      v0417 == '2' ~ 0, # não
    ),
    # nasceu nesta unidade da federação?
    natural_uf = case_when(
      v0418 == '1' ~ 1, # sim
      v0418 == '2' ~ 0, # não
    ),
    # qual é a sua nacionalidade?
    estrangeiro = case_when(
      v0419 == '1' ~ 0, # brasileiro nato
      v0419 == '2' ~ 0, # naturalizado brasileiro
      v0419 == '3' ~ 1, # estrangeiro
      TRUE ~ NA
    ),
    # em que ano fixou residência no brasil?
    ano_residencia_brasil = as.numeric(v0420),
    # qual é a unidade da federação ou país estrangeiro de nascimento?
    uf_nascimento = v4210,    # UF:   v4210 <= 27
    pais_nascimento = v4210,  # País: v4210 >= 30
    # há quanto tempo mora sem interrupção nesta unidade da federação?
    anos_residencia_uf = v0422,
    # qual é a unidade da federação ou país estrangeiro de residência anterior?
    uf_residencia_anterior = v4230,    # UF:   v4230 <= 27
    pais_residencia_anterior = v4230,  # País: v4230 >= 30
    v0424, # onde residia em 31 de julho de 1995?
    # em que município residia em 31 de julho de 1995?
    municipio_residencia_5anos = v4250,
    # em que unidade da federação ou país estrangeiro residia em 31 de julho de 1995?
    uf_residencia_5anos = v4260,   # UF:   v4260 <= 27
    pais_residencia_5anos = v4260  # País: v4260 >= 30
  )

