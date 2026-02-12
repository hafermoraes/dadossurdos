
microdados <-
  microdados_dt |>
  mutate(
    across(where(is.character), as.factor),
    instrucao = factor(instrucao, levels=c('outros','fundamental','medio','superior')),
    dif_ouvir = factor(dif_ouvir, levels=c('nenhuma','alguma','grande','incapaz')),
    dif_enxergar = factor(dif_enxergar, levels=c('nenhuma','alguma','grande','incapaz')),
    dif_locomover = factor(dif_locomover, levels=c('nenhuma','alguma','grande','incapaz')),
    libras_01 = ifelse(libras=='sim',1,0)
  )


## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <-
  survey::svydesign(
    ids = ~upa_pns, 
    strata = ~v0024, 
    data = microdados, 
    weights = ~v0029, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00293=as.character(unique(microdados$v00293)), 
    Freq=as.numeric(unique(microdados$v00292))
  )
popc.types <- popc.types[order(popc.types$v00293),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00293, 
    population=popc.types
  )




# quantidade de pessoas
svytotal(
  ~libras,
  design=pns2019_posterior
)

# número de pessoas segundo a PNS 2019 que sabem libras no brasil  
pns2019_n_libras <-
  pns2019_posterior |>
  as_survey() |>
  summarise(
    n = survey_total(libras_01, na.rm = TRUE, vartype=c('se','ci'))
  ) |>
  mutate(
    across(
      everything(),
      label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")
    )
  )
pns2019_n_libras
paste0("(erro padrão: ", pns2019_n_libras$n_se, ", IC 95%: [", pns2019_n_libras$n_low, "; ", pns2019_n_libras$n_upp, "])")

# percentual de pessoas segundo a PNS 2019 que sabem libras no brasil  
pns2019_pct_libras <-
  pns2019_posterior |>
  as_survey() |>
  summarise(
    pct = survey_mean(libras_01, na.rm = TRUE, vartype=c('se','ci'))
  ) |>
  mutate(
    across(
      everything(),
      label_percent(accuracy = 0.01, big.mark = ".", decimal.mark = ",")
    )
  )
pns2019_pct_libras
paste0("(erro padrão: ", pns2019_pct_libras$pct_se, ", IC 95%: [", pns2019_pct_libras$pct_low, "; ", pns2019_pct_libras$pct_upp, "])")


# svyby(
#   formula=~libras,
#   by=~dif_ouvir,
#   FUN=svymean,
#   design=pns2019_posterior
# )

# svytable(
#   formula=~dif_ouvir+libras,
#   design=pns2019_posterior
# )


eda_vars <-
  pns2019_posterior |>
  as_survey() |>
  group_by(dif_ouvir) |>
  summarise(
    n = survey_total(na.rm = TRUE, vartype = 'ci'),
    l = survey_total(libras_01, na.rm = TRUE, vartype = 'ci'),
    p = survey_mean(libras_01, na.rm = TRUE, vartype = 'ci')
  ) |>
  mutate(
    var = 'dif_ouvir',
    across( 
      c(
        n, n_low, n_upp,
        l, l_low, l_upp
      ), 
      label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")
    ),
    across( 
      c(p, p_low, p_upp), 
      label_percent(accuracy = 0.1, big.mark = ".", decimal.mark = ",")
    )
  ) |>
  rename(level = 1) |>
  transmute(
    var,
    level,
    n,
    n_95ci = paste0("[", n_low, "; ", n_upp, "]"),
    l,
    l_95ci = paste0("[", l_low, "; ", l_upp, "]"),
    p,
    p_95ci = paste0("[", p_low, "; ", p_upp, "]")
  )




