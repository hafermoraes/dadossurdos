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

if(TRUE){
  
  # isolation forest
  # install.packages("solitude")
  library(solitude)
  
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

