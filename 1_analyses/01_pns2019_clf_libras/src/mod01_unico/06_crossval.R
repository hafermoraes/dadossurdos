
tic()
message("configurando a validação cruzada (tidymodels/rsample)...")
if(KFOLD){
  message("usando K-Fold Cross Validation...")
  libras_folds <-
    rsample::vfold_cv(
      data = libras_train,
      strata = libras,
      v = KFOLD_NR
    )
  
} else {
  
  message("usando Bootstraping...")
  libras_folds <-
    rsample::bootstraps(
      data = libras_train,
      times = BOOTSTRAP_TIMES,
      strata = libras
    )
  
}

toc()

