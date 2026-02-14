
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

# harmonização das variáveis de arranjo familiar
subset_censo2010 <-
  open_dataset("/tmp/etl/br_ibge_censo_2010/parquet/pess") |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  select(
    v0011,v0010,v0001,v0002,v6036,v0601,v0627,v0640,v0633,v0606,v0614,v0615,v0616,
    v0502,v0504,v0300
  ) |> 
  mutate(
    across(everything(), ~ str_trim(.)),
    v0010 = as.numeric(v0010),
    v0002 = paste0(v0001,v0002),
  ) |>
  to_duckdb() |>
  # joins com dicionário de variáveis
  # v0001: uf de residência
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v0001') |>
              transmute(v0001 = a_code, uf_residencia = a_desc),
            keep=FALSE) |> 
  # v0002: município de residência
  left_join(dvar_censo2010 |> filter(base == 'pess', q_code=='v0002') |>
              transmute(v0002 = a_code, municipio_residencia = a_desc),
            keep=FALSE) |>
  # v0502: relação de convivência existente com a pessoa responsável pelo domicílio
  left_join(dvar_censo2010 |> filter(q_code=='v0502') |>
              transmute(v0502 = a_code, relacao_resp_domicilio = a_desc),
            keep=FALSE) |> 
  # finalização da tabela de análises
  transmute(
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=v0011,
    peso_amostral=v0010/1e13,
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
    # ......... Variáveis referentes ao Arranjo Familiar  .........
    id_relacao_resp_domicilio = v0502,
    relacao_resp_domicilio,
    nr_ordem_pessoa = v0504,
    id_domicilio = v0300
  )
