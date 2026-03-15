
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
    asfr = sum( fnv_12m, na.rm=TRUE) / sum( nr_mulheres, na.rm = TRUE),
    .groups='drop'
  ) |>
  mutate(
    num_imf = asfr * idade_central
  ) |>
  group_by(ano,subgrp) |>
  summarise(
    tft_periodo = 5.0 * sum(asfr, na.rm=TRUE),
    imf = sum(num_imf, na.rm = TRUE) / sum(asfr, na.rm=TRUE)
  )
  
  
