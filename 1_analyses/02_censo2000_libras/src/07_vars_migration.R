
FILE <- "censo2000_migration"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_migration <-
  subset_censo2000 |>
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
  # v4210: uf de nascimento
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v4210') |>
      transmute(v4210_uf = a_code, uf_nascimento = a_desc) |>
      distinct(v4210_uf, .keep_all = TRUE),
    keep=FALSE
  ) |>
  # v4230: uf de residência anterior
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v4230') |>
      transmute(v4230_uf = a_code, uf_residencia_anterior = a_desc) |>
      distinct(v4230_uf, .keep_all = TRUE),
    keep=FALSE
  ) |>
  # v4260: uf de residência data fixa
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v4260') |>
      transmute(v4260_uf = a_code, uf_residencia_datafixa = a_desc) |>
      distinct(v4260_uf, .keep_all = TRUE),
    keep=FALSE
  ) |>
  # v4210: pais de nascimento
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v4210') |>
      transmute(v4210_pais = a_code, pais_nascimento = a_desc) |>
      distinct(v4210_pais, .keep_all = TRUE),
    keep=FALSE
  ) |>
  # v4230: pais de residência anterior
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v4230') |>
      transmute(v4230_pais = a_code, pais_residencia_anterior = a_desc) |>
      distinct(v4230_pais, .keep_all = TRUE),
    keep=FALSE
  ) |>
  # v4260: pais de residência data fixa
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v4260') |>
      transmute(v4260_pais = a_code, pais_residencia_datafixa = a_desc) |>
      distinct(v4260_pais, .keep_all = TRUE),
    keep=FALSE
  ) |>
  # v4250: município de residência data fixa
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v4250') |>
      transmute(v4250 = a_code, municipio_residencia_datafixa = a_desc) |>
      distinct(v4250, .keep_all = TRUE),
    keep=FALSE
  ) |>
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes à Migração .........
    # mora neste município desde que nasceu?   # provavelmente dá pra retirar essa variável pois não serve...
    municipio_sempre_morou = case_when(
      v0415 == "1" ~ "sim",
      v0415 == "2" ~ "nao",
      TRUE ~ NA
    ),
    # há quanto tempo mora sem interrupção neste município?
    municipio_residencia_tempo_anos = if_else(v0416=='',NA,as.numeric(v0416)), 
    # nasceu neste município?
    municipio_naturalidade = case_when(
      v0417 == '1' ~ "sim",
      v0417 == '2' ~ "nao",
      TRUE ~ NA
    ),
    # nasceu nesta unidade da federação?
    uf_naturalidade = case_when(
      v0418 == '1' ~ "sim",
      v0418 == '2' ~ "nao",
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
    ano_fixou_residencia_brasil = if_else(v0420=='',NA,as.numeric(v0420)),
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
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_migration |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_migration.csv"),
    na = ""
  )
toc()

gc()
