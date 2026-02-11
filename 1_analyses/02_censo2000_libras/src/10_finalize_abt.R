
# comandos rodam via linux para não usar memória
FILES <- paste0(
  data_dir, 
  c(
    "censo2000_survey_expansion.csv",
    "censo2000_common.csv",
    "censo2000_family_arrangements.csv",
    "censo2000_fertility.csv",
    "censo2000_migration.csv",
    "censo2000_libras.csv"
  )
)

INPUTS <- paste(FILES, collapse = " ")
OUTPUT_CSV <- paste0(data_dir, "censo2000_abt.csv")
OUTPUT_PARQUET <- paste0(data_dir, "censo2000_abt.parquet")


# ordena o arquivo conforme row_id
# e remove coluna row_id
for(FILE in FILES){
  tic()
  message("tratando arquivo ", FILE, " ...")
  system(paste0("sort -t, -k1,1n -o ", FILE, " ",FILE))
  system(paste0("sed -i 's/^[^,]*,//' ", FILE))
  toc()
}

tic()
message("concatenando arquivos em uma base única...")
system(paste0("paste -d ',' ", INPUTS, " > ", OUTPUT_CSV))
toc()

tic()
message("removendo arquivos intermediários...")
for(FILE in FILES){
  message("tratando arquivo ", FILE)
  system(paste0("rm ", FILE))
}
toc()

tic()
message("convertendo arquivo csv em parquet para eficiência em disco...")
censo2000_abt_csv <-
  open_dataset(
    OUTPUT_CSV,
    format = "csv",
    skip=0
  )
write_parquet(
  censo2000_abt_csv,
  sink = OUTPUT_PARQUET
)
toc()

size_csv <- file.info(OUTPUT_CSV)$size
size_csv <- utils:::format.object_size(size_csv, "auto")

size_parquet <- file.info(OUTPUT_PARQUET)$size
size_parquet <- utils:::format.object_size(size_parquet, "auto")

message("redução de ", size_csv, " (csv) para ", size_parquet, " (parquet)")
message("removendo arquivo ", OUTPUT_CSV)
system(paste0("rm ", OUTPUT_CSV))

rm(censo2000_abt_csv)

gc()
