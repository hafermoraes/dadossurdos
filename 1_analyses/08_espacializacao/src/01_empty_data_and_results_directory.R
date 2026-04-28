

message("removendo quaisquer arquivos previamente existentes em ", results_dir)
FILES <- 
  list.files(
    path = results_dir,
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  drop_file(f)
}



message("removendo quaisquer arquivos previamente existentes em ", data_dir)
FILES <- 
  list.files(
    path = data_dir,
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  drop_file(f)
}

