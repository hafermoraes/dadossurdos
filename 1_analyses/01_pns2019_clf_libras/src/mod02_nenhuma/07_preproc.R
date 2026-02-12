# passo 4: transformação das variáveis independentes
## recipe_basic <-
##   recipe(libras ~ ., data = libras_train) |>
##   step_impute_knn(all_predictors(), neighbors = 3) |>
##   step_normalize(all_numeric_predictors()) |>
##   step_integer(all_nominal_predictors()) |>
##   step_clean_names(all_nominal_predictors()) #|>
##   # class_weights implementado só com step_upsample() ou step_downsample()
##   #step_downsample(libras, under_ratio = 1)  

recipe_basic <-
  recipe(libras ~ ., data = libras_train) |>
  step_impute_knn(all_predictors(), neighbors = 3) |>
  step_novel(all_nominal_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_interact(terms = ~all_predictors():all_predictors()) |>
  step_ns(idade, deg_free = 3) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  step_corr(all_predictors(), threshold = 0.95) |>
  step_clean_names(all_nominal_predictors())


# recipe2 <- prep(recipe_basic, training = libras_train)
# imputed <- bake(recipe2, libras_train)
