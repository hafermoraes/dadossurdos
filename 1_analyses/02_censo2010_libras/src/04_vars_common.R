
#' @title Processamento de Variáveis Demográficas Comuns: Censo 2010
#' 
#' @description
#' Este script realiza a decodificação e a padronização das características sociodemográficas 
#' básicas dos microdados do Censo 2010. O processo inclui o cruzamento com o dicionário 
#' de variáveis para identificação geográfica e a recodificação de níveis para educação, 
#' estado civil e deficiências sensoriais/motoras, visando compatibilidade com a PNS 2019.
#'
#' @section Regras de Harmonização:
#' \itemize{
#'   \item \bold{Geografia}: Integração via \code{left_join} com o dicionário (\code{v0001, v0002}) 
#'     para atribuição de nomes de UF e Município.
#'   \item \bold{Escolaridade}: Reagrupa os 14 níveis originais da variável \code{v0633} em quatro 
#'     categorias principais: \emph{fundamental, médio, superior} e \emph{outros} (incluindo EJA e creche).
#'   \item \bold{Estado Civil}: Consolida categorias de desquite, separação judicial e divórcio 
#'     em um único grupo \emph{'separado'}.
#'   \item \bold{Funcionalidade}: Mapeia as escalas de dificuldade (\code{v0614, v0615, v0616}) 
#'     para a taxonomia padrão: \emph{incapaz, grande, alguma, nenhuma}.
#' }
#'
#' @section Persistência:
#' Os dados transformados são coletados do motor analítico \code{duckdb} e exportados para 
#' o arquivo \code{censo2010_common.csv} no diretório de dados.
#'
#' @name 04_vars_common_censo2010
NULL



FILE <- "censo2010_common"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_common <-
  subset_censo2010 |>
  # joins com dicionário de variáveis
  # v0001: uf de residência
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v0001') |>
      transmute(v0001 = a_code, uf_residencia = a_desc) |>
      distinct(v0001, .keep_all=TRUE),
    keep=FALSE
  ) |> 
  # v0002: município de residência
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v0002') |>
      transmute(v0002 = a_code, municipio_residencia = a_desc) |>
      distinct(v0002, .keep_all=TRUE),
    keep=FALSE
  ) |>
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis comuns ........................
    uf_residencia, 
    municipio_residencia,
    idade = if_else(v6036=='',NA,as.numeric(v6036)), 
    sexo = case_when(
      v0601 == '1' ~ 'masculino',
      v0601 == '2' ~ 'feminino',
      TRUE ~ NA
    ),
    alfabetizado = case_when( # sabe ler e escrever
      v0627 == '1' ~ 'sim',
      v0627 == '2' ~ 'nao',
      TRUE ~ NA
    ),
    estado_civil = case_when(
      v0640 == '1' ~ 'casado',     # Casado(a)
      v0640 == '2' ~ 'separado',   # Desquitado(a) ou separado(a) judicialmente
      v0640 == '3' ~ 'separado',   # divorciado(a)
      v0640 == '4' ~ 'viúvo',      # viúvo(a)
      v0640 == '5' ~ 'solteiro',   # Solteiro(a)
      TRUE ~ NA
    ),
    instrucao = case_when( # curso mais elevado que frequentou
      v0633 == '01' ~ 'outros',      # Creche, pré-escolar (maternal e jardim de infância), classe de alfabetização - CA
      v0633 == '02' ~ 'outros',      # Alfabetização de jovens e adultos
      v0633 == '03' ~ 'fundamental', # Antigo primário (elementar)
      v0633 == '04' ~ 'fundamental', # Antigo ginásio (médio 1º ciclo)
      v0633 == '05' ~ 'fundamental', # Ensino fundamental ou 1º grau (da 1ª a 3ª série/ do 1º ao 4º ano)
      v0633 == '06' ~ 'fundamental', # Ensino fundamental ou 1º grau (4ª série/ 5º ano)
      v0633 == '07' ~ 'fundamental', # Ensino fundamental ou 1º grau (da 5ª a 8ª série/ 6º ao 9º ano)
      v0633 == '08' ~ 'fundamental', # Supletivo do ensino fundamental ou do 1º grau
      v0633 == '09' ~ 'medio',       # Antigo científico, clássico, etc.....(médio 2º ciclo)
      v0633 == '10' ~ 'medio',       # Regular ou supletivo do ensino médio ou do 2º grau
      v0633 == '11' ~ 'superior',    # Superior de graduação
      v0633 == '12' ~ 'superior',    # Especialização de nível superior ( mínimo de 360 horas )
      v0633 == '13' ~ 'superior',    # Mestrado
      v0633 == '14' ~ 'superior',    # Doutorado
      TRUE ~ NA
    ),
    cor_raca = case_when(
      v0606 == '1' ~ 'branca',
      v0606 == '2' ~ 'preta',
      v0606 == '3' ~ 'amarela',
      v0606 == '4' ~ 'parda',
      v0606 == '5' ~ 'indigena',
      v0606 == '9' ~ 'outros',
      TRUE ~ NA
      ),
    dif_enxergar = case_when( # capacidade de enxergar
      v0614 == '1' ~ 'incapaz',   # incapaz
      v0614 == '2' ~ 'grande',    # grande dificuldade permanente
      v0614 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0614 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0614 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    dif_ouvir = case_when( # capacidade de ouvir
      v0615 == '1' ~ 'incapaz',   # incapaz
      v0615 == '2' ~ 'grande',    # grande dificuldade permanente
      v0615 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0615 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0615 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    dif_locomover = case_when( # capacidade de caminhar/subir escadas
      v0616 == '1' ~ 'incapaz',   # incapaz
      v0616 == '2' ~ 'grande',    # grande dificuldade permanente
      v0616 == '3' ~ 'alguma',    # alguma dificuldade permanente
      v0616 == '4' ~ 'nenhuma',   # nenhuma dificuldade
      v0616 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    )
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_common |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_common.csv"),
    na = ""
  )
toc()

gc()

