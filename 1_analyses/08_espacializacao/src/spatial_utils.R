

# gráfico do país
input_df <-
  spatial_muni %>% 
  mutate(
    n = N_incapaz,
    p =  n / N
  ) 


input_df %>%
  ggplot(aes(x = n)) +
  geom_histogram(fill = "steelblue", color = "white", bins = 50) +
  labs(
       x = "Valores de n",
       y = "Frequência") +
  theme_minimal()
  

input_df %>%
  ggplot() +
  geom_sf(aes(fill=n), color = NA, size = 0.1) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.2) +
  scale_fill_gradient(
    low = "white", 
    high = "darkred",
    name = "População por mil"
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



