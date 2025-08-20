
# dicionário de variáveis
dvar_censo2000 <-
  read_delim(
    '/tmp/etl/br_ibge_censo_2000/variables_dictionary.txt',
    delim = '|'
  ) |>
  filter(base=='pes') |>
  mutate(
    a_desc = str_trim(a_desc),
    a_desc = str_to_title(a_desc, locale = 'pt-br')
  ) |>
  to_duckdb()

# harmonização das variáveis de migração
subset_censo2000 <-
  open_dataset("/tmp/etl/br_ibge_censo_2000/parquet/pes") |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  select(
    areap,p001,v0102,v1103,v4572,v0401,v0428,v0438,v0432,v0408,v0411,v0412,v0413,
    v0415,v0416,v0417,v0418,v0419,v0420,v4210,v0422,v4230,v4250,v4260
  ) |>
  mutate(across(everything(), ~ str_trim(.))) |>
  to_duckdb() |>
  mutate(
    # qual é a unidade da federação ou país estrangeiro de nascimento?
    v4210_uf   =  case_when(v4210 == '' ~ NA, v4210 <= '27' ~ v4210, TRUE ~ NA),
    v4210_pais =  case_when(v4210 == '' ~ NA, v4210 >= '30' ~ v4210, TRUE ~ NA),
    # qual é a unidade da federação ou país estrangeiro de residência anterior?
    v4230_uf   =  case_when(v4230 == '' ~ NA, v4230 <= '27' ~ v4230, TRUE ~ NA),
    v4230_pais =  case_when(v4230 == '' ~ NA, v4230 >= '30' ~ v4230, TRUE ~ NA),
    # em que unidade da federação ou país estrangeiro residia em 31 de julho de 1995?
    v4260_uf   =  case_when(v4260 == '' ~ NA, v4260 <= '27' ~ v4260, TRUE ~ NA),
    v4260_pais =  case_when(v4260 == '' ~ NA, v4260 >= '30' ~ v4260, TRUE ~ NA)
  ) |>
  # joins com dicionário de variáveis
  # v0102: uf de residência
  left_join(dvar_censo2000 |> filter(q_code=='v0102') |>
              transmute(v0102 = a_code, uf_residencia = a_desc),
            keep=FALSE) |> 
  # v4210: uf de nascimento
  left_join(dvar_censo2000 |> filter(q_code=='v4210') |>
              transmute(v4210_uf = a_code, uf_nascimento = a_desc),
            keep=FALSE) |>
  # v4230: uf de residência anterior
  left_join(dvar_censo2000 |> filter(q_code=='v4230') |>
              transmute(v4230_uf = a_code, uf_residencia_anterior = a_desc),
            keep=FALSE) |>
  # v4260: uf de residência data fixa
  left_join(dvar_censo2000 |> filter(q_code=='v4260') |>
              transmute(v4260_uf = a_code, uf_residencia_datafixa = a_desc),
            keep=FALSE) |>
  # v4210: pais de nascimento
  left_join(dvar_censo2000 |> filter(q_code=='v4210') |>
              transmute(v4210_pais = a_code, pais_nascimento = a_desc),
            keep=FALSE) |>
  # v4230: pais de residência anterior
  left_join(dvar_censo2000 |> filter(q_code=='v4230') |>
              transmute(v4230_pais = a_code, pais_residencia_anterior = a_desc),
            keep=FALSE) |>
  # v4260: pais de residência data fixa
  left_join(dvar_censo2000 |> filter(q_code=='v4260') |>
              transmute(v4260_pais = a_code, pais_residencia_datafixa = a_desc),
            keep=FALSE) |>
  # v1103: município de residência
  left_join(dvar_censo2000 |> filter(q_code=='v1103') |>
              transmute(v1103 = a_code, municipio_residencia = a_desc),
            keep=FALSE) |>
  # v4250: município de residência data fixa
  left_join(dvar_censo2000 |> filter(q_code=='v4250') |>
              transmute(v4250 = a_code, municipio_residencia_datafixa = a_desc),
            keep=FALSE) |>
  ## to_duckdb() |> 
  # finalização da tabela de análises
  transmute(
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=areap,
    peso_amostral=as.numeric(p001)/1e8,
    # ......... Variáveis comuns ........................
    uf_residencia, 
    municipio_residencia,
    idade = if_else(v4572=='',NA,as.numeric(v4572)), 
    sexo = case_when(
      v0401 == '1' ~ 'masculino',
      v0401 == '2' ~ 'feminino',
      TRUE ~ NA
    ),
    alfabetizado = case_when( # sabe ler e escrever
      v0428 == '1' ~ 'sim',
      v0428 == '2' ~ 'nao',
      TRUE ~ NA
    ),
    estado_civil = case_when(
      v0438 == '1' ~ 'casado',     # Casado(a)
      v0438 == '2' ~ 'separado',   # desquitado(a) ou separado(a) judicialmente
      v0438 == '3' ~ 'separado',   # divorciado(a)
      v0438 == '4' ~ 'viúvo',      # viúvo(a)
      v0438 == '5' ~ 'solteiro',   # Solteiro(a)
      TRUE ~ NA
    ),
    instrucao = case_when( # curso mais elevado que freqüentou, concluindo pelo menos uma série
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
    cor_raca = case_when(
      v0408 == '1' ~ 'branca',
      v0408 == '2' ~ 'preta',
      v0408 == '3' ~ 'amarela',
      v0408 == '4' ~ 'parda',
      v0408 == '5' ~ 'indigena',
      v0408 == '9' ~ 'outros',
      TRUE ~ NA
      ),
    dif_enxergar = case_when( # capacidade de enxergar
      v0411 == '1' ~ 'incapaz',   # incapaz
      v0411 == '2' ~ 'grande',    # grande dificuldade permanente
      v0411 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0411 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0411 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    dif_ouvir = case_when( # capacidade de ouvir
      v0412 == '1' ~ 'incapaz',   # incapaz
      v0412 == '2' ~ 'grande',    # grande dificuldade permanente
      v0412 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0412 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0412 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    dif_locomover = case_when( # capacidade de caminhar/subir escadas
      v0413 == '1' ~ 'incapaz',   # incapaz
      v0413 == '2' ~ 'grande',    # grande dificuldade permanente
      v0413 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0413 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0413 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # ......... Variáveis referentes à Migração .........
    # mora neste município desde que nasceu?   # provavelmente dá pra retirar essa variável pois não serve...
    sempre_morou = case_when(
      v0415 == "1" ~ 1, # sim
      v0415 == "2" ~ 0, # não
      TRUE ~ NA
    ),
    # há quanto tempo mora sem interrupção neste município?
    municipio_residencia_tempo_anos = if_else(v0416=='',NA,as.numeric(v0416)), 
    # nasceu neste município?
    natural_do_municipio = case_when(
      v0417 == '1' ~ 1, # sim
      v0417 == '2' ~ 0, # não
      TRUE ~ NA
    ),
    # nasceu nesta unidade da federação?
    natural_da_uf = case_when(
      v0418 == '1' ~ 1, # sim
      v0418 == '2' ~ 0, # não
      TRUE ~ NA
    ),
    # qual é a sua nacionalidade?
    nacionalidade = case_when(
      v0419 == '1' ~ 'brasileiro nato',
      v0419 == '2' ~ 'naturalizado brasileiro',
      v0419 == '3' ~ 'estrangeiro',
      TRUE ~ NA
    ),
    # em que ano fixou residência no brasil?
    ano_residencia_brasil = if_else(v0420=='',NA,as.numeric(v0420)),
    # qual é a unidade da federação ou país estrangeiro de nascimento?
    uf_nascimento,
    pais_nascimento,
    # há quanto tempo mora sem interrupção nesta unidade da federação?
    uf_residencia_tempo_anos = if_else(v0422=='',NA,as.numeric(v0422)),
    # qual é a unidade da federação ou país estrangeiro de residência anterior?
    uf_residencia_anterior,
    pais_residencia_anterior,
    # em que município residia em 31 de julho de 1995?
    municipio_residencia_datafixa,
    # em que unidade da federação ou país estrangeiro residia em 31 de julho de 1995?
    uf_residencia_datafixa,
    pais_residencia_datafixa
  )

## --nomenclatura usada na tese--
## uf_nascimento = =
## uf_residencia =
## uf_residencia_tempo_anos =
## uf_residencia_anterior =
## uf_residencia_datafixa =

## municipio_nascimento =
## municipio_residencia =
## municipio_residencia_tempo_anos =
## municipio_residencia_anterior
## municipio_residencia_datafixa =

## estrangeiro =
## ano_residencia_brasil = 
## pais_nascimento =
## pais_residencia_anterior =
## pais_residencia_datafixa =
