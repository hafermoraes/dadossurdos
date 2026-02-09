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
  
  fitted_models_racing <-
    wflow_set |>
    workflow_map(
      "tune_race_anova",
      seed = 1503,
      resamples = libras_folds,
      grid = 25,
      metrics = metrics_set,
      control = race_ctrl,
      verbose = TRUE
    )
  
  # passo 12: lista melhores modelos por métrica
  fitted_models_racing |>
    collect_metrics() |>
    mutate(
      wflow_id = str_remove_all(
        wflow_id,
        "basic_model_"
      )
    ) |>
    arrange(.metric, desc(mean)) |>
    write_csv(
      paste0(
        base_dir,
        "results/",
        "controlrace_metrics.csv"
      )
    )

  # diagnóstico gráfico dos melhores modelos por classificador
  (
    fitted_models_racing |>
      mutate( 
        wflow_id = str_remove_all(
          wflow_id, 
          "basic_model_"
        )
      ) |>
      autoplot(select_best = TRUE) + 
      geom_text(aes(y = mean, label = wflow_id), angle = 90, vjust = -0.7) + 
      ylim(c(0,1)) +
      theme(legend.position = "none") 
  ) |>
    ggsave(
      filename = paste0(
        base_dir,
        "results/controlrace_results.pdf"
        ),
      width=12,
      height=8
    )

 
}
