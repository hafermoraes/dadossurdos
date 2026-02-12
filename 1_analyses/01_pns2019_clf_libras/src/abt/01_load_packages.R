message("carregando pacotes necessários para as análises...")

library(dplyr)   # |>, mutate, glimpse
library(survey)  # amostragem complexa
library(srvyr)   # as_survey
library(tictoc)  # tempo de execução dos comandos
library(tidyr)   # pivot_wider, pivot_longer
library(readr)   # write_csv, read_csv
library(arrow)   # read_parquet, open_dataset, to_duckdb, collect
library(duckdb)
library(ggplot2) # ggplot
library(ggmosaic)
library(corrr)
library(recipes)
library(data.table)
library(xtable)
library(scales)
library(tibble)
