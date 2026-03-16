
tic()
message("calculando a paridade média...")
censos_paridade_Pi <-
  elbadry |> 
  filter( !is.na(filhos_nascidos_vivos)) |>
  mutate(
    num = filhos_nascidos_vivos * n,
    den = n
  ) |>
  group_by(ano, subgrp, fx_idade) |>
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
toc()


tic()
message("calculando a TFT de coorte a partir da razão de progressão de parturições...")

elbadry |> 
  filter(
    !is.na(filhos_nascidos_vivos),
    fx_idade != '10-14'
  ) |>
  mutate(
    fnv_reclass = case_when(
      filhos_nascidos_vivos >= 4 ~ '4+',
      TRUE ~ as.character(filhos_nascidos_vivos)
    ),
    fnv_reclass = factor(
      fnv_reclass,
      levels = c('0','1','2','3','4+'),
      ordered = TRUE
    )
  ) |>
  # agrupando por filhos nascidos vivos reclassificados 0-1-2-3-4+
  group_by(ano, subgrp, fx_idade, fnv_reclass) |>
  summarise( n = sum(n, na.rm = TRUE), .groups = 'drop') |>
  complete(ano, subgrp, fx_idade, fnv_reclass, fill = list(n = 0)) |>
  # calculando mulheres com pelo menos n filhos
  group_by(ano, subgrp, fx_idade) |> 
  mutate(n_reverso = rev(cumsum(rev(n)))) |> 
  # calculando as razões de parturição
  mutate(
    razao = lead(n_reverso) / n_reverso
  ) |> 
  # calculando a TFT de coorte
  mutate(
    prod_acum = cumprod(razao),
    x_tick = paste0(fnv_reclass, "-", lead(fnv_reclass)),
    resultado_final = ifelse(is.na(razao), NA, cumsum(prod_acum))
  ) |> 
  drop_na() |>
  summarise(
    tft_coorte = sum(prod_acum, na.rm = TRUE), 
    .groups = 'drop'
  ) |>
  filter(fx_idade == '45-49')
   
  
  
  
toc()
