message("confirmando que o tratamento externo ao R não corrompeu os dados...")

tic()
message("lendo censo2010_abt.parquet do disco e selecionando uma linha aleatoriamente para teste...")
OUTPUT_VALIDATION <-
  paste0(
  data_dir,
  "censo2010_abt.validation"
)

censo2010_abt <-
  open_dataset(
    paste0(
      data_dir,
      "censo2010_abt.parquet"
    )
  ) |>
  to_duckdb()

options(cli.num_colors = 1)

SEED <- 42
set.seed(SEED)
cat(paste0("SEED = ",SEED, "\n"), file = OUTPUT_VALIDATION, sep='\n',append=FALSE)
sorteio <-
  censo2010_survey_expansion |>
  collect() |>
  slice_sample(n=1)
toc()






tic()
msg <- "censo2010_survey_expansion: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_survey_expansion |>
  filter( row_id == sorteio$row_id) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)

msg <- "survey_expansion section at censo2010_abt: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_abt |>
  filter( row_id == as.numeric(sorteio$row_id))  |>
  select( row_id, area_ponderacao, peso_amostral) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)
toc()






tic()
msg <- "censo2010_common: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_common |>
  filter( row_id == sorteio$row_id) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)


msg <- "common section at censo2010_abt: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_abt |>
  filter( row_id == as.numeric(sorteio$row_id))  |>
  select( row_id, uf_residencia, municipio_residencia, idade, sexo, alfabetizado, estado_civil, instrucao, cor_raca, dif_enxergar, dif_ouvir, dif_locomover) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)
toc()






tic()
msg <- "censo2010_family_arrangements: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_family_arrangements |>
  filter( row_id == sorteio$row_id) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)

msg <- "family_arrangements section at censo2010_abt: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_abt |>
  filter( row_id == as.numeric(sorteio$row_id))  |>
  select( row_id, id_relacao_resp_domicilio, relacao_resp_domicilio, nr_ordem_pessoa, id_domicilio) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)
toc()






tic()
msg <- "censo2010_fertility: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)


censo2010_fertility |>
  filter( row_id == sorteio$row_id) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)


msg <- "fertility section at censo2010_abt: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_abt |>
  filter( row_id == as.numeric(sorteio$row_id))  |>
  select( row_id, filhos_nascidos_vivos, filhos_nascidos_vivos_vivos, filhos_nascidos_mortos, filhos_nascidos, idade_ultimo_filho) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)
toc()






tic()
msg <- "censo2010_libras: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_libras |>
  filter( row_id == sorteio$row_id) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)

msg <- "libras section at censo2010_abt: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_abt |>
  filter( row_id == as.numeric(sorteio$row_id))  |>
  select( row_id, sabe_libras, categ_ouvinte, categ_deficiente_auditivo, categ_surdo, categ_surdocego, sabe_libras_nao0sim1) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)
toc()






tic()
msg <- "censo2010_migration: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_migration |>
  filter( row_id == sorteio$row_id) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)

msg <- "migration section at censo2010_abt: "
message(msg)
cat(msg, file = OUTPUT_VALIDATION, sep='\n', append = TRUE)

censo2010_abt |>
  filter( row_id == as.numeric(sorteio$row_id))  |>
  select(
    row_id,
    municipio_sempre_morou, municipio_residencia_tempo_anos, municipio_naturalidade,
    uf_naturalidade,
    nacionalidade, ano_fixou_residencia_brasil,
    uf_nascimento, pais_nascimento,
    uf_residencia_tempo_anos, uf_residencia_anterior, uf_residencia_datafixa, pais_residencia_datafixa
    ) |>
  collect() |>
  glimpse() |>
  capture.output() |>
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)

options(cli.num_colors = NULL)
toc()





tic()
message("removendo arquivos intermediários da validação...")

rm(censo2010_abt_csv)

rm(censo2010_common)
rm(censo2010_family_arrangements)
rm(censo2010_fertility)
rm(censo2010_libras)
rm(censo2010_migration)
rm(censo2010_oos)
rm(censo2010_survey_expansion)

rm(dvar_censo2010)
rm(subset_censo2010)
toc()

tic()
message("aplicando garbage collection gc() para limpar a memória do GNU R...")
gc()
toc()
