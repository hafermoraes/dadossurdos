
# ajuste el badry para remover informações inconsistentes
# isso introduzirá NAs nos dados originais para não mexermos nos totais
tmp <-
  censos_fecundidade |>
  group_by(subgrp, ano, fx_idade, fx_idade_elb, filhos_nascidos_vivos) |>
  summarise(
    n_old = round(sum(nr_mulheres),0), 
    .groups = 'drop'
  ) |>
  mutate(
    aux = as.numeric(sub(".*-", "", fx_idade)) + 1,
    n_new = if_else( 
      filhos_nascidos_vivos > 2.0/3.0 * aux - 8.0, 
      0, 
      n_old
    ),
    nas = n_old - n_new
  )

n_na <- 
  tmp |>
  group_by( subgrp, ano, fx_idade, fx_idade_elb) |>
  summarise(na_count = sum(nas), .groups = "drop") |>
  transmute(
    subgrp, ano, fx_idade, fx_idade_elb,
    filhos_nascidos_vivos = NA_real_,
    n = na_count
  )
  
n_new <-
  tmp |>
  group_by( subgrp, ano, fx_idade, fx_idade_elb, filhos_nascidos_vivos) |>
  summarise(n = sum(n_new), .groups = "drop")


elbadry <-
  bind_rows(
    n_new,
    n_na
  )


assert_that(
  all.equal(
    tolerance = 0.0001,
    censos_fecundidade |>
      group_by(subgrp, ano, fx_idade, fx_idade_elb) |>
      summarise(n = sum(nr_mulheres), .groups = "drop"),
    elbadry |>
      group_by(subgrp, ano, fx_idade, fx_idade_elb) |>
      summarise(n = sum(n), .groups = "drop")
  )
)


tic()
message("Gráfico confirmatório da necessidade (ou não) de ajustar os dados com El Badry")

plot_data <-
  elbadry |> 
  filter(
    subgrp %in% c('deficiente_auditivo','surdo','surdocego'), 
    fx_idade != "10-14"
  ) |>
  mutate(
    missing = if_else( is.na(filhos_nascidos_vivos), "sim", "nao"),
    subgrp = recode(
      subgrp,
      "deficiente_auditivo" = "Deficiente Auditivo",
      "surdo" = "Surdo",
      "surdocego" = "Surdocego"
    )
  ) |>
  group_by(subgrp, ano, fx_idade, missing) |>
  summarise(n=sum(n)) |>
  pivot_wider(
    id_cols = c(subgrp, ano, fx_idade),
    names_from = missing,
    values_from = n
  ) |>
  mutate(
    pct_missing = sim/(sim+nao)
  ) 

plot_elbadry <- 
  plot_data |>
  ggplot(
    aes(x=fx_idade, y=pct_missing)
  ) + 
  geom_col() + 
  scale_y_continuous(labels = scales::percent) + 
  geom_hline(yintercept = 0.02, linetype = "dashed", color = "red", linewidth = 0.5) +
  facet_grid(ano ~ subgrp) + 
  labs(
    x = "Faixa etária das mulheres",
    y = "Percentual de linhas ausentes (missings)"
  )

ggsave(
  filename = paste0(
    results_dir,
    "fec_elbadry.pdf"
  ),
  plot = plot_elbadry,
  width = 12,
  height = 8
)

toc()


tic()
message("exportando tabelas de ajuste el badry...")
elbadry_upper_latex <-
  tmp |>
  transmute(
    subgrp,
    ano,
    fx_idade,
    linha = filhos_nascidos_vivos,
    latex = case_when(
      nas != 0 ~ paste0(
        "$\\cancelto{0}{", 
        format(round( nas,0), big.mark = ".", decimal.mark = ",", trim=TRUE), 
        "}$"
      ),
      TRUE ~ format(round( n_new, 0), big.mark = ".", decimal.mark = ",", trim=TRUE)
    )
  ) |>
  pivot_wider(
    id_cols = c(ano,subgrp, linha),
    names_from = fx_idade,
    values_from = latex,
    values_fill = '0'
  ) |>
  arrange(ano,subgrp,linha) |>
  select(-`10-14`)


elbadry_na <-
  n_na |>
  transmute(
    subgrp,
    ano,
    fx_idade,
    linha = "Desconhecido",
    latex = format(round( n, 0), big.mark = ".", decimal.mark = ",", trim=TRUE)
  ) |>
  pivot_wider(
    id_cols = c(ano,subgrp, linha),
    names_from = fx_idade,
    values_from = latex,
    values_fill = '0'
  ) |>
  arrange(ano,subgrp,linha) |>
  select(-`10-14`)


