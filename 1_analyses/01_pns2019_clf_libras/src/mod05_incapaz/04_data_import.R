#' Pipeline de Importação e Preparação da Matriz de Modelo (PNS 2019)
#'
#' @description
#' Este módulo realiza a carga da matriz de modelo da Pesquisa Nacional de Saúde (2019),
#' aplica pesos de importância para compatibilidade com \code{tidymodels}, define 
#' os níveis do fator alvo e aplica filtros demográficos.
#'
#' @section Pipeline de Processamento:
#' \enumerate{
#'   \item \bold{Importação:} Leitura do CSV processado via \code{readr}.
#'   \item \bold{Ponderação:} Conversão da coluna \code{case_weights} em 
#'   \code{importance_weights} para uso em fluxos de machine learning.
#'   \item \bold{Tipagem:} Transformação da variável \code{libras} em fator com 
#'   níveis fixos ('nao', 'sim').
#'   \item \bold{Filtro:} Restrição da amostra para indivíduos com idade \eqn{\le 40} anos.
#'   \item \bold{Prototipagem:} (Opcional) Redução drástica do dataset para testes rápidos.
#' }
#'
#' @note 
#' Requer as variáveis globais \code{base_dir} definidas no ambiente e os pacotes 
#' \code{tidyverse}, \code{tidymodels} e \code{tictoc}.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords data-prep pns
NULL


tic()
message("importando a matriz de modelo da PNS2019 (readr)...")
libras <-
  read_csv(
    paste0(
      base_dir, 
      'data/pns2019_02_modelmatrix.csv'
      ),
    show_col_types = FALSE
  ) |>
  mutate(
    # https://workflowsets.tidymodels.org/reference/workflow_set.html
    case_weights = importance_weights(case_weights),
    libras = factor(
      libras,
      levels = c('nao', 'sim')
    )
  ) |>
  filter(dif_ouvir == 'incapaz', idade <=40) |>
  select(-dif_ouvir)
toc()
  
if(FALSE){
  tic()
  message("trabalhando com uma fração dos dados na fase de protótipo...")
  libras <-
    bind_rows(
      libras |> filter(libras == 'nao') |> head(100),
      libras |> filter(libras == 'sim') |> head(100)
    )
  toc()
}

