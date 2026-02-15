#' Calibração de Probabilidades e Otimização de Threshold Pós-Calibração
#'
#' @description
#' Este módulo aplica técnicas de calibração para ajustar as probabilidades geradas 
#' pelo melhor classificador selecionado. Utiliza o pacote \code{probably} para 
#' diagnosticar e corrigir desvios sistemáticos nas predições, comparando três 
#' métodos: Beta, Logístico (Platt Scaling) e Isotônico.
#'
#' @section Diagnósticos de Calibração:
#' \itemize{
#'   \item \bold{Breaks Plot:} Avalia a calibração em bins fixos de probabilidade.
#'   \item \bold{Windowed Plot:} Utiliza janelas móveis para uma visão contínua da calibração.
#'   \item \bold{Logistic Plot:} Compara as probabilidades contra um ajuste logístico ideal.
#' }
#'
#' @section Métodos de Calibração:
#' \itemize{
#'   \item \bold{Calibração Beta:} Ajuste flexível baseado na distribuição Beta, ideal para probabilidades limitadas entre 0 e 1.
#'   \item \bold{Calibração Logística:} Ajuste clássico via Regressão Logística.
#'   \item \bold{Calibração Isotônica:} Método não paramétrico (\code{step-function}) que preserva a monotonicidade, eficaz com grandes volumes de dados.
#' }
#'
#' @details 
#' Após a calibração, o script reavalia o desempenho do modelo através de um novo 
#' grid search de thresholds (\code{threshold_perf}), permitindo uma escolha de 
#' ponto de corte muito mais confiável e precisa.
#'
#' @note 
#' Este bloco está em \code{if(FALSE)} e foca apenas no \bold{melhor modelo} 
#' identificado pela métrica \code{METRIC} no workflow set.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords probably calibration beta-calibration isotonic-regression tidymodels
NULL


if(FALSE){
  tic()
  message("calibrando o modelo (tidymodels/probably)...")
  
  WIDTH <- 7
  HEIGHT <- 7
  
  METRIC <- "j_index"
  
  CLF <- 
    fitted_models |>
    collect_metrics() |>
    filter(.metric == METRIC) |> 
    arrange(.metric, desc(mean)) |>
    head(1) |>
    select(wflow_id) |>
    as.character()
  
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
  
  # diagnóstico da calibração das probabilidades
  
  cal_plot_breaks(best_clf) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_diagnostic_breaks_plot.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )

  cal_plot_windowed(best_clf, step_size = 0.025) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_diagnostic_windowed_plot.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )
  
  cal_plot_logistic(best_clf) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_diagnostic_logistic_plot.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )
  
  # resultado da calibração por três métodos distintos
  (
    best_clf |>
    cal_apply(
      cal_estimate_beta(best_clf, libras)
    ) |>
    cal_plot_windowed(
      truth = libras, 
      estimate = .pred_sim, 
      step_size = 0.025
    )
  ) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_estimate_beta_plot.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )
  
  (
    best_clf |>
    cal_apply(
      cal_estimate_logistic(best_clf, libras)
    ) |>
    cal_plot_windowed(
      truth = libras, 
      estimate = .pred_sim, 
      step_size = 0.025
    )
  ) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_estimate_logistic_plot.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )
  
  set.seed(1)
  (
    best_clf |>
    cal_apply(
      cal_estimate_isotonic(best_clf, libras)
    ) |>
    cal_plot_windowed(
      truth = libras, 
      estimate = .pred_sim, 
      step_size = 0.025
    )
  ) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_estimate_isotonic_plot.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )
  
  # threshold optimization
  thresholds <- seq(0.01, 0.95, by = 0.01)
  
  # cal estimate_isotonic_threshold
  cal_estimate_isotonic_threshold <- 
    best_clf |>
      cal_apply(
        cal_estimate_isotonic(best_clf, libras)
      ) |>
      threshold_perf(
        truth = libras, 
        estimate = .pred_sim, 
        thresholds = thresholds,
        metric =   metric_set(
          accuracy, bal_accuracy,
          sens, spec,
          precision, recall,
          npv, ppv,
          kap, mcc,
          f_meas
        )
      ) |> 
      filter(.metric != 'distance') 
  
  cal_estimate_isotonic_threshold |>
    write_csv(
      paste0(
        save_path,
        'calib_estimate_isotonic_threshold_grid.csv'
      )
    )
  
  (
    cal_estimate_isotonic_threshold |>
      ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
      geom_line()
  ) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_estimate_isotonic_threshold_grid.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )

  # cal estimate_beta_threshold
  cal_estimate_beta_threshold <- 
    best_clf |>
    cal_apply(
      cal_estimate_beta(best_clf, libras)
    ) |>
    threshold_perf(
      truth = libras, 
      estimate = .pred_sim, 
      thresholds = thresholds,
      metric =   metric_set(
        accuracy, bal_accuracy,
        sens, spec,
        precision, recall,
        npv, ppv,
        kap, mcc,
        f_meas
      )
    ) |> 
    filter(.metric != 'distance') 
  
  cal_estimate_beta_threshold |>
    write_csv(
      paste0(
        save_path,
        'calib_estimate_beta_threshold_grid.csv'
      )
    )
  
  (
    cal_estimate_beta_threshold |>
      ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
      geom_line()
  ) |>
    ggsave(
      filename = paste0(
        save_path,
        "calib_estimate_beta_threshold_grid.pdf"
      ),
      width=WIDTH,
      height=HEIGHT
    )
  
  toc()
}
