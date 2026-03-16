


fec_bootstrap_coorte_rpp_df <- 
  read_csv(
    file = paste0(
      results_dir,
      "fec_bootstrap_coorte_rpp_df.csv"
    ),
    show_col_types = FALSE
  )

fec_bootstrap_coorte_rpp_df |>
  mutate(
    fx_idade = factor(fx_idade)
  ) |>
  group_by(
    subgrp, ano, fx_idade
  ) |>
  summarise(
    ppr = median(value),
    ppr_low = quantile(value, 0.025),
    ppr_upp = quantile(value, 0.975)
  ) |>
  ggplot(
    aes(x = fx_idade, group = subgrp)
  ) +
  geom_ribbon(
    aes(
      ymin = ppr_low,
      ymax = ppr_upp,
      fill = subgrp
    ),
    alpha = 0.2
  ) +
  geom_line(
    aes(y = ppr, color = subgrp), 
    size = 1
    ) +
  facet_wrap( ano ~ ., scales='free') +
  labs(
    fill = "",
    color= "",
    title = "",
    y = "Filhos por Mulher (P)",
    x = "Progressão de parturição")






fec_bootstrap_coorte_tft <-
  read_csv(
    file = paste0(
      results_dir,
      "fec_bootstrap_coorte_tft.csv"
    ),
    show_col_types = FALSE
  )

fec_bootstrap_coorte_tft |>
  mutate(
    ano = factor(ano)
  ) |>
  ggplot(
    aes(x = value, fill = subgrp, color = subgrp)
  ) +
  geom_density(alpha = 0.3) +
  facet_wrap( ano ~. , scales='free') +
  labs(
    title = "",
    x = "Taxa de Fecundidade Total (TFT) de Coorte",
    y = "Densidade",
    fill = "",
    color = ""
  )











fec_bootstrap_periodo_tft <-
  read_csv(
    file = paste0(
      results_dir,
      "fec_bootstrap_periodo_tft.csv"
    ),
    show_col_types = FALSE
  )

fec_bootstrap_periodo_tft |>
  mutate(
    ano = factor(ano)
  ) |>
  filter(value < 0.5) |>
  ggplot(
    aes(x = value, fill = subgrp, color = subgrp)
  ) +
  geom_density(alpha = 0.3) +
  facet_wrap( ano ~. , scales='free') +
  labs(
    title = "",
    x = "Taxa de Fecundidade Total (TFT) de Período",
    y = "Densidade",
    fill = "",
    color = ""
  )










fec_bootstrap_periodo_imf <-
  read_csv(
    file = paste0(
      results_dir,
      "fec_bootstrap_periodo_imf.csv"
    ),
    show_col_types = FALSE
  )

fec_bootstrap_periodo_imf |>
  mutate(
    ano = factor(ano)
  ) |>
  ggplot(
    aes(x = value, fill = subgrp, color = subgrp)
  ) +
  geom_density(alpha = 0.3) +
  facet_wrap( ano ~., scales='free' ) +
  labs(
    title = "",
    x = "Idade média à fecundidade",
    y = "Densidade",
    fill = "",
    color = ""
  )










fec_bootstrap_periodo_semfilhos_df <- 
  read_csv(
    file = paste0(
      results_dir,
      "fec_bootstrap_periodo_semfilhos_df.csv"
    ),
    show_col_types = FALSE
  )

fec_bootstrap_periodo_semfilhos_df |>
  mutate(
    fx_idade = factor(fx_idade)
  ) |>
  group_by(
    subgrp, ano, fx_idade
  ) |>
  summarise(
    ppr = median(value),
    ppr_low = quantile(value, 0.025),
    ppr_upp = quantile(value, 0.975)
  ) |>
  ggplot(
    aes(x = fx_idade, group = subgrp)
  ) +
  geom_ribbon(
    aes(
      ymin = ppr_low,
      ymax = ppr_upp,
      fill = subgrp
    ),
    alpha = 0.2
  ) +
  geom_line(
    aes(y = ppr, color = subgrp), 
    size = 1
  ) +
  facet_wrap( ano ~ ., scales='free') +
  labs(
    fill = "",
    color= "",
    title = "",
    y = "Percentual de mulheres sem filhos",
    x = "Faixa etária")




fec_bootstrap_periodo_tef_df <- 
  read_csv(
    file = paste0(
      results_dir,
      "fec_bootstrap_periodo_tef_df.csv"
    ),
    show_col_types = FALSE
  )


fec_bootstrap_periodo_tef_df |>
  group_by(
    subgrp, ano, fx_idade
  ) |>
  summarise(
    median = median(value),
    value_low = hdi(value, credMass = 0.95)[1],
    value_upp = hdi(value, credMass = 0.95)[2],
    .groups = 'drop'
  ) |> 
  ggplot(
    aes(x = fx_idade, group = subgrp)
  ) +
  geom_ribbon(
    aes(
      ymin = value_low,
      ymax = value_upp,
      fill = subgrp
    ),
    alpha = 0.2
  ) +
  geom_line(
    aes(y = median, color = subgrp), 
    size = 1
  ) +
  facet_wrap( ano ~ ., scales = 'free') +
  labs(
    fill = "",
    color= "",
    title = "",
    y = "Taxa Específica de Fecundidade (TEF)",
    x = "Faixa etária"
  )



