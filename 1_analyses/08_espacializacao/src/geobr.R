
library(geobr)
library(dplyr)
library(sf)
library(ggplot2)
library(ggsvg)
library(ggspatial)

cil_svg <- 
  paste(
    readLines(
      '/home/rstudio/1_analyses/08_espacializacao/img/libras.svg'
    ), 
    collapse = "\n"
  )

cil_df <- data.frame(
  cidade = c("São Paulo", "Rio de Janeiro"),
  lat = c(-23.5489, -22.9068), # Valores negativos entre -33 e 5
  lon = c(-46.6388, -43.1729)  # Valores negativos entre -73 e -34
)

br <- 
 read_weighting_area()

estados <- 
  read_state(
    year = 2020
  )

ARG_REGION <- 'Sudeste'

limites_sudeste <- 
  br %>% 
  filter(name_region == ARG_REGION) %>% 
  st_bbox()

if (ARG_REGION == 'Sudeste') {
  limites_sudeste["xmax"] <- -38
}

br %>%
  filter( name_region == ARG_REGION) %>%
  select(code_weighting, geom) %>% 
  mutate(n = rnorm(n(),30,2)) %>%
  ggplot() +
  geom_sf(aes(fill=n), color = NA, size = 0.1) +
  geom_sf(data = estados, fill = NA, color = "white", size = 0.2) +
  scale_fill_viridis_c(option = "magma") + # Escala de cor estilo heat map
  theme_bw() +
  labs(
    x = 'Longitude',
    y = 'Latitude'
  ) + 
  # geom_point_svg(
  #   data = cil_df,
  #   aes(x=lon, y=lat),
  #   svg = cil_svg,
  #   size = 7
  # ) + 
  geom_point(
    data = cil_df,
    aes(x=lon, y=lat),
    color = 'black',
    shape = 19,
    size = 3
  ) + 
  scale_x_continuous(
    # breaks = seq(-75, -30, by = 5),
    labels = function(x) paste0(abs(x), "°O")
  ) +
  scale_y_continuous(
    # breaks = seq(-35, 5, by = 5),
    labels = function(y) paste0(abs(y), "°S")
  ) +
  #coord_sf(datum = st_crs(4674)) +
  coord_sf(
    xlim = c(limites_sudeste["xmin"], limites_sudeste["xmax"]),
    ylim = c(limites_sudeste["ymin"], limites_sudeste["ymax"]),
    datum = st_crs(4674),
    expand = TRUE # TRUE adiciona uma pequena margem suave em volta
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



