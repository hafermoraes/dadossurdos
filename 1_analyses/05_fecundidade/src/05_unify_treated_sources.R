

tic()
message("unificando as bases dos censos 2000 e 2010 para diagnósticos el badry...")
censos_elbadry <-
  bind_rows(
    censo2000_elbadry,
    censo2010_elbadry
  ) 
toc()