elbadry_N <-
  elbadry |>
  group_by(subgrp,ano,fx_idade) |>
  summarise( 
    N = sum(n, na.rm=TRUE), 
    .groups = "drop"
  ) |>
  mutate(
    linha = "Total",
    N = format(round(N, 0), decimal.mark = ",", big.mark = ".")
  ) |>
  pivot_wider(
    id_cols = c(ano,subgrp, linha),
    names_from = fx_idade,
    values_from = N,
    values_fill = '0'
  ) |>
  arrange(ano,subgrp,linha) |>
  select(-`10-14`)



elbadry_na_pct <-
  n_na |>
  transmute(
    subgrp,
    ano,
    fx_idade,
    na = n
  ) |>
  left_join(
    elbadry |> group_by(subgrp,ano,fx_idade)|>summarise(N=sum(n), .groups="drop")
  ) |>
  mutate(
    pct_na = na/N,
    pct_na = paste0(format(round(pct_na*100, 3), decimal.mark = ",", big.mark = "."), "\\%"),
    linha = "Proporção desconhecido"
  ) |> 
  pivot_wider(
    id_cols = c(ano,subgrp, linha),
    names_from = fx_idade,
    values_from = pct_na,
    values_fill = '0'
  ) |>
  arrange(ano,subgrp,linha) |>
  select(-`10-14`)


elbadry_zero_pct <-
  elbadry |>
  filter(filhos_nascidos_vivos==0) |>
  transmute(
    subgrp,
    ano,
    fx_idade,
    z = n
  ) |>
  left_join(
    elbadry |> group_by(subgrp,ano,fx_idade)|>summarise(N=sum(n), .groups="drop")
  ) |>
  mutate(
    pct_z = z/N,
    pct_z = paste0(format(round(pct_z*100, 2), decimal.mark = ",", big.mark = "."), "\\%"),
    linha = "Proporção sem filhos"
  ) |> 
  pivot_wider(
    id_cols = c(ano,subgrp, linha),
    names_from = fx_idade,
    values_from = pct_z,
    values_fill = '0'
  ) |>
  arrange(ano,subgrp,linha) |>
  select(-`10-14`)


elbadry_avg_parity <-
  elbadry |>
  mutate(
    num = filhos_nascidos_vivos * n
  ) |>
  group_by(subgrp,ano,fx_idade) |>
  summarise( 
    Pi = sum(num, na.rm=TRUE) / sum(n, na.rm=TRUE), 
    .groups = "drop"
  ) |>
  mutate(
    linha = "Paridade média",
    Pi = format(round(Pi, 4), decimal.mark = ",", big.mark = ".")
  ) |>
  pivot_wider(
    id_cols = c(ano,subgrp, linha),
    names_from = fx_idade,
    values_from = Pi,
    values_fill = '0'
  ) |>
  arrange(ano,subgrp,linha) |>
  select(-`10-14`)
  
toc()







tic()
message("exportando el badry para latex em disco...")