eda_vars <-
  pns2019_posterior |>
  as_survey() |>
  group_by(dif_ouvir) |>
  summarise(
    n = survey_total(na.rm = TRUE, vartype = 'ci'),
    l = survey_total(libras, na.rm = TRUE, vartype = 'ci'),
    p = survey_mean(libras, na.rm = TRUE, vartype = 'ci')
  ) |>
  mutate(
    var = 'dif_ouvir',
    across( 
      c(
        n, n_low, n_upp,
        l, l_low, l_upp
        ), 
      label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")
    ),
    across( 
      c(p, p_low, p_upp), 
      label_percent(accuracy = 0.1, big.mark = ".", decimal.mark = ",")
    )
  ) |>
  rename(level = 1) |>
  transmute(
    var,
    level,
    n,
    n_95ci = paste0("[", n_low, "; ", n_upp, "]"),
    l,
    l_95ci = paste0("[", l_low, "; ", l_upp, "]"),
    p,
    p_95ci = paste0("[", p_low, "; ", p_upp, "]")
  )

eda_vars |>
  View()



print("Glimpse of pre-EDA data")
microdados |> 
  glimpse() 

print("EDA Table")
pct <- 
  microdados |>
  group_by(dif_ouvir) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct_total=count/sum(count)) |>
  select(-count)

n_total_aux <- 
  microdados |> 
  select(case_weights, !where(is.numeric)) |>
  drop_na() |>
  pivot_longer(-c('case_weights'), names_to = "key", values_to = "value") |> 
  group_by(key) |>
  summarise(
    n_total = sum(case_weights)
  )

pct_total <- 
  microdados |> 
  select(case_weights, !where(is.numeric)) |>
  drop_na() |>
  pivot_longer(-c('case_weights'), names_to = "key", values_to = "value") |> 
  group_by(key, value) |>
  summarise(
    n = sum(case_weights)
  ) |>
  left_join(n_total_aux) |>
  transmute(
    key,
    value,
    pct_total = n/n_total
  )

eda_table <-
  microdados |> 
  select(libras, case_weights, !where(is.numeric)) |>
  mutate(
    libras = if_else( libras == 'sim', 1, 0)
  ) |> 
  drop_na() |>
  pivot_longer(-c('libras','case_weights'), names_to = "key", values_to = "value") |> 
  group_by(key, value) |>
  summarise(
    n_total = sum(case_weights),
    n_libras = sum(libras*case_weights),
    pct_libras = sum(libras*case_weights)/sum(case_weights),
    errpd_pct_libras = sqrt(pct_libras*(1-pct_libras)/n_total)
  ) |> 
  left_join(pct_total) |>
  # filter(key == 'dif_ouvir') |>
  select(key, value, n_total, pct_total, n_libras, pct_libras, errpd_pct_libras) |> 
  mutate(
    n_total = format(round(n_total,0), big.mark = ".", decimal.mark=","),
    n_libras = format(round(n_libras,0), big.mark = ".", decimal.mark=","),
    pct_total = round(100*pct_total, 2),
    pct_libras = round(100*pct_libras, 2),
    errpd_pct_libras = round(errpd_pct_libras, 6)
  ) 

# eda_table |> View()

print(
  xtable( 
    eda_table, 
    digits = c(
      0, # row name
      0, # key
      0, # value
      0, # n_total
      2, # pct_total
      0, # n_libras
      2, # pct_libras
      6 # errpd_pct_libras
      )
    ),
  sanitize.text.function = identity,
  only.contents=TRUE,
  include.rownames=FALSE,
  include.colnames=TRUE,
  hline.after=NULL,
  comment=FALSE,
  format.args=list(big.mark = ".", decimal.mark = ","),
  file=paste0(
    eda_dir,
    "eda_table.tex"
  )
)

print("Class imbalance for response variable libras (g05801): ")
# TODO exportar para LaTeX
microdados |>
  group_by(libras) |>
  summarise( n =sum(case_weights)) |>
  mutate( pct = n/sum(n)) |>
  print()

# mosaic plots

# libras vs dif_ouvir
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(dif_ouvir), 
        fill=libras
        )
    ) + 
    coord_flip() + 
    labs(title='f(dif_ouvir)') 
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_dif_ouvir.pdf"
    ),
    width=12,
    height=8
  )


# libras vs dif_enxergar
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(dif_enxergar), 
        fill=libras
      )
    ) + 
    coord_flip() + 
    labs(title='f(dif_enxergar)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_dif_enxergar.pdf"
    ),
    width=12,
    height=8
  )



