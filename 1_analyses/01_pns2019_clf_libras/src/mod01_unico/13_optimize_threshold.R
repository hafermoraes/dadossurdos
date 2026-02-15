#' Análise de Sensibilidade e Grid Search de Thresholds (Não Calibrados)
#'
#' @description
#' Este módulo realiza uma varredura exaustiva (grid search) de pontos de corte 
#' (thresholds) para cada classificador finalizado. O objetivo é gerar um mapeamento 
#' detalhado de como métricas conflitantes (ex: Sensibilidade vs Especificidade) 
#' se comportam em diferentes níveis de probabilidade, exportando dados tabulares 
#' e visualizações gráficas para suporte à decisão.
#'
#' @section Detalhes da Execução:
#' \itemize{
#'   \item \bold{Grid de Busca:} Varre thresholds de 0.01 a 0.95 com incrementos de 0.01.
#'   \item \bold{Métricas Avaliadas:} \code{accuracy}, \code{sens}, \code{spec}, 
#'   \code{precision} e \code{recall}.
#'   \item \bold{Saídas por Modelo:}
#'   \itemize{
#'     \item \code{threshold_grid_uncalibrated.csv}: Tabela bruta com todas as estimativas.
#'     \item \code{plot_threshold_grid_uncalibrated.pdf}: Gráfico de linhas comparativo 
#'     entre as métricas ao longo do eixo de probabilidade.
#'   }
#' }
#'
#' @note 
#' Este bloco está em \code{if(FALSE)} por ser uma etapa de diagnóstico visual 
#' que precede a calibração final do modelo. Ele utiliza o \code{last_fit} para 
#' avaliar a performance real na base de teste.
#'
#' @return Gera arquivos de diagnóstico no subdiretório de cada modelo em \code{results_dir}.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords thresholds sensitivity-analysis yardstick ggplot2
NULL

if(FALSE){
  tic()
  message("otimizando o threshold (tidymodels/finetune)...")
  WIDTH <- 10
  HEIGHT <- 7

  METRIC <- "j_index"

  classifiers <-
    fitted_models |>
    select(wflow_id) |>
    filter(wflow_id != 'basic_model_null') |>
    as.data.frame()

  for(CLF in classifiers$wflow_id) {

    save_path <- 
      paste0(
        results_dir,
        str_remove_all(CLF, "basic_model_"),
        '/'
      )
    
    best_params <-
      fitted_models |>
      extract_workflow_set_result(CLF) |>
      select_best(metric=METRIC) 
    
    best_clf <- 
      fitted_models |>
      extract_workflow(CLF) |>
      finalize_workflow(best_params) |> 
      last_fit(split = libras_splits, metrics = metrics_set)
    
    thresholds <- seq(0.01, 0.95, by = 0.01)
    
    uncalibrated_threshold <- 
      collect_predictions(best_clf) |> 
      threshold_perf(
        truth = libras, 
        estimate = .pred_sim, 
        thresholds = thresholds,
        metric =   metric_set(
          accuracy,
          sens,
          spec,
          precision,
          recall
        )
      ) |> 
      filter(.metric != 'distance')
    
    uncalibrated_threshold |>
      write_csv(paste0(save_path, 'threshold_grid_uncalibrated.csv'))
    
    (
      uncalibrated_threshold |>
        ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
        geom_line()
    ) |>
      ggsave(
        filename = paste0(save_path, "plot_threshold_grid_uncalibrated.pdf"),
        width=WIDTH,
        height=HEIGHT
      )
    
  }
  toc()
}
