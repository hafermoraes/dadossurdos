

tic()
message("unificando as bases dos censos 2000 e 2010...")
censo_mortalidade <-
  bind_rows(
    censo2000_mortalidade,
    censo2010_mortalidade
  )
toc()
