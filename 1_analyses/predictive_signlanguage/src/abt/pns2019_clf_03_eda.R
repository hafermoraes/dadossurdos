
# importação da matriz de modelo
pre_modelmatrix <-
  read_csv(
    '1_analyses/predictive_signlanguage/data/pns2019_pre_modelmatrix.csv'
  ) |> 
  mutate(
    instrucao = case_when(
      is.na(instrucao) ~ 'outros',
      TRUE ~ as.character(instrucao)
    ),
    dif_ouvir = case_when(
      is.na(dif_ouvir) ~ 'nenhuma',
      TRUE ~ as.character(dif_ouvir)
    ),    
    dif_enxergar = case_when(
      is.na(dif_enxergar) ~ 'nenhuma',
      TRUE ~ as.character(dif_enxergar)
    ),    
    dif_locomover = case_when(
      is.na(dif_locomover) ~ 'nenhuma',
      TRUE ~ as.character(dif_locomover)
    ),    
    across(where(is.character), as.factor),
    instrucao = factor(instrucao, levels=c('fundamental','medio','superior','outros')),
    dif_ouvir = factor(dif_ouvir, levels=c('nenhuma','alguma','grande','incapaz')),
    dif_enxergar = factor(dif_enxergar, levels=c('nenhuma','alguma','grande','incapaz')),
    dif_locomover = factor(dif_locomover, levels=c('nenhuma','alguma','grande','incapaz')),
  )

print("Glimpse of pre-EDA data")
pre_modelmatrix |> 
  glimpse() 

print("Class imbalance for response variable libras (g05801): ")
# TODO exportar para LaTeX
pre_modelmatrix |>
  group_by(libras) |>
  summarise( n =sum(case_weights)) |>
  mutate( pct = n/sum(n)) |>
  print()

# mosaic plots

# libras vs dif_ouvir
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(dif_ouvir), 
      fill=libras
      )
  ) + 
  coord_flip() + 
  labs(title='f(dif_ouvir)')

pre_modelmatrix |>
  group_by(dif_ouvir) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))


pre_modelmatrix |> 
  select(libras, case_weights, !where(is.numeric)) |>
  mutate(
    libras = if_else( libras == 'sim', 1, 0)
  ) |> 
  drop_na() |>
  pivot_longer(-c('libras','case_weights'), names_to = "key", values_to = "value") |> 
  group_by(key, value) |>
  summarise(
    n = sum(case_weights),
    l = sum(libras*case_weights),
    p = sum(libras*case_weights)/sum(case_weights),
    conf_int = 1.96*sqrt(p*(1-p)/n)
  ) |> 
  filter(key == 'dif_ouvir')


# libras vs dif_enxergar
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(dif_enxergar), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  labs(title='f(dif_enxergar)')

# libras vs dif_locomover
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(dif_locomover), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  
  labs(title='f(dif_locomover)')

# libras vs instrucao
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(instrucao), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  
  labs(title='f(instrucao)')

pre_modelmatrix |>
  group_by(instrucao) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))

# libras vs alfabetizado
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(alfabetizado), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  
  labs(title='f(alfabetizado)')

pre_modelmatrix |>
  group_by(alfabetizado) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))


# libras vs sexo
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(sexo), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  
  labs(title='f(sexo)')

pre_modelmatrix |>
  group_by(sexo) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))


# libras vs cor_raca
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(cor_raca), 
      fill=libras
    )
  ) + 
  labs(title='f(cor_raca)') +
  coord_flip()

pre_modelmatrix |>
  group_by(cor_raca) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))


# libras vs estado_civil
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(estado_civil), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  
  labs(title='f(estado_civil)')

pre_modelmatrix |>
  group_by(estado_civil) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))


# libras vs uf
ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(uf), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  labs(title='f(uf)')

# libras vs idade
ggplot(data = pre_modelmatrix) + 
  geom_boxplot( aes(x = libras, y=idade, fill = libras))

ggplot(data = pre_modelmatrix) +
  geom_mosaic(
    aes(
      weights = case_weights, 
      x = product(idade), 
      fill=libras
    )
  ) + 
  coord_flip() + 
  labs(title='f(idade)')

ggplot(data = pre_modelmatrix) +
  geom_density( aes(x=idade, fill = libras), alpha = 0.2) + 
  facet_wrap( ~ dif_ouvir)

ggplot(data = pre_modelmatrix) +
  geom_density( aes(x=idade, fill = libras), alpha = 0.2)


# facets com geom_errorbar
# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
pre_modelmatrix |>
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

# correlações

# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
recipe(libras ~ ., data = pre_modelmatrix) |>
  step_naomit(all_factor_predictors()) |>
  step_dummy(all_nominal_predictors()) |>
  step_rm(case_weights, starts_with("uf")) |>
  prep(pre_modelmatrix) |> 
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
