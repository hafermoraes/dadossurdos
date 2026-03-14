




tic()
message("unificando as bases dos censos 2000 e 2010...")
censos_fecundidade <-
  bind_rows(
    censo2000_fecundidade,
    censo2010_fecundidade
  ) 
toc()