packs <- c(
  'pak',
  #'remotes',
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
  'baguette', # bag_mars
  'betacal',
  'NeuralNetTools'
)
install.packages(packs)

pak::pak('tidymodels/tailor')
pak::pak('tidymodels/bonsai')
