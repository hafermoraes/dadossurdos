
#' @title Orquestrador de Processamento: Censo 2010 (Libras)
#' 
#' @description
#' Este módulo coordena o pipeline de processamento de dados do Censo 2010. 
#' Assim como no Censo 2000, ele estabelece a estrutura de diretórios e dispara 
#' a execução sequencial dos scripts de extração, tratamento estatístico e 
#' engenharia de atributos para o estudo da Língua Brasileira de Sinais.
#'
#' @section Estrutura de Diretórios:
#' \itemize{
#'   \item \code{base_dir}: Raiz do projeto dedicada ao Censo 2010.
#'   \item \code{src_dir}: Pasta contendo os scripts fonte (\code{.R}).
#'   \item \code{data_dir}: Local de persistência dos arquivos CSV, Parquet e ABT final.
#' }
#'
#' @section Fluxo de Módulos:
#' \enumerate{
#'   \item \bold{Preparação}: Carregamento de pacotes (\code{01}) e importação via DuckDB/Arrow (\code{02}).
#'   \item \bold{Calibração}: Definição de pesos e áreas de ponderação (\code{03}).
#'   \item \bold{Domínios Temáticos}:
#'     \itemize{
#'       \item \code{04, 09}: Características demográficas e espaciais.
#'       \item \code{05, 06, 07}: Núcleos familiares, histórico de fecundidade e fluxos migratórios.
#'       \item \code{08}: Classificação e predição da variável Libras.
#'     }
#'   \item \bold{Consolidação}: União dos módulos e validação da integridade (\code{10}).
#' }
#'
#' @name censo2010_orchestrator
NULL

base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '02_censo2010_libras/'
  )

src_dir <-
  paste0(
    base_dir,
    'src/'
  )

data_dir <-
  paste0(
    base_dir,
    'data/'
  )


source(paste0(src_dir, '01_load_packages.R'))

source(paste0(src_dir, '02_import_microdata.R'))

source(paste0(src_dir, '03_vars_survey_expansion.R'))

source(paste0(src_dir, '04_vars_common.R'))

source(paste0(src_dir, '05_vars_family_arrangements.R'))

source(paste0(src_dir, '06_vars_fertility.R'))

source(paste0(src_dir, '07_vars_migration.R'))

source(paste0(src_dir, '08_vars_libras_clf.R'))

source(paste0(src_dir, '09_vars_spatial.R'))

source(paste0(src_dir, '10_finalize_abt.R'))

source(paste0(src_dir, '11_validate_abt.R'))

source(paste0(src_dir, '12_sabe_libras_stats.R'))

