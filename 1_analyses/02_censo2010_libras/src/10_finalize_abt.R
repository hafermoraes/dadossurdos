#' @title Consolidação e Validação da ABT: Censo 2010
#' 
#' @description
#' Este script orquestra a união final de todos os subconjuntos de dados processados 
#' do Censo 2010 (Demografia, Migração, Fecundidade, Arranjos e Predições). 
#' A estratégia de integração utiliza utilitários de baixo nível do sistema operacional 
#' para manipular os arquivos diretamente no disco, preservando a memória RAM.
#'
#' @section Processamento via Sistema (Linux Coreutils):
#' \itemize{
#'   \item \bold{Ordenação}: Aplica \code{sort} em cada CSV para garantir o alinhamento pelo \code{row_id}.
#'   \item \bold{Normalização}: Utiliza \code{sed} para remover colunas repetidas de ID, preparando a estrutura para junção.
#'   \item \bold{Fusão Lateral}: Executa o comando \code{paste} para concatenar os arquivos horizontalmente de forma performática.
#' }
#'
#' @section Otimização e Armazenamento:
#' \itemize{
#'   \item \bold{Conversão Parquet}: O CSV consolidado é convertido para o formato \code{parquet} via \code{arrow}. 
#'   \item \bold{Sanitização de Tipos}: Todas as colunas são convertidas para \emph{character} e strings de valores ausentes (NA, NULL) são normalizadas para strings vazias para evitar corrupção de tipos.
#' }
#'
#' @section Protocolo de Auditoria:
#' O script realiza uma validação cruzada rigorosa:
#' \enumerate{
#'   \item Sorteia um registro aleatório (\code{set.seed(42)}).
#'   \item Extrai os atributos desse registro em cada arquivo de módulo original.
#'   \item Compara esses valores com os dados presentes na ABT final.
#'   \item Gera um log detalhado de verificação em \code{censo2010_abt.validation}.
#' }
#'
#' @name 10_finalize_abt_censo2010
NULL


# comandos rodam via linux para não usar memória
FILES <- paste0(
  data_dir, 
  c(
    "censo2010_survey_expansion.csv",
    "censo2010_common.csv",
    "censo2010_family_arrangements.csv",
    "censo2010_fertility.csv",
    "censo2010_migration.csv",
    "censo2010_libras.csv"
  )
)

INPUTS <- paste(FILES, collapse = " ")
OUTPUT_CSV <- paste0(data_dir, "censo2010_abt.csv")
OUTPUT_PARQUET <- paste0(data_dir, "censo2010_abt.parquet")


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

censo2010_abt_csv <-
  open_dataset(
    OUTPUT_CSV,
    format = "csv"
  )

censo2010_abt_parquet <- 
  censo2010_abt_csv |>
  mutate(across(everything(), as.character)) |>
  mutate(across(everything(), ~if_else(is.na(.x) | .x == "NA" | .x == "NULL", "", .x)))

write_parquet(
  censo2010_abt_parquet,
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



tic()
message("confirmando que o tratamento externo ao R não corrompeu os dados...")
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
  select( row_id, sabe_libras) |>
  collect() |>
  glimpse() |> 
  capture.output() |> 
  cat(file = OUTPUT_VALIDATION, sep = "\n", append = TRUE)


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

gc()
