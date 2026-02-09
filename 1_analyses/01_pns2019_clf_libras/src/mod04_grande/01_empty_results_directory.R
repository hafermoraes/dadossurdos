
FILES <- 
  list.files(
    path = results_dir,
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  file.remove(f)
}

