




tic()
message("unificando as bases dos censos 2000 e 2010...")
piramides_fecundidade <-
  bind_rows(
    censo2000_fecundidade,
    censo2010_fecundidade,
    pns2019_fecundidade,
    expand_grid(
      subgrp = c('total', 'ouvinte','deficiente_auditivo','surdo','surdocego'),
      ano = c(2000,2010,2019),
      sexo = c('feminino','masculino'),
      idade = lt_spec$breaks[-length(lt_spec$breaks)],
      n = 0
    )
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
    feminino_2000, feminino_2010, feminino_2019,
    masculino_2000, masculino_2010, masculino_2019
  )

assert_that(
  sum(piramides_fecundidade[,-c(1,2)], na.rm=TRUE) == 
  (sum(censo2000_fecundidade$n) + sum(censo2010_fecundidade$n) + sum(pns2019_fecundidade$n)),
  msg = "totais depois do pivot_wider devem coincidir!"
)
toc()


tic()
message("exportando dados tratados em disco na pasta", data_dir)
piramides_fecundidade |>
  write_csv(
    paste0(
      data_dir,
      "piramides_etarias_fecundidade.csv"
    )
  )
toc()
