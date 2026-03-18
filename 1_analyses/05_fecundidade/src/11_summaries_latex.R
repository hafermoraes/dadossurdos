
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
toc()