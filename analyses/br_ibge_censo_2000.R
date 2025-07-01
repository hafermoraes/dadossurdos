
library(censobr)
pes <- read_population(year=2000)

pes %>% head(10) %>% collect() %>% View
pes %>%
  summarise(sum=sum(P001,na.rm=TRUE)) %>%
  collect() 


library(arrow)
library(dplyr)
library(tictoc)
library(survey)

dom <- open_dataset(
  "/tmp/etl/br_ibge_censo_2000/parquet/dom" 
)

pes <- open_dataset(
   "/tmp/etl/br_ibge_censo_2000/parquet/pes" 
)

pes %>% count(v0424) %>% collect() %>% View

pes %>% 
  filter( v0412 %in% c('1', '2')) %>%
  count(m4620, sort=TRUE) %>%
  collect() 



pes %>%
  mutate(p001 = as.numeric(p001)/1e8) %>%
  summarise(sum=sum(p001,na.rm=TRUE)) %>%
  collect() 


tic()
dom %>%
  count(v0102) %>%
  arrange(v0102) %>%
  collect() %>% 
  View
toc()




sample <- pes %>%
  transmute(areap=as.numeric(areap),p001=as.numeric(p001)/1e8,v0401=as.numeric(v0401)) %>%
  group_by(areap) %>%
  mutate(N=n()) %>%
  ungroup() %>%
  collect()

svydesign_censo2000 <- svydesign(
  ids = ~1,
  strata = ~areap,
  fpc= ~N,
  weights = ~p001,
  data = sample
)


## validação contra SIDRA/IBGE
## https://sidra.ibge.gov.br/tabela/200#/n3/all/u/y/v/allxp/p/2000/c2/all/c1/0/c58/0/d/v93%200/l/v,p+c2+c1,t+c58/resultado
svytable(formula=~v0401, design = svydesign_censo2000)
