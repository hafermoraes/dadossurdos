
bs_summaries <-
  bind_rows(
    bootstrap_summary(
      csv_file = 'fec_bootstrap_coorte_tft.csv',
      measure = 'cohort_tfr'
    ),
  bootstrap_summary(
    csv_file = 'fec_bootstrap_periodo_tft.csv',
    measure = 'period_tfr'
  ),
  bootstrap_summary(
    csv_file = "fec_bootstrap_periodo_imf.csv",
    measure = 'period_afa'
  ),
  bootstrap_summary(
    csv_file = "fec_bootstrap_coorte_rpp_df.csv",
    measure = 'cohort_ppr'
  ),
  bootstrap_summary(
    csv_file = "fec_bootstrap_periodo_tef_df.csv",
    measure = 'period_asfr'
  ),
  bootstrap_summary(
    csv_file = "fec_bootstrap_periodo_semfilhos_df.csv",
    measure = 'period_childless'
  )
)


source(paste0(src_dir, "fert_utils.R"))

for(arg_categ in c('surdo','surdocego','deficiente_auditivo','ouvinte')){
  export_bs_latex(
    bs_df = bs_summaries,
    categ = arg_categ,
    output_file = paste0(results_dir, "fec_bs_latex_", arg_categ, ".tex")
  )
}


tic()
message("exportando em disco a tabela de medidas agregadas comparativas entre observado e bootstraping...")
fec_comp_grp_measures <-
  bind_rows(
  # Resumo Bootstrap
  bs_summaries |>
    filter(is.na(key)) |>
    select(-key) |>
    pivot_longer(
      cols = c(avg,low,upp),
      names_to = 'key',
      values_to = 'value'
    ) |>
    mutate(
      key = paste0('bs_', key)
    ),
  # Observado TFT Coorte
  fec_coorte |>
    filter(subgrp != 'total') |>
    transmute(
      ano, subgrp, measure = 'cohort_tfr', 
      key = 'observed',
      value = tft_coorte
    ),
  # Observado TFT Período
  fec_periodo |>
    filter(subgrp != 'total') |>
    transmute(
      ano, subgrp, measure = 'period_tfr', 
      key = 'observed', 
      value = tft_periodo
    ),
  # Observado Idade Média à Fecundidade
  fec_periodo |>
    filter(subgrp != 'total') |>
    transmute(
      ano, subgrp, measure = 'period_afa', 
      key = 'observed',
      value = idade_media_a_fecundidade
    )
) |>
pivot_wider(
  id_cols = c(measure, subgrp, ano),
  names_from = key,
  values_from = value
) |>
pivot_wider(
  id_cols = c(measure, subgrp),
  names_from = 'ano',
  values_from = c(bs_avg, bs_low, bs_upp, observed),
  names_glue = '{.value}_{ano}'
) |>
select(
  measure, subgrp,
  observed_2000, bs_avg_2000, bs_low_2000, bs_upp_2000,
  observed_2010, bs_avg_2010, bs_low_2010, bs_upp_2010
)

fec_comp_grp_measures_latex <-
  fec_comp_grp_measures |> 
  mutate(
    subgrp = case_match(
      subgrp,
      'deficiente_auditivo' ~ 'Deficiente Auditivo',
      'surdo' ~ 'Surdo',
      'surdocego' ~ 'Surdocego',
      'ouvinte' ~ 'Ouvinte'
    ),
    measure = case_match(
      measure,
      'cohort_tfr' ~ 'Taxa de Fecundidade Total (TFT) de Coorte',
      'period_tfr' ~ 'Taxa de Fecundidade Total (TFT) de Período',
      'period_afa' ~ 'Idade média à fecundidade'
    ),
    across(where(is.numeric), \(x) format(round(x, 2), big.mark='.', decimal.mark=','))
  ) |>
  arrange(measure, subgrp) |>
  group_by(measure) |>
  mutate(
    n_linhas = n(),
    row_idx = row_number(),
    measure = if_else(
      row_idx == 1, 
      if_else(
        n_linhas == 1,
        paste0("\\midrule ", measure),
        paste0("\\midrule \\multirow{", n_linhas, "}{=}{", measure, "}")
      ),
      ""
    )
  ) |>
  ungroup() |>
  mutate(
    measure = if_else(row_number() == 1, sub("\\\\midrule ", "", measure), measure)
  ) |>
  select(-n_linhas, -row_idx)


res_latex <- xtable::xtable(fec_comp_grp_measures_latex)

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
    "fec_comp_grp_measures_latex.tex"
  )
)

toc()
