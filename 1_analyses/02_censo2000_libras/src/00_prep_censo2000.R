
#' @title Orquestrador de Processamento: Censo 2000 (Libras)
#' 
#' @description
#' Este módulo centraliza a execução do pipeline de dados para a análise do Censo 2000. 
#' Ele define a estrutura de diretórios e carrega sequencialmente os scripts de 
#' importação, expansão amostral e engenharia de atributos (feature engineering) 
#' organizados por domínios temáticos (família, fertilidade, migração, espacial).
#'
#' @section Estrutura de Pastas:
#' \itemize{
#'   \item \code{base_dir}: Raiz do projeto específica para o Censo 2000.
#'   \item \code{src_dir}: Scripts fonte localizados em \code{src/}.
#'   \item \code{data_dir}: Armazenamento dos microdados brutos e processados.
#' }
#'
#' @section Pipeline de Execução:
#' \enumerate{
#'   \item \bold{Infraestrutura}: Carregamento de pacotes (\code{01}) e importação física (\code{02}).
#'   \item \bold{Estatística}: Configuração das variáveis de desenho e expansão (\code{03}).
#'   \item \bold{Engenharia de Atributos}:
#'     \itemize{
#'       \item \code{04, 09}: Variáveis comuns e geográficas.
#'       \item \code{05, 06, 07}: Domínios de arranjos familiares, fertilidade e migração.
#'       \item \code{08}: Variáveis específicas de deficiência e Libras para classificação.
#'     }
#'   \item \bold{Finalização}: Consolidação da ABT final (\code{10}).
#' }
#'
#' @name censo2000_orchestrator
NULL

message("removendo todos os objetos prévios...")
rm(list = ls(all.names = TRUE))

base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '02_censo2000_libras/'
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

results_dir <-
  paste0(
    base_dir,
    'results/'
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
