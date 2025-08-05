library(dplyr)    # %>%,  mutate, rename_with
library(survey)   # svydesign, svytable
library(arrow)    # open_dataset

microdados <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2010/parquet/pess"
  ) %>%
  rename_with(tolower) %>%        # converte nomes de colunas para minúsculas
  mutate(
    v0011=as.numeric(v0011),      # area de ponderação
    v0010=as.numeric(v0010)/1e13, # peso do indivíduo
    v0601=as.numeric(v0601)       # sexo do indivíduo
  ) %>%
  collect()

svydesign_censo2010 <-
  svydesign(
    ids = ~1,
    weights = ~v0010,
    data = microdados
  )
