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
    ggplot(data = microdados) +
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
  'sexo',
  'alfabetizado',
  'estado_civil',
  'instrucao',
  'cor_raca',
  'dif_enxergar',
  'dif_ouvir',
  'dif_locomover',
  'uf',
  'faixa_idade',
  'idade'
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
  ggplot(data = microdados) +
    geom_density( aes(x=idade, fill = libras), alpha = 0.2) + 
    facet_wrap( ~ dif_ouvir)
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_density_idade.pdf"
    ),
    width=12,
    height=8
  )


# correlações

# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
(
  recipe(libras ~ ., data = microdados) |>
    step_naomit(all_factor_predictors()) |>
    step_dummy(all_nominal_predictors()) |>
    step_rm(case_weights, starts_with("uf")) |>
    prep(microdados) |> 
    bake(new_data = NULL) |> 
    mutate(
      libras = if_else( libras == 'sim', 1, 0)
    ) |> 
    correlate() |>
    shave() |>
    rplot( print_cor = T) +
    # scale_color_gradient2(low = 'orange', high = 'light blue') + 
    theme(axis.text.x = element_text(angle = 90)) +
    labs(title = "Correlation Plot")
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_corr_plot.pdf"
    ),
    width=12,
    height=8
  )

