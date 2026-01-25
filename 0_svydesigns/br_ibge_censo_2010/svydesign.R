library(dplyr)    # |>,  mutate, rename_with
library(survey)   # svydesign, svytable
library(arrow)    # open_dataset

microdados <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2010/parquet/pess"
  ) |>
  rename_with(tolower) |>        # converte nomes de colunas para minúsculas
  mutate(
    across(everything(), as.numeric),
    v0010=v0010/1e13,             # peso amostral do indivíduo
  ) |>
  collect()

svydesign_censo2010 <-
  survey::svydesign(
    ids = ~1,
    weights = ~v0010,
    data = microdados
  )
