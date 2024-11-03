## Converte microdados do formato texto para o formato parquet usando library(arrow)
library(arrow)
library(readr)

src_dir <- '/tmp/etl/br_ibge_pns_2013/'
raw_data <- paste0(src_dir, 'raw/')
proc_data <- paste0(src_dir, 'data/')


microdata <-
  read_delim_arrow(
    file = paste0(proc_data, 'microdata.txt'),
    delim = '|',
    col_names = FALSE,
    as_data_frame = FALSE
  )

col_names <-
  read_delim(
    file = paste0(proc_data, 'col_names.txt'),
    delim = '|',
    show_col_types = FALSE
  )

names(microdata) <- col_names$var

write_parquet(
  microdata,
  paste0(proc_data, 'microdata.parquet')
)
