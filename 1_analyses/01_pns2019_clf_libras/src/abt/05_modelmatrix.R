


modelmatrix <-
  microdados |> 
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

message("validações pontuais...")

message(
  paste0(
    "sum(microdados$case_weights) = ", 
    sum(microdados$case_weights))
  )
message(
  paste0(
    "sum(modelmatrix$case_weights) = ", 
    sum(modelmatrix$case_weights)
    )
  )
message(
  paste0(
    "sum(microdados$case_weights) == sum(modelmatrix$case_weights) = ", 
    sum(microdados$case_weights) == sum(modelmatrix$case_weights)
    )
  )

tic()
message("exportando a base de modelagem em disco...")
modelmatrix |>
  arrange(desc(case_weights)) |>
  write_csv(
    paste0(
      data_dir,
      "pns2019_02_modelmatrix.csv"
    )
  )
toc()
