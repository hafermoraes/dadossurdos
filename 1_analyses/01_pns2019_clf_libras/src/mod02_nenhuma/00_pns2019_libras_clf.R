#' Orquestrador do Pipeline de Modelagem Preditiva (PNS 2019)
#'
#' @description
#' Este módulo atua como o controlador central do projeto. Ele define as variáveis 
#' globais de configuração, estabelece a estrutura de diretórios e executa 
#' sequencialmente todos os scripts do pipeline, desde a limpeza inicial até 
#' a calibração final dos modelos.
#'
#' @section Configurações Globais (Hiperparâmetros de Fluxo):
#' \itemize{
#'   \item \bold{PARALLEL:} Define se o processamento paralelo (\code{doParallel}) será ativado.
#'   \item \bold{KFOLD:} Ativa a validação cruzada (atualmente configurado para \eqn{k=5}).
#'   \item \bold{BOOTSTRAP_TIMES:} Número de repetições para reamostragem via Bootstrap.
#'   \item \bold{METRIC:} Métrica principal para otimização (J-Index).
#' }
#'
#' @section Estrutura de Diretórios:
#' O script organiza o projeto em três pilares principais sob o \code{base_dir}:
#' \itemize{
#'   \item \code{src/}: Código fonte organizado por versão de modelo.
#'   \item \code{results/}: Saídas, logs e tabelas LaTeX geradas.
#'   \item \code{data/}: Bases de dados originais e processadas.
#' }
#'
#' @note 
#' A execução é sequencial e dependente. Cada arquivo \code{source()} carrega 
#' objetos para o Global Environment que são necessários para os passos seguintes.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords master-script pipeline tidymodels
NULL

message("removendo todos os objetos prévios...")
rm(list = ls(all.names = TRUE))


message("definindo as variáveis globais...")

PARALLEL <- FALSE

KFOLD <- TRUE
KFOLD_NR <- 5

BOOTSTRAP_TIMES <- 25

CLASS_INDEPENDENT_METRIC <- "pr_auc"
CLASS_DEPENDENT_METRIC <- "j_index"

CONF_MAT_SUB <- FALSE

VARIABLE_IMPORTANCE <- TRUE

base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '01_pns2019_clf_libras/'
  )

model <- 'mod02_nenhuma/'

results_dir <-
  paste0(
    base_dir,
    'results/',
    model
  )

src_dir <-
  paste0(
    base_dir,
    'src/',
    model
  )

source(paste0(base_dir, 'src/', 'mod_graph_utils.R'))

source(paste0(base_dir, 'src/', 'mod_latex_utils.R'))

source(paste0(src_dir, '01_empty_results_directory.R'))

# source(paste0(src_dir, '02_install_packages.R'))

source(paste0(src_dir, '03_load_packages.R'))

source(paste0(src_dir, '04_data_import.R'))

source(paste0(src_dir, '05_data_split.R'))

source(paste0(src_dir, '06_crossval.R'))

source(paste0(src_dir, '07_preproc.R'))

source(paste0(src_dir, '08_classifiers.R'))

source(paste0(src_dir, '09_metrics.R'))

source(paste0(src_dir, '10_workflow_set.R'))

source(paste0(src_dir, '11m_fit_workflowmap.R'))

source(paste0(src_dir, '11r_fit_racing.R'))

source(paste0(src_dir, '12_finalize_models.R'))

source(paste0(src_dir, '13_optimize_threshold.R'))

source(paste0(src_dir, '14_calibrate_model.R'))

