
FILES <- 
  list.files(
    path = paste0(base_dir, 'results'),
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  file.remove(f)
}

