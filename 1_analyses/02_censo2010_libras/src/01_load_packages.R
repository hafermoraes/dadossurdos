
#' @title Carregamento de Dependências: Censo 2010 (Libras)
#' 
#' @description
#' Este script centraliza todas as bibliotecas necessárias para a execução do pipeline 
#' de dados do Censo 2010. A arquitetura de software foca em performance (Arrow/DuckDB) 
#' e robustez estatística para o desenvolvimento de modelos de classificação.
#'
#' @section Pilhas de Software (Tech Stack):
#' \itemize{
#'   \item \bold{Big Data & SQL}: \code{arrow} para leitura de datasets em Parquet e 
#'     \code{duckdb} para processamento analítico eficiente em disco.
#'   \item \bold{Transformação Tidy}: \code{dplyr}, \code{readr} e \code{stringr} para 
#'     limpeza de strings e manipulação gramatical de tabelas.
#'   \item \bold{Modelagem (Tidymodels)}: \code{tidymodels} (core), \code{themis} para 
#'     balanceamento de amostras (downsampling) e \code{embed} para representação 
#'     vetorial de variáveis categóricas.
#'   \item \bold{Engenharia de Atributos}: \code{textrecipes} e \code{janitor} para 
#'     limpeza de metadados e padronização de nomes de colunas.
#' }
#'
#' @note 
#' O uso de \code{tictoc} é obrigatório para o log de performance, dado que o volume 
#' de microdados do Censo 2010 é superior ao de 2000.
#'
#' @name 01_load_packages_censo2010
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
