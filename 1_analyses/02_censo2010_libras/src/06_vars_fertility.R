#' @title Processamento de Variáveis de Fecundidade: Censo 2010
#' 
#' @description
#' Este script realiza o tratamento das variáveis de histórico reprodutivo feminino para o Censo 2010. 
#' Assim como nos módulos anteriores, converte campos de largura fixa em métricas numéricas e 
#' calcula variáveis derivadas, como a mortalidade de filhos nascidos vivos.
#'
#' @section Variáveis e Regras de Cálculo:
#' \itemize{
#'   \item \bold{Nascidos Vivos}: Total de filhos tidos que nasceram vivos (\code{v6633}).
#'   \item \bold{Sobreviventes}: Total de filhos nascidos vivos que permanecem vivos (\code{v6643}).
#'   \item \bold{Nascidos Mortos (Cálculo Indireto)}: Calculado pela diferença entre 
#'     \code{filhos_nascidos_vivos} e \code{filhos_nascidos_vivos_vivos}, visto que a 
#'     variável direta é ausente no layout simplificado de 2010.
#'   \item \bold{Total de Gestações}: Soma total de filhos tidos (\code{v6800}).
#'   \item \bold{Idade no Último Filho}: Idade da mãe no nascimento do último filho (\code{v6660}).
#' }
#'
#' @section Persistência:
#' O processamento ocorre via \code{duckdb}, com coleta e exportação para 
#' \code{censo2010_fertility.csv} no diretório de dados.
#'
#' @name 06_vars_fertility_censo2010
NULL


FILE <- "censo2010_fertility"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_fertility <-
  subset_censo2010 |>
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes à Fecundidade .........
    # TODO incluir filhos nascidos ultimos 12 meses
    filhos_nascidos_vivos = ifelse(v6633=='', NA, as.numeric(v6633)),
    filhos_nascidos_vivos_vivos = ifelse(v6643=='', NA, as.numeric(v6643)),
    filhos_nascidos_mortos = ifelse(v6633=='' && v6643=='', NA, filhos_nascidos_vivos - filhos_nascidos_vivos_vivos),
    filhos_nascidos = ifelse(v6800=='', NA, as.numeric(v6800)),
    idade_ultimo_filho = ifelse(v6660=='', NA, as.numeric(v6660))
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_fertility |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_fertility.csv"),
    na = ""
  )
toc()

gc()
