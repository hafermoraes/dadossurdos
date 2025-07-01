
library(arrow)
library(dplyr)
library(tictoc)

dom <- open_dataset(
   "/tmp/etl/br_ibge_censo_2000/parquet/dom" 
)

tic()
dom %>%
  count(v0102) %>%
  arrange(v0102) %>%
  collect() %>% 
  View
toc()
