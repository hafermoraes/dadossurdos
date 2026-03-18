
fecund_data_relational_models <-
  bind_rows(
    censos_elbadry |>
      filter(subgrp != 'total', subgrp != 'ouvinte', fx_idade != '10-14') |>
      group_by(ano, subgrp, fx_idade) |>
      summarise(
        m = sum(nr_mulheres, na.rm=TRUE),
        fnv = sum(filhos_nascidos_vivos*nr_mulheres, na.rm=TRUE),
        f12m = sum(filhos_ultimos_12meses*nr_mulheres, na.rm=TRUE)
      ),
      # Linhas de totais
      censos_elbadry |>
        filter(subgrp != 'total', subgrp != 'ouvinte', fx_idade != '10-14') |>
        mutate(fx_idade = 'Total') |>
        group_by(ano, subgrp, fx_idade) |>
        summarise(
          m = sum(nr_mulheres, na.rm=TRUE),
          fnv = sum(filhos_nascidos_vivos*nr_mulheres, na.rm=TRUE),
          f12m = sum(filhos_ultimos_12meses*nr_mulheres, na.rm=TRUE)
        )
   ) |>
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
  fecund_data_relational_models |>
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


