#' @title Processamento de Arranjos Familiares: Censo 2010
#' 
#' @description
#' Este script extrai e decodifica as variáveis de composição e hierarquia doméstica 
#' dos microdados do Censo 2010. Ele permite identificar o papel de cada indivíduo 
#' na unidade domiciliar e possibilita a reconstrução de núcleos familiares.
#'
#' @section Variáveis de Estrutura Familiar:
#' \itemize{
#'   \item \bold{Relação com Responsável}: Decodifica a variável \code{v0502} via \code{left_join} 
#'     com o dicionário (\code{dvar_censo2010}), identificando cônjuges, filhos e outros parentes ou agregados.
#'   \item \bold{Identificação do Domicílio}: Mantém a chave \code{v0300} (\code{id_domicilio}) para 
#'     permitir agrupamentos e análises por unidade habitacional.
#'   \item \bold{Ordem de Morador}: Preserva a variável \code{v0504} (\code{nr_ordem_pessoa}) para 
#'     referência da sequência de preenchimento do questionário no domicílio.
#' }
#'
#' @section Persistência:
#' O processamento é realizado no motor \code{duckdb}, coletado para o R e exportado 
#' para \code{censo2010_family_arrangements.csv} no diretório de dados.
#'
#' @name 05_vars_family_arrangements_censo2010
NULL


FILE <- "censo2010_family_arrangements"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_family_arrangements <-
  subset_censo2010 |>
  # joins com dicionário de variáveis
  # v0502: relação de convivência existente com a pessoa responsável pelo domicílio
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v0502') |>
      transmute(v0502 = a_code, relacao_resp_domicilio = a_desc) |>
      distinct(v0502, .keep_all=TRUE),
    keep=FALSE
  ) |> 
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes ao Arranjo Domiciliar .........
    id_relacao_resp_domicilio = v0502,
    relacao_resp_domicilio,
    nr_ordem_pessoa = v0504,
    id_domicilio = v0300
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_family_arrangements |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_family_arrangements.csv"),
    na = ""
  )
toc()

gc()

