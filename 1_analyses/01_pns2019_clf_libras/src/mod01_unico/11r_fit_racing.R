#' Otimização de Modelos via Racing (ANOVA Race)
#'
#' @description
#' Este módulo realiza a triagem eficiente de hiperparâmetros utilizando o método 
#' de "racing" (\code{tune_race_anova}). Diferente do \code{tune_grid} convencional, 
#' o racing avalia os modelos em subconjuntos das dobras (folds) e interrompe o 
#' ajuste daqueles que demonstram performance significativamente inferior aos demais.
#'
#' @section Configurações de Racing:
#' \itemize{
#'   \item \bold{Mecanismo:} Utiliza ANOVA para comparar os modelos após as primeiras 
#'   dobras e eliminar candidatos não competitivos.
#'   \item \bold{Controle:} \code{control_race} está configurado para salvar predições 
#'   e workflows, permitindo diagnósticos posteriores e calibração.
#'   \item \bold{Paralelismo:} Configurado para rodar sobre "everything" (modelos e dobras), 
#'   maximizando o uso do cluster registrado.
#' }
#'
#' @section Saídas e Diagnósticos:
#' \itemize{
#'   \item \bold{Métricas:} Registra o desempenho consolidado em \code{controlrace_metrics.csv}.
#'   \item \bold{Gráfico de Eficiência:} Gera um PDF comparativo dos modelos remanescentes 
#'   na competição (os que "venceram a corrida").
#' }
#'
#' @note 
#' Este bloco está envolto em \code{if(FALSE)} por ser um processo computacionalmente 
#' intensivo, destinado a fases de refinamento final da arquitetura de modelos.
#'
#' @return Cria o objeto \code{fitted_models_racing} (workflow_set otimizado).
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords finetune racing anova-race model-selection tidymodels
NULL

if(FALSE){
  tic()
  message("ajustando os modelos preditivos com racing (tidymodels/finetune)...")
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
        results_dir,
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
        results_dir,
        "controlrace_results.pdf"
        ),
      width=12,
      height=8
    )

  toc() 
}
