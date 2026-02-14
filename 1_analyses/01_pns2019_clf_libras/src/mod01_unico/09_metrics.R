
tic()
message("definindo o conjunto de métricas sob as quais os modelos serão avaliados (tidymodels/yardstick)...")
metrics_set <-
  metric_set(
    ## 'class' type
    # accuracy,
    # bal_accuracy,
    # precision,
    # recall,
    # sens,
    # spec,
    # kap,
    # mcc,
    j_index,
    ## 'class prob' type
    roc_auc,
    average_precision,
    brier_class,
    mn_log_loss,
    pr_auc
  )

toc()