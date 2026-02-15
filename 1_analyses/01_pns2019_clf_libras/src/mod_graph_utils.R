
library(ggplot2)
library(ggmosaic)
library(dplyr)


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
