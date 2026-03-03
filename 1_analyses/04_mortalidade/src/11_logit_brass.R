
tic()
message("garbage collection preventivo para impedir interrupção do R por falta de memória...")
gc()
toc()


tic()
message("reclassificando os capítulos do CID-19 na análise de pareto com os dados do SIM/Datasus...")
# Rótulos para os gráficos
cid10_cap_ix <- "Cap. IX - Aparelho Circulatório (28,4% dos Óbitos)"
cid10_cap_ii <- "Cap. II - Neoplasias (14,4% dos Óbitos)"
cid10_cap_x  <- "Cap. X  - Aparelho Respitarório (9,9% dos Óbitos)"
cid10_cap_iv <- "Cap. IV - Endócrinas, nutricionais e metabólicas (5,5% dos Óbitos)"
cid10_cap_v  <- "Cap. V  - Transtornos mentais (0,9% dos óbitos)"
cid10_cap_i  <- "Cap. I  - Infecciosas e parasitárias (4,5%)"
toc()

tic()
message("relendo do disco e transformando os dados da análise de pareto...")
morb_prevalencias <-
  read_csv(
    paste0(
      results_dir,
      "morb_prevalencias.csv"
    ),
    show_col_types = FALSE
  ) |>
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
      var == "mort_diagnostico_asma"                  ~ cid10_cap_x,
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
toc()


tic()
message("análise das razões de prevalência (estimação de \alpha...)")

message("criação do tibble 'morb_prevalencias_data'...")
morb_prevalencias_data <-
  morb_prevalencias |>
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
    m_rp_surdo = masculino_categ_surdo / masculino_categ_total,
    f_rp_surdocego = feminino_categ_surdocego / feminino_categ_total,
    m_rp_surdocego = masculino_categ_surdocego / masculino_categ_total,
    f_rp_deficiente_auditivo = feminino_categ_deficiente_auditivo / feminino_categ_total,
    m_rp_deficiente_auditivo = masculino_categ_deficiente_auditivo / masculino_categ_total
  ) |> 
  arrange(cid10_cap, doenca)
toc()


