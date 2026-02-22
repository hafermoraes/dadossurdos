
tic()
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
toc()


tic()
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
toc()


tic()
demog_fec_dir <- paste0(
  results_dir,
  'demog_fecundidade/'
)
message("removendo quaisquer arquivos previamente existentes em ", demog_fec_dir)
FILES <- 
  list.files(
    path = demog_fec_dir,
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  file.remove(f)
}
toc()


tic()
demog_mort_dir <- paste0(
  results_dir,
  'demog_mortalidade/'
)
message("removendo quaisquer arquivos previamente existentes em ", demog_mort_dir)
FILES <- 
  list.files(
    path = demog_mort_dir,
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  file.remove(f)
}
toc()
