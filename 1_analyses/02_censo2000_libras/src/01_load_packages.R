#' @title Carregamento de Dependências: Censo 2000 (Libras)
#' 
#' @description
#' Este script centraliza o carregamento das bibliotecas necessárias para o 
#' processamento dos microdados do Censo 2000. A stack tecnológica é focada em 
#' alta performance para Big Data e pipelines de Machine Learning (Tidymodels).
#'
#' @section Grupos de Ferramentas:
#' \itemize{
#'   \item \bold{Dados e Performance}: \code{arrow} e \code{duckdb} para manipulação de arquivos Parquet e execução SQL em disco.
#'   \item \bold{Manipulação Tidy}: \code{dplyr, readr, stringr} para transformação e limpeza de strings.
#'   \item \bold{Ecossistema Tidymodels}: \code{tidymodels} para o fluxo de modelagem, \code{themis} para balanceamento de classes (oversampling/downsampling) e \code{embed} para encodings de variáveis categóricas.
#'   \item \bold{Engenharia de Texto e Atributos}: \code{textrecipes} para limpeza de nomes e \code{janitor} para tabelas de frequência e limpeza de metadados.
#' }
#'
#' @note 
#' O uso de \code{tictoc} é essencial para o monitoramento de performance em scripts 
#' de longa duração comuns no processamento do Censo 2000.
#'
#' @name 01_load_packages_censo
NULL

library(arrow)    # open_dataset, collect
library(duckdb)   # to_duckdb
library(dplyr)    # |>,  mutate, transmute, select
library(readr)    # read_csv, read_delim
library(stringr)  # str_trim

library(tidymodels)
library(janitor)
library(themis)
library(textrecipes)   # step_clean_names
library(janitor)
library(themis)        # step_downsample
library(embed)

library(tictoc)
