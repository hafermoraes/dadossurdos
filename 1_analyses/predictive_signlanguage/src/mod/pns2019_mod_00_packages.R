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
  'c50',
  'baguette', # bag_mars
  'betacal',
  'NeuralNetTools'
)
install.packages(packs)

pak::pak('tidymodels/tailor')
pak::pak('tidymodels/bonsai')

library(readr)         # read_csv, write_rds,read_rds
library(dplyr)         # |>, mutate, glimpse
library(tidymodels)    # initial_splits, train, test
library(textrecipes)   # step_clean_names
library(janitor)
library(themis)        # step_downsample
library(stringr)       # str_remove_all
library(probably)      # cal_plot_breaks, cal_apply, cal_estimate_*
library(betacal)
library(tailor)
library(bonsai)
#library(catboost)
library(discrim)
library(finetune)
#library(doParallel)
library(lme4)
library(earth)
library(C50)
library(kernlab)
