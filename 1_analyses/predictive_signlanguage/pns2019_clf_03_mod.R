
# https://www.tidymodels.org/learn/
# https://www.tidymodels.org/start/case-study/
# https://www.tidymodels.org/learn/models/calibration/
# https://rpubs.com/eR_ic/classification

packs <- c(
  'themis',
  'bonsai',
  'lightgbm',
  'xgboost',
  'glmnet',
  'ranger',
  'naivebayes',
  'finetune',
  'doParallel',
  'earth',
  'lme4',
  'kernlab', # svm
  'c50',
  'baguette', # bag_mars
  'betacal',
  'tailor'
)
install.packages(packs)

library(readr)      # read_csv
library(dplyr)      # |>, mutate, glimpse
library(tidymodels) # initial_splits, train, test
library(themis)     # step_downsample
library(stringr)    # str_remove_all
library(probably)   # cal_plot_breaks
library(betacal)
library(tailor)
library(bonsai)
library(discrim)
#library(finetune)
#library(doParallel)
library(lme4)
library(earth)
library(C50)
library(kernlab)

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
if (TRUE){
  libras <-
    bind_rows(
      libras |> filter(libras == 'nao') |> head(100),
      libras |> filter(libras == 'sim') |> head(100)
    )
}

# passo 2: separação em treino/teste
set.seed(1)
libras_splits <- initial_split(libras, strata = libras)
libras_train  <- training(libras_splits)
libras_test   <- testing(libras_splits)

# passo 3: preparação da validação cruzada em 10 partes (folds)
libras_folds <- vfold_cv(libras_train, strata = libras, v = 5)

