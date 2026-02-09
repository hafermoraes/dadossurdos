
if(FALSE){

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

}
