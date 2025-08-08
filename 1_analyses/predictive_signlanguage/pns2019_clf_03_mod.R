
# https://www.tidymodels.org/learn/
# https://www.tidymodels.org/start/case-study/
# https://www.tidymodels.org/learn/models/calibration/
# https://rpubs.com/eR_ic/classification

library(readr)      # read_csv
library(dplyr)      # |>, mutate, glimpse
library(tidymodels) # initial_splits, train, test

# packs <- c(
#   'bonsai',
#   'lightgbm',
#   'xgboost',
#   'glmnet',
#   'earth',
#   'C50',
#   'xrf',
#   'LiblineaR',
#   'ranger',
#   'naivebayes',
#   'rules',
#   'baguette',
#   'desirability2',
#   'GGally'
# )
# install.packages(packs)

library(rules)
library(bonsai)

library(discrim)
#library(treesnip)
library(baguette)
library(desirability2)
library(GGally)

# passo 1: importação da matriz de modelo
libras <-
  read_csv(
    '1_analyses/predictive_signlanguage/pns2019_modelmatrix.csv'
  ) |> 
  mutate(
    across(where(is.character), as.factor),
    # https://workflowsets.tidymodels.org/reference/workflow_set.html
    case_weights = importance_weights(case_weights) 
  )
  
# passo 1.1: redução do dataset para prototipagem de tidymodels
libras <- 
  bind_rows(
    libras |> filter(libras == 'nao') |> head(100),
    libras |> filter(libras == 'sim') |> head(100)
  )

# passo 2: separação em treino/teste
set.seed(1)
libras_splits <- initial_split(libras, strata = libras)
libras_train  <- training(libras_splits)
libras_test   <- testing(libras_splits)

# passo 3: preparação da validação cruzada em 10 partes (folds)
libras_folds <- vfold_cv(libras_train, strata = libras)

# passo 4: transformação das variáveis independentes
recipe_basic <-
  recipe(libras ~ ., data = libras) |>
  step_impute_knn(all_predictors(), neighbors = 3) |>
  step_normalize(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors())

#recipe2 <- prep(recipe_basic, training = libras_train)
#imputed <- bake(recipe2, libras_train)

preproc <-
  list(basic = recipe_basic)

# passo 5: classificadores usados na comparação

## classificadores
# https://parsnip.tidymodels.org/articles/Examples.html

# null model
model_null <-
  null_model() |>
  set_engine("parsnip") |>
  set_mode("classification")

# logistic regression
model_lr <- 
  logistic_reg(penalty = double(1), mixture = double(1)) |>
  set_engine("glmnet")

# multivariate adaptive regression splines (MARS)
model_mars <-
  mars(num_terms = NULL, prod_degree = 1, prune_method = "backward") |>
  set_engine("earth") |>
  set_mode("classification")

# multi layer perceptron via nnet
model_mlp <-
  mlp(
    # penalty = 0,
    # epochs = 100
  ) |>
  set_engine("nnet") |>
  set_mode("classification") 

# lightgbm
model_lgb <-
  boost_tree(
    # mtry = integer(), trees = integer(), tree_depth = integer(),
    # learn_rate = numeric(), min_n = integer(), loss_reduction = numeric()
  ) |>
  set_engine("lightgbm") |>
  set_mode("classification")

# xgboost
model_xgb <-
  boost_tree(
    # mtry = integer(), trees = integer(), min_n = integer(), tree_depth = integer(),
    # learn_rate = numeric(), loss_reduction = numeric(), sample_size = numeric(),
    # stop_iter = integer()
  ) |>
  set_engine("xgboost") |>
  set_mode("classification") 

# decision_tree
model_dt <-
  decision_tree(
    # tree_depth = integer(1), min_n = integer(1), cost_complexity = double(1)
  ) |>
  set_engine("rpart") |>
  set_mode("classification") 

# boosted trees via  C5.0
model_bc5 <-
  boost_tree(
    # trees = integer(), min_n = integer(), sample_size = numeric()
  ) |>
  set_engine("C5.0") |>
  set_mode("classification") 

# support vector machines via kernlab
model_svm <-
  svm_linear(
    cost = 1
  ) |>
  set_engine("kernlab") |>
  set_mode("classification") 
  
# random forest via ranger
model_rf <-
  rand_forest(
    # mtry = integer(1),
    # trees = integer(1),
    # min_n = integer(1)
  ) |>
  set_engine("ranger") |>
  set_mode("classification") 

# naive bayes
model_nb <-
  naive_Bayes(
    # smoothness = numeric(0), Laplace = numeric(0)
  ) |>
  set_engine("naivebayes")

models <-
  list(
      model_null = model_null,
      model_logres = model_lr,
      model_mars = model_mars,
      model_mlp = model_mlp,
      model_lgb = model_lgb,
      model_xgb = model_xgb,
      model_dt = model_dt,
      model_bc5 = model_bc5,
      model_svm = model_svm,
      model_rf = model_rf,
      model_nb = model_nb
    )

# passo 6: criação dos fluxos de trabalho
# https://workflowsets.tidymodels.org/reference/workflow_set.html#see-also

wflow_set <- 
  workflow_set(
    preproc,
    models,
    cross = TRUE,
    case_weights = case_weights
  )

# passo 7: definição das métricas de avaliação dos classificadores
m_set <-
  metric_set(
    accuracy,
    bal_accuracy,
    precision,
    recall,
    roc_auc,
    sens,
    spec,
    average_precision
  )

# passo 8: ajuste dos modelos
set.seed(1)
wflow_set_fit <- 
  workflow_map(
    wflow_set, 
    verbose = TRUE, 
    seed = 1, 
    metrics = m_set,
    resamples = libras_folds
  )

# passo 9: diagnóstico gráfico
autoplot(wflow_set_fit)

# passo 9: selecção do melhor modelo
wflow_set_fit |>
  collect_metrics() |>
  pivot_wider(
    id_cols = c(wflow_id, .config), 
    names_from = .metric, 
    values_from = mean
  ) |>
  select(-c(wflow_id, .config)) |>
  ggpairs() +
  theme(axis.text.x = element_text(angle = 45, vjust = .8, hjust = .9))

# passo 10: 
wflow_set_fit |>
  collect_metrics()

# passo 11:
