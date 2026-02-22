
tic()
message("unificando as bases dos censos 2000 e 2010...")
censo_mortalidade <-
  bind_rows(
    censo2000_mortalidade,
    censo2010_mortalidade
  ) |> 
  mutate(
    fx_idade = cut(
        idade, 
        breaks = lt_spec$breaks, 
        labels = lt_spec$labels, 
        right = FALSE, 
        ordered_result = TRUE
      )
  ) |>
  pivot_wider(
    id_cols = c(subgrp, fx_idade),
    names_from = c(ano, sexo),
    values_from = n,
    names_glue = "{sexo}_{ano}",
    values_fn = sum
  ) |>
  arrange( subgrp, fx_idade) |>
  select( 
    subgrp, fx_idade, 
    feminino_2000, feminino_2010, 
    masculino_2000, masculino_2010
  )

assert_that(
  sum(censo_mortalidade[,-c(1,2)], na.rm=TRUE) == 
  (sum(censo2000_mortalidade$n) + sum(censo2010_mortalidade$n)),
  msg = "totais depois do pivot_wider devem coincidir!"
)
toc()


tic()
message("exportando dados tratados em disco na pasta", data_dir)
censo_mortalidade |>
  write_csv(
    paste0(
      data_dir,
      "mortalidade.csv"
    )
  )
toc()
