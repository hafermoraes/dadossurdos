
if(PNS2019_PREVALENCES_DATA){
  
  VARS <-
    c(
      "mort_diagnostico_hipertensao_arterial",       "mort_diagnostico_diabetes",
      "mort_diagnostico_colesterol_alto",            "mort_diagnostico_cardiopatia",
      "mort_cardiopata_infarto",                     "mort_cardiopata_angina",
      "mort_cardiopata_insuficiencia_cardiaca",      "mort_cardiopata_arritmia",
      "mort_diagnostico_avc",                        "mort_diagnostico_asma",
      "mort_diagnostico_reumatismo",                 "mort_diagnostico_dort",
      "mort_diagnostico_depressão",                  "mort_diagnostico_doenca_mental",
      "mort_doenca_mental_esquizofrenia",            "mort_doenca_mental_transtorno_bipolar",
      "mort_doenca_mental_toc",                      "mort_diagnostico_doenca_pulmonar",
      "mort_doenca_pulmonar_enfisema",               "mort_doenca_pulmonar_bronquite_cronica",
      "mort_diagnostico_cancer",                     "mort_cancer_pele",
      "mort_cancer_pulmao",                          "mort_cancer_intestino",
      "mort_cancer_estomago",                        "mort_cancer_mama",
      "mort_cancer_colon_utero",                     "mort_cancer_prostata",
      "mort_cancer_boca_orofaringe_laringe",         "mort_cancer_bexiga",
      "mort_cancer_linfoma_ou_leucemia",             "mort_cancer_cerebro",
      "mort_cancer_ovario",                          "mort_cancer_tireoide",
      "mort_diagnostico_doenca_chagas",              "mort_diagnostico_dst_ist",
      "antrop_imc"
    )

  gc()

  append_flag <- FALSE

  morb_prevalencias <-
    tibble(
      sexo = character(),
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
          "morb_prevalencias.csv"
        ),
        arg_append = append_flag
      )

    morb_prevalencias <-
      bind_rows(
        morb_prevalencias,
        aux
      )

    append_flag <- TRUE
  } # for(var in VARS)

} # if(PNS2019_PREVALENCES_DATA)


if(PNS2019_PREVALENCES_PLOT){
  dodge_spacing <- 0.7
  
  morb_prevalencias_data |>
    filter(
      subgrp != "categ_ouvinte",
      !is.na(cid10_cap)
    ) |> 
    ggplot(
      aes(
        x = doenca, 
        y = p, 
        color = subgrp,
        shape = subgrp
      )
    ) +
    geom_point(
      position = position_dodge(width = dodge_spacing), 
      size = 2
    ) +
    geom_errorbar(
      aes(ymin = p_low, ymax = p_upp), 
      position = position_dodge(width = dodge_spacing), 
      width = 0.2
    ) +
    facet_wrap(cid10_cap ~ sexo, scales = "free") + 
    coord_flip() +
    scale_y_continuous(labels = scales::percent_format(accuracy = 1)) +
    scale_shape_manual(values = c(0, 1, 2, 8)) +
    theme_bw() +
    theme(
      legend.position = "bottom",
      aspect.ratio = 0.6
    ) +
    labs(
      x = "Variável PNS",
      y = "Prevalência (p)",
      color = "Subgrupo",
      shape = "Subgrupo"
    )

}  
