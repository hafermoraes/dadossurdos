

if(KFOLD){
  
  libras_folds <-
    rsample::vfold_cv(
      data = libras_train,
      strata = libras,
      v = KFOLD_NR
    )
  
} else {
  
  libras_folds <-
    rsample::bootstraps(
      data = libras_train,
      times = BOOTSTRAP_TIMES,
      strata = libras
    )
  
}



