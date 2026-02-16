#' Instalação de Dependências e Pacotes de Desenvolvimento
#'
#' @description
#' Este módulo gerencia a instalação dos pacotes necessários para o projeto. 
#' Utiliza o gerenciador \code{pak} para facilitar a instalação de extensões 
#' do \code{tidymodels} que ainda se encontram em repositórios de desenvolvimento 
#' (GitHub).
#'
#' @section Processo de Instalação:
#' \itemize{
#'   \item \bold{Gerenciador de Pacotes:} Instala o pacote \code{pak} via CRAN, 
#'   que oferece instalações mais rápidas e seguras.
#'   \item \bold{Extensões Tidymodels:} Instala o pacote \code{tailor} 
#'   diretamente do repositório oficial da organização no GitHub.
#' }
#'
#' @note 
#' A instalação do \code{tailor} é essencial para as etapas de calibração e 
#' ajuste de thresholds customizados que ocorrem no final do pipeline.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords setup installation
NULL

packs <- c(
  'pak'
)
install.packages(packs)

pak::pak('tidymodels/tailor')
