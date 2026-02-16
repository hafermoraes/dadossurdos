#' Finalização, Otimização de Threshold e Exportação de Resultados
#'
#' @description
#' Este módulo itera sobre todos os classificadores treinados no \code{workflow_set},
#' seleciona os melhores hiperparâmetros, ajusta o modelo final contra a base de teste
#' e realiza a busca pelo ponto de corte (threshold) que otimiza o \code{j_index}.
#' Adicionalmente, exporta tabelas LaTeX, gráficos de importância de variáveis
#' e matrizes de confusão (ponderadas e não ponderadas).
#'
#' @section Fluxo de Finalização por Modelo:
#' \itemize{
#'   \item \bold{Extração e Ajuste:} Recupera os melhores parâmetros segundo a métrica global
#'   e realiza o \code{last_fit} na base de teste.
#'   \item \bold{Otimização de Threshold:} Varre valores de 0 a 0.9 para encontrar o ponto
#'   que maximiza a performance do classificador.
#'   \item \bold{Ponderação Amostral:} Gera predições ponderadas expandindo as observações
#'   pelos pesos da PNS (\code{uncount}) para garantir representatividade populacional.
#'   \item \bold{Exportação LaTeX:} Gera arquivos \code{.tex} para parâmetros, métricas e
#'   matrizes de confusão usando \code{xtable}.
#'   \item \bold{Visualização:} Produz histogramas de probabilidade, gráficos de importância
#'   (\code{vip}) e matrizes de confusão (Mosaic e Heatmap).
#' }
#'
#' @note
#' O modelo final e o threshold ótimo são salvos em um único objeto \code{.rds} dentro
#' da pasta específica de cada classificador no \code{results_dir}.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords finalize threshold-optimization confusion-matrix xtable tidymodels
NULL


tic()
message("finalizando os modelos (métricas, parâmetros, matrizes de confusão)...")

message("obtendo lista de classificadores ajustados em 'classifers'...")
classifiers <-
  fitted_models |>
  select(wflow_id) |>
  filter(wflow_id != 'basic_model_null')

