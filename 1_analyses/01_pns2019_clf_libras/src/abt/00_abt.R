#' @title Pipeline de Preparação da ABT (Analytical Base Table)
#' 
#' @description
#' Este módulo orquestra o fluxo de processamento de dados para o projeto PNS 2019. 
#' Ele define a estrutura de diretórios base e carrega sequencialmente os scripts de 
#' dependências, extração de dados brutos e análise exploratória.
#'
#' @section Estrutura de Diretórios:
#' \itemize{
#'   \item \code{base_dir}: Raiz do projeto no ambiente RStudio.
#'   \item \code{src_dir}: Scripts fonte localizados em \code{src/abt/}.
#'   \item \code{data_dir}: Armazenamento de datasets processados e brutos.
#'   \item \code{eda_dir}: Saídas da Análise Exploratória de Dados.
#' }
#'
#' @section Fluxo de Execução:
#' \enumerate{
#'   \item \code{01_load_packages.R}: Carregamento de bibliotecas (tidyverse, tidymodels, etc).
#'   \item \code{02_rawdata.R}: Leitura e limpeza dos dados brutos da PNS.
#'   \item \code{03_eda.R}: Execução de estatísticas descritivas.
#'   \item \code{05_modelmatrix.R}: Preparação da matriz de design para modelagem.
#' }
#'
#' @note 
#' O script \code{04_eda_graphs.R} está atualmente desativado (comentado).
#'
#' @name abt_orchestrator
NULL

library(tictoc)

tic()
message("removendo todos os objetos prévios...")
rm(list = ls(all.names = TRUE))
toc()

base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '01_pns2019_clf_libras/'
  )

src_dir <-
  paste0(
    base_dir,
    'src/abt/'
  )

data_dir <-
  paste0(
    base_dir,
    'data/'
  )

eda_dir <-
  paste0(
    base_dir,
    "eda/"
  )

source(paste0(src_dir, '01_empty_data_and_results_directory.R'))

source(paste0(src_dir, '02_load_packages.R'))
  
source(paste0(src_dir, '03_rawdata.R'))

source(paste0(src_dir, '04_treat_rawdata.R'))

source(paste0(src_dir, '05_apply_svydesign.R'))

source(paste0(src_dir, '06_eda.R'))

source(paste0(src_dir, '07_modelmatrix.R'))

source(paste0(src_dir, '08_eda_graphs.R'))

