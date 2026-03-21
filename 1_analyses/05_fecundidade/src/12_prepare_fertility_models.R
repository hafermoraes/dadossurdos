
fecund_data_relational_models <-
  bind_rows(
    censos_elbadry |> 
      filter(subgrp != 'total', subgrp != 'ouvinte', fx_idade != '10-14') |>
      group_by(ano, subgrp, fx_idade) |>
      summarise(
        m = sum(nr_mulheres, na.rm=TRUE),
        fnv = sum(filhos_nascidos_vivos*nr_mulheres, na.rm=TRUE),
        f12m = sum(filhos_ultimos_12meses*nr_mulheres, na.rm=TRUE),
        Pi = sum(filhos_nascidos_vivos*nr_mulheres, na.rm=TRUE) / sum(nr_mulheres, na.rm=TRUE),
        .groups = 'drop'
      ),
    # Linhas de totais
    censos_elbadry |>
      filter(subgrp != 'total', subgrp != 'ouvinte', fx_idade != '10-14') |>
      mutate(fx_idade = 'Total') |>
      group_by(ano, subgrp, fx_idade) |>
      summarise(
        m = sum(nr_mulheres, na.rm=TRUE),
        fnv = sum(filhos_nascidos_vivos*nr_mulheres, na.rm=TRUE),
        f12m = sum(filhos_ultimos_12meses*nr_mulheres, na.rm=TRUE),
        Pi = NA_real_,
        .groups = 'drop'
      )
  )


fecund_data_relational_models_wide <-
  fecund_data_relational_models |>
  mutate(
    subgrp = case_match(
      subgrp,
      'deficiente_auditivo' ~ 'Deficiente Auditivo',
      'surdo' ~ 'Surdo',
      'surdocego' ~ 'Surdocego',
      'ouvinte' ~ 'Ouvinte'
    )
  ) |>
  pivot_wider(
    id_cols = c(subgrp,fx_idade),
    names_from = ano,
    values_from = c(m,fnv,f12m),
    names_glue = '{.value}_{ano}',
    values_fn = \(x) round(x,0)
  ) |> 
  select(
    subgrp, fx_idade,
    m_2000, fnv_2000, f12m_2000,
    m_2010, fnv_2010, f12m_2010
  ) |>
  arrange(subgrp, fx_idade)


res_table <-
  fecund_data_relational_models_wide |>
  group_by(subgrp) |>
  mutate(
    n_linhas = n(),
    row_idx = row_number(),
    # Identifica se é a linha do Total para inserir o prefixo
    prefixo_total = if_else(fx_idade == "Total", "\\cmidrule(lr){2-8} ", ""),
    # Constrói a primeira coluna combinando o prefixo (cmidrule) com a lógica do multirow
    subgrp_new = case_when(
      row_idx == 1 & n_linhas == 1 ~ paste0("\\midrule ", prefixo_total, subgrp),
      row_idx == 1 ~ paste0("\\midrule ", prefixo_total, "\\multirow{", n_linhas, "}{=}{", subgrp, "}"),
      TRUE ~ prefixo_total # Se for a linha do Total (mas não a primeira), o subgrp recebe apenas o cmidrule
    ),
    across(where(is.numeric), \(x) format(round(x, 0), big.mark='.', decimal.mark=','))
  ) |>
  ungroup() |>
  mutate(
    subgrp = if_else(row_number() == 1, sub("\\\\midrule ", "", subgrp_new), subgrp_new)
  ) |>
  select(subgrp, fx_idade, everything(), -n_linhas, -row_idx, -subgrp_new, -prefixo_total)


res_latex <- xtable::xtable(res_table)

tab_out <- 
  capture.output(
    print(
      res_latex, 
      include.rownames = FALSE, 
      include.colnames = FALSE,
      only.contents = TRUE,
      sanitize.text.function = identity,
      hline.after = NULL
    )
  )

idx <- max(which(grepl("\\\\\\\\", tab_out)))

tab_out[idx] <- sub("\\\\\\\\\\s*$", "", tab_out[idx])

cat(
  tab_out, 
  sep = "\n", 
  file = paste0(
    results_dir,
    "fec_data_relational_models.tex"
  )
)




