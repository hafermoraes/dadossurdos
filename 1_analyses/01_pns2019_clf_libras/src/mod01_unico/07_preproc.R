#' Definição do Pipeline de Pré-processamento (Feature Engineering)
#'
#' @description
#' Este módulo utiliza o pacote \code{recipes} para definir a sequência de transformações 
#' de dados necessárias antes da modelagem. O pipeline abrange desde o tratamento de 
#' categorias ausentes até a criação de termos de interação e expansão de bases para 
#' preditores numéricos.
#'
#' @section Passos do Pipeline:
#' \itemize{
#'   \item \bold{Tipagem e Fatores:} Define níveis e ordenação para variáveis ordinais (\code{instrucao}) 
#'   e nominais (\code{sexo}).
#'   \item \bold{Tratamento de Categorias:} Gerencia novos níveis (\code{step_novel}) e 
#'   valores ausentes (\code{step_unknown}).
#'   \item \bold{Encoding:} Converte \code{instrucao} em escores ordinais e aplica 
#'   \code{Target Encoding} (Mixed Effects) em \code{sexo}.
#'   \item \bold{Expansão de Base:} Cria interações entre todos os preditores (\code{step_interact}) 
#'   e aplica Natural Splines (\code{step_ns}) na idade com 3 graus de liberdade.
#'   \item \bold{Redução de Dimensionalidade:} Remove variáveis com variância zero (\code{step_zv}) 
#'   e elimina variáveis altamente correlacionadas (\eqn{r > 0.95}).
#'   \item \bold{Normalização:} Padroniza todos os preditores numéricos para média 0 e desvio padrão 1.
#' }
#'
#' @note 
#' O balanceamento de classes (ex: \code{step_downsample}) está comentado, pois pode ser 
#' controlado via \code{case_weights} ou em workflows específicos de amostragem.
#'
#' @return Cria o objeto \code{recipe_basic} (objeto recipe) contendo o blueprint das transformações.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords recipes preprocessing feature-engineering tidymodels
NULL

tic()
message("definindo o pipeline de tratamento de dados para a modelagem (tidymodels/recipe)...")
recipe_basic <-
  recipe(libras ~ ., data = libras_train) |>
  step_mutate(
    instrucao = factor(
      instrucao,
      levels = c('outros', 'fundamental', 'medio', 'superior'),
      ordered = TRUE
    ),
    dif_ouvir = factor(
      dif_ouvir,
      levels = c('nenhuma', 'alguma', 'grande', 'incapaz'),
      ordered = TRUE
    ),
    sexo = factor(
      sexo,
      levels = c('feminino', 'masculino')
    )
  ) |>
  # step_novel(all_nominal_predictors()) |> 
  # step_unknown(all_nominal_predictors(), new_level = "nao_informado") |>
  step_ordinalscore(instrucao, dif_ouvir) |>
  # step_lencode_mixed(sexo, outcome = vars(libras)) |>  
  step_dummy(all_nominal_predictors()) |>
  # step_interact(terms = ~all_predictors():all_predictors()) |>
  step_ns(idade, deg_free = 10) |>
  #step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  #step_corr(all_predictors(), threshold = 0.95) |>
  step_clean_names(all_nominal_predictors())
  # class_weights implementado só com step_upsample() ou step_downsample()
  #step_upsample(libras, over_ratio = 1)  

# recipe2 <- prep(recipe_basic, training = libras_train)
# imputed <- bake(recipe2, libras_train)
toc()
