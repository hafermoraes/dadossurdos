
eda_path <-
  paste0(
    base_dir,
    "eda/"
  )

# importação da matriz de modelo
pre_modelmatrix <-
  pre_modelmatrix |>
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

print("EDA Table")
pct <- 
  pre_modelmatrix |>
  group_by(dif_ouvir) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct_total=count/sum(count)) |>
  select(-count)

n_total_aux <- 
  pre_modelmatrix |> 
  select(case_weights, !where(is.numeric)) |>
  drop_na() |>
  pivot_longer(-c('case_weights'), names_to = "key", values_to = "value") |> 
  group_by(key) |>
  summarise(
    n_total = sum(case_weights)
  )

pct_total <- 
  pre_modelmatrix |> 
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
  pre_modelmatrix |> 
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
  format.args = list(big.mark = ".", decimal.mark = ","),
  file=paste0(eda_path, "eda_table.tex")
)

print("Class imbalance for response variable libras (g05801): ")
# TODO exportar para LaTeX
pre_modelmatrix |>
  group_by(libras) |>
  summarise( n =sum(case_weights)) |>
  mutate( pct = n/sum(n)) |>
  print()

# mosaic plots

# libras vs dif_ouvir
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_dif_ouvir.pdf"),
    width=12,
    height=8
  )


# libras vs dif_enxergar
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_dif_enxergar.pdf"),
    width=12,
    height=8
  )



# libras vs dif_locomover
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_dif_locomover.pdf"),
    width=12,
    height=8
  )


# libras vs instrucao
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_instrucao.pdf"),
    width=12,
    height=8
  )


# libras vs alfabetizado
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_alfabetizado.pdf"),
    width=12,
    height=8
  )

# libras vs sexo
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_sexo.pdf"),
    width=12,
    height=8
  )



# libras vs cor_raca
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_cor_raca.pdf"),
    width=12,
    height=8
  )


# libras vs estado_civil
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_estado_civil.pdf"),
    width=12,
    height=8
  )

# libras vs uf
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_uf.pdf"),
    width=12,
    height=8
  )


# libras vs idade
(
  ggplot(data = pre_modelmatrix) + 
  geom_boxplot( aes(x = libras, y=idade, fill = libras))
) |>
  ggsave(
    filename = paste0(eda_path, "eda_boxplot_idade.pdf"),
    width=12,
    height=8
  )

(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_mosaic_idade.pdf"),
    width=12,
    height=8
  )

(
  ggplot(data = pre_modelmatrix) +
    geom_density( aes(x=idade, fill = libras), alpha = 0.2) + 
    facet_wrap( ~ dif_ouvir)
) |>
  ggsave(
    filename = paste0(eda_path, "eda_density_idade.pdf"),
    width=12,
    height=8
  )


# facets com geom_errorbar
# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_facet.pdf"),
    width=12,
    height=8
  )


# correlações

# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
(
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
) |>
  ggsave(
    filename = paste0(eda_path, "eda_corr_plot.pdf"),
    width=12,
    height=8
  )