tic()
message("exportando a tabela de prevalências para estimar \alpha em disco...")
morb_prevalencias_data |>
  mutate(
    across(
      contains("_rp_"),
      ~ ifelse(is.na(.), "-", round(., 2))
    )
  ) |>
  mutate(across(contains("_rp_"), ~ map_chr(., get_gradient_color))) |>
  group_by(cid10_cap) |> 
  mutate(
    n_total = n(),
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
  writeLines(
    paste0(
      results_dir,
      "mort_razoes_prevalencia.tex"
    )
  )
toc()



tic()
message("tratando os dados para a análise de prioris de \alpha...")
mort_priors_alpha <-
  morb_prevalencias_data |>
  pivot_longer(
    -c(cid10_cap, doenca)
  ) |>
  drop_na() |>
  mutate(
    name = str_replace(name, "f_rp_", "feminino_"),
    name = str_replace(name, "m_rp_", "masculino_")
  ) |>
  separate(name, into = c("sex", "category"), sep = "_", extra = "merge") |>
  group_by(sex, category) |>
  summarise(
    # paramétrico
    mean = mean(value, na.rm=TRUE),
    sd = sd(value, na.rm=TRUE),
    # não paramétrico
    median = median(value, na.rm = TRUE),
    mad = mad(value, na.rm = TRUE),
    iqr = IQR(value, na.rm=TRUE)
  ) |>
  ungroup() |>
  transmute(
    sex, category, alpha_mu = median, alpha_sd = mad
  )
toc()




tic()
message("tratando os dados para a análise de prioris de \beta...")
mort_beta_data <-
  bind_rows(
    censo2000_mortalidade |> mutate(src = 'censo2000'),
    censo2010_mortalidade |> mutate(src = 'censo2010'),
    pns2019_mortalidade |> mutate( src = 'pns2019')
  ) |>
  filter(!(subgrp %in% c('ouvinte'))) |>
  mutate(
    ind_65mais = ifelse( idade >= 65, 1, 0),
    ind_15_64 = ifelse( (idade > 14) & (idade < 65) , 1, 0)
  ) |>
  group_by(
    src, subgrp, sexo
  ) |>
  summarise(
    im = sum( idade * n) / sum(n),
    rdi = sum( ind_65mais * idade * n) / sum( ind_15_64 * idade * n)
  ) |>
  pivot_longer(
    -c(src,subgrp,sexo)
  ) |>
  pivot_wider(
    id_cols = c(src,sexo),
    names_from = c(subgrp, name),
    names_glue = "{subgrp}_{name}",
    values_from = "value"
  ) |> 
  transmute(
    src, sexo,
    im_surdo = surdo_im / total_im,
    im_da = deficiente_auditivo_im / total_im,
    im_surdocego = surdocego_im / total_im,
    rdi_surdo = surdo_rdi / total_rdi,
    rdi_da = deficiente_auditivo_rdi / total_rdi,
    rdi_surdocego = surdocego_rdi / total_rdi
  ) |>
  pivot_longer(
    cols = -c(src, sexo)
  ) |>
  separate(name, into = c("index", "category"), sep = "_", extra = "merge") |>
  pivot_wider(
    id_cols = c(sexo,category),
    names_from = c(index, src),
    values_from = value
  ) |>
  mutate(
    category = case_match(
      category,
      "surdo" ~ "Surdo",
      "surdocego" ~ "Surdocego",
      "da" ~ "Deficiente Auditivo"
    )
  ) |>
  arrange( sexo, category) |>
  ungroup() |>
  select(sexo, category, starts_with("im"), starts_with("rdi"))
toc()


tic()
message("prioris para \beta...")
mort_priors_beta <-
  mort_beta_data |>
    pivot_longer(
      cols = -c(sexo, category)
    ) |>
    filter(
      grepl("^im_", name)
    ) |>
    group_by( sexo, category) |>
    summarise(
      median = median( value, na.rm=TRUE),
      mad = mad(value, na.rm=TRUE)
    ) |>
    ungroup() |>
    rename(
      sex = sexo,
      beta_mu = median,
      beta_sd = mad
    ) |>
    mutate(
      category = case_match(
        category,
        "Surdo" ~ "surdo",
        "Surdocego" ~ "surdocego",
        "Deficiente Auditivo" ~ "deficiente_auditivo"
      )
  )
toc()




tic()
message("exportando a tabela de prioris de \beta em disco...")
mort_beta_data |>
  mutate(
    across(where(is.numeric), ~ ifelse(is.na(.), "-", round(., 3))),
    across(where(is.numeric), ~ map_chr(., get_gradient_color)),
    is_last = row_number() == n()
  ) |>
  ungroup() |>
  mutate(
    sexo = case_when(
      row_number() == 1 ~ "\\multirow{3}{=}{Feminino}",
      row_number() == 4 ~ "\\multirow{3}{=}{Masculino}",
      TRUE ~ ""
    )
  ) |>
  mutate(
    line_str = paste(
      sexo, 
      category, 
      apply(across(3:8), 1, paste, collapse = " & "), 
      sep = " & "
    ),
    latex_line = case_when(
      row_number() == 3 ~ paste0(line_str, " \\\\ \\midrule"),    # Fim do feminino
      row_number() == n() ~ paste0(line_str, " "), # Fim da tabela
      TRUE ~ paste0(line_str, " \\\\")                             # Linhas comuns
    )
  ) |> 
  pull(latex_line) |>
  writeLines(
    paste0(
      results_dir,
      "mort_beta_summary.tex"
    )
  )
toc()


tic()
message("criando a lista de prioris por categoria e por sexo...")
mort_brass_logit_priors <-
  list(
    surdo = list(
      male = list(
        alpha = list(
          mu = mort_priors_alpha |> filter( sex == 'masculino', category == 'surdo') |> pull(alpha_mu),
          sd = mort_priors_alpha |> filter( sex == 'masculino', category == 'surdo') |> pull(alpha_sd)
        ),
        beta  = list(
          mu = mort_priors_beta |> filter( sex == 'masculino', category == 'surdo') |> pull(beta_mu),
          sd = mort_priors_beta |> filter( sex == 'masculino', category == 'surdo') |> pull(beta_sd)
        )
      ), # surdo/male
      female = list(
        alpha = list(
          mu = mort_priors_alpha |> filter( sex == 'feminino', category == 'surdo') |> pull(alpha_mu),
          sd = mort_priors_alpha |> filter( sex == 'feminino', category == 'surdo') |> pull(alpha_sd)
        ),
        beta  = list(
          mu = mort_priors_beta |> filter( sex == 'feminino', category == 'surdo') |> pull(beta_mu),
          sd = mort_priors_beta |> filter( sex == 'feminino', category == 'surdo') |> pull(beta_sd)
        )
      ) # surdo/female
    ), # surdo
    surdocego = list(
      male = list(
        alpha = list(
          mu = mort_priors_alpha |> filter( sex == 'masculino', category == 'surdocego') |> pull(alpha_mu),
          sd = mort_priors_alpha |> filter( sex == 'masculino', category == 'surdocego') |> pull(alpha_sd)
        ),
        beta  = list(
          mu = mort_priors_beta |> filter( sex == 'masculino', category == 'surdocego') |> pull(beta_mu),
          sd = mort_priors_beta |> filter( sex == 'masculino', category == 'surdocego') |> pull(beta_sd)
        )
      ), # surdocego/male
      female = list(
        alpha = list(
          mu = mort_priors_alpha |> filter( sex == 'feminino', category == 'surdocego') |> pull(alpha_mu),
          sd = mort_priors_alpha |> filter( sex == 'feminino', category == 'surdocego') |> pull(alpha_sd)
        ),
        beta  = list(
          mu = mort_priors_beta |> filter( sex == 'feminino', category == 'surdocego') |> pull(beta_mu),
          sd = mort_priors_beta |> filter( sex == 'feminino', category == 'surdocego') |> pull(beta_sd)
        )
      ) # surdocego/female
    ), # surdocego
    deficiente_auditivo = list(
      male = list(
        alpha = list(
          mu = mort_priors_alpha |> filter( sex == 'masculino', category == 'deficiente_auditivo') |> pull(alpha_mu),
          sd = mort_priors_alpha |> filter( sex == 'masculino', category == 'deficiente_auditivo') |> pull(alpha_sd)
        ),
        beta  = list(
          mu = mort_priors_beta |> filter( sex == 'masculino', category == 'deficiente_auditivo') |> pull(beta_mu),
          sd = mort_priors_beta |> filter( sex == 'masculino', category == 'deficiente_auditivo') |> pull(beta_sd)
        )
      ), # deficiente_auditivo/male
      female = list(
        alpha = list(
          mu = mort_priors_alpha |> filter( sex == 'feminino', category == 'deficiente_auditivo') |> pull(alpha_mu),
          sd = mort_priors_alpha |> filter( sex == 'feminino', category == 'deficiente_auditivo') |> pull(alpha_sd)
        ),
        beta  = list(
          mu = mort_priors_beta |> filter( sex == 'feminino', category == 'deficiente_auditivo') |> pull(beta_mu),
          sd = mort_priors_beta |> filter( sex == 'feminino', category == 'deficiente_auditivo') |> pull(beta_sd)
        )
      ) # deficiente_auditivo/female
    ) # deficiente_auditivo
  )
toc()


tic()
message("exportando tabela de prioris em disco para latex...")
OUTPUT_FILE <- paste0(results_dir, "mort_priors_table.tex")

cat('\n% Tabela de prioris para a análise do logito de Brass\n', file = OUTPUT_FILE, append=FALSE)

cat(
  paste0(
    '\\multirow{3}{=}{Feminino} & ',
    'Surdo & ',
    formata_br(mort_brass_logit_priors$surdo$female$alpha$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdo$female$alpha$sd),
    ' & ',
    formata_br(mort_brass_logit_priors$surdo$female$beta$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdo$female$beta$sd),
    ' \\\\ '
  ),
  file = OUTPUT_FILE,
  sep = '\n',
  append=TRUE
)

cat(
  paste0(
    ' & ',
    'Surdocego & ',
    formata_br(mort_brass_logit_priors$surdocego$female$alpha$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdocego$female$alpha$sd),
    ' & ',
    formata_br(mort_brass_logit_priors$surdocego$female$beta$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdocego$female$beta$sd),
    ' \\\\ '
  ),
  file = OUTPUT_FILE,
  sep = '\n',
  append=TRUE
)

cat(
  paste0(
    ' & ',
    'Deficiente Auditivo & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$female$alpha$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$female$alpha$sd),
    ' & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$female$beta$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$female$beta$sd),
    ' \\\\ \\midrule '
  ),
  file = OUTPUT_FILE,
  sep = '\n',
  append=TRUE
)

cat(
  paste0(
    '\\multirow{3}{=}{Masculino} & ',
    'Surdo & ',
    formata_br(mort_brass_logit_priors$surdo$male$alpha$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdo$male$alpha$sd),
    ' & ',
    formata_br(mort_brass_logit_priors$surdo$male$beta$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdo$male$beta$sd),
    ' \\\\ '
  ),
  file = OUTPUT_FILE,
  sep = '\n',
  append=TRUE
)

cat(
  paste0(
    ' & ',
    'Surdocego & ',
    formata_br(mort_brass_logit_priors$surdocego$male$alpha$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdocego$male$alpha$sd),
    ' & ',
    formata_br(mort_brass_logit_priors$surdocego$male$beta$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$surdocego$male$beta$sd),
    ' \\\\ '
  ),
  file = OUTPUT_FILE,
  sep = '\n',
  append=TRUE
)

cat(
  paste0(
    ' & ',
    'Deficiente Auditivo & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$male$alpha$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$male$alpha$sd),
    ' & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$male$beta$mu),
    ' & ',
    formata_br(mort_brass_logit_priors$deficiente_auditivo$male$beta$sd),
    ' \\\\ \\bottomrule '
  ),
  file = OUTPUT_FILE,
  sep = '\n',
  append=TRUE
)
toc()




tic()
message("iniciando as análises do logito de brass...")

message("baixando os arquivos de https://www.lifetable.de/File/GetDocument/data/BRA/BRA.zip ...") 

temp <- tempfile()
download.file("https://www.lifetable.de/File/GetDocument/data/BRA/BRA.zip", temp)

bra_lt <- 
  read_csv(
    unz(temp, "BRA.csv"),
    show_col_types = FALSE
  ) |>
  transmute(
    type = case_when(
      TypeLT == 4 ~ 'abridged',
      TypeLT == 1 ~ 'unabridged',
      TRUE ~ NA_character_
    ),
    year = Year1,
    sex = ifelse(Sex==1, 'male', 'female'),
    x = Age, 
    n = AgeInt, 
    mx = `m(x)`,
    qx = `q(x)`,
    lx = `l(x)`, 
    dx = `d(x)`, 
    Lx = `L(x)`,
    Tx = `T(x)`,
    ex = `e(x)`,
    ex_orig = `e(x)Orig`
  )

unlink(temp)
rm(temp)
toc()

mort_male_censo2000 <-
  bra_lt |> 
  filter(sex=='male', type == 'abridged', year==2000)
  

output <-
  LifeTable(
    x = mort_male_censo2000$x,
    lx = mort_male_censo2000$lx,
    lx0 = 1e5
  )

# ex para simulações de monte carlo
output$lt[1,'ex']


# priors

mort_priors[["surdo"]][["alpha"]][["median"]]

mort_priors[["surdo"]][["alpha"]][["mad"]]

mort_priors$surdo$alpha$mad
