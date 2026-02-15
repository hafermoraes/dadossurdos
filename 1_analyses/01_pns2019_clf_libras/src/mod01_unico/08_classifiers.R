#' Configuração dos Algoritmos de Classificação (Model Specs)
#'
#' @description
#' Este módulo define as especificações de diversos algoritmos de aprendizado de máquina
#' utilizando a interface unificada do pacote \code{parsnip}. Cada modelo é configurado
#' com hiperparâmetros marcados para otimização via \code{tune()}.
#'
#' @section Modelos Disponíveis:
#' \itemize{
#'   \item \bold{Linha de Base:} \code{null_model} (Modelo Nulo) para benchmark de performance.
#'   \item \bold{Lineares e Splines:} Regressão Logística Regularizada (\code{glmnet}) e MARS (\code{earth}).
#'   \item \bold{Baseados em Árvores:} Decision Tree (\code{rpart}), Random Forest (\code{ranger}) e Gradient Boosting (\code{xgboost} e \code{lightgbm}).
#'   \item \bold{Redes Neurais e Kernel:} Multi-Layer Perceptron (\code{nnet}) e SVM Linear (\code{kernlab}).
#'   \item \bold{Probabilísticos:} Naive Bayes (\code{naivebayes}).
#' }
#'
#' @details 
#' Para modelos de floresta e boosting, as árvores foram fixadas em 1000 para garantir convergência, 
#' enquanto parâmetros de complexidade, taxa de aprendizado e amostragem foram deixados para 
#' o processo de busca de hiperparâmetros.
#'
#' @note 
#' A Random Forest utiliza \code{importance = "impurity"} no motor \code{ranger} para 
#' permitir a extração posterior de importância das variáveis.
#'
#' @return Define múltiplos objetos de classe \code{model_spec} no Global Environment.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords parsnip classification tuning tidymodels
NULL

tic()
message("configurando os classificadores (tidymodels/parsnip)...")

## classificadores
# https://parsnip.tidymodels.org/articles/Examples.html

# null model
model_null <-
  null_model() |>
  set_engine("parsnip") |>
  set_mode("classification")

# logistic regression
model_logres <- 
  logistic_reg(
    penalty = tune(), 
    mixture = tune()
  ) |>
  set_engine("glmnet")

# multivariate adaptive regression splines (MARS)
model_mars <-
  mars(
    num_terms = tune(), prod_degree = tune(), prune_method = "backward"
    ) |>
  set_engine("earth") |>
  set_mode("classification")

# multi layer perceptron via nnet
model_mlp <-
  mlp(
    hidden_units = tune(),
    penalty = tune(),
    epochs = tune()
  ) |>
  set_engine("nnet") |>
  set_mode("classification") 

# lightgbm
model_lgb <-
  boost_tree(
    mtry = tune(), trees = 1000, tree_depth = tune(),
    learn_rate = tune(), min_n = tune(), loss_reduction = tune()
  ) |>
  set_engine("lightgbm") |>
  set_mode("classification")

# xgboost
model_xgb <-
  boost_tree(
    mtry = tune(), trees = 1000, min_n = tune(), tree_depth = tune(),
    learn_rate = tune(), loss_reduction = tune(), sample_size = tune(),
    stop_iter = tune()
  ) |>
  set_engine("xgboost") |>
  set_mode("classification") 

# decision_tree
model_dt <-
  decision_tree(
    tree_depth = tune(), min_n = tune(), cost_complexity = tune()
  ) |>
  set_engine("rpart") |>
  set_mode("classification") 

# support vector machines via kernlab
model_svm <-
  svm_linear(
    cost = tune()
  ) |>
  set_engine("kernlab") |>
  set_mode("classification")
  
# random forest via ranger
model_rf <-
  rand_forest(
    mtry = tune(),
    trees = tune(),
    min_n = tune()
  ) |>
  set_engine("ranger", importance = "impurity") |>
  set_mode("classification") 

# naive bayes
model_nb <-
  naive_Bayes(
    smoothness = tune(), Laplace = tune()
  ) |>
  set_engine("naivebayes")


# -----------

# boosted trees via  C5.0
# model_bc5 <-
#   boost_tree(
#     trees = tune(), min_n = tune(), sample_size = tune()
#   ) |>
#   set_engine("C5.0") |>
#   set_mode("classification")

# model_bart <-
#   parsnip::bart() |>
#   set_mode("classification") |>
#   set_engine("dbarts")

# model_bagrpart <-
#   bag_tree(
#     class_cost = tune(),
#     tree_depth = tune(),
#     min_n = tune(),
#     cost_complexity = double(1)
#   ) |>
#     set_engine("rpart", times = NR_TIMES) |>
#     set_mode("classification")

toc()
