
library(geobr)
library(dplyr)
library(sf)
library(ggplot2)


sc <- 
  read_census_tract(
    code_tract = 3509502, 
    year=2010
    )

# correto!!!!
sc |>
  st_union() |> 
  st_cast("LINESTRING") |>
  plot()

# vai curintia
sc |>
  group_by(name_district) |>
  summarise(geom = st_union(geom), .groups = 'drop') |> 
  st_cast("LINESTRING") |>
  ggplot() + geom_sf()
  


