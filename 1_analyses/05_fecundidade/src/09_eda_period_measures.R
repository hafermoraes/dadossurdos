arg_ano <- 2010
arg_var <- 'dif_ouvir'



#censo2000_fecundidade_subset |> head() |> collect() |> View()

fec_eda_subset_surdo <-
  censo2010_fecundidade_subset |>
  filter( 
    fx_idade != '10-14',
#    categ_surdo == 1,
    ano == arg_ano
  ) |>
  transmute(
    var = arg_var,
    level = .data[[arg_var]],
    ano,
    subgrp = 'surdo',
    fx_idade,
    filhos_nascidos_vivos,
    tef_num = if_else(
      is.na(filhos_ultimos_12meses),
      0,
      filhos_ultimos_12meses * peso_amostral
    ),
    peso_amostral
  ) 


fec_eda_subset_surdo |> 
  group_by(var, level, ano, subgrp, fx_idade) |>
  summarise(
    tef = sum(tef_num, na.rm = TRUE) / sum(peso_amostral, na.rm=TRUE),
    .groups = 'drop'
  ) |>
  collect() |>
  ggplot( 
    aes(x = fx_idade, y=tef, group = level, color=level)) + 
  geom_line() + 
  geom_point()+
  labs(
    x = "Faixa etária das mulheres",
    y = "Taxa Específica de Fecundidade (TEF)",
    color = arg_var
  )



