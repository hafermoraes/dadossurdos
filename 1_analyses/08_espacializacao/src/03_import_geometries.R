
tic("importando áreas de ponderação do país...")
AP_geom <- 
 read_weighting_area(year=2010)
toc()


tic("importando polígonos dos estados da federação...")
UF_geom <- 
  read_state(year = 2010)
toc()
