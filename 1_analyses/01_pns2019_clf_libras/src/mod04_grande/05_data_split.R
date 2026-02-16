#' Divisão de Dados em Treino e Teste (Data Splitting)
#'
#' @description
#' Este módulo realiza a partição inicial do dataset \code{libras} em conjuntos de 
#' treinamento e teste utilizando o pacote \code{rsample}. A divisão é feita de 
#' forma estratificada para garantir que a proporção da variável alvo (\code{libras}) 
#' seja mantida em ambas as bases.
#'
#' @section Metodologia:
#' \itemize{
#'   \item \bold{Reprodutibilidade:} Define \code{set.seed(1)} para garantir que a 
#'   divisão seja idêntica em cada execução do pipeline.
#'   \item \bold{Estratificação:} Utiliza o argumento \code{strata} na variável alvo 
#'   para evitar viés de seleção, especialmente importante em classes desbalanceadas.
#'   \item \bold{Proporção Padrão:} Por padrão (\code{initial_split}), utiliza 75% 
#'   dos dados para treino e 25% para teste.
#' }
#'
#' @return Cria os objetos \code{libras_splits} (objeto rsplit), \code{libras_train} 
#' (data.frame de treino) e \code{libras_test} (data.frame de teste) no Global Environment.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords rsample data-split tidymodels
NULL

tic()
message("dividindo a matriz de modelo em bases de treino e teste (tidymodels/rsample)...")
set.seed(1)
libras_splits <-
  rsample::initial_split(
    libras,
    strata = libras
  )

libras_train <-
  rsample::training(
    libras_splits
  )

libras_test <-
  rsample::testing(
    libras_splits
  )

toc()
