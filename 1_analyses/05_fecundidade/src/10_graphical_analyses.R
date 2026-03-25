

tic()
message("análise explotarória de dif_ouvir...")
for(ano in c(2000,2010)){
  message("exportando em disco o gráfico da TEF para dif_ouvir do ano ", ano, '...')
  export_eda_period_tef(
    arg_ano = ano, 
    arg_var = 'dif_ouvir',
    output_file = paste0(
      results_dir,
      'fec_eda_tef_difouvir_',ano,'.pdf'
    ), 
    plot_width = 6, 
    plot_height = 4
    )
}
toc()


tic()
message("comparando a taxa de fecundidade total de coorte por ano e entre categorias...")
export_bs_comp_density(
  file = "fec_bootstrap_coorte_tft",
  x_label = "Taxa de Fecundidade Total de Coorte",
  plot_width = 6,
  plot_height = 2
)
toc()


tic()
message("comparando a taxa de fecundidade total de período por ano e entre categorias...")
export_bs_comp_density(
  file = "fec_bootstrap_periodo_tft",
  x_label = "Taxa de Fecundidade Total de Período",
  plot_width = 6,
  plot_height = 2
)
toc()


tic()
message("comparando a idade média à fecundidade por ano e entre categorias...")
export_bs_comp_density(
  file = "fec_bootstrap_periodo_imf",
  x_label = "Idade média à fecundidade",
  plot_width = 6,
  plot_height = 2 
)
toc()


tic()
message("comparando a taxa específica de fecundidade por ano e entre categorias...")
export_bs_comp_lineplot(
  file = "fec_bootstrap_periodo_tef_df",
  x_label = "Faixa etária",
  y_label = "Taxa específica de fecundidade",
  plot_width = 7,
  plot_height = 4
)
toc()



tic()
message("comparando a razão de progressão de parturição por ano e entre categorias...")
export_bs_comp_lineplot(
  file = "fec_bootstrap_coorte_rpp_df",
  x_label = "Progressão de parturição",
  y_label = "Razão",
  plot_width = 7,
  plot_height = 4
)
toc()



tic()
message("comparando a proporção de mulheres sem filhos por ano e entre categorias...")
export_bs_comp_lineplot(
  file = "fec_bootstrap_periodo_semfilhos_df",
  x_label = "Faixa Etária",
  y_label = "Proporção de mulheres sem filhos",
  plot_width = 7,
  plot_height = 4
)
toc()




PLOT_WIDTH <- 5
PLOT_HEIGHT <- 4

tic()
for(arg_ano in c(2000,2010)){
  for(arg_categ in c('surdo','surdocego','deficiente_auditivo','ouvinte')){
    
  message("exportando em disco o gráfico da razão de progressão de parturição para ", arg_categ, " ano ", arg_ano)
  export_ppr_plot(
    input_file = paste0(results_dir,"fec_bootstrap_coorte_rpp_df.csv"),
    arg_ano = arg_ano,
    arg_categ = arg_categ,
    output_file = paste0(results_dir,"fec_plot_ppr_", arg_categ, '_', arg_ano, '.pdf'),
    plot_width = PLOT_WIDTH,
    plot_height = PLOT_HEIGHT
  )
  
  message("exportando em disco o gráfico da TFT de coorte para ", arg_categ, " ano ", arg_ano)
  export_cohort_tfr_plot(
    input_file = paste0(results_dir,"fec_bootstrap_coorte_tft.csv"),
    arg_ano = arg_ano,
    arg_categ = arg_categ,
    output_file = paste0(results_dir,"fec_plot_cohort_tfr_", arg_categ, '_', arg_ano, '.pdf'),
    plot_width = PLOT_WIDTH,
    plot_height = PLOT_HEIGHT
  )
  
  
  
  
  message("exportando em disco o gráfico TFT de período para ", arg_categ, " ano ", arg_ano)
  export_period_tfr_plot(
    input_file = paste0(results_dir,"fec_bootstrap_periodo_tft.csv"),
    arg_ano = arg_ano,
    arg_categ = arg_categ,
    output_file = paste0(results_dir,"fec_plot_period_tfr_", arg_categ, '_', arg_ano, '.pdf'),
    plot_width = PLOT_WIDTH,
    plot_height = PLOT_HEIGHT
  )
  
  
  
  
  
  
  message("exportando em disco o gráfico da idade média à fecundidade para ", arg_categ, " ano ", arg_ano)
  export_period_avg_fert_age_plot(
    input_file = paste0(results_dir,"fec_bootstrap_periodo_imf.csv"),
    arg_ano = arg_ano,
    arg_categ = arg_categ,
    output_file = paste0(results_dir,"fec_plot_period_avg_fert_age_", arg_categ, '_', arg_ano, '.pdf'),
    plot_width = PLOT_WIDTH,
    plot_height = PLOT_HEIGHT
  )
  
  
  
  
  message("exportando em disco o gráfico proporção de mulheres sem filhos para ", arg_categ, " ano ", arg_ano)
  export_period_childless_plot(
    input_file = paste0(results_dir,"fec_bootstrap_periodo_semfilhos_df.csv"),
    arg_ano = arg_ano,
    arg_categ = arg_categ,
    output_file = paste0(results_dir,"fec_plot_childless_", arg_categ, '_', arg_ano, '.pdf'),
    plot_width = PLOT_WIDTH,
    plot_height = PLOT_HEIGHT
  )
  
  message("exportando em disco o gráfico das taxas específicas de fecundidade (TEF) para ", arg_categ, " ano ", arg_ano)
  export_period_asfr_plot(
    input_file = paste0(results_dir,"fec_bootstrap_periodo_tef_df.csv"),
    arg_ano = arg_ano,
    arg_categ = arg_categ,
    output_file = paste0(results_dir,"fec_plot_asfr_", arg_categ, '_', arg_ano, '.pdf'),
    plot_width = PLOT_WIDTH,
    plot_height = PLOT_HEIGHT
  )

  } # for(arg_categ in c('surdo','surdocego','deficiente_auditivo','ouvinte','total'))
} # for(arg_ano in c(2000,2010))
toc()
