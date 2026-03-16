

tic()
message("análise explotarória de dif_ouvir...")
for(ano in c(2000,2010)){
  message("exportando em disco o gráfico da TEF para dif_ouvir do ano ", ano)
  export_eda_period_tef(
    arg_ano = ano, 
    arg_var = 'dif_ouvir',
    output_file = paste0('fec_eda_tef_difouvir_',ano,'.pdf'), 
    plot_width = 6, 
    plot_height = 4
    )
}
toc()





arg_ano <- 2010
arg_categ <- 'surdo'


export_ppr_plot(
  input_file = paste0(results_dir,"fec_bootstrap_coorte_rpp_df.csv"),
  arg_ano = arg_ano,
  arg_categ = arg_categ,
  output_file = paste0(results_dir,"fec_plot_ppr_", arg_categ, '_', arg_ano, '.pdf'),
  plot_width = 8,
  plot_height = 5
)

source(paste0(src_dir,'fert_utils.R'))

export_cohort_tfr_plot(
  input_file = paste0(results_dir,"fec_bootstrap_coorte_tft.csv"),
  arg_ano = arg_ano,
  arg_categ = arg_categ,
  output_file = paste0(results_dir,"fec_plot_cohort_tfr_", arg_categ, '_', arg_ano, '.pdf'),
  plot_width = 8,
  plot_height = 5
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



