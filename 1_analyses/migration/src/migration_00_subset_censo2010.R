
# dicionário de variáveis
dvar_censo2010 <-
  read_delim(
    '/tmp/etl/br_ibge_censo_2010/variables_dictionary.txt',
    delim = '|'
  ) |>
  filter(base=='pess') |>
  mutate(
    a_desc = str_trim(a_desc),
    a_desc = str_to_title(a_desc, locale = 'pt-br')
  ) |>
  to_duckdb()

# harmonização das variáveis de migração
subset_censo2010 <-
  open_dataset("/tmp/etl/br_ibge_censo_2010/parquet/pess") |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  select(
    v0011,v0010,v0001,v0002,v6036,v0601,v0627,v0640,v0633,v0606,v0614,v0615,v0616,
    v0618,v0624,v0619,v0620,v0621,v0623,v6222,v6252,v6262,v6224,v6256,v6266,v6264,v6254
  ) |> 
  mutate(
    across(everything(), ~ str_trim(.)),
    v0002 = paste0(v0001,v0002),
    v6222 = str_sub(v6222, start=1, end=2),
    v6252 = str_sub(v6252, start=1, end=2),
    v6262 = str_sub(v6262, start=1, end=2)
  ) |>
  to_duckdb() |>
  # joins com dicionário de variáveis
  # v0001: uf de residência
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v0001') |>
              transmute(v0001 = a_code, uf_residencia = a_desc),
            keep=FALSE) |> 
  # v6222: uf de nascimento
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6222') |>
              transmute(v6222 = a_code, uf_nascimento = a_desc),
            keep=FALSE) |>
  # v6252: uf de residência anterior
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6252') |>
              transmute(v6252 = a_code, uf_residencia_anterior = a_desc),
            keep=FALSE) |>
  # v6262: uf de residência data fixa
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6262') |>
              transmute(v6262 = a_code, uf_residencia_datafixa = a_desc),
            keep=FALSE) |>
  # v6224: pais de nascimento
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6224') |>
              transmute(v6224 = a_code, pais_nascimento = a_desc),
            keep=FALSE) |>
  # v6256: pais de residência anterior
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6256') |>
              transmute(v6256 = a_code, pais_residencia_anterior = a_desc),
            keep=FALSE) |>
  # v6266: pais de residência data fixa
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6266') |>
              transmute(v6266 = a_code, pais_residencia_datafixa = a_desc),
            keep=FALSE) |>
  # v0002: município de residência
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v0002') |>
              transmute(v0002 = a_code, municipio_residencia = a_desc),
            keep=FALSE) |>
  # v6264: município de residência data fixa
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6264') |>
              transmute(v6264 = a_code, municipio_residencia_datafixa = a_desc),
            keep=FALSE) |>
  # v6254: município de residência anterior
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v6254') |>
              transmute(v6254 = a_code, municipio_residencia_anterior = a_desc),
            keep=FALSE) |>
  ## to_duckdb() |> 
  # finalização da tabela de análises
  transmute(
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=v0011,
    peso_amostral=as.numeric(v0010)/1e8,
    # ......... Variáveis comuns ........................
    uf_residencia, 
    municipio_residencia,
    idade = if_else(v6036=='',NA,as.numeric(v6036)), 
    sexo = case_when(
      v0601 == '1' ~ 'masculino',
      v0601 == '2' ~ 'feminino',
      TRUE ~ NA
    ),
    alfabetizado = case_when( # sabe ler e escrever
      v0627 == '1' ~ 'sim',
      v0627 == '2' ~ 'nao',
      TRUE ~ NA
    ),
    estado_civil = case_when(
      v0640 == '1' ~ 'casado',     # Casado(a)
      v0640 == '2' ~ 'separado',   # Desquitado(a) ou separado(a) judicialmente
      v0640 == '3' ~ 'separado',   # divorciado(a)
      v0640 == '4' ~ 'viúvo',      # viúvo(a)
      v0640 == '5' ~ 'solteiro',   # Solteiro(a)
      TRUE ~ NA
    ),
    instrucao = case_when( # curso mais elevado que frequentou
      v0633 == '01' ~ 'outros',      # Creche, pré-escolar (maternal e jardim de infância), classe de alfabetização - CA
      v0633 == '02' ~ 'outros',      # Alfabetização de jovens e adultos
      v0633 == '03' ~ 'fundamental', # Antigo primário (elementar)
      v0633 == '04' ~ 'fundamental', # Antigo ginásio (médio 1º ciclo)
      v0633 == '05' ~ 'fundamental', # Ensino fundamental ou 1º grau (da 1ª a 3ª série/ do 1º ao 4º ano)
      v0633 == '06' ~ 'fundamental', # Ensino fundamental ou 1º grau (4ª série/ 5º ano)
      v0633 == '07' ~ 'fundamental', # Ensino fundamental ou 1º grau (da 5ª a 8ª série/ 6º ao 9º ano)
      v0633 == '08' ~ 'fundamental', # Supletivo do ensino fundamental ou do 1º grau
      v0633 == '09' ~ 'medio',       # Antigo científico, clássico, etc.....(médio 2º ciclo)
      v0633 == '10' ~ 'medio',       # Regular ou supletivo do ensino médio ou do 2º grau
      v0633 == '11' ~ 'superior',    # Superior de graduação
      v0633 == '12' ~ 'superior',    # Especialização de nível superior ( mínimo de 360 horas )
      v0633 == '13' ~ 'superior',    # Mestrado
      v0633 == '14' ~ 'superior',    # Doutorado
      TRUE ~ NA
    ),
    cor_raca = case_when(
      v0606 == '1' ~ 'branca',
      v0606 == '2' ~ 'preta',
      v0606 == '3' ~ 'amarela',
      v0606 == '4' ~ 'parda',
      v0606 == '5' ~ 'indigena',
      v0606 == '9' ~ 'outros',
      TRUE ~ NA
      ),
    dif_enxergar = case_when( # capacidade de enxergar
      v0614 == '1' ~ 'incapaz',   # incapaz
      v0614 == '2' ~ 'grande',    # grande dificuldade permanente
      v0614 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0614 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0614 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    dif_ouvir = case_when( # capacidade de ouvir
      v0615 == '1' ~ 'incapaz',   # incapaz
      v0615 == '2' ~ 'grande',    # grande dificuldade permanente
      v0615 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0615 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0615 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    dif_locomover = case_when( # capacidade de caminhar/subir escadas
      v0616 == '1' ~ 'incapaz',   # incapaz
      v0616 == '2' ~ 'grande',    # grande dificuldade permanente
      v0616 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0616 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0616 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # ......... Variáveis referentes à Migração .........
    # nasceu neste município?   # provavelmente dá pra retirar essa variável pois não serve...
    sempre_morou = case_when(
      v0618 == "1" ~ 1, # Sim e sempre morou
      v0618 == "2" ~ 0, # Sim mas morou em outro município ou país estrangeiro
      v0618 == "3" ~ 0, # Não
      TRUE ~ NA
    ),
    # tempo de moradia no município
    municipio_residencia_tempo_anos = if_else(v0624=='',NA,as.numeric(v0624)), 
    # nasceu neste município?
    natural_do_municipio = case_when(
      v0618 == '1' ~ 1, # Sim e sempre morou
      v0618 == '2' ~ 1, # Sim mas morou em outro município ou país estrangeiro
      v0618 == '3' ~ 0, # Não
      TRUE ~ NA
    ),
    # nasceu nesta unidade da federação?
    natural_da_uf = case_when(
      v0619 == '1' ~ 1, # Sim e sempre morou
      v0619 == '2' ~ 1, # Sim mas morou em outro município ou país estrangeiro
      v0619 == '3' ~ 0, # Não
      TRUE ~ NA
    ),
    # qual é a sua nacionalidade?
    nacionalidade = case_when(
      v0620 == '1' ~ 'brasileiro nato',
      v0620 == '2' ~ 'naturalizado brasileiro',
      v0620 == '3' ~ 'estrangeiro',
      TRUE ~ NA
    ),
    # em que ano fixou residência no brasil?
    ano_residencia_brasil = if_else(v0621=='',NA,as.numeric(v0621)),
    # qual é a unidade da federação ou país estrangeiro de nascimento?
    uf_nascimento,
    pais_nascimento,
    # há quanto tempo mora sem interrupção nesta unidade da federação?
    uf_residencia_tempo_anos = if_else(v0623=='',NA,as.numeric(v0623)),
    # qual é a unidade da federação ou país estrangeiro de residência anterior?
    uf_residencia_anterior,
    pais_residencia_anterior,
    municipio_residencia_anterior,
    # em que município residia em 31 de julho de 1995?
    municipio_residencia_datafixa,
    # em que unidade da federação ou país estrangeiro residia em 31 de julho de 1995?
    uf_residencia_datafixa,
    pais_residencia_datafixa
  )
