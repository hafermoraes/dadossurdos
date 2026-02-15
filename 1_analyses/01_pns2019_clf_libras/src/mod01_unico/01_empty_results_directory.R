#' Limpeza de Diretório de Resultados
#'
#' @description
#' Este módulo varre recursivamente o diretório definido em \code{results_dir} e 
#' remove permanentemente todos os arquivos encontrados. É utilizado para 
#' garantir um ambiente limpo antes de iniciar novas rodadas de modelagem.
#'
#' @section Procedimento de Segurança:
#' \itemize{
#'   \item \bold{Mapeamento:} Localiza todos os arquivos, incluindo arquivos ocultos e em subdiretórios.
#'   \item \bold{Exclusão:} Executa \code{file.remove} em um loop iterativo.
#' }
#'
#' @note 
#' \strong{Atenção:} Esta operação é irreversível. Certifique-se de que a variável 
#' \code{results_dir} esteja apontando para o caminho correto antes da execução.
#'
#' @author Rafael Rodrigues de Moraes
#' @keywords cleanup utility
NULL

FILES <- 
  list.files(
    path = results_dir,
    full.names = TRUE,
    all.files = TRUE,
    recursive = TRUE
  )

for( f in FILES) {
  file.remove(f)
}

file.remove(
  paste0(
      results_dir,
      "vars_unico.tex"
    )
)
