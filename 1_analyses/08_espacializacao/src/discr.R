
library(ggplot2)
library(dplyr)

spatial_muni %>%
  transmute(n=N_surdo) %>%
  mutate(
    pop = cut(n, c(-Inf,0,10,25,50,100,500,1000,2500,Inf))
  ) %>%
  count(pop)


# 1. Preparar os dados com as categorias
spatial_muni_plot <- spatial_muni %>%
  mutate(
    pop_cat = cut(N_surdo, 
                  breaks = c(-Inf, 0, 10, 25, 50, 100, 2500, Inf),
                  labels = c("0", "1-10", "11-25", "26-50", "51-100", "101-2500", "> 2500"))
  )

spatial_muni_plot <- spatial_muni %>%
  mutate(
    pop_cat = cut(N_surdo, 
                  breaks = c(-Inf, 0, 100, 500, 2500, Inf),
                  labels = c("0", "1-100", "101-500", "501-2.500", "2.500+"))
  )


# 2. Definir a paleta de cores (uma cor para cada label acima)

cores_azul <- c("white", "#deebf7", "#9ecae1", "#4292c6", "#021a3b")

cores_vermelho <- c("white", "#fff5f0", "#fb9a99", "#e31a1c", "#67000d")
# O #fff5f0 é apenas um "sopro" de vermelho/rosa.

cores_verde <- c("white", "#f7fcf5", "#a1d99b", "#238b45", "#00441b")
# O #f7fcf5 é um verde quase imperceptível.

cores_lilas <- c("white", "#fcfaff", "#bcbddc", "#807dba", "#3f007d")
# O #fcfaff é um lilás extremamente suave.

#cores_azul <- cores_lilas

# 3. Plotar
ARG_UF <- 'SP'

xy_lims <- 
  AP_geom %>% 
  filter(abbrev_state == ARG_UF) %>% 
  st_bbox()


spatial_muni_plot %>%
  filter(abbrev_state == ARG_UF) %>%
  ggplot() +
  geom_sf(aes(fill = pop_cat), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_manual(
    values = cores_azul,
    name = "População Surda",
    guide = guide_legend(reverse = TRUE) # Opcional: inverte a legenda para o maior ficar no topo
  ) +
  coord_sf(
    xlim = c(xy_lims["xmin"], xy_lims["xmax"]),
    ylim = c(xy_lims["ymin"], xy_lims["ymax"]),
    datum = st_crs(4674),
    expand = TRUE
  ) +
  theme_bw() +
  labs(
    x = "Longitude",
    y = "Latitude"
  )
