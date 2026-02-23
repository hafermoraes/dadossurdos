
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
    "mort_diagnostico_doenca_chagas",              "mort_diagnostico_dst_ist"#,
    #"antrop_imc"
  )


VARS <-
  c(
    "mort_diagnostico_hipertensao_arterial",       "mort_diagnostico_diabetes",
    "mort_diagnostico_colesterol_alto",            "mort_diagnostico_cardiopatia",
    "mort_diagnostico_avc",                        "mort_diagnostico_asma",
    "mort_diagnostico_reumatismo",                 "mort_diagnostico_dort",
    "mort_diagnostico_depressão",                  "mort_diagnostico_doenca_mental",
    "mort_diagnostico_doenca_pulmonar",
    "mort_diagnostico_cancer",
    "mort_diagnostico_doenca_chagas",              "mort_diagnostico_dst_ist"
  )

dodge_spacing <- 0.7

morb_prevalencias |>
  filter(subgrp != "categ_total") |> 
  filter(var %in% VARS) |>
  #filter(var %in% "antrop_imc") |>
  ggplot(
    aes(
      x = var, 
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
