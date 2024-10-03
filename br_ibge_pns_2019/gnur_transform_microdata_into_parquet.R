## Converte microdados do formato texto para o formato parquet usando library(arrow)
library(arrow)
library(readr)

microdata <-
  read_delim_arrow(
    file = '/tmp/etl/br_ibge_pns_2019/data/microdata.txt',
    delim = '|',
    col_names = FALSE,
    as_data_frame = FALSE
  )

col_names <-
  read_delim(
    file = '/tmp/etl/br_ibge_pns_2019/data/col_names.txt',
    delim = '|',
    show_col_types = FALSE
  )

names(microdata) <- col_names$var

write_parquet(
  microdata,
  '/tmp/etl/br_ibge_pns_2019/data/microdata.parquet'
)
