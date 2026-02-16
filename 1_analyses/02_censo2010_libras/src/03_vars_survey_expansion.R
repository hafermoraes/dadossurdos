
#' @title Processamento de Variáveis de Expansão: Censo 2010
#' 
#' @description
#' Este script isola e normaliza as variáveis de desenho amostral do Censo 2010. 
#' Assim como no Censo 2000, realiza a correção de escala do peso amostral para 
#' permitir a expansão correta das estimativas populacionais no ambiente R.
#'
#' @section Regras de Transformação:
#' \itemize{
#'   \item \bold{Área de Ponderação}: Mapeia a variável \code{v0011} para o campo 
#'     \code{area_ponderacao}, unidade geográfica fundamental para o cálculo de erros padrão.
#'   \item \bold{Peso Amostral}: Aplica o fator de correção escalar de \eqn{10^{13}} 
#'     à variável \code{v0010}. No Censo 2010, os pesos possuem 13 casas decimais 
#'     implícitas no formato de armazenamento original do IBGE.
#' }
#'
#' @section Persistência:
#' Os dados são coletados do motor \code{duckdb} e persistidos em formato CSV 
#' (\code{censo2010_survey_expansion.csv}) para integração na ABT final.
#'
#' @name 03_vars_survey_expansion_censo2010
NULL


FILE <- "censo2010_survey_expansion"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_survey_expansion <-
  subset_censo2010 |>
  # finalização da tabela de análises
  transmute(
    row_id, 
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=v0011,
    peso_amostral=v0010/1e13
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_survey_expansion |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_survey_expansion.csv"),
    na = ""
  )
toc()

gc()
