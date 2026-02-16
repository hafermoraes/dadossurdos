#' @title Processamento de Variáveis de Fecundidade: Censo 2000
#' 
#' @description
#' Este script extrai e trata as variáveis relacionadas ao histórico reprodutivo feminino 
#' coletadas pelo Censo 2000. Realiza a conversão de campos de largura fixa para 
#' valores numéricos, permitindo o cálculo de taxas de sobrevivência infantil e 
#' análise de composição familiar.
#'
#' @section Variáveis de Fecundidade:
#' \itemize{
#'   \item \bold{Nascidos Vivos}: Total de filhos tidos que nasceram vivos (\code{v4620}).
#'   \item \bold{Sobreviventes}: Total de filhos tidos que nasceram vivos e ainda estavam vivos na data de referência (\code{v0463}).
#'   \item \bold{Nascidos Mortos}: Total de filhos que nasceram mortos (\code{v4670}).
#'   \item \bold{Total de Gestações}: Soma total de filhos tidos (\code{v4690}).
#'   \item \bold{Idade no Último Filho}: Idade da mulher por ocasião do nascimento do último filho tido (\code{v4654}).
#' }
#'
#' @section Persistência:
#' Os dados são processados via \code{duckdb}, coletados para o R e exportados como 
#' \code{censo2000_fertility.csv} no diretório de dados.
#'
#' @note 
#' Campos vazios (\code{''}) são convertidos sistematicamente para \code{NA} para garantir 
#' a integridade dos cálculos estatísticos.
#'
#' @name 06_vars_fertility_censo
NULL

FILE <- "censo2000_fertility"

tic()
message("preparando ", FILE, " no duckdb...")
censo2000_fertility <-
  subset_censo2000 |>
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes à Fecundidade .........
    # TODO incluir filhos nascidos ultimos 12 meses
    filhos_nascidos_vivos = ifelse(v4620=='', NA, as.numeric(v4620)),
    filhos_nascidos_vivos_vivos = ifelse(v0463=='', NA, as.numeric(v0463)),
    filhos_nascidos_mortos = ifelse(v4670=='', NA, as.numeric(v4670)),
    filhos_nascidos = ifelse(v4690=='', NA, as.numeric(v4690)),
    idade_ultimo_filho = ifelse(v4654=='', NA, as.numeric(v4654))
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2000_fertility |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2000_fertility.csv"),
    na = ""
  )
toc()

gc()
