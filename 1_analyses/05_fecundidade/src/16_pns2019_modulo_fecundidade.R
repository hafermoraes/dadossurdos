
if(PNS2019_PREVALENCES_DATA){
  
  VARS <-
    c(
      "fec_relacao_sexual_12meses",
      "fec_grupo_planejamento_familiar_12meses",
      "fec_evita_gravidez_atualmente",
      "fec_motivo_nao_evita_quer_engravidar",
      "fec_motivo_nao_evita_religiao",
      "fec_motivo_nao_evita_desconhecimento",
      "fec_motivo_nao_evita_gestante",
      "fec_motivo_nao_evita_ligamento_trompa",
      "fec_motivo_nao_evita_vasectomia_companheiro",
      "fec_motivo_nao_evita_homossexual",
      "fec_motivo_evita_pilula",
      "fec_motivo_evita_tabela",
      "fec_motivo_evita_camisinha_masculina",
      "fec_motivo_evita_camisinha_feminina",
      "fec_motivo_evita_diafragma",
      "fec_motivo_evita_diu",
      "fec_motivo_evita_contraceptivo_injetavel",
      "fec_motivo_evita_implantes_norplant",
      "fec_motivo_evita_creme_ovulo",
      "fec_motivo_evita_pilula_dia_seguinte",
      "fec_tratamento_engravidar"
    )
  
  gc()
  
  append_flag <- FALSE
  
  fecund_prevalencias <-
    tibble(
      n = numeric(),
      n_low = numeric(),
      n_upp = numeric(),
      p = numeric(),
      p_low = numeric(),
      p_upp = numeric(),
      subgrp = character(),
      var = character()
    )
  
    for(var in VARS){
    
    gc()
    
    aux <-
      prevalence_all_ages(
        arg_var = var,
        arg_output_file = paste0(
          results_dir,
          "fecund_prevalencias.csv"
        ),
        arg_append = append_flag
      )
    
    fecund_prevalencias <-
      bind_rows(
        fecund_prevalencias,
        aux
      )
    
    append_flag <- TRUE
  } # for(var in VARS)
  
} # if(PNS2019_PREVALENCES_DATA)


fecund_prevalencias <-
  read_csv(
    paste0(
      results_dir,
      "fecund_prevalencias.csv"
    )
  )

aux_latex <-     
  fecund_prevalencias |>
  filter(
    var %in% c(
      'fec_relacao_sexual_12meses', 
      'fec_grupo_planejamento_familiar_12meses', 
      'fec_evita_gravidez_atualmente'#, 'fec_tratamento_engravidar'
      )
  ) |>
  pivot_longer(
    cols = c(n, n_low, n_upp, p, p_low, p_upp)
  ) |>
  mutate(
    var = case_match(
      var,
      "fec_relacao_sexual_12meses" ~ '\\FecRelacaoSexual',
      "fec_grupo_planejamento_familiar_12meses" ~ '\\FecPlanejamentoFamiliar',
      "fec_evita_gravidez_atualmente" ~ '\\FecEvitaGravidez',
    ),
    subgrp = paste0('\\', gsub('categ_', '', subgrp)),
    subgrp = gsub("_","", subgrp),
    value_latex = case_when(
      name %in% c('n','n_low','n_upp') ~ format(round(value,0), big.mark=".", decimal.mark=','),
      name %in% c('p','p_low','p_upp') ~ format(round(100*value,1), big.mark=".", decimal.mark=',')
    ),
    value_latex = str_trim(value_latex)
  ) |>
  pivot_wider(
    id_cols = c(var,subgrp),
    names_from = name,
    values_from = value_latex
  ) |>
  transmute(
    var, subgrp,
    n = case_when(
      var == '\\FecPlanejamentoFamiliar' & subgrp == '\\surdocego' ~ '-',
      TRUE ~ n
    ), 
    n_ic = case_when(
      var == '\\FecPlanejamentoFamiliar' & subgrp == '\\surdocego' ~ '-',
      TRUE ~ paste0('[', n_low,'; ', n_upp,']')
    ), 
    p = case_when(
      var == '\\FecPlanejamentoFamiliar' & subgrp == '\\surdocego' ~ '-',
      TRUE ~ p
    ), 
    p_ic = case_when(
      var == '\\FecPlanejamentoFamiliar' & subgrp == '\\surdocego' ~ '-',
      TRUE ~ paste0('[', p_low,'; ', p_upp,']')
    )
  )
  


fecund_prevalencias_latex <-
  aux_latex |>
  arrange(var, subgrp) |>
  group_by(var) |>
  mutate(
    n_linhas = n(),
    row_idx = row_number(),
    var = if_else(
      row_idx == 1, 
      if_else(
        n_linhas == 1,
        paste0("\\midrule ", var),
        paste0("\\midrule \\multirow{", n_linhas, "}{=}{", var, "}")
      ),
      ""
    )
  ) |>
  ungroup() |>
  mutate(
    var = if_else(row_number() == 1, sub("\\\\midrule ", "", var), var)
  ) |>
  select(-n_linhas, -row_idx)
  


res_latex <- xtable::xtable(fecund_prevalencias_latex)

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
    "fec_pns2019_latex.tex"
  )
)





