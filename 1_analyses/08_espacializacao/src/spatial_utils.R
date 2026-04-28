
# gráfico do país
input_df <-
  spatial_df %>%
  mutate(n = N_incapaz / N) 

input_df %>%
  ggplot() +
  geom_sf(aes(fill=n), color = NA, size = 0.1) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.2) +
  scale_fill_gradient(
    low = "white", 
    high = "darkblue",
    name = "População"
  ) +
  theme_bw() +
  labs(
    x = 'Longitude',
    y = 'Latitude',
  ) + 
  geom_point(
    data = cil_df,
    aes(x=lon, y=lat, shape = "CIL"),
    color = 'black',
    size = 3
  ) + 
  scale_shape_manual(
    name = NULL, 
    values = c("CIL" = 19)
  ) +
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


# sc <- 
#   read_census_tract(
#     code_tract = 3509502, 
#     year=2010
#     )



# # correto!!!!
# sc |>
#   st_union() |> 
#   st_cast("LINESTRING") |>
#   plot()
# 
# # vai curintia
# sc |>
#   group_by(name_district) |>
#   summarise(geom = st_union(geom), .groups = 'drop') |> 
#   st_cast("LINESTRING") |>
#   ggplot() + geom_sf()



