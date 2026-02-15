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

  message("obtendo lista de hiperparâmetros do modelo ", CLF, " com melhor desempenho na métrica '", METRIC, "'...")
  best_params <-
    fitted_models |>
    extract_workflow_set_result(CLF) |>
    select_best(metric=METRIC)

  message("modelo ", CLF, "final ajustado com os hiperparâmetros otimizados...")
  best_clf <-
    fitted_models |>
    extract_workflow(CLF) |>
    finalize_workflow(best_params) |>
    last_fit(split = libras_splits, metrics = metrics_set)

  # >>> Encontra threshold que otimiza o modelo >>>
  message("encontrando o threshold que otimiza a métrica '", METRIC, "' do modelo '", CLF, "'...")
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
  message("salvando em disco (formato RDS) o melhor modelo '", CLF,"'...")
  all_objects <- list(
    clf_model = best_clf |> extract_workflow(),
    optimum_threshold = opt_threshold$.threshold
  )
  write_rds(
      all_objects,
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
    classifier=CLF,
    specification="params",
    output_file = paste0(
      results_dir,
      "vars_unico.tex"
    )
  )
  # <<< Exporta hiperparâmetros em disco para LaTeX <<<

  # >>> Exporta métricas em disco para LaTeX >>>
  message("exportando lista de métricas do melhor modelo '", CLF, "' para o LaTeX...")
  export_metrics <-
    best_clf |>
    collect_metrics() |>
    select(.metric, .estimate)

  export_specs_to_latex(
    input_table=export_metrics,
    model=model,
    classifier=CLF,
    specification="metrics",
    output_file = paste0(
      results_dir,
      "vars_unico.tex"
    )
  )

  # <<< Exporta métricas em disco para LaTeX <<<

  # >>> Diagnóstico Gráfico: Variable Importance (vip) >>>
  if(VARIABLE_IMPORTANCE){
    if (! str_remove_all(CLF, "basic_model_") %in% c('svm', 'nb', 'bc5', 'bart', 'bagrpart')){

      tryCatch({
        message("exportando gráfico de importância de variáveis para o melhor modelo '", CLF, "' em disco...")
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
      },
      error = function(e) {
        message("Erro: ", e$message)
      },
      warning = function(w) {
        message("Warning: ", w$message)
      },
      finally = {
        message("Sem erros")
      }
      )
    }
  }
  # <<< Diagnóstico Gráfico: Variable Importance (vip) <<<

  # >>> Diagnóstico Gráfico: Histograma das probabilidades por classe de 'sabe_libras' >>>
  message("exportando histograma de probabilidades por classe de 'sabe_libras' para o melhor modelo '", CLF, "' em disco...")
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
        # title = "Distribuição dos escores (probabilidade de saber Libras) por classe de predição",
        # subtitle = paste0(
        #   "Nota: A linha vermelha refere-se ao ponto de corte (threshold) ",
        #   optimum_threshold,
        #   " que otimiza a performance do modelo segundo a métrica ",
        #   METRIC
        # ),
        x = "Estimativa da probabilidade de saber Libras",
        y = "Quantidade de casos"
        )
  ) |>
    ggsave(
      filename = paste0(save_path, "plot_probability_histogram.pdf"),
      width=12,
      height=8
    )
  # <<< Diagnóstico Gráfico: Histograma das probabilidades por classe de 'sabe_libras' <<<

  # matriz de confusão (dados não ponderados)
  clf_confmat_unweighted <-
    unweighted_preds_with_optimum_threshold |>
    conf_mat(
      truth=libras,
      .pred_class
      )

  # >>> Diagnóstico Gráfico: Matriz de Confusão (Mosaic) para dados não ponderados >>>
  (
     clf_confmat_unweighted |>
      autoplot(type = "mosaic") +
      labs(
        title = "Matriz de confusão",
        caption = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (Real)",
        y = "Sabe Libras (Predito)"
      )
  ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_mosaic_unweighted.pdf"),
      width=5,
      height=5
    )
  # <<< Diagnóstico Gráfico: Matriz de Confusão (Mosaic) para dados não ponderados <<<
  
  # >>> Diagnóstico Gráfico: Matriz de Confusão (Heatmap) para dados não ponderados >>>
  (
    clf_confmat_unweighted |>
      autoplot(type = "heatmap") +
      labs(
        title = "Matriz de confusão",
        subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (Real)",
        y = "Sabe Libras (Predito)"
      )  ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_heatmap_unweighted.pdf"),
      width=5,
      height=5
    )
  # <<< Diagnóstico Gráfico: Matriz de Confusão (Heatmap) para dados não ponderados <<<
  
  # matriz de confusão (dados ponderados)
  clf_confmat_weighted <-
    weighted_preds_with_optimum_threshold |>
    conf_mat(
      truth=libras,
      .pred_class
    )

  # >>> Diagnóstico Gráfico: Matriz de Confusão (Mosaic) para dados ponderados >>>
  (
    clf_confmat_weighted |>
      autoplot(type = "mosaic") +
      labs(
        title = "Matriz de confusão",
        subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (Real)",
        y = "Sabe Libras (Predito)"
      )  ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_mosaic_weighted.pdf"),
      width=5,
      height=5
    )
  # <<< Diagnóstico Gráfico: Matriz de Confusão (Mosaic) para dados ponderados <<<

  # >>> Diagnóstico Gráfico: Matriz de Confusão (Heatmap) para dados ponderados >>>
  (
    clf_confmat_weighted |>
    autoplot(type = "heatmap") +
      labs(
        title = "Matriz de confusão",
        subtitle = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (Real)",
        y = "Sabe Libras (Predito)"
      )
    ) |>
    ggsave(
      filename = paste0(save_path, "plot_confusion_matrix_heatmap_weighted.pdf"),
      width=5,
      height=5
    )
  # <<< Diagnóstico Gráfico: Matriz de Confusão (Heatmap) para dados ponderados <<<

  # Matrizes de confusão por nível de dif_ouvir
  if(CONF_MAT_SUB){
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
            x = "Sabe Libras (Real)",
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
            x = "Sabe Libras (Real)",
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
            x = "Sabe Libras (Real)",
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
            x = "Sabe Libras (Real)",
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


}

toc()