tic()
message("preparando dados para P/F de Brass...")
for(arg_categ in c('surdo','surdocego','deficiente_auditivo')){
  for(arg_ano in c(2000,2010)){
    
    fecund_data_relational_models |>
      filter(ano == arg_ano, subgrp == arg_categ) |>
      transmute(
        idade = fx_idade,
        mulheres = round(m, 0),
        nasc.v = round(fnv, 0),
        nasc.12 = round(f12m, 0)
      ) |>
      write_tsv(
        file = paste0(
          results_dir,
          'fec_dados_PFbrass_', arg_categ, '_', arg_ano, '.txt'
        )
      )
  } # for(arg_ano in c(2000,2010))
} # for(arg_categ in c('surdo','surdocego','deficiente_auditivo'))
toc()


tic()
message("preparando dados para Gompertz Relacional Modificado...")
for(arg_categ in c('surdo','surdocego','deficiente_auditivo')){
  for(arg_ano in c(2000,2010)){
    
    bind_rows(
      tribble(
        ~Idade, ~Pi, ~TEF,
        '10-14', NA_real_, NA_real_,
      ),
      fecund_data_relational_models |>
        filter(ano == arg_ano, subgrp == arg_categ, fx_idade != 'Total') |>
        transmute(
          Idade = if_else(fx_idade=='Total', NA_character_, fx_idade),
          Pi = round(Pi, 3),
          TEF = round( f12m / m, 3)
        ),
      # Linha dos Totais
      fecund_data_relational_models |>
        filter(ano == arg_ano, subgrp == arg_categ, fx_idade != 'Total') |>
        transmute(
          Idade = NA_character_,
          Pi = NA_real_,
          TEF = round( 5.0 * sum(f12m/m), 3)
        ) |>
        unique()
    ) |>
      write_tsv(
        file = paste0(
          results_dir,
          'fec_dados_GompertzRelMod_', arg_categ, '_', arg_ano, '.txt'
        )
      )
  } # for(arg_ano in c(2000,2010))
} # for(arg_categ in c('surdo','surdocego','deficiente_auditivo'))
toc()



tic()
message("preparando dados para Gompertz Relacional Sintético...")
for(arg_categ in c('surdo','surdocego','deficiente_auditivo')){

    bind_rows(
      tribble(
        ~Idades, ~Pm1, ~Pm2, ~f1, ~f2,
        '10-14', NA_real_, NA_real_, NA_real_, NA_real_,
      ),
      fecund_data_relational_models |>
        filter(ano == 2000 | ano == 2010, subgrp == arg_categ, fx_idade != 'Total') |>
        mutate(
          Fi = f12m / m
        ) |>
        pivot_wider(
          id_cols = c(fx_idade),
          names_from = ano,
          values_from = c(Pi,Fi)
        ) |>
        mutate(
          across( where(is.numeric), \(x) round(x, 4))
        ) |>
        rename(
          Idades = fx_idade,
          Pm1 = Pi_2000,
          Pm2 = Pi_2010,
          f1 = Fi_2000,
          f2 = Fi_2010
        ),
      # Linha dos Totais
      tribble(
        ~Idades, ~Pm1, ~Pm2, ~f1, ~f2,
        '50+', NA_real_, NA_real_, NA_real_, NA_real_,
      )
    ) |>
      write_tsv(
        file = paste0(
          results_dir,
          'fec_dados_GompertzSintetico_2000_2010_', arg_categ, '.txt'
        )
      )
} # for(arg_categ in c('surdo','surdocego','deficiente_auditivo'))
toc()


fec_models_output_file <- 
  paste0(
    results_dir,
    "fec_data_asfr_relational_models.csv"
  )

asfrs_tmp <-
  fecund_data_relational_models |> 
  filter(fx_idade != 'Total') |>
  transmute(
    subgrp, fx_idade, ano, 
    key = 'original',
    value = f12m / m
  )

bind_rows(
  asfrs_tmp,
  asfrs_tmp |>
    group_by(subgrp, ano, key) |>
    summarise(
      tfr = 5.0 * sum(value),
      .groups = 'drop'
    ) |>
    transmute(
      subgrp, fx_idade = 'total', ano, key, value = tfr
    )
  ) |>
  write_csv(
    fec_models_output_file,
    append = FALSE
  )
