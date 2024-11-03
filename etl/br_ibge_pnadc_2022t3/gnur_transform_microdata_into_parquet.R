## Converte microdados do formato texto para o formato parquet usando library(arrow)
library(arrow)  # open_dataset, write_dataset
library(readr)  # read_delim
library(purrr)  # map

src_dir <- '/tmp/etl/br_ibge_pnadc_2022t3/'
raw_data <- paste0(src_dir, 'raw/')
proc_data <- paste0(src_dir, 'data/')
parq_data <- paste0(src_dir, 'parquet/')


col_names <-
  read_delim(
    file = paste0(proc_data, 'col_names.txt'),
    delim = '|',
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
    paste0(proc_data, 'microdata.txt'),
    format="csv",
    schema = csv_schema,
    col_names = TRUE,
    skip = 0
  )

## escrita dos microdados tratados em formato 'parquet'
## para agilidade e menor espaço em disco
  write_parquet(
    microdata_pipe_delimited, 
    sink = paste0(parq_data, 'microdata.parquet'),
  )
