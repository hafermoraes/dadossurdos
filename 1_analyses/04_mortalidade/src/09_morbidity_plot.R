
VARS <-
  c(
    ,       ,
    ,            ,
    "mort_diagnostico_reumatismo",                 "mort_diagnostico_dort",
    ,                  ,
    ,            ,
    ,                      ,
    
    
  )




# Rótulos para os gráficos
cid10_cap_ix <- "Cap. IX - Aparelho Circulatório (28,4% dos Óbitos)"
cid10_cap_ii <- "Cap. II - Neoplasias (14,4% dos Óbitos)"
cid10_cap_x  <- "Cap. X  - Aparelho Respitarório (9,9% dos Óbitos)"
cid10_cap_iv <- "Cap. IV - Endócrinas, nutricionais e metabólicas (5,5% dos Óbitos)"
cid10_cap_v  <- "Cap. V  - Transtornos mentais (0,9% dos óbitos)"
cid10_cap_i  <- "Cap. I  - Infecciosas e parasitárias (4,5%)"

morb_prevalencias_data <-
  morb_prevalencias |>
  mutate(
    doenca = case_when(
      # Capítulo IX - Aparelho Circulatório
      var == "mort_diagnostico_hipertensao_arterial"  ~ "Hipertensão Arterial",
      var == "mort_diagnostico_cardiopatia"           ~ "Cardiopatia",
      var == "mort_cardiopata_infarto"                ~ "Infarto",
      var == "mort_cardiopata_angina"                 ~ "Angina",
      var == "mort_cardiopata_insuficiencia_cardiaca" ~ "Insuficiência Cardíaca",
      var == "mort_cardiopata_arritmia"               ~ "Arritmia",
      var == "mort_diagnostico_avc"                   ~ "AVC",
      # Cap. II - Neoplasias
      var == "mort_diagnostico_cancer"                ~ "Câncer",
      var == "mort_cancer_pele"                       ~ "Câncer de pele",
      var == "mort_cancer_pulmao"                     ~ "Câncer de pulmão",
      var == "mort_cancer_intestino"                  ~ "Câncer de intestino",
      var == "mort_cancer_estomago"                   ~ "Câncer de estômago",
      var == "mort_cancer_mama"                       ~ "Câncer de mama",
      var == "mort_cancer_colon_utero"                ~ "Câncer de cólon/útero",
      var == "mort_cancer_prostata"                   ~ "Câncer de próstata",
      var == "mort_cancer_boca_orofaringe_laringe"    ~ "Câncer de boca/orofaringe/laringe",
      var == "mort_cancer_bexiga"                     ~ "Câncer de bexiga",
      var == "mort_cancer_linfoma_ou_leucemia"        ~ "Câncer de linfoma/leucemia",
      var == "mort_cancer_cerebro"                    ~ "Câncer de cérebro",
      var == "mort_cancer_ovario"                     ~ "Câncer de ovário",
      var == "mort_cancer_tireoide"                   ~ "Câncer de tireoide",
      # Cap. X - Aparelho Respiratório
      var == "mort_diagnostico_asma"                  ~ "Asma",
      var == "mort_diagnostico_doenca_pulmonar"       ~ "Doença pulmonar",
      var == "mort_doenca_pulmonar_enfisema"          ~ "Enfisema",
      var == "mort_doenca_pulmonar_bronquite_cronica" ~ "Bronquite crônica",
      # Cap. IV - Endócrinas, nutricionais e metabólicas
      var == "mort_diagnostico_diabetes"              ~ "Diabetes",
      var == "mort_diagnostico_colesterol_alto"       ~ "Colesterol alto",
      var == "antrop_imc"                             ~ "IMC",
      # # Cap. V - Transtornos Mentais
      # var == "mort_diagnostico_depressão"             ~ "Depressão",
      # var == "mort_diagnostico_doenca_mental"         ~ "Transtorno mental",
      # var == "mort_doenca_mental_esquizofrenia"       ~ "Esquizofrenia",
      # var == "mort_doenca_mental_transtorno_bipolar"  ~ "Transtorno Bipolar",
      # var == "mort_doenca_mental_toc"                 ~ "TOC",
      # # Cap. I - Infecciosas e Parasitárias
      # var == "mort_diagnostico_doenca_chagas"         ~ "Doença de chagas",
      # var == "mort_diagnostico_dst_ist"               ~ "ISTs",
      TRUE ~ NA_character_
      
    ),
    cid10_cap = case_when(
      # Capítulo IX - Aparelho Circulatório
      var == "mort_diagnostico_hipertensao_arterial"  ~ cid10_cap_ix,
      var == "mort_diagnostico_cardiopatia"           ~ cid10_cap_ix,
      var == "mort_cardiopata_infarto"                ~ cid10_cap_ix,
      var == "mort_cardiopata_angina"                 ~ cid10_cap_ix,
      var == "mort_cardiopata_insuficiencia_cardiaca" ~ cid10_cap_ix,
      var == "mort_cardiopata_arritmia"               ~ cid10_cap_ix,
      var == "mort_diagnostico_avc"                   ~ cid10_cap_ix,
      # Cap. II - Neoplasias
      var == "mort_diagnostico_cancer"                ~ cid10_cap_ii,
      var == "mort_cancer_pele"                       ~ cid10_cap_ii,
      var == "mort_cancer_pulmao"                     ~ cid10_cap_ii,
      var == "mort_cancer_intestino"                  ~ cid10_cap_ii,
      var == "mort_cancer_estomago"                   ~ cid10_cap_ii,
      var == "mort_cancer_mama"                       ~ cid10_cap_ii,
      var == "mort_cancer_colon_utero"                ~ cid10_cap_ii,
      var == "mort_cancer_prostata"                   ~ cid10_cap_ii,
      var == "mort_cancer_boca_orofaringe_laringe"    ~ cid10_cap_ii,
      var == "mort_cancer_bexiga"                     ~ cid10_cap_ii,
      var == "mort_cancer_linfoma_ou_leucemia"        ~ cid10_cap_ii,
      var == "mort_cancer_cerebro"                    ~ cid10_cap_ii,
      var == "mort_cancer_ovario"                     ~ cid10_cap_ii,
      var == "mort_cancer_tireoide"                   ~ cid10_cap_ii,
      # Cap. X - Aparelho Respiratório
      var == "mort_diagnostico_asma" ~ cid10_cap_x,
      var == "mort_diagnostico_doenca_pulmonar"       ~ cid10_cap_x,
      var == "mort_doenca_pulmonar_enfisema"          ~ cid10_cap_x,
      var == "mort_doenca_pulmonar_bronquite_cronica" ~ cid10_cap_x,
      # Cap. IV - Endócrinas, nutricionais e metabólicas
      var == "mort_diagnostico_diabetes"              ~ cid10_cap_iv,
      var == "mort_diagnostico_colesterol_alto"       ~ cid10_cap_iv,
      var == "antrop_imc"                             ~ cid10_cap_iv,
      # # Cap. V - Transtornos Mentais
      # var == "mort_diagnostico_depressão"             ~ cid10_cap_v,
      # var == "mort_diagnostico_doenca_mental"         ~ cid10_cap_v,
      # var == "mort_doenca_mental_esquizofrenia"       ~ cid10_cap_v,
      # var == "mort_doenca_mental_transtorno_bipolar"  ~ cid10_cap_v,
      # var == "mort_doenca_mental_toc"                 ~ cid10_cap_v,
      # # Cap. I - Infecciosas e Parasitárias
      # var == "mort_diagnostico_doenca_chagas"         ~ cid10_cap_i,
      # var == "mort_diagnostico_dst_ist"               ~ cid10_cap_i,
      TRUE ~ NA_character_
    )
  ) 
  

