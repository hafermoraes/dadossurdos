#' @title Processamento de Arranjos Familiares: Censo 2000
#' 
#' @description
#' Este script extrai e decodifica as variáveis que definem a posição de cada indivíduo 
#' dentro da unidade doméstica no Censo 2000. Ele permite a identificação da hierarquia 
#' familiar e a reconstrução de domicílios através de identificadores únicos.
#'
#' @section Variáveis de Estrutura Familiar:
#' \itemize{
#'   \item \bold{Relação com Responsável}: Realiza \code{left_join} com o dicionário 
#'     (\code{v0402}) para identificar se o indivíduo é o cônjuge, filho, parente, 
#'     agregado ou pensionista.
#'   \item \bold{Identificação Domiciliar}: Mantém o \code{id_domicilio} (\code{v0300}) 
#'     para permitir agregações por unidade habitacional.
#'   \item \bold{Ordem na Unidade}: O campo \code{nr_ordem_pessoa} (\code{v0400}) define 
#'     a sequência dos moradores dentro do domicílio.
#' }
#'
#' @section Persistência:
#' Os dados são processados via \code{duckdb}, coletados para o R e exportados como 
#' \code{censo2000_family_arrangements.csv} no diretório de dados.
#'
#' @name 05_vars_family_arrangements_censo
NULL

FILE <- "censo2000_family_arrangements"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_family_arrangements <-
  subset_censo2000 |>
  # joins com dicionário de variáveis
  # v0402: relação de convivência existente com a pessoa responsável pelo domicílio
  left_join(
    dvar_censo2000 |>
      filter(base == 'pes', q_code=='v0402') |>
      transmute(v0402 = a_code, relacao_resp_domicilio = a_desc) |>
      distinct(v0402, .keep_all=TRUE),
    keep=FALSE
  ) |> 
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes ao Arranjo Domiciliar .........
    id_relacao_resp_domicilio = v0402,
    relacao_resp_domicilio,
    nr_ordem_pessoa = v0400,
    id_domicilio = v0300
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_family_arrangements |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_family_arrangements.csv"),
    na = ""
  )
toc()

gc()

