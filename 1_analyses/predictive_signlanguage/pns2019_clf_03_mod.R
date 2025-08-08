

# https://www.tidymodels.org/learn/
# https://www.tidymodels.org/start/case-study/
# https://www.tidymodels.org/learn/models/calibration/
# https://rpubs.com/eR_ic/classification

library(dplyr)   # |>, mutate, glimpse
library(readr)   # read_csv
library(tidyr)   # pivot_longer

# importação da matriz de modelo
rawdata <-
  read_csv(
    '1_analyses/predictive_signlanguage/pns2019_modelmatrix.csv'
  ) |> 
  mutate(across(where(is.character), as.factor))

rawdata |> glimpse()

rawdata |>
  count(cor_raca)
