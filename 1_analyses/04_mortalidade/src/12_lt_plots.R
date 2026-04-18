
VARS <- 
  c(
    'mort_lt_2000_deficiente_auditivo_female',
    'mort_lt_2000_deficiente_auditivo_male',
    'mort_lt_2000_surdocego_female',
    'mort_lt_2000_surdocego_male',
    'mort_lt_2000_surdo_female',
    'mort_lt_2000_surdo_male',
    'mort_lt_2010_deficiente_auditivo_female',
    'mort_lt_2010_deficiente_auditivo_male',
    'mort_lt_2010_surdocego_female',
    'mort_lt_2010_surdocego_male',
    'mort_lt_2010_surdo_female',
    'mort_lt_2010_surdo_male'
  )

aux_lt <- tibble(
  x.int = as.character(),
  x = as.numeric(),
  mx = as.numeric(),
  qx = as.numeric(),
  ax = as.numeric(),
  lx = as.numeric(),
  dx = as.numeric(),
  Lx = as.numeric(),
  Tx = as.numeric(),
  ex = as.numeric(),
  key = as.character()
)

for(arg_var in VARS){

  aux_lt <- 
    bind_rows(
      aux_lt,
      read_csv(paste0(results_dir, arg_var, ".csv"), show_col_types = FALSE) |>
        mutate(key = arg_var)
    )

}

lt_data <- 
  aux_lt |> 
  extract(
    key, 
    into = c("year", "subgrp", "sex"), 
    regex = "mort_lt_(\\d{4})_(.*)_(male|female)$"
  ) |>
  mutate(
    sex = case_match(
      sex,
      'female' ~ 'Feminino',
      'male' ~ 'Masculino'
    ),
    subgrp = case_match(
      subgrp,
      'deficiente_auditivo' ~ 'Deficiente Auditivo',
      'surdo' ~ 'Surdo',
      'surdocego' ~ 'Surdocego'
    ),
    year = as.character(year),
    year = case_match(
      year,
      '2000' ~ 'Censo 2000',
      '2010' ~ 'Censo 2010'
    )
  )

lt_plot <-
  lt_data |>
  mutate(
    log_qx = log(qx)
  ) |>
  ggplot( 
    aes(x=x, y=log_qx, color = subgrp, linetype=sex)  
  ) + 
  geom_line(size=0.5) + 
  facet_grid(. ~ year) + 
  labs(
    x = "Idade em anos completos (x)",
    y = expression(log(q[x])),
    color = "Categoria",
    linetype = "Sexo"
  ) + 
  theme(
    legend.position = 'top',
    legend.box = 'vertical'
  ) 
  
  
  ggsave(
    filename = paste0(results_dir, "mort_lt.pdf"),
    plot = lt_plot,
    width = 6,
    height = 4
  )
  
