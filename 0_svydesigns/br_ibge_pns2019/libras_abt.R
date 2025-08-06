library(dplyr)   # manipulação de dados
library(survey)  # amostragem complexa
library(tictoc)  # tempo de execução dos comandos
library(tidyr)   # pivot_wider
library(arrow)   # read_parquet, open_dataset

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

pns2019_prior <- survey::svydesign(
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



## matriz de modelo preditivo libras
abt <- 
  svytable(
  formula=~v0001+c006+c008+c009+d001+c011+d00901+g058+g05801, 
  design=pns2019_posterior
  ) |>
  as.data.frame() |> 
  filter(Freq>0) |>
  group_by(across(-Freq)) |>
  summarise(n=sum(Freq)) |>
  arrange(desc(n)) 

abt |>
  group_by(g05801) |>
  summarise(count=sum(n))

library(readr)
abt |>
  write_csv('analyses/libras_abt.csv')


