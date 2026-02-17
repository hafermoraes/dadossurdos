#' Definição do Conjunto de Métricas de Avaliação
#'
#' @description
#' Este módulo utiliza o pacote \code{yardstick} para consolidar as métricas de 
#' performance que guiarão a otimização dos hiperparâmetros e a seleção final 
#' dos modelos. O foco principal reside no \code{j_index} (Youden's J) e em 
#' métricas de precisão média e área sob a curva.
#'
#' @section Métricas Selecionadas:
#' \itemize{
#'   \item \bold{Baseadas em Classe:} \code{j_index} (Soma de Sensibilidade e 
#'   Especificidade - 1). Ideal para conjuntos com desbalanceamento, pois 
#'   penaliza falsos positivos e negativos igualmente.
#'   \item \bold{Baseadas em Probabilidade:} 
#'   \itemize{
#'     \item \code{roc_auc}: Área sob a curva ROC (discriminação geral).
#'     \item \code{pr_auc} e \code{average_precision}: Eficácia na classe positiva.
#'     \item \code{mn_log_loss} e \code{brier_class}: Avaliação da qualidade e 
#'     calibração das probabilidades preditas.
#'   }
#' }
#'
#' @details 
#' Métricas tradicionais como \code{accuracy} foram omitidas propositalmente 
#' para evitar o viés de avaliação em dados desbalanceados (ex: alta acurácia 
#' apenas prevendo a classe majoritária).
#'
#' @return Cria o objeto \code{metrics_set} (objeto metric_set) para uso nas 
#' funções de \code{tune} e \code{fit_resamples}.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords yardstick metrics classification tidymodels
NULL

tic()
message("definindo o conjunto de métricas sob as quais os modelos serão avaliados (tidymodels/yardstick)...")

class_independent_metrics_set <-
  metric_set(
    ## 'class' type
    ## accuracy,
    ## bal_accuracy,
    ## precision,
    ## recall,
    ## sens,
    ## spec,
    ## kap,
    ## mcc,
    ## j_index,
    ## 'class prob' type
    roc_auc,
    ## average_precision,
    ## brier_class,
    ## mn_log_loss,
    pr_auc
  )


message("configurando métricas dependentes de classe para otimização do classificador otimizado...")
# f1_measure <- metric_tweak("f1", f_meas, beta = 1)
# f2_measure <- metric_tweak("f2", f_meas, beta = 2)

class_dependent_metrics_set <- metric_set(
  accuracy, 
  j_index
  # f1_measure, 
  # f2_measure
)

toc()
