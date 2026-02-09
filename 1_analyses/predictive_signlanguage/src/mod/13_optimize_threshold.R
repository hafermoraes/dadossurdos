
if(FALSE){
  
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
      base_dir,
      'results/',
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
    write_csv(paste0(save_path, 'uncalibrated_threshold.csv'))
  
  (
    uncalibrated_threshold |>
    ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
    geom_line()
  ) |>
    ggsave(
      filename = paste0(save_path, "uncalibrated_threshold.pdf"),
      width=WIDTH,
      height=HEIGHT
    )
    
}

}