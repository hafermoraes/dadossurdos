#' Módulo de Exportação de Gráficos de Performance de Modelos
#'
#' @description
#' Este módulo centraliza funções utilitárias para a geração e exportação de visualizações 
#' diagnósticas de modelos de Machine Learning, incluindo importância de variáveis, 
#' histogramas de probabilidade e matrizes de confusão.
#'
#' @details
#' As funções utilizam o ecossistema `tidymodels`, `ggplot2` e `vip`. 
#' Todas as funções seguem o padrão de salvar os arquivos diretamente em disco 
#' com dimensões customizáveis.
#'
#' @name mod_export_graphs
NULL



#' Exportar Gráfico de Importância de Variáveis (Variable Importance Plot)
#'
#' Esta função gera e salva um gráfico de importância de variáveis (VIP) a partir de um modelo treinado,
#' exceto para classificadores específicos que não suportam essa visualização direta via `vip`.
#'
#' @param input_table Um objeto (geralmente um workflow do tidymodels ou uma tibble) que contém o ajuste do modelo.
#' @param classifier String. O nome do classificador utilizado (ex: 'rf', 'xgboost'). 
#'   A função ignora o prefixo "basic_model_" para validação interna.
#' @param plot_width Numérico. A largura do arquivo de saída (em polegadas, por padrão).
#' @param plot_height Numérico. A altura do arquivo de saída (em polegadas, por padrão).
#' @param output_file String. O caminho completo ou nome do arquivo onde o gráfico será salvo (ex: "importancia.png").
#'
#' @return A função não retorna um valor explicitamente, mas salva um arquivo de imagem no disco 
#'   e imprime mensagens de log no console.
#' 
#' @details 
#' A função verifica se o classificador está na "lista negra" (svm, nb, bc5, bart, bagrpart). 
#' Caso não esteja, ela tenta extrair o ajuste via `extract_fit_parsnip()`, gera o gráfico com 
#' a biblioteca `vip` e o salva utilizando `ggsave`.
#'
#' @export
#'
#' @examples
#' # Exemplo de uso:
#' # export_graph_variable_importance(meu_workflow, "basic_model_rf", 8, 6, "vip_rf.png")
export_graph_variable_importance <- function(
  input_table,
  classifier,
  plot_width,
  plot_height,
  output_file
){
  
  if (! str_remove_all(classifier, "basic_model_") %in% c('svm', 'nb', 'bc5', 'bart', 'bagrpart')){

    tryCatch({
      plt <- 
        input_table |>
          extract_fit_parsnip() |>
          vip(geom="point")

      ggsave(
        filename = output_file,
        plot = plt,
        width=plot_width,
        height=plot_height
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


#' Exportar Histograma de Probabilidades
#'
#' Gera e salva um histograma da distribuição das probabilidades preditas, segmentado 
#' pela classe real, incluindo uma linha vertical indicando o ponto de corte (threshold).
#'
#' @param input_table Uma tibble ou data frame contendo as predições. Deve conter 
#'   obrigatoriamente as colunas `.pred_sim` (probabilidade estimada) e `libras` (classe real).
#' @param threshold Numérico. O valor do ponto de corte (ex: 0.5) para plotagem da linha de referência.
#' @param plot_width Numérico. Largura do arquivo de imagem de saída.
#' @param plot_height Numérico. Altura do arquivo de imagem de saída.
#' @param output_file String. Caminho completo ou nome do arquivo para salvar o gráfico (ex: "hist_prob.png").
#'
#' @return A função não retorna um objeto, mas exporta o gráfico para o local especificado no disco.
#'
#' @details 
#' O gráfico utiliza `facet_wrap` para separar as distribuições pela variável `libras`. 
#' Inclui também um `geom_rug` para visualizar a densidade individual dos pontos na base do gráfico.
#' 
#' @note 
#' Esta função assume que o resultado positivo é rotulado como "sim" na coluna de predição.
#'
#' @export
#'
#' @examples
#' # export_graph_probability_histogram(df_preds, 0.65, 10, 8, "histograma_libras.png")
export_graph_probability_histogram <- function(
  input_table,
  threshold,
  plot_width,
  plot_height,
  output_file
) {

  plt <- 
    input_table |>
    ggplot(aes(.pred_sim)) +
    geom_histogram(col = "white", bins = 40) +
    facet_wrap(~ libras, ncol = 1) +
    geom_vline(
      xintercept = threshold,
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

  ggsave(
    filename = output_file,
    plot = plt,
    width=plot_width,
    height=plot_height
  )
}


#' Exportar Gráfico de Matriz de Confusão
#'
#' Gera e salva uma visualização da matriz de confusão utilizando a função `autoplot` 
#' do ecossistema tidymodels/yardstick.
#'
#' @param input_table Um objeto de matriz de confusão (geralmente gerado por `conf_mat()`).
#' @param threshold Numérico. O ponto de corte utilizado para classificar as predições.
#' @param plot_type String. O tipo de visualização desejada: 'mosaic' (mosaico) ou 'heatmap' (mapa de calor).
#' @param plot_width Numérico. Largura do arquivo de imagem de saída.
#' @param plot_height Numérico. Altura do arquivo de imagem de saída.
#' @param output_file String. Caminho completo ou nome do arquivo para salvar o gráfico.
#'
#' @return A função não retorna um objeto, mas exporta o gráfico para o local especificado.
#' 
#' @details 
#' A função utiliza o método `autoplot` para formatar automaticamente a matriz. Os eixos 
#' são renomeados para refletir a variável de interesse ("Sabe Libras").
#'
#' @export
#'
#' @examples
#' # mat_conf <- df_preds |> conf_mat(truth = libras, estimate = .pred_class)
#' # export_graph_confusion_matrix(mat_conf, 0.5, "heatmap", 6, 6, "matriz.png")
export_graph_confusion_matrix <- function(
  input_table,
  threshold,
  plot_type, # 'mosaic' / 'heatmap'
  plot_width,
  plot_height,
  output_file
) {

  plt <-
    input_table |>
      autoplot(type = plot_type) +
      labs(
        ## title = "Matriz de confusão",
        ## caption = paste0("Ponto de corte (Threshold): ", opt_threshold$.threshold),
        x = "Sabe Libras (Real)",
        y = "Sabe Libras (Predito)"
      )

  ggsave(
    filename = output_file,
    plot = plt,
    width = plot_width,
    height = plot_height
  )  
}
