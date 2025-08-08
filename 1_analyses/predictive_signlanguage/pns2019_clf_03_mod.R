

# https://www.tidymodels.org/learn/
# https://www.tidymodels.org/start/case-study/
# https://www.tidymodels.org/learn/models/calibration/
# https://rpubs.com/eR_ic/classification

library(dplyr)      # |>, mutate, glimpse
library(readr)      # read_csv
library(tidyr)      # pivot_longer
library(tidymodels) # initial_splits, train, test

library(baguette)
library(desirability2)
library(GGally)

library(xgboost)

# passo 1: importação da matriz de modelo
libras <-
  read_csv(
    '1_analyses/predictive_signlanguage/pns2019_modelmatrix.csv'
  ) |> 
  mutate(across(where(is.character), as.factor))

# passo 2: separação em treino/teste
set.seed(1)
libras_splits <- initial_split(libras, strata = libras)
libras_train  <- training(libras_splits)
libras_test   <- testing(libras_splits)

# passo 3: preparação da validação cruzada em 10 partes (folds)
libras_folds <- vfold_cv(libras_train, strata = libras)

# passo 4: transformação das variáveis independentes
recipe_basic <-
  recipe(libras ~ ., data = libras) %>%
  step_unknown(all_nominal_predictors()) %>%
  step_YeoJohnson(all_numeric_predictors()) %>%
  step_normalize(all_numeric_predictors()) %>%
  step_dummy(all_nominal_predictors())

# passo 5: classificadores usados na comparação
spec_lr <- 
  logistic_reg("classification")

spec_bt <-
  boost_tree("classification", mtry = tune(), learn_rate = tune(), trees = 500)

spec_nn <-
  bag_mlp("classification", hidden_units = tune(), penalty = tune())

# passo 6: criação dos fluxos de trabalho
wflow_set <- 
  workflow_set(
    preproc = list(basic = recipe_basic),
    models = list(lr = spec_lr, bt = spec_bt, nn = spec_nn)
  )

# passo 7: definição das métricas de avaliação dos classificadores
m_set <-
  metric_set(
    accuracy,
    roc_auc,
    # equal_opportunity(cor_raca),
    # equalized_odds(cor_raca),
    # demographic_parity(cor_raca)
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

# passo 9: selecção do melhor modelo
wflow_set_fit %>%
  collect_metrics() %>%
  pivot_wider(
    id_cols = c(wflow_id, .config), 
    names_from = .metric, 
    values_from = mean
  ) %>%
  select(-c(wflow_id, .config)) %>%
  ggpairs() +
  theme(axis.text.x = element_text(angle = 45, vjust = .8, hjust = .9))