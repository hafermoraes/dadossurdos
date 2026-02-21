#' @title Geração da Matriz de Modelagem (Design Matrix)
#' 
#' @description
#' Este script consolida os microdados expandidos probabilisticamente em uma matriz 
#' de design agregada. Utiliza as estimativas populacionais da PNS 2019 para gerar 
#' combinações únicas de preditores e seus respectivos pesos de frequência.
#'
#' @section Processo de Agregação:
#' \itemize{
#'   \item \bold{\code{svytable}}: Projeta as contagens amostrais para a população brasileira, 
#'   considerando o design de pós-estratificação (\code{pns2019_posterior}).
#'   \item \bold{Filtro de Sparsidade}: Remove combinações de variáveis que não possuem 
#'   representação populacional (\code{n > 0}).
#'   \item \bold{Colapso de Grupos}: Agrupa e sumariza as contagens para garantir a 
#'   unicidade das linhas por combinação de atributos.
#'   \item \bold{Pesos de Frequência}: A variável \code{n} é renomeada para \code{case_weights}, 
#'   parâmetro essencial para o treinamento de modelos ponderados.
#' }
#'
#' @section Variáveis Selecionadas:
#' \itemize{
#'   \item \bold{Preditores}: \code{idade}, \code{sexo}, \code{instrucao}, \code{dif_ouvir}.
#'   \item \bold{Alvo}: \code{libras}.
#' }
#'
#' @return Exporta o arquivo \code{pns2019_02_modelmatrix.csv} para o diretório de dados.
#' 
#' @name 05_modelmatrix
NULL

modelmatrix <-
  svytable(
    formula=~idade+sexo+instrucao+dif_ouvir+libras+uf+alfabetizado,
    design=pns2019_posterior
  ) |>
  as_tibble() |>
  filter(n>0) |>
  group_by(across(-n)) |>
  summarise(n=sum(n)) |>
  arrange(desc(n)) |>
  ungroup() |>
  rename(case_weights=n)


tic()
message("exportando a base de modelagem em disco...")
modelmatrix |>
  arrange(desc(case_weights)) |>
  write_csv(
    paste0(
      data_dir,
      "pns2019_02_modelmatrix.csv"
    )
  )
toc()