# libras vs dif_locomover
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(dif_locomover), 
        fill=libras
      )
    ) + 
    coord_flip() + 
    labs(title='f(dif_locomover)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_dif_locomover.pdf"
    ),
    width=12,
    height=8
  )


# libras vs instrucao
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(instrucao), 
        fill=libras
      )
    ) + 
    coord_flip() + 
    labs(title='f(instrucao)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_instrucao.pdf"
    ),
    width=12,
    height=8
  )


# libras vs alfabetizado
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(alfabetizado), 
        fill=libras
      )
    ) + 
    coord_flip() +
    labs(title='f(alfabetizado)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_alfabetizado.pdf"
    ),
    width=12,
    height=8
  )

# libras vs sexo
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(sexo), 
        fill=libras
      )
    ) + 
    coord_flip() + 
    labs(title='f(sexo)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_sexo.pdf"
    ),
    width=12,
    height=8
  )



# libras vs cor_raca
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(cor_raca), 
        fill=libras
      )
    ) + 
    labs(title='f(cor_raca)') +
    coord_flip()
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_cor_raca.pdf"
    ),
    width=12,
    height=8
  )


# libras vs estado_civil
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(estado_civil), 
        fill=libras
      )
    ) + 
    coord_flip() + 
    labs(title='f(estado_civil)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_estado_civil.pdf"
    ),
    width=12,
    height=8
  )

# libras vs uf
(
  ggplot(data = microdados) +
    geom_mosaic(
      aes(
        weights = case_weights, 
        x = product(uf), 
        fill=libras
      )
    ) + 
    coord_flip() + 
    labs(title='f(uf)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_uf.pdf"
    ),
    width=12,
    height=8
  )


# libras vs idade
(
  ggplot(data = microdados) + 
  geom_boxplot( aes(x = libras, y=idade, fill = libras))
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_boxplot_idade.pdf"
    ),
    width=12,
    height=8
  )

(
  ggplot(data = microdados) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(idade), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  labs(title='f(idade)')
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_mosaic_idade.pdf"
    ),
    width=12,
    height=8
  )

(
  ggplot(data = microdados) +
    geom_density( aes(x=idade, fill = libras), alpha = 0.2) + 
    facet_wrap( ~ dif_ouvir)
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_density_idade.pdf"
    ),
    width=12,
    height=8
  )


# facets com geom_errorbar
# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
(
  microdados |>
  select(libras, case_weights, !where(is.numeric)) |>
  mutate(
    libras = if_else( libras == 'sim', 1, 0)
  ) |> 
  drop_na() |>
  pivot_longer(-c('libras','case_weights'), names_to = "key", values_to = "value") |> 
  group_by(key, value) |>
  summarise(
    n = sum(case_weights),
    p = sum(libras*case_weights)/sum(case_weights),
    conf_int = 1.96*sqrt(p*(1-p)/n)
  ) |> 
  ggplot(aes(x=value, y=p, color=value)) +
  geom_point() +
  geom_errorbar(aes(ymin = p - conf_int, ymax = p + conf_int), width = 0.1) +
  theme(legend.position = "none") + 
  scale_color_viridis_d(aesthetics = c("color", "fill"), end = 0.5) +
  facet_wrap(~key, scales = 'free') +
  labs(title = 'Categorical Variable Analysis', subtitle = 'With 95% Confidence Intervals') + 
  coord_flip()
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_facet.pdf"
    ),
    width=12,
    height=8
  )


# correlações

# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
(
  recipe(libras ~ ., data = microdados) |>
    step_naomit(all_factor_predictors()) |>
    step_dummy(all_nominal_predictors()) |>
    step_rm(case_weights, starts_with("uf")) |>
    prep(microdados) |> 
    bake(new_data = NULL) |> 
    mutate(
      libras = if_else( libras == 'sim', 1, 0)
    ) |> 
    correlate() |>
    shave() |>
    rplot( print_cor = T) +
    # scale_color_gradient2(low = 'orange', high = 'light blue') + 
    theme(axis.text.x = element_text(angle = 90)) +
    labs(title = "Correlation Plot")
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_corr_plot.pdf"
    ),
    width=12,
    height=8
  )

