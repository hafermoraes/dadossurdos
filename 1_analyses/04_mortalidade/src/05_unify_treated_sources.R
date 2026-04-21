
tic("Construindo tabela de idade simples para pirâmides etárias")
piramides_mortalidade_aux <-
  bind_rows(
    censo2000_mortalidade,
    censo2010_mortalidade,
    pns2019_mortalidade,
    expand_grid(
      subgrp = c('total', 'ouvinte','deficiente_auditivo','surdo','surdocego'),
      ano = c(2000,2010,2019),
      sexo = c('feminino','masculino'),
      idade = 0:139,
      n = 0
    )
  ) |>
  group_by(subgrp,ano,sexo,idade) |>
  summarise(n_original=sum(n), .groups = 'drop') |>
  arrange(subgrp,ano,sexo,idade)
toc()



tic("Calculando os índices de atração (Whipple, Myers)...")
agepyramid_idxs <-
  piramides_mortalidade_aux |>
  group_by(subgrp,ano,sexo) |>
  complete(idade = 23:82, fill = list(n = 0)) |>
  summarise(
    idx_myers = check_heaping_myers(
      Value = n_original,
      Age=idade,
      ageMin=23,
      ageMax=82,
      details=FALSE,
      method = 'orig'
    ),
    idx_whipple = check_heaping_whipple(
      Value = n_original,
      Age=idade,
      ageMin=23,
      ageMax=82,
      digit = c(0,5)
    ),
    dec_myers = case_when(
      idx_myers <= 4.9 ~ 'baixo',
      idx_myers <= 14.09 ~ 'mediano',
      idx_myers <= 29.9 ~ 'alto',
      idx_myers > 29.9 ~ 'muito alto'
    ),
    dec_whipple = case_when( # https://pt.wikipedia.org/wiki/%C3%8Dndice_de_Whipple
      idx_whipple <= 1.049 ~ 'mínima',
      idx_whipple <= 1.099 ~ 'pequena',
      idx_whipple <= 1.249 ~ 'média',
      idx_whipple <= 1.749 ~ 'grande',
      idx_whipple > 1.749  ~ 'muito grande'
    ),
    whipple = paste0(
      '\\makecell{',
      format(round(idx_whipple,3), decimal.mark=',', big.mark='.', nsmall=3),
      '\\\\ ',
      '\\textcolor{\\cor}{(', dec_whipple, ')}',
      '}'
    ),
    myers = paste0(
      '\\makecell{',
      format(round(idx_myers,3), decimal.mark=',', big.mark='.', nsmall=3),
      '\\\\ ',
      '\\textcolor{\\cor}{(', dec_myers, ')}',
      '}'
    )
  ) |>
  select(subgrp, ano, sexo, myers, whipple) |>
  pivot_wider(
    id_cols = c(subgrp, sexo),
    names_from = ano,
    values_from = c(myers,whipple),
    names_glue = '{.value}_{ano}'
  ) |>
  filter(subgrp != 'total') 


df_export <- 
  agepyramid_idxs |>
  mutate(
    subgrp = case_match(
      subgrp,
      'deficiente_auditivo' ~ 'Deficiente Auditivo',
      'surdo' ~ 'Surdo',
      'surdocego' ~ 'Surdocego',
      'ouvinte' ~ 'Ouvinte'
    )
  ) |>
  ungroup() |>
  arrange(subgrp, sexo) |>
  mutate(
    ## subgrp = ifelse(duplicated(subgrp), "", 
    ##                 paste0("\\midrule \\multirow{2}{*}{", subgrp, "}")),
    subgrp = case_when(
      duplicated(subgrp) ~ "",
      row_number() == 1  ~ paste0("\\multirow{2}{=}{", subgrp, "}"),
      TRUE               ~ paste0("\\midrule \\multirow{2}{=}{", subgrp, "}")
    ),
    sexo = ifelse(sexo=='feminino', 'Feminino', 'Masculino')
  )

tab_string <- capture.output(
  print(xtable(df_export), 
        include.rownames = FALSE, 
        include.colnames = FALSE, 
        only.contents = TRUE, 
        hline.after = NULL, 
        sanitize.text.function = identity,
        comment = FALSE)
)

tab_string <- tab_string[trimws(tab_string) != ""]

n_linhas <- length(tab_string)

tab_string[n_linhas] <- trimws(tab_string[n_linhas], which = "right")

tab_string[n_linhas] <- sub("\\\\\\\\$", "", tab_string[n_linhas])

writeLines(
  tab_string, 
  paste0(results_dir, "agepyramid_idxs.tex")
)
toc()







tic()
message("tábuas de vida suavizadas 5-5 anos...")

piramides_mortalidade_sprague <- 
  piramides_mortalidade_aux |>
  # 1. Preparação: garantir idades completas (0-80+) para cada grupo
  group_by(subgrp, ano, sexo) |>
  complete(idade = 0:max(idade), fill = list(n_original = 0)) |>
  arrange(idade) |>
  # 2. Agrupamento (Abridging): Sprague exige dados em grupos de 5 anos
  mutate(idade_5 = (idade %/% 5) * 5) |>
  group_by(subgrp, ano, sexo, idade_5) |>
  summarise(n_grupo = sum(n_original), .groups = "drop") |>
  # 3. Graduação de Sprague: expande de grupos de 5 anos para idades simples suavizadas
  group_by(subgrp, ano, sexo) |>
  reframe(
    # Sprague retorna idades simples; reframe permite aumentar o número de linhas
    n_sprague = graduate(
      Value = n_grupo, 
      Age = idade_5, 
      method = "sprague"
    ),
    # Cria o vetor de idades simples correspondente ao retorno do graduate
    idade = 0:(length(n_sprague) - 1)
  ) |>
  ungroup()
toc()


piramides_mortalidade <- 
  piramides_mortalidade_aux |>
  left_join(piramides_mortalidade_sprague) |>
  mutate(
    across(
      where(is.numeric), 
      ~round(replace_na(.x, 0), 3)
    )
  )


tic(
  paste0("exportando dados tratados em disco na pasta", data_dir)
)
piramides_mortalidade |>
  write_csv(
    paste0(
      data_dir,
      "piramides_etarias_mortalidade.csv"
    )
  )
toc()


