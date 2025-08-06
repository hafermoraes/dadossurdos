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
    "/tmp/etl/br_ibge_censo_2010/parquet/pess"
  ) |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  mutate(
    across(everything(), as.numeric),
    v0010=v0010/1e13
  ) |> 
  select(
    v0011,  # area de ponderação
    v0010,  # peso amostral do indivíduo
    v0601   # sexo do indivíduo
  ) |>
  collect()

svydesign_censo2010 <-
  svydesign(
    ids = ~1,
    weights = ~v0010,
    data = microdados
  )


## Recálculo
recalculo <-
  svytable(
    formula = ~v0601,
    design = svydesign_censo2010
  ) |>
  as_tibble() |>
  transmute(
    fonte = 'recalculo',
    sexo = case_when(
      v0601 == 1 ~ 'Homens',
      v0601 == 2 ~ 'Mulheres'
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

## SIDRA/IBGE
## https://sidra.ibge.gov.br/tabela/608#/n1/all/v/allxp/p/all/c1/0/c2/all/l/v,p+c1,t+c2/resultado
sidra <-
  httr::GET(
  "https://apisidra.ibge.gov.br/values/t/608/n1/all/v/allxp/p/all/c1/0/c2/all"
  ) |>
  getElement("content") |>
  rawToChar() |>
  jsonlite::fromJSON() |>
  filter(V != 'Valor') |>
  transmute(
    fonte = 'sidra',
    sexo = D5N,
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
    diff = round(recalculo - sidra, 5),
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
