# passo 2: separação em treino/teste
set.seed(1)
libras_splits <-
  rsample::initial_split(
    libras,
    strata = libras
  )

libras_train <-
  rsample::training(
    libras_splits
  )

libras_test <-
  rsample::testing(
    libras_splits
  )

if(ANOMALY_DETECTION_ISOLATION_FOREST){
  # isolation forest

  iso_forest <- isolationForest$new(
    num_trees = 100,         # number of trees (default = 100)
    sample_size = 256,       # subsample size per tree (default = 256)
    max_depth = 8            # max depth per tree (default = 8)
  )
  iso_forest$fit(libras_train)
  iso_scores_train <- iso_forest$predict(libras_train)$anomaly_score
  libras_train$isolation_forest_score <- iso_scores_train
  
  iso_scores_test <- iso_forest$predict(libras_test)$anomaly_score
  libras_test$isolation_forest_score <- iso_scores_test
}

if(ANOMALY_DETECTION_LOG_OCSVM){
  library(e1071)
  library(dbscan)

  train <- libras_train |> select(-isolation_forest_score) 
  
  recipe1 <-
    recipe(libras ~ ., data = train) |>
    step_impute_knn(all_predictors(), neighbors = 3) |>
    step_normalize(all_numeric_predictors()) |>
    step_integer(all_nominal_predictors()) |>
    step_clean_names(all_nominal_predictors())
  
  recipe2 <- prep(recipe1, training = train)
  train <- 
    bake(recipe2, train) |>
    select(-libras)
  
  outlier_lof <- lof(train, minPts=10)
  
  outlier_ocsvm <-
    svm(
      train,
      type= 'one-classification',
      kernel='radial',
      nu=0.025
    )

  preds <-
    predict(
      outlier_ocsvm,
      train
    )
  
  libras_train$ocsvm <- !preds
  libras_train$lof <- outlier_lof
  
  test <- libras_test |> select(-isolation_forest_score) 
  
  recipe1 <-
    recipe(libras ~ ., data = test) |>
    step_impute_knn(all_predictors(), neighbors = 3) |>
    step_normalize(all_numeric_predictors()) |>
    step_integer(all_nominal_predictors()) |>
    step_clean_names(all_nominal_predictors())
  
  recipe2 <- prep(recipe1, training = test)
  test <- 
    bake(recipe2, test) |>
    select(-libras)
  
  outlier_lof <- lof(test, minPts=10)
  
  outlier_ocsvm <-
    svm(
      test,
      type= 'one-classification',
      kernel='radial',
      nu=0.025
    )
  
  preds <-
    predict(
      outlier_ocsvm,
      test
    )
  
  libras_test$ocsvm <- !preds
  libras_test$lof <- outlier_lof
  
}
  
  

