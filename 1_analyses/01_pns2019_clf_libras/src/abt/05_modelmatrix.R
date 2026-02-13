
modelmatrix <-
  svytable(
    formula=~idade+sexo+instrucao+dif_ouvir+libras,
    design=pns2019_posterior
  ) |>
  as_tibble() |>
  filter(n>0) |>
  group_by(across(-n)) |>
  summarise(n=sum(n)) |>
  arrange(desc(n)) |>
  ungroup() |>
  rename(case_weights=n)


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

