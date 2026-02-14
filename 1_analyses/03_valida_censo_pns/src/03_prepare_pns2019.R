
pns2019_num <-
  pns2019 |>
  mutate(
    faixa_idade = case_when(
      idade <= 4   ~ "0-4",
      idade <= 9   ~ "5-9",
      idade <= 19  ~ "10-19",
      idade <= 29  ~ "20-39",
      TRUE         ~ "40+"
    )
  ) |>
  select(-libras,-idade) |>
  pivot_longer(
    cols = c('faixa_idade', 'sexo', 'dif_ouvir', 'instrucao'),
    names_to = 'key',
    values_to = 'value'
  ) |>
  transmute(
    src = 'pns2019',
    key, value,
    n = case_weights
  ) |>
  group_by(src, key, value) |>
  summarise(num = sum(n, na.rm=TRUE)) |> 
  ungroup() |>
  collect() 

pns2019_den <- 
  pns2019_num |>
  group_by(src,key) |>
  summarise(den = sum(num, na.rm=TRUE)) |>
  ungroup() |>
  collect()

pns2019_dist <-
  pns2019_num |>
  left_join(pns2019_den) |>
  transmute(
    src,key,value,
    pct=num/den
  ) |>
  arrange(src,key,value)

