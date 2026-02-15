#' Execução e Avaliação de Tuning do Workflow Set
#'
#' @description
#' Este módulo executa o processo de otimização de hiperparâmetros para todos os 
#' fluxos de trabalho definidos. Ele gerencia o processamento paralelo, realiza 
#' a busca em grade (\code{tune_grid}), consolida as métricas de performance e 
#' gera visualizações diagnósticas para comparação dos algoritmos.
#'
#' @section Processamento e Performance:
#' \itemize{
#'   \item \bold{Paralelismo:} Se \code{PARALLEL = TRUE}, utiliza o pacote \code{doParallel} 
#'   para registrar um cluster com o número de núcleos físicos detectados menos 2.
#'   \item \bold{Tuning:} Aplica \code{workflow_map} com a função \code{tune_grid} 
#'   sobre os \code{libras_folds}, utilizando o \code{metrics_set} customizado.
#' }
#'
#' @section Exportação e Diagnóstico:
#' \itemize{
#'   \item \bold{Métricas:} Coleta e salva as métricas de todos os modelos em 
#'   \code{workflowset_metrics.csv}, simplificando os IDs para facilitar a leitura.
#'   \item \bold{Visualização:} Gera um gráfico comparativo (\code{autoplot}) 
#'   destacando o melhor desempenho de cada classificador, exportando-o em PDF.
#' }
#'
#' @note 
#' A semente aleatória (\code{seed = 1}) é aplicada tanto no nível do script quanto 
#' dentro do \code{workflow_map} para garantir a reprodutibilidade dos subconjuntos 
#' de tuning.
#'
#' @return Cria o objeto \code{fitted_models} (workflow_set treinado) e arquivos 
#' físicos no \code{results_dir}.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords workflow_map tuning parallel visualization tidymodels
NULL

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
