# passo -8: finetune + racing
if(FALSE){
  # ## https://finetune.tidymodels.org/reference/tune_race_anova.html
  # cores <- parallel::detectCores(logical = FALSE)
  # cl <- makePSOCKcluster(cores)
  # registerDoParallel(cl)
  
  ## https://www.tmwr.org/workflow-sets#racing-example
  race_ctrl <-
    control_race(
      save_pred = TRUE,
      parallel_over = "everything",
      save_workflow = TRUE,
      verbose_elim = TRUE
    )
  
  race_results <-
    wflow_set |>
    workflow_map(
      "tune_race_anova",
      seed = 1503,
      resamples = libras_folds,
      grid = 25,
      metrics = m_set,
      control = race_ctrl,
      verbose = TRUE
    )
  
  race_results |> 
    mutate( wflow_id = str_remove_all(wflow_id, "basic_model_")) |>
    autoplot(select_best = FALSE) +
    geom_text(aes(y = mean - 1/20, label = wflow_id), angle = 90, hjust = 1) + 
    theme(legend.position = "none")
 
}
