
censos_paridade_Pi <-
  el_badry |> 
  filter( !is.na(filhos_nascidos_vivos)) |>
  mutate(
    num = filhos_nascidos_vivos * n,
    den = n
  ) |>
  group_by(ano, subgrp, fx_idade, fx_idade_elb) |>
  summarise(
    Pi = sum(num, na.rm=TRUE)/sum(den, na.rm=TRUE),
    .groups = "drop"
  ) 


censos_paridade_Pi |> 
  ggplot(
    aes( x = fx_idade, y=Pi, color=subgrp, group=subgrp)
    ) + 
    geom_line() + 
    facet_grid( . ~ ano)


  ggsave(
    filename = paste0(
      results_dir,
      "fec_parities.pdf"
    ),
    width = 12,
    height = 8
  )
