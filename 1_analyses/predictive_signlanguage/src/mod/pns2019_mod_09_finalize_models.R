
METRIC <- "j_index"
for(CLF in fitted_models$wflow_id) {

  save_path <- 
    paste0(
      '/home/rstudio/',
      '1_analyses/',
      'predictive_signlanguage/',
      'results/',
      str_remove_all(CLF, "basic_model_"),
      '/'
    )
  
  # hiperparametros do modelo com melhor desempenho na metrica METRIC
  best_params <-
    fitted_models |>
    extract_workflow_set_result(CLF) |>
    select_best(metric=METRIC) 
  
  best_params |>
    select(-.config) |>
    pivot_longer(
      1:2,
      names_to = "hyperparameter",
      values_to = "value",
    ) |>
    write_csv(paste0(save_path, 'best_params.csv'))
  
  # modelo final ajustado com os hiperparametros otimizados
  best_clf <- 
    fitted_models |>
    extract_workflow(CLF) |>
    finalize_workflow(best_params) |> 
    last_fit(split = libras_splits, metrics = metrics_set)
  
  # salva modelo final (com a melhor métrica) em disco
  best_clf |>
    extract_workflow() |>
    write_rds(paste0(save_path, 'model.rds'))
  
  # salva metricas do modelo final em disco
  best_clf |>
    collect_metrics() |>
    write_csv(paste0(save_path, 'metrics.csv'))
  
  # histograma das probabilidades
  (
    collect_predictions(best_clf) |>
    ggplot(aes(.pred_sim)) +
    geom_histogram(col = "white", bins = 40) +
    facet_wrap(~ libras, ncol = 1) +
    geom_rug(col = "blue", alpha = 1 / 2) + 
    labs(x = "Probability Estimate of Libras")
  ) |>
    ggsave(
      filename = paste0(save_path, "workflowset_results.pdf"),
      width=12,
      height=8
    )
  
  # diagnóstico da calibração das probabilidades
  (
    cal_plot_breaks(best_clf)
  ) |>
    ggsave(
      filename = paste0(save_path, "cal_plot_breaks.pdf"),
      width=5,
      height=5
    )
  
  (
    cal_plot_windowed(best_clf, step_size = 0.025)
  ) |>
    ggsave(
      filename = paste0(save_path, "cal_plot_windowed.pdf"),
      width=5,
      height=5
    )
  
  (
    cal_plot_logistic(best_clf)
  ) |>
    ggsave(
      filename = paste0(save_path, "cal_plot_logistic.pdf"),
      width=5,
      height=5
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
      filename = paste0(save_path, "cal_estimate_beta.pdf"),
      width=5,
      height=5
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
      filename = paste0(save_path, "cal_estimate_logistic.pdf"),
      width=5,
      height=5
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
      filename = paste0(save_path, "cal_estimate_isotonic.pdf"),
      width=5,
      height=5
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
    write_csv(paste0(save_path, 'cal_estimate_isotonic_threshold.csv'))
  
  (
    cal_estimate_isotonic_threshold |>
      ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
      geom_line()
  ) |>
    ggsave(
      filename = paste0(save_path, "cal_estimate_isotonic_threshold.pdf"),
      width=5,
      height=5
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
    write_csv(paste0(save_path, 'cal_estimate_beta_threshold.csv'))
  
  (
    cal_estimate_beta_threshold |>
      ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
      geom_line()
  ) |>
    ggsave(
      filename = paste0(save_path, "cal_estimate_beta_threshold.pdf"),
      width=5,
      height=5
    )
  
  # otimização de threshold (sem calibração)
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
    write_csv(paste0(save_path, 'uncalibrated_threshold.csv'))
  
  (
    uncalibrated_threshold |>
    ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
    geom_line()
  ) |>
    ggsave(
      filename = paste0(save_path, "uncalibrated_threshold.pdf"),
      width=5,
      height=5
    )
  
  # variable importance (vip)
  (
    best_clf |>
    extract_fit_parsnip() |>
    vip(geom="point")
  ) |>
    ggsave(
      filename = paste0(save_path, "feature_importance.pdf"),
      width=5,
      height=5
    )
  
  (
    collect_predictions(best_clf) |>
      conf_mat(libras, .pred_class) |> 
      autoplot(type = "mosaic")
  ) |>
    ggsave(
      filename = paste0(save_path, "uncalibrated_confmat_mosaic.pdf"),
      width=5,
      height=5
    )
  
  # matriz de confusão
  (
    collect_predictions(best_clf) |>
      conf_mat(libras, .pred_class) |>
      autoplot(type = "heatmap")
  ) |>
    ggsave(
      filename = paste0(save_path, "uncalibrated_confmat_heatmap.pdf"),
      width=5,
      height=5
    )
  
}


# mod <-
#   read_rds('/tmp/mod.rds')
# 
# mod |>
#   predict(libras_test, type = "prob")

