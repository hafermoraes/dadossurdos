# passo 5: classificadores usados na comparação

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

# # multivariate adaptive regression splines (MARS)
# model_mars <-
#   mars(
#     num_terms = tune(), prod_degree = tune(), prune_method = "backward"
#     ) |>
#   set_engine("earth") |>
#   set_mode("classification")

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

# # boosted trees via  C5.0
# model_bc5 <-
#   boost_tree(
#     trees = tune(), min_n = tune(), sample_size = tune()
#   ) |>
#   set_engine("C5.0") |>
#   set_mode("classification") 

# # support vector machines via kernlab
# model_svm <-
#   svm_linear(
#     cost = tune()
#   ) |>
#   set_engine("kernlab") |>
#   set_mode("classification") 
  
# random forest via ranger
model_rf <-
  rand_forest(
    # mtry = tune(),
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
# model_gam <-
#   gen_additive_mod(
#     select_features = FALSE, 
#     adjust_deg_free = tune()
#     ) |> 
#     set_mode("classification") |> 
#     set_engine("mgcv")

# model_bart <-
#   bart(
#     trees = tune()
#   ) |>
#   set_mode("classification") |>
#   set_engine("dbarts")

# model_mlp2 <-
#   mlp(
#     penalty = tune(),
#     epochs = tune()
#   ) |>
#   set_mode("classification") |>
#   set_engine("brulee", hidden_units = 2)

# # Bagging Models
# NR_TIMES <- 25
# model_bagc50 <-
#   bag_tree(
#     min_n = tune()
#     ) |>
#     set_engine("C5.0", times = NR_TIMES) |>
#     set_mode("classification")

# model_bagrpart <- 
#   bag_tree(
#     class_cost = tune(),
#     tree_depth = tune()
#     # min_n = tune(), 
#     # cost_complexity = double(1)
#   ) |>
#     set_engine("rpart", times = NR_TIMES) |>
#     set_mode("classification")