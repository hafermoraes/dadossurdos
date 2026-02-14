
tic()
message("preparando dados do censo2010 para a comparação...")
censo2010_num <-
  censo2010 |>
  mutate(
    across(c(idade, peso_amostral), as.numeric),
    faixa_idade = case_when(
      idade <= 4   ~ "0-4",
      idade <= 9   ~ "5-9",
      idade <= 19  ~ "10-19",
      idade <= 29  ~ "20-39",
      TRUE         ~ "40+"
    )
  ) |> 
  select(faixa_idade, sexo, dif_ouvir, instrucao, peso_amostral) |>
  pivot_longer(
    cols = c('faixa_idade', 'sexo', 'dif_ouvir', 'instrucao'),
    names_to = 'key',
    values_to = 'value'
  ) |>
  transmute(
    src = 'censo2010',
    key, value,
    n = peso_amostral
  ) |> 
  group_by(src, key, value) |>
  summarise(num = sum(n, na.rm=TRUE)) |> 
  ungroup() |>
  collect() 

censo2010_den <- 
  censo2010_num |>
  group_by(src,key) |>
  summarise(den = sum(num, na.rm=TRUE)) |>
  ungroup() |>
  collect()

censo2010_dist <-
  censo2010_num |>
  left_join(censo2010_den) |>
  transmute(
    src,key,value,
    pct=num/den
  ) |>
  arrange(src,key,value)
toc()


