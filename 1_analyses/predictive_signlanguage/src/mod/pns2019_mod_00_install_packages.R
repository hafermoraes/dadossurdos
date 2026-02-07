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
  'dbarts',
  'parsnip',
  'hardhat',
  'sparsevctrs',
  'bonsai',
  'baguette',
  'brulee'
)
install.packages(packs)

pak::pak('tidymodels/tailor')
