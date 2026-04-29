
ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_surdo), color = NA) + # 'color = NA' remove as bordas das cidades para não poluir
  scale_fill_viridis_c(
    option = "magma", 
    name = "População Surda",
    direction = -1,
    labels = scales::label_number(big.mark = ".", decimal.mark= ',')
  ) +
  labs(
    title = "Distribuição da População Surda por Município",
    subtitle = "Brasil",
    caption = "Fonte: Dados espaciais consolidados"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )


max_global <- max(spatial_muni$N_surdo, na.rm=TRUE)

ARG_UF <- 'MG'

xy_lims <- 
  AP_geom %>% 
  filter(abbrev_state == ARG_UF) %>% 
  st_bbox()


spatial_muni %>%
  filter(abbrev_state == ARG_UF) %>%
  ggplot() +
  geom_sf(aes(fill = N_surdo), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    colors = c("white", "#f768a1", "#ae017e", "#49006a"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = ".", decimal.mark=','),
    values = c(0, 0.05, 0.4, 1),
    limits = c(0, max_global)
  ) +
  theme_bw() +
  labs(
    x = 'Longitude',
    y = 'Latitude',
  ) + 
  # geom_point(
  #   data = cil_df,
  #   aes(x=lon, y=lat, shape = "CIL"),
  #   color = 'black',
  #   size = 3
  # ) + 
  # scale_shape_manual(
  #   name = NULL, 
  #   values = c("CIL" = 19)
  # ) +
  scale_x_continuous(labels = function(x) paste0(abs(x), "°O")) +
  scale_y_continuous(labels = function(y) paste0(abs(y), "°S")) +
  coord_sf(
    xlim = c(xy_lims["xmin"], xy_lims["xmax"]),
    ylim = c(xy_lims["ymin"], xy_lims["ymax"]),
    datum = st_crs(4674),
    expand = TRUE
  ) +
  annotation_scale(
    location = "bl",
    width_hint = 0.2,
    style = "bar",
    bar_cols = c("black", "white")
  ) +
  annotation_north_arrow(
    location = "bl",
    which_north = "true",
    pad_x = unit(0.25, "in"),
    pad_y = unit(0.3, "in"),
    style = north_arrow_fancy_orienteering(),
    height = unit(1.0, "cm"), 
    width = unit(1.0, "cm")
  )


# input_df %>%
#   arrange(desc(N_surdo)) %>%
#   mutate(
#     p=N_surdo/sum(N_surdo),
#     c=cumsum(p)
#   ) %>%
#   View()


ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o azul celeste, azul real e azul meia-noite
    colors = c("white", "#9ecae1", "#2171b5", "#08306b"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Garante que o branco predomine nos valores muito baixos
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()



ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o coral, vermelho vivo e bordô (vinho escuro)
    colors = c("white", "#fb9a99", "#e31a1c", "#67000d"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Mantém a transição suave para o branco no início
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()



ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o verde menta, verde grama e verde floresta fechada
    colors = c("white", "#a1d99b", "#238b45", "#00441b"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Transição suave para destacar o branco nos valores próximos de zero
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()



ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o cinza claro, cinza grafite e preto/chumbo
    colors = c("white", "#bdbdbd", "#636363", "#252525"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Ajuste fino para o branco cobrir o zero e o preto os picos
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()





