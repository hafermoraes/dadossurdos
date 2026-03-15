
censos_fecundidade |>
  mutate(
    fnv_12m = filhos_ultimos_12meses * nr_mulheres,
    idade_central = map_dbl(
      str_extract_all(fx_idade, "\\d+"), 
      ~ {
        nums <- as.numeric(.x)
        (min(nums) + max(nums) + 1) / 2
      }
    )
  ) |> 
  group_by(ano, subgrp, fx_idade, idade_central) |>
  summarise(
    # age specific fertility rate
    tef = sum( fnv_12m, na.rm = TRUE) / sum( nr_mulheres, na.rm = TRUE),
    .groups='drop'
  ) |>
  mutate(
    num_imf = tef * idade_central
  ) |>
  group_by(ano,subgrp) |>
  summarise(
    tft_periodo = 5.0 * sum(tef, na.rm=TRUE),
    idade_media_a_fecundidade = sum(num_imf, na.rm = TRUE) / sum(tef, na.rm=TRUE)
  )
  
  
