library(dplyr)    # |>,  mutate, rename_with
library(survey)   # svydesign, svytable
library(arrow)    # open_dataset

microdados <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2000/parquet/pes" 
  ) |>
  rename_with(tolower) |>     # converte nomes de colunas para minúsculas
  mutate(
    across(everything(), as.numeric),
    p001=p001/1e8,             # peso amostral do indivíduo
  ) |> 
  collect()

svydesign_censo2000 <-
  svydesign(
    ids = ~1,
    weights = ~p001,
    data = microdados
  )
