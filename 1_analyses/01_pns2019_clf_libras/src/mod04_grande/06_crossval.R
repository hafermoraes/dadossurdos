#' Configuração de Reamostragem (Resampling) para Validação de Modelos
#'
#' @description
#' Este módulo estabelece a estratégia de reamostragem a ser utilizada durante a fase 
#' de treinamento e ajuste de hiperparâmetros. Ele suporta duas metodologias principais: 
#' K-Fold Cross-Validation e Bootstrapping, ambas com amostragem estratificada.
#'
#' @section Estratégias de Validação:
#' \itemize{
#'   \item \bold{K-Fold Cross-Validation:} Ativada quando \code{KFOLD = TRUE}. Divide 
#'   a base de treino em \code{KFOLD_NR} subconjuntos (folds). Recomendada para 
#'   estimativas de performance robustas.
#'   \item \bold{Bootstrapping:} Ativada como alternativa ao K-Fold. Realiza 
#'   \code{BOOTSTRAP_TIMES} repetições com reposição. Útil para avaliar a 
#'   estabilidade das métricas.
#' }
#'
#' @details 
#' Independente da técnica escolhida, a variável \code{strata = libras} garante 
#' que o desbalanceamento de classes original seja preservado em cada partição 
#' (fold ou bootstrap).
#'
#' @note 
#' Requer as variáveis globais \code{KFOLD}, \code{KFOLD_NR} e \code{BOOTSTRAP_TIMES} 
#' previamente definidas no script mestre.
#'
#' @return Cria o objeto \code{libras_folds} (objeto rset) contendo as partições 
#' de reamostragem.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords rsample cross-validation bootstrap tidymodels
NULL

tic()
message("configurando a validação cruzada (tidymodels/rsample)...")
if(KFOLD){
  message("usando K-Fold Cross Validation...")
  libras_folds <-
    rsample::vfold_cv(
      data = libras_train,
      strata = libras,
      v = KFOLD_NR
    )
  
} else {
  
  message("usando Bootstraping...")
  libras_folds <-
    rsample::bootstraps(
      data = libras_train,
      times = BOOTSTRAP_TIMES,
      strata = libras
    )
  
}

toc()

