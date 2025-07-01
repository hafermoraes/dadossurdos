
library(censobr)

pes <- read_population(year=2000)

library(arrow)
library(dplyr)
library(tictoc)

pes <- open_dataset(
   "/tmp/etl/br_ibge_censo_2000/parquet/pes" 
)

pess <- open_dataset(
  "/tmp/etl/br_ibge_censo_2010/parquet/pess" 
) 


tic()
dom %>%
  count(v0102) %>%
  arrange(v0102) %>%
  collect() %>% 
  View
toc()
