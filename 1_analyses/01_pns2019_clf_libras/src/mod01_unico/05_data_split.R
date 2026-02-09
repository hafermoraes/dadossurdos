
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

