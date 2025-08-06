library(arrow)    # open_dataset, collect
library(dplyr)    # |>,  mutate, transmute, rename_with
library(tidyr)    # pivot_wider, pivot_longer
library(survey)   # svydesign, svytable
library(httr)     # GET
library(jsonlite) # fromJSON
library(xtable)   # xtable
library(scales)   # number

microdados <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2000/parquet/pes" 
  ) |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  mutate(
    across(everything(), as.numeric),
    p001=p001/1e8, # peso amostral do indivíduo
    ) |>
  select(areap, p001, v0401) |>
  collect()

svydesign_censo2000 <-
  svydesign(
    ids = ~1,
    weights = ~p001,
    data = microdados
  )


## Recálculo
recalculo <-
  svytable(
    formula = ~v0401,
    design = svydesign_censo2000
  ) |>
  as_tibble() |>
  transmute(
    fonte = 'recalculo',
    sexo = case_when(
      v0401 == 1 ~ 'Homens',
      v0401 == 2 ~ 'Mulheres'
    ),
    n
  ) |>
  pivot_wider(
    names_from = sexo,
    values_from = n
  ) |>
  mutate(
    Total = Homens + Mulheres
  ) |>
  pivot_longer(
    cols = -1,
    names_to = "sexo",
    values_to = "n"
  )


## validação contra SIDRA/IBGE
## https://sidra.ibge.gov.br/tabela/200#/n1/all/v/allxp/p/2000/c2/all/c1/0/c58/0/d/v93%200/l/v,p+c2+c1,t+c58/resultado
sidra <-
  httr::GET(
  "https://apisidra.ibge.gov.br/values/t/200/n1/all/v/allxp/p/2000/c2/all/c1/0/c58/0/d/v93%200"
  ) |>
  getElement("content") |>
  rawToChar() |>
  jsonlite::fromJSON() |>
  filter(V != 'Valor') |>
  transmute(
    fonte = 'sidra',
    sexo = D4N,
    n = as.numeric(V)
  ) |>
  as_tibble()


validacao <-
  bind_rows(
    recalculo,
    sidra
  ) |>
  pivot_wider(
    id_cols = sexo,
    names_from = fonte,
    values_from = n
  ) |>
  mutate(
    diff = round(recalculo - sidra, 0),
    recalculo = number( recalculo, big.mark = '.', accuracy = 1, decimal.mark = ','),
    sidra = number( sidra, big.mark = '.', accuracy = 1, decimal.mark = ',')
  ) 


print(
  xtable(validacao, type = 'latex'),
  only.contents = TRUE,
  hline.after = NULL,
  include.colnames = FALSE,
  include.rownames = FALSE,
  comment = FALSE,
  file = './svydesign_validation.tex'
)
