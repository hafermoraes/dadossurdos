packs <- c(
  'pak',
  'corr',
  'mosaic',
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
  'betacal',
  'NeuralNetTools',
  'parsnip',
  'hardhat',
  'sparsevctrs',
  'bonsai',
  'baguette',
  'brulee',
  'solitude'
)
install.packages(packs)

pak::pak('tidymodels/tailor')
