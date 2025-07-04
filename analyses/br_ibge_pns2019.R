library(dplyr)   # manipulação de dados
library(survey)  # amostragem complexa
library(tictoc)  # tempo de execução dos comandos
library(arrow)

br_ibge_pns_2019 <-
  read_parquet(
    "/tmp/etl/br_ibge_pns_2019/parquet/microdata.parquet" 
  ) %>% 
  filter(v0015 == '01', m001 == '1') %>%
  mutate(across(everything(), as.numeric))

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <- survey::svydesign(
  ids = ~upa_pns, 
  strata = ~v0024, 
  data = subset(br_ibge_pns_2019, !is.na(v0029)), 
  weights = ~v0029, 
  nest = TRUE
)
# Post-stratification
popc.types <- data.frame( 
  v00293=as.character(unique(br_ibge_pns_2019$v00293)), 
  Freq=as.numeric(unique(br_ibge_pns_2019$v00292))
)
popc.types <- popc.types[order(popc.types$v00293),]
pns2019_posterior <- survey::postStratify(
  design=pns2019_prior, 
  strata=~v00293, 
  population=popc.types
)

round( svytable(formula=~c006, design=subset(pns2019_posterior, c008 >= 18)), 0)

# https://sidra.ibge.gov.br/tabela/4394#resultado
# https://sidra.ibge.gov.br/tabela/4394
round( svytable(formula=~p027, design=subset(pns2019_posterior, c008 >= 18)), 0)
