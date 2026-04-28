
library(geobr)
library(dplyr)
library(sf)
library(ggplot2)

#remotes::install_github("coolbutuseless/ggsvg")
#install.packages('rsvg')
library(ggsvg)

map_marker_svg <- '
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24" fill="red">
  <path d="M12 2C8.13 2 5 5.13 5 9c0 5.25 7 13 7 13s7-7.75 7-13c0-3.87-3.13-7-7-7z"/>
</svg>'

map_marker_svg <- 
  paste(
    readLines(
      '/home/rstudio/1_analyses/08_espacializacao/img/libras.svg'
    ), 
    collapse = "\n"
  )


pontos <- data.frame(
  cidade = c("São Paulo", "Rio de Janeiro"),
  lat = c(-23.5489, -22.9068), # Valores negativos entre -33 e 5
  lon = c(-46.6388, -43.1729)  # Valores negativos entre -73 e -34
)

#br <- 
#  read_weighting_area()

br %>%
  select(code_weighting, geom) %>% 
  mutate(n = rnorm(n(),30,2)) %>%
  ggplot() +
  geom_sf(aes(fill=n), color = NA, size = 0.1) +
  scale_fill_viridis_c(option = "magma") + # Escala de cor estilo heat map
  theme_void() +
  labs(title = "Exemplo de Mapa de Calor por Setores",
       fill = "Valor") + 
  geom_point_svg(
    data = pontos,
    aes(x=lon, y=lat),
    svg = map_marker_svg,
    size = 7  # Ajuste o tamanho do ícone aqui
  ) + 
  coord_sf()






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

