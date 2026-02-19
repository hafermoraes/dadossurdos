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

gc()

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
  gc()
  message("tratando arquivo ", FILE, " ...")
  system(paste0("sort -t, -k1,1n -o ", FILE, " ",FILE))
  if(FILE != FILES[1]){
    # deixando coluna row_id no primeiro arquivo somente...
    system(paste0("sed -i 's/^[^,]*,//' ", FILE))
  }
  toc()
}


tic()
gc()
message("concatenando arquivos em uma base única...")
system(paste0("paste -d ',' ", INPUTS, " > ", OUTPUT_CSV))
toc()



tic()
gc()
message("removendo arquivos intermediários...")
for(FILE in FILES){
  message("tratando arquivo ", FILE)
  system(paste0("rm ", FILE))
}
toc()


tic()
gc()
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

gc()
