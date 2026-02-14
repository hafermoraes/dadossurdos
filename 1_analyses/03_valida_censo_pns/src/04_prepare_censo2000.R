
censo2000_num <-
  censo2000 |>
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
    src = 'censo2000',
    key, value,
    n = peso_amostral
  ) |> 
  group_by(src, key, value) |>
  summarise(num = sum(n)) |> 
  ungroup() |>
  collect() 

censo2000_den <- 
  censo2000_num |>
  group_by(src,key) |>
  summarise(den = sum(num)) |>
  ungroup() |>
  collect()

censo2000_dist <-
  censo2000_num |>
  left_join(censo2000_den) |>
  transmute(
    src,key,value,
    pct=num/den
  ) |>
  arrange(src,key,value)
  
  

