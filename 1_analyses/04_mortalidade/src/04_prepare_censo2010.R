
tic()
message("preparando os dados do censo2010 para as análises de mortalidade...")

censo2010_mortalidade_subset <-
  censo2010 |> 
  mutate(
    across(c(idade, peso_amostral), as.numeric)
  ) |>
  group_by(
    dif_ouvir,
    dif_enxergar,
    sabe_libras,
    sexo,
    idade
  ) |>
  summarise(
    n = sum(peso_amostral, na.rm=TRUE)
  ) |> collect()


toc()


sum(censo2010_mortalidade_subset$n)
