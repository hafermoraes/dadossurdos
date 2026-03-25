
fec_data_asfr_relational_models <-
  read_csv(
    file = paste0(
      results_dir,
      "fec_data_asfr_relational_models.csv"
    ),
    show_col_types = FALSE
  )



tic()
message("exportando tabela resumo dos modelos relacionais em disco em latex...")

fec_asfr_models_wide <-
  fec_data_asfr_relational_models |> 
  filter(fx_idade != 'total') |>
  mutate(
    key = case_match(
      key,
      'original' ~ 'orig',
      'gompertz_relacional_modificado' ~ 'grm',
      'gompertz_sintetico' ~ 'grs',
      'pf_brass' ~ 'pf'
    )
  ) |> 
  pivot_wider(
    id_cols = c(subgrp,fx_idade),
    names_from = c(ano, key),
    values_from = value,
    names_glue = '{key}_{ano}'
  ) |>
  mutate(
    grs_2005_media = (orig_2000 + orig_2010)/2.0
  )


res_asfr_wide <-
  fec_asfr_models_wide |> 
  group_by(subgrp) |>
  group_modify(
    ~ bind_rows(
      .x, 
      summarize(
        .x, 
        across(
          where(is.numeric), 
          \(x) 5*sum(x)
        ), 
      fx_idade = "TFT de Período"
      )
    )
  ) |>
  ungroup() |> 
  mutate(
    across(where(is.numeric), \(x) format(round(x,3), big.mark='.',decimal.mark=',') )
  ) |> 
  select(
    subgrp, fx_idade,
    orig_2000, pf_2000, grm_2000,
    orig_2010, pf_2010, grm_2010,
    grs_2005_media,
    grs_2005
  )



tic()
for(arg_categ in fec_data_asfr_relational_models$subgrp |> unique()){
  
  message("exportando resumo em latex em disco para ", arg_categ)
  
  res_asfr_table <-
    res_asfr_wide |>
    filter(subgrp == arg_categ) |>
    group_by(subgrp) |>
    mutate(
      subgrp = case_match(
        subgrp,
        'deficiente_auditivo' ~ 'Deficiente Auditivo',
        'surdo' ~ 'Surdo',
        'surdocego' ~ 'Surdocego'
      ),
      n_linhas = n(),
      row_idx = row_number(),
      # Identifica se é a linha do Total para inserir o prefixo
      prefixo_total = if_else(fx_idade == "TFT de Período", "\\cmidrule(lr){2-10} ", ""),
      # Constrói a primeira coluna combinando o prefixo (cmidrule) com a lógica do multirow
      subgrp_new = case_when(
        row_idx == 1 & n_linhas == 1 ~ paste0("\\midrule ", prefixo_total, subgrp),
        row_idx == 1 ~ paste0("\\midrule ", prefixo_total, "\\multirow{", n_linhas, "}{=}{", subgrp, "}"),
        TRUE ~ prefixo_total # Se for a linha do Total (mas não a primeira), o subgrp recebe apenas o cmidrule
      )
    ) |>
    ungroup() |>
    mutate(
      subgrp = if_else(row_number() == 1, sub("\\\\midrule ", "", subgrp_new), subgrp_new)
    ) |>
    select(subgrp, fx_idade, everything(), -n_linhas, -row_idx, -subgrp_new, -prefixo_total)
  
  
  res_latex <- xtable::xtable(res_asfr_table)
  
  tab_out <- 
    capture.output(
      print(
        res_latex, 
        include.rownames = FALSE, 
        include.colnames = FALSE,
        only.contents = TRUE,
        sanitize.text.function = identity,
        hline.after = NULL
      )
    )
  
  idx <- max(which(grepl("\\\\\\\\", tab_out)))
  
  tab_out[idx] <- sub("\\\\\\\\\\s*$", "", tab_out[idx])
  
  cat(
    tab_out, 
    sep = "\n", 
    file = paste0(
      results_dir,
      "fec_asfr_models_", arg_categ, ".tex"
    )
  )

} # for(arg_categ in fec_data_asfr_relational_models$subgrp |> unique())
toc()




tic()
message("resumo gráfico das TEFs...")

PLOT_WIDTH  <- 5
PLOT_HEIGHT <- 3

for(arg_categ in c('deficiente_auditivo','surdo','surdocego')){
  for(arg_ano in c(2000,2005,2010)){
    plt_data <-
      fec_asfr_models_wide |>
      rename(orig_2005 = grs_2005_media) |>
      pivot_longer(
        cols = -c(subgrp, fx_idade), 
        names_to = c("key", "ano"), 
        names_pattern = "(.*)_(.*)", 
        values_to = "value"
      ) |>
      filter(
        ano == arg_ano,
        subgrp == arg_categ
      )
    
    plt_labels <- 
      plt_data |>
      group_by(key) |>
      summarise(tft = sum(value) * 5, .groups = 'drop') |>
      mutate(
        new_key = case_match(
          key,
          'orig' ~ 'Orig.',
          'grm' ~ 'GRM',
          'pf' ~ 'P/F',
          'grs' ~ 'GRS'
        ),
        label = paste0(
          new_key, 
          " (TFT = ", 
          format(round(tft, 3), nsmall = 3, big.mark='.', decimal.mark=','), 
          ")"
        )
      )
    
    plt <-  
      plt_data |> 
      left_join(plt_labels, by = "key") |> 
      ggplot(
        aes(x=factor(fx_idade), y=value, linetype = label, group=label)
      ) + 
      geom_line(size=0.5) +
      labs(
        x = 'Faixa etária',
        y = 'Taxa Específica de Fecundidade',
        linetype = '',
        group = ''
      ) + 
      theme(
        legend.title = element_blank(),
        legend.position = "inside",
        legend.position.inside = c(0.8, 0.8),
        legend.background = element_rect(fill = "white", color = "grey80") # Opcional: borda/fundo
      )  
    
    ggsave(
      filename = paste0(
        results_dir,
        'fec_asfr_models_',
        arg_categ,
        '_',
        arg_ano,
        '.pdf'
      ),
      width = PLOT_WIDTH,
      height = PLOT_HEIGHT
    )
    
  } # for(arg_ano in c(2000,2005,2010))
} # for(arg_categ in c('deficiente_auditivo','surdo','surdocego'))
toc()



tic()
message("séries P/F de diferentes anos em um mesmo gráfico")
fec_pf_series <- 
  read_csv(
    file = paste0(results_dir, "fec_pf_series.csv"),
    show_col_types = FALSE
  )

for(arg_categ in fec_pf_series$categ |> unique()){
  plt_data <-
    fec_pf_series |>
    filter(categ == arg_categ) |>
    transmute(
      ano = as.factor(ano),
      fx_idade = factor(key),
      serie_pf = value
    )
  
  plt <- 
    plt_data |>
    ggplot( aes(x=fx_idade, y=serie_pf, group =ano, linetype = ano)) + 
    geom_line() + 
    ylim(0, max(plt_data$serie_pf)*1.1) + 
    labs(
      x = "Faixa etária",
      y = 'Razão P/F'
    ) + 
    theme(
      legend.title = element_blank(),
      legend.position = "inside",
      legend.position.inside = c(0.2, 0.8),
      legend.background = element_rect(fill = "white", color = "grey80") # Opcional: borda/fundo
    )
  
  ggsave(
    filename = paste0(results_dir, 'fec_PFbrass_', arg_categ, '_seriePF.pdf'),
    plot = plt,
    width = 7,
    height = 4
  )
  
}
toc()