# passo 4: transformação das variáveis independentes
recipe_basic <-
  recipe(libras ~ ., data = libras) |>
  step_impute_knn(all_predictors(), neighbors = 3) |>
  step_normalize(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_downsample(libras, under_ratio = 1)  # class_weights implementado só com step_upsample() ou step_downsample()
  

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
  logistic_reg(
    # penalty = tune(), mixture = tune()
  ) |>
  set_engine("glmnet")

# multivariate adaptive regression splines (MARS)
model_mars <-
  mars(
    # num_terms = tune(), prod_degree = tune(), prune_method = "backward"
    ) |>
  set_engine("earth") |>
  set_mode("classification")

# multi layer perceptron via nnet
model_mlp <-
  mlp(
    # penalty = tune(),
    # epochs = tune()
  ) |>
  set_engine("nnet") |>
  set_mode("classification") 

# lightgbm
model_lgb <-
  boost_tree(
    # mtry = tune(), trees = tune(), tree_depth = tune(),
    # learn_rate = tune(), min_n = tune(), loss_reduction = tune()
  ) |>
  set_engine("lightgbm") |>
  set_mode("classification")

# xgboost
model_xgb <-
  boost_tree(
    # mtry = tune(), trees = tune(), min_n = tune(), tree_depth = tune(),
    # learn_rate = tune(), loss_reduction = tune(), sample_size = tune(),
    # stop_iter = tune()
  ) |>
  set_engine("xgboost") |>
  set_mode("classification") 

# decision_tree
model_dt <-
  decision_tree(
    # tree_depth = tune(), min_n = tune(), cost_complexity = tune()
  ) |>
  set_engine("rpart") |>
  set_mode("classification") 

# boosted trees via  C5.0
model_bc5 <-
  boost_tree(
    # trees = tune(), min_n = tune(), sample_size = tune()
  ) |>
  set_engine("C5.0") |>
  set_mode("classification") 

# support vector machines via kernlab
model_svm <-
  svm_linear(
    # cost = tune()
  ) |>
  set_engine("kernlab") |>
  set_mode("classification") 
  
# random forest via ranger
model_rf <-
  rand_forest(
    # mtry = tune(),
    # trees = tune(),
    # min_n = tune()
  ) |>
  set_engine("ranger") |>
  set_mode("classification") 

# naive bayes
model_nb <-
  naive_Bayes(
    # smoothness = tune(), Laplace = tune()
  ) |>
  set_engine("naivebayes")

models <-
  list(
      model_null = model_null,
      # model_logres = model_lr,
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
    ## 'class' type
    # accuracy,
    # bal_accuracy,
    # precision,
    # recall,
    # sens,
    # spec,
    kap,
    j_index,
    mcc,
    specificity,
    ## 'class prob' type
    roc_auc,
    average_precision,
    brier_class,
    mn_log_loss,
    pr_auc
  )


# passo -8: finetune + racing
if(FALSE){
  # ## https://finetune.tidymodels.org/reference/tune_race_anova.html
  # cores <- parallel::detectCores(logical = FALSE)
  # cl <- makePSOCKcluster(cores)
  # registerDoParallel(cl)
  
  ## https://www.tmwr.org/workflow-sets#racing-example
  race_ctrl <-
    control_race(
      save_pred = TRUE,
      parallel_over = "everything",
      save_workflow = TRUE,
      verbose_elim = TRUE
    )
  
  race_results <-
    wflow_set %>%
    workflow_map(
      "tune_race_anova",
      seed = 1503,
      resamples = libras_folds,
      grid = 25,
      control = race_ctrl,
      verbose = TRUE
    )
  
  race_results |>
    mutate( wflow_id = str_remove_all(wflow_id, "basic_model_")) |>
    autoplot(select_best = TRUE) + 
    geom_text(aes(y = mean - 1/20, label = wflow_id), angle = 90, hjust = 1) + 
    theme(legend.position = "none")
  
  METRIC <- 'brier_class'
  race_results |>
    mutate( wflow_id = str_remove_all(wflow_id, "basic_model_")) |>
    autoplot(
    rank_metric = METRIC,  
    metric = METRIC,       
    select_best = FALSE
  ) +
    geom_text(aes(y = mean - 1/7, label = wflow_id), angle = 90, hjust = 1) +
    theme(legend.position = "none")
}

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


# passo 9: diagnóstico gráfico (autoplot)
wflow_set_fit |>
  mutate( wflow_id = str_remove_all(wflow_id, "basic_model_")) |>
  autoplot() + 
  geom_text(aes(y = mean -1/7, label = wflow_id), angle = 90, hjust = 1) + 
  theme(legend.position = "none")

# passo 10: diagnóstico gráfico (autoplot modificado)
metric <- 'brier_class'
wflow_set_fit |>
  mutate( wflow_id = str_remove_all(wflow_id, "basic_model_")) |>
  autoplot(
    rank_metric = metric,  
    metric = metric,       
    select_best = TRUE    
  ) +
    geom_text(aes(y = mean -1/10, label = wflow_id), angle = 90, hjust = 1) +
    theme(legend.position = "none")

# passo 11: coleta métricas
wflow_set_fit |>
  collect_metrics() 

# passo 12: lista melhores modelos por métrica
wflow_set_fit |>
  collect_metrics() |>
  mutate( wflow_id = str_remove_all(wflow_id, "basic_model_")) |>
  arrange(.metric, desc(mean)) |>
  write_csv("./wflow_set_fit_metrics.csv")

# passo 13: extrai melhor modelo
wflow_results <-
  wflow_set_fit |>
  extract_workflow("basic_model_lgb") |>
  last_fit(split = libras_splits)

collect_metrics(wflow_results)


# matriz de confusão
collect_predictions(wflow_results) |>
  conf_mat(libras, .pred_class) |>
  autoplot(type = "heatmap")

# calibração das probabilidades
collect_predictions(wflow_results) %>%
  ggplot(aes(.pred_sim)) +
  geom_histogram(col = "white", bins = 40) +
  facet_wrap(~ libras, ncol = 1) +
  geom_rug(col = "blue", alpha = 1 / 2) + 
  labs(x = "Probability Estimate of Libras")

cal_plot_breaks(wflow_results)
cal_plot_windowed(wflow_results, step_size = 0.025)
cal_plot_logistic(wflow_results)

# otimização de threshold 
thresholds <- seq(0.01, 0.95, by = 0.01)
collect_predictions(wflow_results) |> 
  threshold_perf(
    truth = libras, 
    estimate = .pred_sim, 
    thresholds = thresholds,
    metric =   metric_set(
      accuracy,
      sens,
      spec
    )
  ) |> 
  filter(.metric != 'distance') |>
  ggplot( aes( x = .threshold, y = .estimate, color = .metric)) + 
  geom_line()


# variable importance (vip)
library(vip)
wflow_results |>
  extract_fit_parsnip() |>
  vip()


# to-dos
# ajuste dos hiperparâmetros para encontrar o melhor modelo
# seleção do melhor modelo
# calibração das probabilidades (https://www.tidymodels.org/learn/models/calibration/)
# verifica thresholds diversos (https://probably.tidymodels.org/reference/threshold_perf.html)
# otimização do threshold com base na métrica ideal (https://probably.tidymodels.org/articles/where-to-use.html)
# matriz de confusão
