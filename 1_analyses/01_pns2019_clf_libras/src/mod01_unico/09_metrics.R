
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