for(arg_ano in c(2000,2010)){
  for(arg_categ in c('total','ouvinte','surdo','deficiente_auditivo','surdocego')){
    
    arg_append <- FALSE

    message("tabela ajuste elbadry para ", arg_categ, " ano ", arg_ano)
    elbadry_upper_latex |>
      filter(
        ano == arg_ano,
        subgrp == arg_categ
      ) |>
      transmute(
        linha_latex = paste(linha,`15-19`,`20-24`,`25-29`,`30-34`,`35-39`,`40-44`,`45-49`, sep = " & ")
      ) |> 
      pull(linha_latex) |> 
      paste(collapse = " \\\\\n") |> 
      cat(
        file = paste0(
          results_dir,
          "fec_table_elbadry_",
          arg_ano,
          "_",
          arg_categ,
          ".tex"
        ), 
        append = arg_append
      )

    arg_append <- TRUE

    cat(
      "\\\\\n\n",
      file = paste0(
        results_dir,
        "fec_table_elbadry_",
        arg_ano,
        "_",
        arg_categ,
        ".tex"
      ), 
      append = arg_append
    )

    message("linha NA ajuste elbadry para ", arg_categ, " ano ", arg_ano)
    elbadry_na |>
      filter(
        ano == arg_ano,
        subgrp == arg_categ
      ) |>
      transmute(
        linha_latex = paste(linha,`15-19`,`20-24`,`25-29`,`30-34`,`35-39`,`40-44`,`45-49`, sep = " & ")
      ) |> 
      pull(linha_latex) |> 
      paste(collapse = " \\\\\n") |> 
      cat(
        file = paste0(
          results_dir,
          "fec_table_elbadry_",
          arg_ano,
          "_",
          arg_categ,
          ".tex"
        ), 
        append = arg_append
      )




    cat(
      "\\\\\n  \\midrule \n",
      file = paste0(
        results_dir,
        "fec_table_elbadry_",
        arg_ano,
        "_",
        arg_categ,
        ".tex"
      ), 
      append = arg_append
    )

    message("linha Total ajuste elbadry para ", arg_categ, " ano ", arg_ano)
    elbadry_N |>
      filter(
        ano == arg_ano,
        subgrp == arg_categ
      ) |>
      transmute(
        linha_latex = paste(linha,`15-19`,`20-24`,`25-29`,`30-34`,`35-39`,`40-44`,`45-49`, sep = " & ")
      ) |> 
      pull(linha_latex) |> 
      paste(collapse = " \\\\\n") |> 
      cat(
        file = paste0(
          results_dir,
          "fec_table_elbadry_",
          arg_ano,
          "_",
          arg_categ,
          ".tex"
        ), 
        append = arg_append
      )




    cat(
      "\\\\\n  \\midrule \n",
      file = paste0(
        results_dir,
        "fec_table_elbadry_",
        arg_ano,
        "_",
        arg_categ,
        ".tex"
      ), 
      append = arg_append
    )

    message("linha 'Proporção desconhecido' ajuste elbadry para ", arg_categ, " ano ", arg_ano)
    elbadry_na_pct |>
      filter(
        ano == arg_ano,
        subgrp == arg_categ
      ) |>
      transmute(
        linha_latex = paste(linha,`15-19`,`20-24`,`25-29`,`30-34`,`35-39`,`40-44`,`45-49`, sep = " & ")
      ) |> 
      pull(linha_latex) |> 
      paste(collapse = " \\\\\n") |> 
      cat(
        file = paste0(
          results_dir,
          "fec_table_elbadry_",
          arg_ano,
          "_",
          arg_categ,
          ".tex"
        ), 
        append = arg_append
      )




    cat(
      "\\\\\n  \n",
      file = paste0(
        results_dir,
        "fec_table_elbadry_",
        arg_ano,
        "_",
        arg_categ,
        ".tex"
      ), 
      append = arg_append
    )

    message("linha 'Proporção Sem Filhos' ajuste elbadry para ", arg_categ, " ano ", arg_ano)
    elbadry_zero_pct |>
      filter(
        ano == arg_ano,
        subgrp == arg_categ
      ) |>
      transmute(
        linha_latex = paste(linha,`15-19`,`20-24`,`25-29`,`30-34`,`35-39`,`40-44`,`45-49`, sep = " & ")
      ) |> 
      pull(linha_latex) |> 
      paste(collapse = " \\\\\n") |> 
      cat(
        file = paste0(
          results_dir,
          "fec_table_elbadry_",
          arg_ano,
          "_",
          arg_categ,
          ".tex"
        ), 
        append = arg_append
      )




    cat(
      "\\\\\n  \n",
      file = paste0(
        results_dir,
        "fec_table_elbadry_",
        arg_ano,
        "_",
        arg_categ,
        ".tex"
      ), 
      append = arg_append
    )

    message("linha 'Paridade média' ajuste elbadry para ", arg_categ, " ano ", arg_ano)
    elbadry_avg_parity |>
      filter(
        ano == arg_ano,
        subgrp == arg_categ
      ) |>
      transmute(
        linha_latex = paste(linha,`15-19`,`20-24`,`25-29`,`30-34`,`35-39`,`40-44`,`45-49`, sep = " & ")
      ) |> 
      pull(linha_latex) |> 
      paste(collapse = " \\\\\n") |> 
      cat(
        file = paste0(
          results_dir,
          "fec_table_elbadry_",
          arg_ano,
          "_",
          arg_categ,
          ".tex"
        ), 
        append = arg_append
      )

  } # for(arg_categ in c('total','ouvinte','surdo','deficiente_auditivo','surdocego'))
} # for(arg_ano in c(2000,2010))




toc()
