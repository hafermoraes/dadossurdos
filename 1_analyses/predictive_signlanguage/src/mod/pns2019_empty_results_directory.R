
FILES <- 
  list.files(
    path = '/home/rstudio/1_analyses/predictive_signlanguage/results',
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  file.remove(f)
}

