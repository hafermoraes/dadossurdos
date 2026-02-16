#' Consolidação do Conjunto de Fluxos de Trabalho (Workflow Set)
#'
#' @description
#' Este módulo utiliza o pacote \code{workflowsets} para realizar o cruzamento (\code{cross}) 
#' entre as receitas de pré-processamento e as especificações dos modelos. Ele cria uma 
#' estrutura organizada que permite a execução paralela e comparativa de múltiplos 
#' experimentos em uma única chamada.
#'
#' @section Estrutura do Workflow Set:
#' \itemize{
#'   \item \bold{Preproc:} Utiliza a \code{recipe_basic} como base de tratamento de dados.
#'   \item \bold{Models:} Inclui 10 especificações distintas, variando desde o modelo nulo 
#'   até algoritmos de boosting e redes neurais.
#'   \item \bold{Case Weights:} Incorpora pesos de amostragem (\code{case_weights}) 
#'   diretamente no fluxo, garantindo que o desenho amostral da PNS seja respeitado 
#'   durante o treinamento.
#' }
#'
#' @details 
#' O argumento \code{cross = TRUE} garante que cada modelo seja pareado com cada 
#' receita definida (neste caso, resultando em uma matriz 1x10). O identificador 
#' resultante seguirá o padrão \code{basic_[modelo]}.
#'
#' @return Cria o objeto \code{wflow_set} (objeto workflow_set) contendo a lista 
#' de todos os fluxos de trabalho prontos para o tuning.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords workflowsets model-selection tidymodels
NULL


tic()
message("unificando o pipeline de tratamento e ajuste (tidymodels/workflowsets)...")
# https://workflowsets.tidymodels.org/reference/workflow_set.html#see-also

wflow_set <- 
  workflow_set(
    preproc = list(
      basic = recipe_basic
    ),
    models = list(
      model_null = model_null,
      model_dt = model_dt,
      # model_lgb = model_lgb,
      model_logres = model_logres,
      model_mars = model_mars,
      model_mlp = model_mlp,
      model_nb = model_nb,
      model_rf = model_rf,
      model_svm = model_svm,
      model_xgb = model_xgb
    ),
    cross = TRUE,
    case_weights = "case_weights"
  ) 

toc()
