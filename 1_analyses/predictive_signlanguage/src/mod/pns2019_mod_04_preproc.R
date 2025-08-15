# passo 4: transformação das variáveis independentes
recipe_basic <-
  recipe(libras ~ ., data = libras) |>
  step_impute_knn(all_predictors(), neighbors = 3) |>
  step_normalize(all_numeric_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_clean_names(all_nominal_predictors()) |>
  # class_weights implementado só com step_upsample() ou step_downsample()
  step_downsample(libras, under_ratio = 1)  
  

# recipe2 <- prep(recipe_basic, training = libras_train)
# imputed <- bake(recipe2, libras_train)
