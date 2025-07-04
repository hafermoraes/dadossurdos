library(dplyr)   # manipulação de dados
library(survey)  # amostragem complexa
library(tictoc)  # tempo de execução dos comandos
library(arrow)

br_ibge_pns_2019 <-
  read_parquet(
    "/tmp/etl/br_ibge_pns_2019/parquet/microdata.parquet" 
  ) %>% 
  filter(v0015 == '01', !is.na(v0015), m001 == '1', !is.na(m001)) %>%
  mutate(across(everything(), as.numeric))

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <- survey::svydesign(
  ids = ~upa_pns, 
  strata = ~v0024, 
  data = br_ibge_pns_2019, 
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

# https://sidra.ibge.gov.br/tabela/4394#resultado
# https://sidra.ibge.gov.br/tabela/4394
svytable(formula=~p027, design=subset(pns2019_posterior, c008 >= 18))/1e3


library(tidyr)
svytable(formula=~n001+c006, design=subset(pns2019_posterior, c008 >=18)) %>%
  as.data.frame() %>%
  mutate(
    tab7666 = case_when(
      n001 %in% c(1,2) ~ 1,
      n001 == 3 ~ 2,
      n001 %in% c(4,5) ~ 3,
    )
    ,tab7666 = factor( tab7666, levels = 1:3, labels = c('Muito ruim e ruim','Regular','Muito bom e bom'))
    ,c006 = factor( c006, levels = 1:2, labels = c('Masculino', 'Feminino'))
  ) %>%
  na.omit() %>%
  group_by(tab7666, c006) %>%
  summarise( n = round(sum(Freq)/1e3,0) ) %>%
  pivot_wider(id_cols = tab7666, names_from = c006, values_from = n)
