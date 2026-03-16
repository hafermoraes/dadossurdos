
if(RUN_BOOTSTRAP){
  
  set.seed(19821117)
  
  N_SIMULATIONS <- 1e4
  
  append_flag <- FALSE
  
  tic()
  message("iniciando as simulações (bootstrap)...")
  for(arg_ano in c(2000,2010)){
    
    for(arg_categ in c('categ_surdo','categ_surdocego','categ_deficiente_auditivo','categ_ouvinte')){
    
      if(arg_ano == 2000) { subset_df <- censo2000_fecundidade_subset }
      
      if(arg_ano == 2010) { subset_df <- censo2010_fecundidade_subset }
  
      message("  preparando input_df para ", arg_categ, " ano ", arg_ano)    
      input_df <- 
        subset_df |>
        #filter(.data[[arg_categ]] == 1) |>
        filter(!!sym(arg_categ) == 1) |>
        group_by(fx_idade,filhos_nascidos_vivos,filhos_ultimos_12meses) |>
        summarise(nr_mulheres = sum(peso_amostral, na.rm=TRUE), .groups = 'drop') |>
        mutate(subgrp = arg_categ, ano = arg_ano) |>
        collect() |>
        mutate(subgrp = sub(".*_", "", subgrp))
      
      for(arg_bootstrap_id in seq_len(N_SIMULATIONS)){
        
        if(arg_bootstrap_id %% 100 == 0) {
          message("    reamostragem número ", arg_bootstrap_id, " do input_df para ", arg_categ, " ano ", arg_ano)
        }
        
        bootstrap_df <- 
          slice_sample(
            input_df,
            prop=1,
            weight_by = nr_mulheres,
            replace=TRUE
          )
        
        period_measures <- fert_period_measures(input_df = bootstrap_df)
        cohort_measures <- fert_cohort_measures(input_df = bootstrap_df)
  
        
        #message("      escrevendo tef_df em disco...")
        period_measures$tef_df |>
          transmute(
            bootstrap_id = arg_bootstrap_id,
            subgrp = sub("categ_", "", arg_categ),
            ano = arg_ano,
            fx_idade = key,
            value
          ) |>
          write_csv(
            file = paste0(
              results_dir,
              "fec_bootstrap_periodo_tef_df.csv"
              ),
            append = append_flag
          )
  
        
        #message("      escrevendo semfilhos_df em disco...")
        period_measures$semfilhos_df |>
          transmute(
            bootstrap_id = arg_bootstrap_id,
            subgrp = sub("categ_", "", arg_categ),
            ano = arg_ano,
            fx_idade = key,
            value
          ) |>
          write_csv(
            file = paste0(
              results_dir,
              "fec_bootstrap_periodo_semfilhos_df.csv"
            ),
            append = append_flag
          )
        
        
        #message("      escrevendo tft de período em disco...")
        tibble(
          bootstrap_id = arg_bootstrap_id,
          subgrp = sub("categ_", "", arg_categ),
          ano = arg_ano,
          value = period_measures$tft_periodo
        ) |>
          write_csv(
            file = paste0(
              results_dir,
              "fec_bootstrap_periodo_tft.csv"
            ),
            append = append_flag
          )
        
        
        #message("      escrevendo imf em disco...")
        tibble(
          bootstrap_id = arg_bootstrap_id,
          subgrp = sub("categ_", "", arg_categ),
          ano = arg_ano,
          value = period_measures$imf
        ) |>
          write_csv(
            file = paste0(
              results_dir,
              "fec_bootstrap_periodo_imf.csv"
            ),
            append = append_flag
          )
        
        
        #message("      escrevendo tft de coorte em disco...")
        tibble(
          bootstrap_id = arg_bootstrap_id,
          subgrp = sub("categ_", "", arg_categ),
          ano = arg_ano,
          value = cohort_measures$tft_coorte
        ) |>
          write_csv(
            file = paste0(
              results_dir,
              "fec_bootstrap_coorte_tft.csv"
            ),
            append = append_flag
          )
        
        
        #message("      escrevendo rpp_df em disco...")
        cohort_measures$ppr_df |>
          transmute(
            bootstrap_id = arg_bootstrap_id,
            subgrp = sub("categ_", "", arg_categ),
            ano = arg_ano,
            fx_idade = key,
            value
          ) |>
          write_csv(
            file = paste0(
              results_dir,
              "fec_bootstrap_coorte_rpp_df.csv"
            ),
            append = append_flag
          )
        
        append_flag <- TRUE
        
      } # for(bootstrap_id in seq_len(N_SIMULATIONS)
      
    } # for(arg_categ in c('categ_surdo','categ_surdocego','categ_deficiente_auditivo','categ_ouvinte'))
    
  } # for(arg_ano in c(2000,2010))
  toc()

}