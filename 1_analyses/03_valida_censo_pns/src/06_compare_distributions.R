
dist_summary <-
  bind_rows(
    censo2000_dist,
    censo2010_dist,
    pns2019_dist
  )

tbl_comparison <- 
  dist_summary |>
  pivot_wider(
    id_cols = c('key', 'value'),
    names_from = 'src',
    values_from = 'pct'
  )

dist_summary |>
  filter(value != 'nenhuma') |> 
  ggplot(aes(x = value, y = pct, fill = src)) +
    geom_col(position = "dodge") + 
    facet_wrap(~key, scales = "free") +
    scale_y_continuous(labels = scales::percent)+
    labs(
      title = "Comparativo das distribuições de respostas por variável preditora",
      x = "",
      y = "Frequência relativa",
      fill = "Fonte",
      caption ="Nota: 'nenhuma' omitido em dif_ouvir devido à escala do gráfico (censo2000: 96,2%, censo2010: 94,9%, pns2019: 94,5%)"
    ) +
    theme(axis.text.x = element_text(angle = 45, hjust = 1)) 
