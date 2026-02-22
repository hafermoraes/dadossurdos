#' @title Visualização Exploratória e Matriz de Correlação
#' 
#' @description
#' Este script automatiza a geração de diagnósticos visuais para a PNS 2019. 
#' Inclui gráficos de mosaico para análise de associação entre variáveis categóricas 
#' e a variável alvo (Libras), boxplots e densidades para variáveis contínuas, 
#' e uma análise de correlação entre preditores dummyficados.
#'
#' @section Visualizações Geradas:
#' \itemize{
#'   \item \bold{Gráficos de Mosaico}: Proporções de usuários de Libras ponderadas pelo peso amostral (\code{case_weights}).
#'   \item \bold{Análise de Idade}: Distribuição de idade por uso de Libras via Boxplot e Densidade (facetado por dificuldade auditiva).
#'   \item \bold{Matriz de Correlação}: Visualização das relações lineares entre preditores após transformação em variáveis dummy.
#' }
#'
#' @section Engenharia de Atributos (Correlação):
#' A correlação utiliza o pacote \code{recipes} para:
#' \enumerate{
#'   \item Omitir NAs em preditores fatoriais.
#'   \item Transformar variáveis nominais em dummies.
#'   \item Remover pesos e variáveis de alta cardinalidade (\code{uf}).
#' }
#' 
#' @note 
#' Todos os gráficos são exportados em formato PDF para preservação de qualidade vetorial na tese.
#'
#' @name 04_eda_graphs
NULL


# mosaic plots

eda_plot_mosaic <- function(column){
  eda_plot <- 
    ggplot(data = modelmatrix) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(!!sym(column)), 
        fill=libras
      )
    ) + 
    coord_flip() + 
    labs(
      title=paste0('f(',column,')')
      )
  return(eda_plot)
}

COLUMNS <- c(
  'idade',
  'sexo',
  'instrucao',
  'dif_ouvir',
  'uf',
  'alfabetizado'
  ## 'estado_civil',
  ## 'cor_raca',
  ## 'dif_enxergar',
  ## 'dif_locomover',
  ## 'faixa_idade',
)


for(arg_column in COLUMNS){
  tic()
  message("exportando eda_plot_mosaic para libras vs ", arg_column, "...")
  (
    eda_plot_mosaic(column=arg_column)
  ) |>
    ggsave(
      filename = paste0(
        eda_dir,
        paste0("eda_mosaic_", arg_column, ".pdf")
      ),
      width=12,
      height=8
    )
  toc()  
}

# box-plot libras vs idade
(
  ggplot(data = microdados) + 
  geom_boxplot( aes(x = libras, y=idade, fill = libras))
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_boxplot_idade.pdf"
    ),
    width=12,
    height=8
  )


(
  modelmatrix |>
    group_by(idade, dif_ouvir, libras) |>
    summarise(case_weights = sum(case_weights, na.rm=TRUE)) |>
    mutate(idade = as.numeric(idade)) |>
    ggplot(
      aes(x=idade, fill = libras, weight = case_weights)
    ) +
    labs(
      x = "idade",
      y = "densidade de probabilidade"
    ) +
    geom_histogram(aes(y = after_stat(density)), alpha = 0.5) + 
    facet_wrap( ~ dif_ouvir, scales='free_y')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_density_idade.pdf"
    ),
    width=12,
    height=8
  )


