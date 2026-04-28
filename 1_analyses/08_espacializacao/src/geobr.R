
library(geobr)
library(dplyr)
library(sf)
library(ggplot2)
library(ggsvg)
library(ggspatial)

cil_df <- tribble(
  ~cidade, ~lat, ~lon,
  'São Paulo', -23.5489, -46.6388,
  'Rio de Janeiro', -22.9068, -43.1729,
)

br <- 
 read_weighting_area()

estados <- 
  read_state(
    year = 2020
  )


REGIONS <- c("Norte", "Nordeste", "Sudeste", "Sul", "Centro Oeste")

ARG_REGION <- REGIONS[3]


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
  geom_sf(data = estados, fill = NA, color = "black", size = 0.2) +
  scale_fill_gradient(
    low = "white", 
    high = "darkblue",
    name = "Valor (n)"
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
    xlim = c(limites_sudeste["xmin"], limites_sudeste["xmax"]),
    ylim = c(limites_sudeste["ymin"], limites_sudeste["ymax"]),
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



