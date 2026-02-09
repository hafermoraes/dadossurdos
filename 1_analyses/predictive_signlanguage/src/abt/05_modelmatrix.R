


modelmatrix <-
  pre_modelmatrix |> 
  group_by(
    idade,
    sexo,
    instrucao,
    dif_ouvir,
    libras
    ) |>
  summarise(
    case_weights = sum(case_weights)
  )

print(
  paste0(
    "sum(pre_modelmatrix$case_weights) = ", 
    sum(pre_modelmatrix$case_weights))
  )
print(
  paste0(
    "sum(modelmatrix$case_weights) = ", 
    sum(modelmatrix$case_weights)
    )
  )
print(
  paste0(
    "sum(pre_modelmatrix$case_weights) == sum(modelmatrix$case_weights) = ", 
    sum(pre_modelmatrix$case_weights) == sum(modelmatrix$case_weights)
    )
  )

modelmatrix |>
  arrange(desc(case_weights)) |>
  write_csv(
    paste0(
      base_dir,
      "data/pns2019_03_modelmatrix.csv"
    )
  )
