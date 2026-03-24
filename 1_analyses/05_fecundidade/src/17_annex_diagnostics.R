tic()
message("exportando tabelas de diagnóstico do método P/F em latex em disco...")
fec_params_pf <-
  read_csv(
    file = paste0(
      results_dir,
      "fec_params_pf.csv"
    ),
    show_col_types = FALSE
  )

for(arg_categ in fec_params_pf$categ |> unique()){
  
  fec_res_pf <-
    fec_params_pf |>
    filter( categ == arg_categ) |>
    mutate(
      value = format(round(value, 3), big.mark='.', decimal.mark=',')
    ) |>
    pivot_wider(
      id_cols = key,
      names_from = ano,
      values_from = value
    )
  
  res <- capture.output(
    print(
      xtable(fec_res_pf, type = 'latex'),
      only.contents = TRUE,
      hline.after = NULL,
      include.colnames = FALSE,
      include.rownames = FALSE,
      comment = FALSE,
      sanitize.text.function = identity
    )
  )
  
  res_clean <- paste(res, collapse = "\n")
  res_clean <- sub("\\\\\\\\(?=[\\s\\n]*$)", "", res_clean, perl = TRUE)
  
  cat(res_clean, file = paste0(results_dir, 'fec_params_pf_', arg_categ, '.tex'))
  
  # print(
  #   xtable(fec_res_pf, type = 'latex'),
  #   only.contents = TRUE,
  #   hline.after = NULL,
  #   include.colnames = FALSE,
  #   include.rownames = FALSE,
  #   comment = FALSE,
  #   file = paste0(
  #     results_dir,
  #     'fec_params_pf_',
  #     arg_categ,
  #     '.tex'
  #   )
  # )
} # for(arg_categ in fec_params_pf$categ |> unique())
toc()






fec_metrics_gompertz_models <-
  read_csv(
    file = paste0(
      results_dir,
      "fec_metrics_gompertz_models.csv"
    ),
    show_col_types = FALSE
  )


tic()
message("exportando tabelas de diagnóstico do método Gompertz Relacional Modificado em latex em disco...")
for(arg_categ in fec_metrics_gompertz_models$categ |> unique()){
  
  fec_res_grm <-
    fec_metrics_gompertz_models |>
    filter(
      model == 'GRM',
      categ == arg_categ
    ) |>
    mutate(
      value = format(round(value, 4), big.mark='.', decimal.mark=','),
      key = case_match(
        key,
        'alpha' ~ '\\alphaparam',
        'beta' ~ '\\betaparam',
        'rsquared' ~ paste0('\\', key),
        'mse' ~ paste0('\\', key)
      )
    ) |>
    pivot_wider(
      id_cols = key,
      names_from = ano,
      values_from = value
    )

  res <- capture.output(
    print(
      xtable(fec_res_grm, type = 'latex'),
      only.contents = TRUE,
      hline.after = NULL,
      include.colnames = FALSE,
      include.rownames = FALSE,
      comment = FALSE,
      sanitize.text.function = identity
    )
  )
  
  res_clean <- paste(res, collapse = "\n")
  res_clean <- sub("\\\\\\\\(?=[\\s\\n]*$)", "", res_clean, perl = TRUE)
  
  cat(res_clean, file = paste0(results_dir, 'fec_metrics_grm_', arg_categ, '.tex'))
      
  # print(
  #   xtable(fec_res_grm, type = 'latex'),
  #   only.contents = TRUE,
  #   hline.after = NULL,
  #   include.colnames = FALSE,
  #   include.rownames = FALSE,
  #   comment = FALSE,
  #   sanitize.text.function = identity,
  #   file = paste0(
  #     results_dir,
  #     'fec_metrics_grm_',
  #     arg_categ,
  #     '.tex'
  #   )
  # )
} # for(arg_categ in fec_metrics_gompertz_models$categ |> unique())
toc()






tic()
message("exportando tabelas de diagnóstico do método Gompertz Relacional Sintético em latex em disco...")
for(arg_categ in fec_metrics_gompertz_models$categ |> unique()){
  
  fec_res_grm <-
    fec_metrics_gompertz_models |>
    filter(
      model == 'GRS',
      categ == arg_categ
    ) |>
    mutate(
      value = format(round(value, 4), big.mark='.', decimal.mark=','),
      key = case_match(
        key,
        'alpha' ~ '\\alphaparam',
        'beta' ~ '\\betaparam',
        'rsquared' ~ paste0('\\', key),
        'mse' ~ paste0('\\', key)
      )
    ) |>
    pivot_wider(
      id_cols = key,
      names_from = ano,
      values_from = value
    )

  res <- capture.output(
    print(
      xtable(fec_res_grm, type = 'latex'),
      only.contents = TRUE,
      hline.after = NULL,
      include.colnames = FALSE,
      include.rownames = FALSE,
      comment = FALSE,
      sanitize.text.function = identity
    )
  )
  
  res_clean <- paste(res, collapse = "\n")
  res_clean <- sub("\\\\\\\\(?=[\\s\\n]*$)", "", res_clean, perl = TRUE)
  
  cat(res_clean, file = paste0(results_dir, 'fec_metrics_grs_', arg_categ, '.tex'))  
  
  # print(
  #   xtable(fec_res_grm, type = 'latex'),
  #   only.contents = TRUE,
  #   hline.after = NULL,
  #   include.colnames = FALSE,
  #   include.rownames = FALSE,
  #   comment = FALSE,
  #   sanitize.text.function = identity,
  #   file = paste0(
  #     results_dir,
  #     'fec_metrics_grs_',
  #     arg_categ,
  #     '.tex'
  #   )
  # )
} # for(arg_categ in fec_metrics_gompertz_models$categ |> unique())
toc()


