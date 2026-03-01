
tic()
message("preparando dataframe de comparação...")
dist_summary <-
  bind_rows(
    censo2000_dist,
    censo2010_dist,
    pns2019_dist
  ) |>
  mutate(
    value = case_when(
      value == "" ~ 'nao_informado',
      TRUE ~ as.character(value)
    )
  )
toc()


tic()
message("exportando dataframe de comparação em disco...")
dist_summary |>
  write_csv(
    file = paste0(data_dir, "dist_summary.csv")
  )
toc()

tic()
message("preparando tabela de comparação...")
tbl_comparison <- 
  dist_summary |>
  pivot_wider(
    id_cols = c('key', 'value'),
    names_from = 'src',
    values_from = 'pct',
    values_fill = 0
  )
toc()

tic()
message("exportando tabela de comparação no formato LaTeX em disco...")
tbl_reordered <-
  tbl_comparison |> 
  mutate(
    across(
      c(censo2000, censo2010, pns2019), 
      ~sprintf("%.1f%%", . * 100)
    ),
    rank = case_when(
      # reordenamento para 'instrucao'
      value == "outros"        ~ 1,
      value == "fundamental"   ~ 2,
      value == "medio"         ~ 3,
      value == "superior"      ~ 5,
      value == "nao_informado" ~ 6,
      # reordenamento para 'dif_ouvir'
      value == "nenhuma"  ~ 1,
      value == "alguma"   ~ 2,
      value == "grande"   ~ 3,
      value == "incapaz"  ~ 4,
      value == "ignorado" ~ 5,
      # reordenamento para 'faixa_idade'
      value == "0-4"      ~ 1,
      value == "5-9"      ~ 2,
      value == "10-19"    ~ 3,
      value == "20-39"    ~ 4,
      value == "40+"      ~ 5,
      TRUE                ~ 6
    )
  ) |> 
  arrange(key, rank) |>
  mutate(
    value = gsub("___.*", "", as.character(value))
  ) |>
  select(-rank)


print(
  xtable(
    tbl_reordered, 
    digits = c(
      0, # row name
      0, # key
      0, # value
      0, # censo2000
      0, # censo2010
      0  # pns2019
    )
  ),
  sanitize.text.function = NULL,
  only.contents=TRUE,
  include.rownames=FALSE,
  include.colnames=FALSE,
  hline.after=NULL,
  comment=FALSE,
  file=paste0(
    results_dir,
    "tbl_comparison.tex"
  )
)
toc()

tic()
message("preparando gráfico de comparação...")
plot_comparison <-
  dist_summary |> 
  mutate(
    rank = case_when(
      # reordenamento para 'instrucao'
      value == "outros"        ~ 1,
      value == "fundamental"   ~ 2,
      value == "medio"         ~ 3,
      value == "superior"      ~ 5,
      value == "nao_informado" ~ 6,
      # reordenamento para 'dif_ouvir'
      value == "nenhuma"  ~ 1,
      value == "alguma"   ~ 2,
      value == "grande"   ~ 3,
      value == "incapaz"  ~ 4,
      value == "ignorado" ~ 5,
      # reordenamento para 'faixa_idade'
      value == "0-4"      ~ 1,
      value == "5-9"      ~ 2,
      value == "10-19"    ~ 3,
      value == "20-39"    ~ 4,
      value == "40+"      ~ 5,
      TRUE                ~ 6
    ),
    value = reorder_within(value, rank, key)
  ) |>
  filter(value != 'nenhuma___dif_ouvir') |> 
  ggplot(
    aes(x = value, y = pct, fill = src)
  ) +
  geom_col(position = "dodge") + 
  facet_wrap(~key, scales = "free") +
  scale_y_continuous(labels = scales::percent)+
  labs(
    # title = "Comparativo das distribuições de respostas por variável preditora",
    # caption ="Nota: 'nenhuma' omitido em dif_ouvir devido à escala do gráfico (censo2000: 96,2%, censo2010: 94,9%, pns2019: 94,5%)", 
    x = "",
    y = "Frequência relativa",
    fill = "Fonte"
  ) +
  scale_fill_grey(start = 0.8, end = 0.2) + 
  scale_x_reordered() + 
  theme_bw() +
  theme(
    legend.position = "top"
  )
toc()

tic()
message("exportando gráfico de comparação no formato pdf em disco...")
plot_comparison |>
  ggsave(
    filename = paste0(results_dir, "plt_comparison.pdf"),
    width = 8,
    height = 6
  )
toc()