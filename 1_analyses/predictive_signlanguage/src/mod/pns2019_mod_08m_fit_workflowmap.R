# passo 8: ajuste dos modelos
set.seed(1)

wflow_set_fit <- 
  workflow_map(
    wflow_set, 
    fn = "tune_grid",
    seed = 1, 
    metrics = metrics_set,
    resamples = libras_folds,
    verbose = TRUE
  )


# passo 12: lista melhores modelos por métrica
wflow_set_fit |>
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
      "./",
      "1_analyses/",
      "predictive_signlanguage/",
      "results/",
      "workflowset_metrics.csv"
    )
  )

# diagnóstico gráfico dos melhores modelos por classificador
(
  wflow_set_fit |>
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
    filename = "1_analyses/predictive_signlanguage/results/workflowset_results.pdf",
    width=12,
    height=8
    )
