
message("removendo quaisquer arquivos previamente existentes em ", eda_dir)
FILES <- 
  list.files(
    path = eda_dir,
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  file.remove(f)
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
  file.remove(f)
}