message("iniciando o loop de finalização para cada classificador ajustado...")
for(CLF in classifiers$wflow_id) {

  message("executando garbage collection -- gc() -- para aliviar o consumo de memória...")
  gc()

  save_path <-
    paste0(
      results_dir,
      str_remove_all(CLF, "basic_model_"),
      '/'
    )

  message("obtendo lista de hiperparâmetros do modelo ", CLF, " com melhor desempenho na métrica '", CLASS_INDEPENDENT_METRIC, "'...")
  best_params <-
    fitted_models |>
    extract_workflow_set_result(CLF) |>
    select_best(metric=CLASS_INDEPENDENT_METRIC)

  message("modelo ", CLF, "final ajustado com os hiperparâmetros otimizados...")
  best_clf <-
    fitted_models |>
    extract_workflow(CLF) |>
    finalize_workflow(best_params) |>
    last_fit(split = libras_splits, metrics = class_independent_metrics_set)

  # >>> Encontra threshold que otimiza o modelo >>>
  message("encontrando o threshold que otimiza a métrica '", CLASS_DEPENDENT_METRIC, "' do modelo '", CLF, "'...")
  preds <-
    best_clf |>
    collect_predictions()

  thresholds <-
    preds |>
    threshold_perf(
      libras,
      .pred_sim,
      thresholds = seq(0, 0.9, by = 0.01),
      metrics=class_dependent_metrics_set
    )

  opt_threshold <-
    thresholds |>
    filter(.metric == CLASS_DEPENDENT_METRIC) |>
    arrange(desc(.estimate)) |>
    head(1)

  optimum_threshold <- opt_threshold$.threshold

  message("exportando threshold (ponto de corte) em disco para latex...")
  export_threshold_to_latex(
    threshold=optimum_threshold,
    model=model,
    classifier=str_remove_all(CLF, "basic_model_"),
    specification="threshold",
    output_file = paste0(
      results_dir,
      "vars_",
      stringr::str_split_i(model, "[_/]", 2),
      ".tex"
    )
  )


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
          case_weights = round(as.numeric(case_weights),0)
        )
    )

  weighted_preds_with_optimum_threshold <-
    unweighted_preds_with_optimum_threshold |>
    uncount(case_weights)
  # <<< Encontra threshold que otimiza o modelo <<<

  # >>> salva modelo final (com a melhor métrica) em disco >>>
  message("salvando em disco (formato RDS) o melhor modelo '", CLF,"'...")
  all_objects <- list(
    clf_model = best_clf |> extract_workflow(),
    optimum_threshold = opt_threshold$.threshold
  )
  write_rds(
    all_objects,
    paste0(save_path, 'model.rds')
  )
  # mod <- read_rds(paste0(save_path, 'model.rds'))
  # mod$clf_model |> predict(libras_test, type = "prob")
  # mod$optimum_threshold
  # <<< salva modelo final (com a melhor métrica) em disco <<<



  # >>> Exporta hiperparâmetros em disco para LaTeX >>>
  message("exportando lista de hiperparâmetros do melhor modelo '", CLF, "' para o LaTeX...")
  export_params <-
    best_params |>
    pivot_longer(
      -.config,
      names_to = "hyperparameter",
      values_to = "value",
      ) |>
    select(-.config)

  export_specs_to_latex(
    input_table=export_params,
    model=model,
    classifier=str_remove_all(CLF, "basic_model_"),
    specification="params",
    output_file = paste0(
      results_dir,
      "vars_",
      stringr::str_split_i(model, "[_/]", 2),
      ".tex"
    )
  )
  # <<< Exporta hiperparâmetros em disco para LaTeX <<<


  
  # >>> Exporta métricas em disco para LaTeX >>>
  message("exportando lista de métricas do melhor modelo '", CLF, "' para o LaTeX...")
  export_class_independent_metrics <-
    best_clf |>
    collect_metrics() |>
    select(.metric, .estimate)

  export_class_dependent_metrics <-
    preds_with_optimum_threshold |>
    class_dependent_metrics_set(
      truth = libras,
      estimate = .pred_class
    ) |> 
    select(.metric, .estimate)
   
  export_metrics <- 
    bind_rows(
      export_class_independent_metrics,
      export_class_dependent_metrics
    )

  export_specs_to_latex(
    input_table=export_metrics,
    model=model,
    classifier=str_remove_all(CLF, "basic_model_"),
    specification="metrics",
    output_file = paste0(
      results_dir,
      "vars_",
      stringr::str_split_i(model, "[_/]", 2),
      ".tex"
    )
  )
  # <<< Exporta métricas em disco para LaTeX <<<

  
  
  # >>> Diagnóstico Gráfico: Variable Importance (vip) >>>
  if(VARIABLE_IMPORTANCE){
    message("exportando gráfico de importância de variáveis para o melhor modelo '", CLF, "' em disco...")
    export_graph_variable_importance(
      input_table = best_clf,
      classifier = str_remove_all(CLF, "basic_model_"),
      plot_width = 5,
      plot_height = 5,
      output_file = paste0(save_path, "plot_feature_importance.pdf")
    )
  }
  # <<< Diagnóstico Gráfico: Variable Importance (vip) <<<


  # >>> Diagnóstico Gráfico: Histograma das probabilidades por classe de 'sabe_libras' >>>
  message("exportando histograma de probabilidades por classe de 'sabe_libras' para o melhor modelo '", CLF, "' em disco...")
  export_graph_probability_histogram(
    input_table = collect_predictions(best_clf),
    threshold = opt_threshold$.threshold,
    plot_width = 12,
    plot_height = 8,
    output_file = paste0(save_path, "plot_probability_histogram.pdf")
  )
  # <<< Diagnóstico Gráfico: Histograma das probabilidades por classe de 'sabe_libras' <<<

  
  # Matrizes de Confusão
  clf_confmat <-
    list(
      # matriz de confusão (dados ponderados)
      weighted = weighted_preds_with_optimum_threshold |>
        conf_mat(
          truth=libras,
          .pred_class
        ),
      # matriz de confusão (dados não ponderados)
      unweighted = unweighted_preds_with_optimum_threshold |>
        conf_mat(
          truth=libras,
          .pred_class
        )
    )

  message("exportando matrizes de confusão em disco para latex...")
  export_confmat_to_latex(
    input_table = clf_confmat[[ "weighted" ]],
    model=model,
    classifier=str_remove_all(CLF, "basic_model_"),
    output_file = paste0(
      results_dir,
      "vars_",
      stringr::str_split_i(model, "[_/]", 2),
      ".tex"
    )
  )

  
  # >>> Diagnóstico Gráfico: Matriz de Confusão >>>
  for(data_type in names(clf_confmat)){
    for(graph_type in c("mosaic", "heatmap")){
      export_graph_confusion_matrix(
        input_table = clf_confmat[[data_type]],
        threshold = opt_threshold$.threshold,
        plot_type = graph_type,
        plot_width = 5,
        plot_height = 5,
        output_file = paste0(save_path, "plot_confusion_matrix_", graph_type, "_", data_type, ".pdf")
      )
    }
  }
  # <<< Diagnóstico Gráfico: Matriz de Confusão <<<

}

toc()
