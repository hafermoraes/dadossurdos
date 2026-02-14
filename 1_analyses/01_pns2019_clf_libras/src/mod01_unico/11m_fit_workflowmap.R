
tic()
message("ajuste dos modelos preditivos (tidymodels/workflowsets)...")

if(PARALLEL){
  message("ativando o paralelismo...")
  cores <- parallel::detectCores(logical = FALSE) - 2
  cl <- makePSOCKcluster(cores)
  registerDoParallel(cl)
}

set.seed(1)

fitted_models <- 
  workflow_map(
    wflow_set, 
    fn = "tune_grid",
    seed = 1, 
    metrics = metrics_set,
    resamples = libras_folds,
    verbose = TRUE
  )


# passo 12: lista melhores modelos por métrica
fitted_models |>
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
      results_dir,
      "workflowset_metrics.csv"
    )
  )
# TODO exportar para LaTeX

# diagnóstico gráfico dos melhores modelos por classificador
(
  fitted_models |>
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
      results_dir,
      "workflowset_results.pdf"
      ),
    width=12,
    height=8
    )

toc()