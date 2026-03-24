
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
    names_from = c(ano,key),
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

