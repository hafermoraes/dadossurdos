
tic("importando áreas de ponderação do país...")
BR_geom <- 
 read_weighting_area(year=2010)
toc()


tic("importando polígonos dos estados da federação...")
UF_geom <- 
  read_state(year = 2010)
toc()
