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
    v0102, # unidade da federação
    v1103, # código município
    v4572, # idade calculada em anos completos - a partir de 1 ano
    v0401, # sexo
    v0428, # sabe ler e escrever
    v0438, # estado civil
    v0432, # curso mais elevado que freqüentou, concluindo pelo menos uma série
    v0408, # cor ou raça
    v0411, # capacidade de enxergar
    # capacidade de ouvir
    dif_ouvir = case_when(
      v0412 == '1' ~ 'incapaz',
      v0412 == '2' ~ 'grande',
      v0412 == '3' ~ 'alguma',
      v0412 == '4' ~ 'nenhuma',
      TRUE ~ NA
    ),
    v0413, # capacidade de caminhar/subir escadas
    # ......... Variáveis referentes à Migração .........
    # mora neste município desde que nasceu?
    nasceu_municipio = case_when(
      v0415 == "2" ~ 0, # não
      v0415 == "1" ~ 1, # sim
      TRUE ~ NA
    ),
    v0416, # há quanto tempo mora sem interrupção neste município?
    v0417, # nasceu neste município?
    v0418, # nasceu nesta unidade da federação?
    v0419, # qual é a sua nacionalidade?
    v0420, # em que ano fixou residência no brasil?
    v4210, # qual é a unidade da federação ou país estrangeiro de nascimento?
    v0422, # há quanto tempo mora sem interrupção nesta unidade da federação?
    v4230, # qual é a unidade da federação ou país estrangeiro de residência anterior?
    v0424, # onde residia em 31 de julho de 1995?
    v4250, # em que município residia em 31 de julho de 1995?
    v4260  # em que unidade da federação ou país estrangeiro residia em 31 de julho de 1995?
  )

