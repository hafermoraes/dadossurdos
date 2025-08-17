packs <- c(
  'pak',
  'textrecipes',
  'janitor',
  'themis',
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
  'C50',
  'betacal',
  'NeuralNetTools',
  'dbarts'
)
install.packages(packs)

pak::pak('tidymodels/tailor')
pak::pak('tidymodels/bonsai')
pak::pak('tidymodels/baguette')
pak::pak('tidymodels/brulee')
