#' @title Processamento de Variáveis de Expansão: Censo 2000
#' 
#' @description
#' Este script isola e normaliza as variáveis de desenho amostral do Censo 2000. 
#' A principal operação consiste na correção do fator de escala do peso amostral, 
#' garantindo que as estimativas populacionais sejam calculadas corretamente no R.
#'
#' @section Regras de Transformação:
#' \itemize{
#'   \item \bold{Área de Ponderação}: Renomeia \code{areap} para \code{area_ponderacao}, unidade geográfica mínima para aplicação dos pesos.
#'   \item \bold{Peso Amostral}: Converte \code{p001} para numérico e aplica o divisor \eqn{10^8}. 
#'     No Censo 2000, os pesos são armazenados como inteiros grandes para evitar decimais no arquivo fixo; 
#'     a divisão restaura a precisão decimal necessária.
#' }
#'
#' @section Persistência:
#' O resultado é coletado do \code{duckdb} e salvo como um arquivo CSV 
#' (\code{censo2000_survey_expansion.csv}) para garantir a modularidade do pipeline.
#'
#' @name 03_vars_survey_expansion_censo
NULL

FILE <- "censo2000_survey_expansion"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_survey_expansion <-
  subset_censo2000 |>
  # finalização da tabela de análises
  transmute(
    row_id, 
    # ......... Variáveis de expansão da amostra ........
    area_ponderacao=areap,
    peso_amostral=as.numeric(p001)/1e8
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_survey_expansion |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_survey_expansion.csv"),
    na = ""
  )
toc()

gc()
