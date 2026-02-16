#' Ambiente de Modelagem Preditiva e Dependências
#'
#' @description
#' Este módulo centraliza o carregamento das bibliotecas necessárias para o 
#' pipeline de machine learning. Abrange desde o pré-processamento de dados 
#' até o ajuste fino (tuning) e calibração de modelos.
#'
#' @section Grupos de Ferramentas:
#' \itemize{
#'   \item \bold{Manipulação de Dados:} \code{readr}, \code{dplyr}, \code{janitor}, \code{stringr}.
#'   \item \bold{Ecossistema Tidymodels:} \code{tidymodels}, \code{finetune}, \code{parsnip}.
#'   \item \bold{Engenharia de Features:} \code{textrecipes}, \code{themis}, \code{embed}.
#'   \item \bold{Algoritmos Específicos:} \code{bonsai} (LightGBM), \code{baguette}, \code{earth} (MARS), \code{kernlab} (SVM).
#'   \item \bold{Avaliação e Calibração:} \code{probably}, \code{betacal}, \code{vip}, \code{tailor}.
#'   \item \bold{Exportação e Performance:} \code{xtable}, \code{doParallel}.
#' }
#'
#' @note 
#' O pacote \code{catboost} está comentado por padrão para evitar conflitos de 
#' instalação em ambientes sem suporte a GPU ou dependências específicas de C++.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords library-dependencies machine-learning
NULL

library(tictoc)
library(readr)         # read_csv, write_rds,read_rds
library(dplyr)         # |>, mutate, glimpse
library(tidymodels)    # initial_splits, train, test
library(textrecipes)   # step_clean_names
library(janitor)
library(themis)        # step_downsample
library(stringr)       # str_remove_all
library(probably)      # cal_plot_breaks, cal_apply, cal_estimate_*
library(betacal)
library(tailor)
library(discrim)
library(finetune)
library(doParallel)
library(lme4)
library(vip)
library(bonsai)
library(baguette)
library(earth)
library(kernlab)
library(parsnip)
library(solitude)
library(xtable)
library(embed)
#library(catboost)
