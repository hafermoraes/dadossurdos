if(PNS2019_PREVALENCES_BY_AGE_DATA){
  
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

  morb_prevalencias_fx_idade <-
    tibble(
      sexo = character(),
      n = numeric(),
      n_low = numeric(),
      n_upp = numeric(),
      p = numeric(),
      p_low = numeric(),
      p_upp = numeric(),
      subgrp = character(),
      var = character(),
      fx_idade = character()
    )

  for(var in VARS){

    gc()

    aux <-
      prevalence_by_agegrp(
        arg_var = var,
        arg_output_file = paste0(
          results_dir,
          "morb_prevalencias_fx_idade.csv"
        ),
        arg_append = append_flag
      )

    morb_prevalencias_fx_idade <-
      bind_rows(
        morb_prevalencias_fx_idade,
        aux
      )

    append_flag <- TRUE
  }
} # if(PNS2019_PREVALENCES_BY_AGE_DATA)

if(PNS2019_PREVALENCES_BY_AGE_PLOT){
  dodge_spacing <- 0.7

  morb_prevalencias_fx_idade |> 
    filter(
      !is.na(p),
      subgrp != "categ_total"
    ) |> 
    ggplot(
      aes(
        x = fx_idade,
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
      aes(
        ymin = p_low,
        ymax = p_upp
      ), 
      position = position_dodge(width = dodge_spacing), 
      width = 0.2
    ) +
    facet_wrap(
      ~var,
      scales = "free",
      labeller = as_labeller(function(x) {
        x |>
          str_remove("mort_diagnostico_") |>
          str_replace_all("_", " ") |>
          str_to_sentence()}
        )
    ) +
    scale_y_continuous(labels = scales::percent) +
    coord_flip() +
    scale_color_viridis_d(option = "plasma", end = 0.7) +
    #scale_color_brewer(palette = "Dark2")+
    #theme_minimal() +
    theme(legend.position = "bottom") +
    labs(
      x = "Faixa Etária",
      y = "Prevalência (%)",
      color = "Subgrupo",
      shape = "Subgrupo"
    )

  
} # if(PNS2019_PREVALENCES_BY_AGE_PLOT)


