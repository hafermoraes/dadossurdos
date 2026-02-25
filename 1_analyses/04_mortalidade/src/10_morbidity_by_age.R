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


VARS <-
  c(
    "mort_diagnostico_depressão",       "mort_diagnostico_doenca_mental"
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

