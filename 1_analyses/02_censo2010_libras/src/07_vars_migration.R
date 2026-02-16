
#' @title Processamento de Variáveis de Migração e Naturalidade: Censo 2010
#' 
#' @description
#' Este script reconstrói a trajetória migratória dos indivíduos no Censo 2010. Ele 
#' processa informações de naturalidade, nacionalidade e residência em três momentos 
#' distintos: nascimento, residência anterior e residência em data fixa (31 de julho de 2005).
#'
#' @section Lógica de Decodificação e Joins:
#' \itemize{
#'   \item \bold{Múltiplos Joins}: Realiza cruzamentos exaustivos com o \code{dvar_censo2010} 
#'     para obter nomes de municípios e UFs para residência atual, anterior e de data fixa.
#'   \item \bold{Naturalidade}: Consolida a variável \code{v0618} para identificar se o 
#'     indivíduo nasceu no município de residência, diferenciando quem sempre morou de 
#'     quem retornou.
#'   \item \bold{Data Fixa (2005)}: Diferente do Censo 2000 (que usava 1995), este script 
#'     captura a posição do indivíduo exatos 5 anos antes do Censo de 2010.
#' }
#'
#' @section Regras de Negócio:
#' \itemize{
#'   \item \bold{Nacionalidade}: Classifica entre brasileiro nato, naturalizado e estrangeiro (\code{v0620}).
#'   \item \bold{Tempo de Residência}: Converte variáveis de tempo (\code{v0624, v0623}) para formato numérico.
#'   \item \bold{Naturalidade da UF}: Harmoniza a variável \code{v0619} para identificar natos da unidade da federação.
#' }
#'
#' @section Persistência:
#' O resultado é processado no motor \code{duckdb}, coletado e exportado como 
#' \code{censo2010_migration.csv} para compor a ABT final.
#'
#' @name 07_vars_migration_censo2010
NULL


FILE <- "censo2010_migration"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_migration <-
  subset_censo2010 |>
  # joins com dicionário de variáveis
  # v0001: uf de residência
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v0001') |>
      transmute(v0001 = a_code, uf_residencia = a_desc) |>
      distinct(v0001, .keep_all=TRUE),
    keep=FALSE
  ) |> 
  # v6222: uf de nascimento
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6222') |>
      transmute(v6222 = a_code, uf_nascimento = a_desc) |>
      distinct(v6222, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v6252: uf de residência anterior
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6252') |>
      transmute(v6252 = a_code, uf_residencia_anterior = a_desc) |>
      distinct(v6252, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v6262: uf de residência data fixa
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6262') |>
      transmute(v6262 = a_code, uf_residencia_datafixa = a_desc) |>
      distinct(v6262, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v6224: país de nascimento
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6224') |>
      transmute(v6224 = a_code, pais_nascimento = a_desc) |>
      distinct(v6224, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v6256: país de residência anterior
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6256') |>
      transmute(v6256 = a_code, pais_residencia_anterior = a_desc) |>
      distinct(v6256, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v6266: país de residência data fixa
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6266') |>
      transmute(v6266 = a_code, pais_residencia_datafixa = a_desc) |>
      distinct(v6266, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v0002: município de residência
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v0002') |>
      transmute(v0002 = a_code, municipio_residencia = a_desc) |>
      distinct(v0002, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v6264: município de residência data fixa
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6264') |>
      transmute(v6264 = a_code, municipio_residencia_datafixa = a_desc) |>
      distinct(v6264, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # v6254: município de residência anterior
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v6254') |>
      transmute(v6254 = a_code, municipio_residencia_anterior = a_desc) |>
      distinct(v6254, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes à Migração .........
    # nasceu neste município?   # provavelmente dá pra retirar essa variável pois não serve...
    municipio_sempre_morou = case_when(
      v0618 == "1" ~ "sim", # Sim e sempre morou
      v0618 == "2" ~ "nao", # Sim mas morou em outro município ou país estrangeiro
      v0618 == "3" ~ "nao", # Não
      TRUE ~ NA
    ),
    # tempo de moradia no município
    municipio_residencia_tempo_anos = if_else(v0624=='',NA,as.numeric(v0624)), 
    # nasceu neste município?
    municipio_naturalidade = case_when(
      v0618 == '1' ~ "sim", # Sim e sempre morou
      v0618 == '2' ~ "sim", # Sim mas morou em outro município ou país estrangeiro
      v0618 == '3' ~ "nao", # Não
      TRUE ~ NA
    ),
    # nasceu nesta unidade da federação?
    uf_naturalidade = case_when(
      v0619 == '1' ~ "sim", # Sim e sempre morou
      v0619 == '2' ~ "sim", # Sim mas morou em outro município ou país estrangeiro
      v0619 == '3' ~ "nao", # Não
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
    ano_fixou_residencia_brasil = if_else(v0621=='',NA,as.numeric(v0621)),
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
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_migration |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_migration.csv"),
    na = ""
  )
toc()

gc()
