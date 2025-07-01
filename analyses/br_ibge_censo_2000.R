library(dplyr)   # manipulação de dados
library(survey)  # amostragem complexa
library(tictoc)  # tempo de execução dos comandos

##========================================================
## Expansão/validação do Censo2000 usando pacote 'censobr'
##========================================================

library(censobr)
pes <- read_population(year=2000) %>% collect()

tic()
svycenso2000 <-
  svydesign(
    ids = ~1,
    ## strata = ~areap,
    ## fpc= ~N,
    weights = ~P001,
    data = pes
  )
toc()

## validação contra SIDRA/IBGE
## https://sidra.ibge.gov.br/tabela/200#/n1/all/n3/all/u/y/v/allxp/p/2000/c2/all/c1/0/c58/0/d/v93%200/l/v,p+c2+c1,t+c58/resultado
tic()
svytable(
  formula=~V0401,
  design = svycenso2000
)
toc()



##========================================================
## Expansão/validação do Censo2000 usando dados brutos
##========================================================

library(arrow)

pes <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2000/parquet/pes" 
  )

## pes %>% 
##   filter( v0412 %in% c('1', '2')) %>%
##   count(m4620, sort=TRUE) %>%
##   collect() 

tic()
sample <-
  pes %>%
  transmute(
    areap=as.numeric(areap),   # area de ponderação
    p001=as.numeric(p001)/1e8, # peso do indivíduo
    v0401=as.numeric(v0401)    # sexo do indivíduo
  ) %>%
  ## group_by(areap) %>%
  ## mutate(N=n()) %>%
  ## ungroup() %>%
  collect()
toc()

tic()
svycenso2000 <-
  svydesign(
    ids = ~1,
    ## strata = ~areap,
    ## fpc= ~N,
    weights = ~p001,
    data = sample
  )
toc()

## validação contra SIDRA/IBGE
## https://sidra.ibge.gov.br/tabela/200#/n1/all/n3/all/u/y/v/allxp/p/2000/c2/all/c1/0/c58/0/d/v93%200/l/v,p+c2+c1,t+c58/resultado
tic()
svytable(
  formula=~v0401,
  design = svycenso2000
)
toc()
