# passo 3: preparação da validação cruzada em 10 partes (folds)

if(KFOLD){
  
  libras_folds <-
    rsample::vfold_cv(
      data = libras_train,
      strata = libras,
      v = KFOLD_NR,
      repeats = KFOLD_REPEATS
    )
  
} else {
  
  libras_folds <-
    rsample::bootstraps(
      data = libras_train,
      times = BOOTSTRAP_TIMES,
      strata = libras
    )
  
}



