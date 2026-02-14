
tic()
message("definindo o pipeline de tratamento de dados para a modelagem (tidymodels/recipe)...")
recipe_basic <-
  recipe(libras ~ ., data = libras_train) |>
  step_mutate(
    instrucao = factor(
      instrucao, 
      levels = c('outros', 'fundamental', 'medio', 'superior'), 
      ordered = TRUE
    ),
    sexo = factor(
      sexo,
      levels = c('feminino', 'masculino')
    )
  ) |>
  step_novel(all_nominal_predictors()) |> 
  step_unknown(all_nominal_predictors(), new_level = "nao_informado") |>
  step_ordinalscore(instrucao) |>
  step_lencode_mixed(sexo, outcome = vars(libras)) |>  
  step_dummy(all_nominal_predictors()) |>
  step_interact(terms = ~all_predictors():all_predictors()) |>
  step_ns(idade, deg_free = 3) |>
  step_zv(all_predictors()) |>
  step_normalize(all_numeric_predictors()) |>
  step_corr(all_predictors(), threshold = 0.95) |>
  step_clean_names(all_nominal_predictors()) 
  # class_weights implementado só com step_upsample() ou step_downsample()
  #step_downsample(libras, under_ratio = 1)  

# recipe2 <- prep(recipe_basic, training = libras_train)
# imputed <- bake(recipe2, libras_train)
toc()