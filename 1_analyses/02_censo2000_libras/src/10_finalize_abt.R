
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
  if(FILE != FILES[1]){
    # deixando coluna row_id no primeiro arquivo somente...
    system(paste0("sed -i 's/^[^,]*,//' ", FILE))
  }
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
col_names <- names(read_csv(OUTPUT_CSV, n_max = 0))
csv_schema <- schema(
  sapply(col_names, function(x) field(x, utf8()))
)

censo2000_abt_csv <-
  open_dataset(
    OUTPUT_CSV,
    format = "csv"
  )

censo2000_abt_parquet <- 
  censo2000_abt_csv |>
  mutate(across(everything(), as.character)) |>
  mutate(across(everything(), ~if_else(is.na(.x) | .x == "NA" | .x == "NULL", "", .x)))

write_parquet(
  censo2000_abt_parquet,
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

rm(censo2000_common)
rm(censo2000_family_arrangements)
rm(censo2000_fertility)
rm(censo2000_libras)
rm(censo2000_migration)
rm(censo2000_oos)
rm(censo2000_survey_expansion)

rm(dvar_censo2000)
rm(subset_censo2000)

gc()
