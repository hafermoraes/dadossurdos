

library(arrow)
library(dplyr)

dom <- open_dataset(
   "/tmp/etl/br_ibge_censo_2000/parquet/dom" 
)

library(tictoc)

tic()
dom %>%
  count() %>%
  collect()
toc()
