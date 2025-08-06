library(arrow)    # open_dataset, collect
library(dplyr)    # |>,  mutate, transmute, rename_with
library(tidyr)    # pivot_wider, pivot_longer
library(survey)   # svydesign, svytable
library(httr)     # GET
library(jsonlite) # fromJSON
library(xtable)   # xtable
library(scales)   # number

microdados <-
  read_parquet(
    "/tmp/etl/br_ibge_pns_2019/parquet/microdata.parquet" 
  ) |>
  rename_with(tolower) |>
  filter(v0015 == '01', !is.na(v0015), m001 == '1', !is.na(m001)) |>
  mutate(across(everything(), as.numeric))

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <-
  survey::svydesign(
  ids = ~upa_pns, 
  strata = ~v0024, 
  data = microdados, 
  weights = ~v0029, 
  nest = TRUE
)
# Post-stratification
popc.types <-
  data.frame( 
    v00293=as.character(unique(microdados$v00293)), 
    Freq=as.numeric(unique(microdados$v00292))
  )
popc.types <- popc.types[order(popc.types$v00293),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00293, 
    population=popc.types
  )


## recalculo
recalculo <-
  svytable(
    formula=~n001+c006,
    design=subset(pns2019_posterior, c008 >=18)
  ) |>
  as.data.frame() |>
  mutate(
    tab7666 = case_when(
      n001 %in% c(1,2) ~ 3,
      n001 == 3 ~ 2,
      n001 %in% c(4,5) ~ 1,
      )
   ,tab7666 = factor( 
     tab7666, 
     levels = 3:1, 
     labels = c(
       'Muito bom e bom',
       'Regular',
       'Ruim e muito ruim'
     )
   )
  ,c006 = factor(
    c006, 
    levels = 1:2, 
    labels = c('Masculino', 'Feminino')
  )
  ) |>
  na.omit() |>
  group_by(tab7666, c006) |>
  summarise( n = round(sum(Freq)/1e3,0) ) |>
  pivot_wider(id_cols = tab7666, names_from = c006, values_from = n) |>
  mutate(Total = Masculino + Feminino) |>
  pivot_longer(cols=-1) |>
  pivot_wider(names_from = tab7666) |>
  mutate(Total=`Muito bom e bom` + `Ruim e muito ruim` + Regular) |>
  rename(sexo=name) |>
  pivot_longer(cols=-1, names_to = "aval_estado_saude") |>
  transmute(
    fonte = 'recalculo',
    sexo,
    aval_estado_saude,
    n = value
  )


## SIDRA/IBGE
## https://sidra.ibge.gov.br/tabela/7666#resultado
sidra <-
  httr::GET(
  "https://apisidra.ibge.gov.br/values/t/7666/n1/all/v/2667/p/all/c2/all/c12258/all/d/v2667%200"
  ) |>
  getElement("content") |>
  rawToChar() |>
  jsonlite::fromJSON() |>
  filter(V != 'Valor') |>
  transmute(
    fonte = 'sidra',
    sexo = D4N,
    aval_estado_saude = D5N,
    n = as.numeric(V)
  ) |>
  as_tibble()


validacao <-
  bind_rows(
    recalculo,
    sidra
  ) |>
  pivot_wider(
    id_cols = c('sexo', 'aval_estado_saude'),
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
