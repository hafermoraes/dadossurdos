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

prevalence_all_ages <- function(arg_var, arg_output_file, arg_append){

  message("calculando prevalência de ",arg_var, "...")

  # (re)inicializa tabela de resultados em branco
  outer_table <-
    tibble(
      n = numeric(),          # número de pessoas com arg_var == 1
      n_low = numeric(),      # limite inferior do número de pessoas com arg_var == 1
      n_upp = numeric(),      # limite superior do número de pessoas com arg_var == 1
      p = numeric(),          # percentual de pessoas com arg_var == 1
      p_low = numeric(),      # limite inferior do percentual de pessoas com arg_var == 1
      p_upp = numeric(),      # limite superior do número de pessoas com arg_var == 1
      subgrp = character(),   # categoria (total/ouvinte/deficiente_auditivo/surdo/surdocego)
      var = character()       # arg_var (atributo mensurado na PNS 2019)
    )

  # itera cada subgrupo de interesse da tese
  SUBGRPS <-
    c(
      "categ_total",
      "categ_ouvinte",
      "categ_surdo",
      "categ_surdocego",
      "categ_deficiente_auditivo"
    )
  
  svy_prop_method <- 'xlogit'

  for(arg_subgrp in SUBGRPS){

    tic()

    message("   para o grupo ", arg_subgrp, "...")

    if(arg_subgrp == 'categ_total'){

      inner_table <-
        pns2019_posterior |>
        as_survey() |>
        summarise(
          n = survey_total(
            .data[[arg_var]],
            na.rm=TRUE,
            vartype='ci'
          ),
          p = survey_mean(
            .data[[arg_var]],
            na.rm=TRUE,
            proportion = TRUE,
            prop_method = svy_prop_method,
            vartype='ci'
          )
        ) |>
        mutate(
          n_low = pmax(0, n_low),
          subgrp = arg_subgrp,
          var = arg_var
        )

    } else {

      inner_table <-
        pns2019_posterior |>
        as_survey() |>
        filter( .data[[arg_subgrp]] == 1) |>
        summarise(
          n = survey_total(
            .data[[arg_var]],
            na.rm=TRUE,
            vartype='ci'
          ),
          p = survey_mean(
            .data[[arg_var]],
            na.rm=TRUE,
            proportion = TRUE,
            prop_method = svy_prop_method,
            vartype='ci'
          )
        ) |>
        mutate(
          n_low = pmax(0, n_low),
          subgrp = arg_subgrp,
          var = arg_var
        )

    } # if(arg_subgrp == 'categ_total')

    outer_table <-
      bind_rows(
        outer_table,
        inner_table
      )

    toc()

    message("     salvando dados de ", arg_var, " em disco em ", arg_output_file, "...")
    inner_table |>
      write_csv(
        file = arg_output_file,
        append = arg_append
      )
    arg_append <- TRUE # sobrescreve arg_append daqui pra frente...
    
  } # for(arg_subgrp in SUBGRPS)

  return(outer_table)

} # prevalence_all_ages <- function(arg_var, output_file, append)


append_flag <- FALSE

morb_prevalencias <-
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
}
