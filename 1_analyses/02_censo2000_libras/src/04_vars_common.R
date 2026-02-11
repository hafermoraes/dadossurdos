
FILE <- "censo2000_common"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_common <-
  subset_censo2000 |>
  # joins com dicionário de variáveis
  # v0102: uf de residência
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v0102') |>
      transmute(v0102 = a_code, uf_residencia = a_desc) |>
      distinct(v0102, .keep_all=TRUE),
    keep=FALSE
  ) |> 
  # v1103: município de residência
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v1103') |>
      transmute(v1103 = a_code, municipio_residencia = a_desc) |>
      distinct(v1103, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # finalização da tabela de análises
  transmute(
    row_id,
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
    )
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_common |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_common.csv"),
    na = ""
  )
toc()

gc()

