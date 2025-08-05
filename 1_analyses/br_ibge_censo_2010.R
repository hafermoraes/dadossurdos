library(dplyr)    # manipulação de dados
library(survey)   # amostragem complexa
library(tictoc)   # tempo de execução dos comandos
library(httr)     # GET
library(jsonlite) # fromJSON

##========================================================
## Expansão/validação do Censo2010 usando dados brutos
##========================================================

library(arrow)

pes <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2010/parquet/pess"
  )

tic()
sample <-
  pes %>%
  transmute(
    v0011=as.numeric(v0011),      # area de ponderação
    v0010=as.numeric(v0010)/1e13, # peso do indivíduo
    v0601=as.numeric(v0601)       # sexo do indivíduo
  ) %>%
  collect()
toc()


tic()
svycenso2010 <-
  svydesign(
    ids = ~1,
    ## strata = ~v0011,
    ## fpc= ~N,
    weights = ~v0010,
    data = sample
  )
toc()

## validação contra SIDRA/IBGE
## https://sidra.ibge.gov.br/tabela/608#/n1/all/v/allxp/p/all/c1/0/c2/all/l/v,p+c1,t+c2/resultado
## api: https://apisidra.ibge.gov.br/values/t/608/n1/all/v/allxp/p/all/c1/0/c2/all
tic()
svytable(
  formula=~v0601,
  design = svycenso2010
)
toc()


httr::GET(
  "https://apisidra.ibge.gov.br/values/t/608/n1/all/v/allxp/p/all/c1/0/c2/all"
  ) |>
  getElement("content") |>
  rawToChar() |>
  jsonlite::fromJSON() |>
  select(D5N, V)
