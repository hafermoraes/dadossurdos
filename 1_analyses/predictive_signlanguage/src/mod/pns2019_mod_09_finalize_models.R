
METRIC <- "j_index"

classifiers <-
  fitted_models |>
  select(wflow_id) |>
  filter(wflow_id != 'basic_model_null') |>
  as.data.frame()

for(CLF in classifiers) {

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
    pivot_longer(
      -.config,
      names_to = "hyperparameter",
      values_to = "value",
    ) |>
    select(-.config) |>
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
    select(.metric, .estimate) |>
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
      filename = paste0(save_path, "uncalibrated_prob_histogram.pdf"),
      width=12,
      height=8
    )
    
  # variable importance (vip)
  if (! str_remove_all(CLF, "basic_model_") %in% c('svm', 'nb')){
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
  }

  # matriz de confusão (gráfico de mosaico)
  clf_confmat <-
    collect_predictions(best_clf) |>
    conf_mat(libras, .pred_class)
  
  (
     clf_confmat |> 
      autoplot(type = "mosaic")
  ) |>
    ggsave(
      filename = paste0(save_path, "uncalibrated_confmat_mosaic.pdf"),
      width=5,
      height=5
    )
  
  # matriz de confusão (heatmap)
  (
    clf_confmat |>
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

