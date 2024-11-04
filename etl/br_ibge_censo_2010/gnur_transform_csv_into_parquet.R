## gnur_transform_csv_into_parquet.R
##
## Converte microdados do formato texto para o formato parquet usando library(arrow)
##
## Função é chamada como
##  R CMD BATCH --quiet --vanilla "--args base='pess' uf='SP1'" ./gnur_transform_csv_into_parquet.R

## recupera os argumentos passados via linha de comando
args <- commandArgs(TRUE)

for(i in 1:length(args)){
  eval(parse(text=args[[i]]))
}

library(arrow)  # open_dataset, write_dataset
library(readr)  # read_delim
library(glue)   # glue

## pastas nas quais alocados os dados tratados e em formato parquet
src_dir <- '/tmp/etl/br_ibge_censo_2010/'
proc_data <- paste0(src_dir, 'data')
parq_data <- paste0(src_dir, 'parquet')

## importa todos os campos como string
col_names <-
    read_delim(
      file = glue('{proc_data}/vdict_qdesc_{base}.txt'),
      delim='|',
      show_col_types = FALSE
    )
## adaptado de https://stackoverflow.com/a/71305598
csv_schema <- schema(
  purrr::map( col_names$q_code, ~Field$create(name = .x, type = string()))
)

## leitura dos microdados delimitados por ',' via
## pacote 'arrow'.
microdata_pipe_delimited <-
  open_dataset(
    glue('{proc_data}/microdata_{base}_{uf}.csv'),
    format="csv",
    schema = csv_schema,
    col_names = TRUE,
    skip = 0
  )

## escrita dos microdados tratados em formato 'parquet'
## para agilidade e menor espaço em disco
  write_parquet(
    microdata_pipe_delimited, 
    sink = glue('{parq_data}/{base}/{uf}.parquet'),
  )
