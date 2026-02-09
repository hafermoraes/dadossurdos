# passo 3: preparação da validação cruzada em 10 partes (folds)
NR_FOLDS <- 5

libras_folds <-
  rsample::vfold_cv(
    data = libras_train,
    strata = libras,
    v = NR_FOLDS
  )