morb_prevalencias_data |>
  drop_na() |>
  select(cid10_cap, doenca, subgrp, sexo, p) |> 
  pivot_wider(
    id_cols = c(cid10_cap, doenca),
    names_from = c(sexo, subgrp),
    values_from = p
  ) |> 
  transmute(
    cid10_cap, doenca,
    f_rp_surdo = feminino_categ_surdo / feminino_categ_total,
    f_rp_surdocego = feminino_categ_surdocego / feminino_categ_total,
    f_rp_deficiente_auditivo = feminino_categ_deficiente_auditivo / feminino_categ_total,
    m_rp_surdo = masculino_categ_surdo / masculino_categ_total,
    m_rp_surdocego = masculino_categ_surdocego / masculino_categ_total,
    m_rp_deficiente_auditivo = masculino_categ_deficiente_auditivo / masculino_categ_total
  ) |> 
  arrange(cid10_cap, doenca) |>
  mutate(
    across(
      contains("_rp_"), 
      ~ ifelse(is.na(.), "-", format(round(., 2), nsmall = 2))
    )
  ) |>
  group_by(cid10_cap) |> 
  mutate(
    n_total = n(),
    # Escapa o % para \% antes de montar a estrutura do LaTeX
    cid10_cap_clean = gsub("%", "\\\\%", cid10_cap),
    cid10_cap_latex = ifelse(
      row_number() == 1, 
      paste0(
        "\\makecell[{{m{3.5cm}}}]{",
        "\\multirow{", 
        n_total, 
        "}{=}{", 
        cid10_cap_clean, 
        "}}"
        ),
      ""
    ),
    is_last = row_number() == n()
  ) |> 
  ungroup() |> 
  select(cid10_cap_latex, doenca, contains("_rp_"), is_last) |>
  mutate(
    row_idx = row_number(),
    line_str = apply(across(1:8), 1, paste, collapse = " & "),
    latex_line = case_when(
      row_idx == n() ~ paste0(line_str, " \\\\ \\bottomrule"),
      is_last ~ paste0(line_str, " \\\\ \\midrule"),
      TRUE ~ paste0(line_str, " \\\\")
    )
  ) |> 
  pull(latex_line) |> 
  # # Converte para as linhas do LaTeX
  # apply(1, function(x) {
  #   # x[1:8] são os dados, x[9] é o marcador is_last
  #   dados <- paste(x[1:8], collapse = " & ")
  #   if (as.logical(x[9])) {
  #     paste0(dados, " \\\\ \\midrule")
  #   } else {
  #     paste0(dados, " \\\\")
  #   }
  # }) |> 
  writeLines(
    paste0(
      results_dir,
      "mort_razoes_prevalencia.tex"
    )
  )

  
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
