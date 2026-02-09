
METRIC <- "j_index"

classifiers <-
  fitted_models |>
  select(wflow_id) |>
  filter(wflow_id != 'basic_model_null') 

for(CLF in classifiers$wflow_id) {

  save_path <- 
    paste0(
      base_dir,
      'results/',
      str_remove_all(CLF, "basic_model_"),
      '/'
    )
  
  # hiperparametros do modelo com melhor desempenho na métrica METRIC
  best_params <-
    fitted_models |>
    extract_workflow_set_result(CLF) |>
    select_best(metric=METRIC) 
  
  # modelo final ajustado com os hiperparametros otimizados
  best_clf <- 
    fitted_models |>
    extract_workflow(CLF) |>
    finalize_workflow(best_params) |> 
    last_fit(split = libras_splits, metrics = metrics_set)
  
  # >>> Encontra threshold que otimiza o modelo >>>
  preds <-
    best_clf |>
    collect_predictions()
  
  thresholds <- 
    preds |>
    threshold_perf(
      libras, 
      .pred_sim, 
      thresholds = seq(0, 0.9, by = 0.01)
    )
  
  opt_threshold <-
    thresholds |> 
    filter(.metric == "j_index") |>
    arrange(desc(.estimate)) |>
    head(1)
  
  optimum_threshold <- opt_threshold$.threshold
  
  preds_with_optimum_threshold <-
    preds |>
    mutate(
      .pred_class = make_two_class_pred(
        .pred_sim,
        levels(libras),
        threshold = opt_threshold$.threshold
      )
    )

  unweighted_preds_with_optimum_threshold <-
    preds_with_optimum_threshold |> 
    select( libras, .pred_class) |> 
    bind_cols(
      libras_test |> 
        transmute(
          case_weights = round(as.numeric(case_weights),0),
          dif_ouvir
        )
    )
  
  weighted_preds_with_optimum_threshold <-
    unweighted_preds_with_optimum_threshold |> 
    uncount(case_weights)
  # <<< Encontra threshold que otimiza o modelo <<<
  
  # >>> salva modelo final (com a melhor métrica) em disco >>>
  write_rds(
    list(
      isolation_forest = iso_forest,
      clf_model = best_clf |> extract_workflow(),
      optimum_threshold = opt_threshold$.threshold
    ),
    paste0(save_path, 'model.rds')
  )
  # mod <-
  #   read_rds(paste0(save_path, 'model.rds'))
  # 
  # mod$clf_model |>
  #   predict(libras_test, type = "prob")
  # 
  # mod$optimum_threshold
  # <<< salva modelo final (com a melhor métrica) em disco <<<
    
  # >>> Exporta parâmetros em disco para LaTeX >>>
  export_params <-
    best_params |>
    pivot_longer(
      -.config,
      names_to = "hyperparameter",
      values_to = "value",
    ) |>
    select(-.config) 
  
  print(
    xtable( 
      export_params, 
      digits = c(
        0, # row name
        0, # hyperparameter
        6 # value
      )
    ),
    sanitize.text.function = identity,
    only.contents=TRUE,
    include.rownames=FALSE,
    include.colnames=TRUE,
    hline.after=NULL,
    comment=FALSE,
    format.args = list(big.mark = ".", decimal.mark = ","),
    file=paste0(save_path, "params.tex")
  )
  # <<< Exporta parâmetros em disco para LaTeX <<<
  
  # >>> Exporta métricas em disco para LaTeX >>>
  export_metrics <-
    best_clf |>
    collect_metrics() |> 
    select(.metric, .estimate) 
  
  print(
    xtable( 
      export_metrics, 
      digits = c(
        0, # row name
        0, # .metric
        6  # .estimate
      )
    ),
    sanitize.text.function = identity,
    only.contents=TRUE,
    include.rownames=FALSE,
    include.colnames=TRUE,
    hline.after=NULL,
    comment=FALSE,
    format.args = list(big.mark = ".", decimal.mark = ","),
    file=paste0(save_path, "metrics.tex")
  )
  # <<< Exporta métricas em disco para LaTeX <<<
  
  # variable importance (vip)
  if (! str_remove_all(CLF, "basic_model_") %in% c('svm', 'nb', 'bc5', 'bart', 'bagrpart')){
    (
      best_clf |>
      extract_fit_parsnip() |>
      vip(geom="point")
    ) |>
      ggsave(
        filename = paste0(save_path, "plot_feature_importance.pdf"),
        width=5,
        height=5
      )
  }
  
  
  # histograma das probabilidades
  (
    collect_predictions(best_clf) |>
      ggplot(aes(.pred_sim)) +
      geom_histogram(col = "white", bins = 40) +
      facet_wrap(~ libras, ncol = 1) +
      geom_vline(
        xintercept = opt_threshold$.threshold, 
        color = "red", 
        linetype = "dashed", 
        linewidth = 0.5
      ) +
      geom_rug(col = "blue", alpha = 1 / 2) + 
      labs(
        x = "Estimativa da probabilidade de saber Libras",
        y = "Quantidade de casos",
        title = "Distribuição dos escores por classe de predição",
        subtitle = paste0(
          "Linha vermelha refere-se ao ponto de corte ", 
          optimum_threshold,
          "que otimiza a performance do modelo")
        )
  ) |>
    ggsave(
      filename = paste0(save_path, "plot_probability_histogram.pdf"),
      width=12,
      height=8
    )
  

  # matriz de confusão (dados não ponderados)
  clf_confmat_unweighted <-
    unweighted_preds_with_optimum_threshold |> 
    conf_mat(
      truth=libras, 
      .pred_class
      )
  
  # https://stackoverflow.com/questions/63449602/merge-several-confusion-matrix-with-xtable
  print(
    xtable( 
      clf_confmat_unweighted$table, 
      digits = c(0, 0, 0)
    ),
    sanitize.text.function = identity,
    only.contents=TRUE,
    include.rownames=FALSE,
    include.colnames=TRUE,
    hline.after=NULL,
    comment=FALSE,
    format.args = list(big.mark = ".", decimal.mark = ","),
    file=paste0(save_path, "conf_mat_unweighted.tex")
  )

  # Mosaic  
  (
     clf_confmat_unweighted |> 
      autoplot(type = "mosaic") +
      labs(
        title = "Matriz de confusão",
        subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (real)",
        y = "Sabe Libras (Predito)"
      )
  ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_mosaic_unweighted.pdf"),
      width=5,
      height=5
    )
  
  # Heatmap
  (
    clf_confmat_unweighted |>
      autoplot(type = "heatmap") + 
      labs(
        title = "Matriz de confusão",
        subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (real)",
        y = "Sabe Libras (Predito)"
      )  ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_heatmap_unweighted.pdf"),
      width=5,
      height=5
    )
  
  # matriz de confusão (dados ponderados)
  clf_confmat_weighted <-
    weighted_preds_with_optimum_threshold |> 
    conf_mat(
      truth=libras, 
      .pred_class
    )

  print(
    xtable( 
      clf_confmat_weighted$table, 
      digits = c(0, 0, 0)
    ),
    sanitize.text.function = identity,
    only.contents=TRUE,
    include.rownames=FALSE,
    include.colnames=TRUE,
    hline.after=NULL,
    comment=FALSE,
    format.args = list(big.mark = ".", decimal.mark = ","),
    file=paste0(save_path, "conf_mat_weighted.tex")
  )
  
  # Mosaic  
  (
    clf_confmat_weighted |> 
      autoplot(type = "mosaic") +
      labs(
        title = "Matriz de confusão",
        subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (real)",
        y = "Sabe Libras (Predito)"
      )  ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_mosaic_weighted.pdf"),
      width=5,
      height=5
    )
  
  # Heatmap
  (
    clf_confmat_weighted |>
    autoplot(type = "heatmap") + 
      labs(
        title = "Matriz de confusão",
        subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (real)",
        y = "Sabe Libras (Predito)"
      )
    ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_heatmap_weighted.pdf"),
      width=5,
      height=5
    )
    
  # Matrizes de confusão por nível de dif_ouvir
  DIF_OUVIR <- 
    libras_test$dif_ouvir |>
    as.character() |>
    unique()
  
  for(dif in DIF_OUVIR){
    
    # Dados ponderados
    weighted_preds_sub <-
      weighted_preds_with_optimum_threshold |>
      filter(dif_ouvir == dif)
    
    clf_confmat_weighted_sub <-
      weighted_preds_sub |>
      conf_mat(
        truth=libras, 
        .pred_class
      )

    print(
      xtable( 
        clf_confmat_weighted_sub$table, 
        digits = c(0, 0, 0)
      ),
      sanitize.text.function = identity,
      only.contents=TRUE,
      include.rownames=FALSE,
      include.colnames=TRUE,
      hline.after=NULL,
      comment=FALSE,
      format.args = list(big.mark = ".", decimal.mark = ","),
      file=paste0(save_path, "conf_mat_weighted_",dif,".tex")
    )
    
    # Matriz de Confusão
    # Mosaic  
    (
      clf_confmat_weighted_sub |>
        autoplot(type = "mosaic") +
        labs(
          title = paste0(
            "Matriz de confusão (dif_ouvir=",
            dif,
            ")"
          ),
          subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
          x = "Sabe Libras (real)",
          y = "Sabe Libras (Predito)"
        )  
      ) |>
      ggsave(
        filename = paste0(
          save_path, 
          "plot_confusion_matrix_mosaic_weighted_",
          dif,
          ".pdf"),
        width=5,
        height=5
      )
    
    # Heamap
    (
      clf_confmat_weighted_sub |>
        autoplot(type = "heatmap") +
        labs(
          title = paste0(
            "Matriz de confusão (dif_ouvir=",
            dif,
            ")"
          ),
          subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
          x = "Sabe Libras (real)",
          y = "Sabe Libras (Predito)"
        )  ) |>
      ggsave(
        filename = paste0(
          save_path, 
          "plot_confusion_matrix_heatmap_weighted_",
          dif,
          ".pdf"),
        width=5,
        height=5
      )
    
    # Dados não ponderados
    unweighted_preds_sub <-
      unweighted_preds_with_optimum_threshold |>
      filter(dif_ouvir == dif)

    clf_confmat_unweighted_sub <-
      unweighted_preds_sub |>
      conf_mat(
        truth=libras, 
        .pred_class
      )
    
    print(
      xtable( 
        clf_confmat_unweighted_sub$table, 
        digits = c(0, 0, 0)
      ),
      sanitize.text.function = identity,
      only.contents=TRUE,
      include.rownames=FALSE,
      include.colnames=TRUE,
      hline.after=NULL,
      comment=FALSE,
      format.args = list(big.mark = ".", decimal.mark = ","),
      file=paste0(save_path, "conf_mat_unweighted_",dif,".tex")
    )
    
        
    # Matriz de Confusão
    # Mosaic  
    (
      clf_confmat_unweighted_sub |>
        autoplot(type = "mosaic") +
        labs(
          title = paste0(
            "Matriz de confusão (dif_ouvir=",
            dif,
            ")"
          ),
          subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
          x = "Sabe Libras (real)",
          y = "Sabe Libras (Predito)"
        )  ) |>
      ggsave(
        filename = paste0(
          save_path, 
          "plot_confusion_matrix_mosaic_unweighted_",
          dif,
          ".pdf"),
        width=5,
        height=5
      )
    
    # Heatmap
    (
      clf_confmat_unweighted_sub |>
        autoplot(type = "heatmap") +
        labs(
          title = paste0(
            "Matriz de confusão (dif_ouvir=",
            dif,
            ")"
          ),
          subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
          x = "Sabe Libras (real)",
          y = "Sabe Libras (Predito)"
        )  ) |>
      ggsave(
        filename = paste0(
          save_path, 
          "plot_confusion_matrix_heatmap_unweighted_",
          dif,
          ".pdf"),
        width=5,
        height=5
      )    
    
  }
  
  
}



