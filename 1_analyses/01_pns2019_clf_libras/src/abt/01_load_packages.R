#' @title Carregamento de Dependências do Projeto
#' 
#' @description
#' Este script centraliza todas as bibliotecas necessárias para a execução das análises
#' da PNS 2019. O carregamento é organizado por categorias funcionais: manipulação de dados,
#' amostragem complexa, armazenamento e visualização.
#'
#' @section Dependências Principais:
#' \itemize{
#'   \item \code{dplyr, tidyr, tibble}: Gramática de manipulação e organização de dados (Tidyverse).
#'   \item \code{survey, srvyr}: Processamento de dados provenientes de amostragem complexa.
#'   \item \code{arrow, duckdb}: Manipulação eficiente de grandes volumes de dados em disco (Parquet/SQL).
#'   \item \code{ggplot2, ggmosaic, scales}: Geração de gráficos e escalas de visualização.
#'   \item \code{recipes, corrr}: Engenharia de atributos (feature engineering) e análise de correlação.
#'   \item \code{xtable, data.table}: Exportação de tabelas (LaTeX) e processamento de alta performance.
#'   \item \code{tictoc}: Monitoramento do tempo de execução de rotinas críticas.
#' }
#'
#' @note 
#' Certifique-se de que os pacotes estão instalados no ambiente RStudio Server antes da execução.
#'
#' @name 01_load_packages
NULL

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
library(tictoc)
library(tidytext)
