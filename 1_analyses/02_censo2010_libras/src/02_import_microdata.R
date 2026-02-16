#' @title Importação e Harmonização de Microdados: Censo 2010
#' 
#' @description
#' Este script realiza a extração e o tratamento inicial dos microdados do Censo 2010 
#' (Registro de Pessoas). Ele seleciona variáveis críticas para demografia, fecundidade, 
#' migração e deficiências, integrando-as ao dicionário de variáveis via \code{duckdb} 
#' para otimização de performance em larga escala.
#'
#' @section Componentes do Processamento:
#' \itemize{
#'   \item \bold{Dicionário de Variáveis}: Carga dos metadados da base 'pess' (Pessoas) com normalização de descrições.
#'   \item \bold{Seleção Temática}:
#'     \itemize{
#'       \item \emph{Amostragem}: \code{v0011} (área de ponderação) e \code{v0010} (peso).
#'       \item \emph{Demografia}: Sexo, idade (\code{v6036}), raça, alfabetização e instrução.
#'       \item \emph{Deficiência}: Variáveis de dificuldade sensorial e motora (\code{v0614} a \code{v0616}).
#'       \item \emph{Fecundidade}: Filhos nascidos vivos, sobreviventes e idade no último parto.
#'       \item \emph{Migração}: Histórico de residência anterior, naturalidade e tempo de moradia.
#'     }
#'   \item \bold{Engenharia de Atributos}: 
#'     \itemize{
#'       \item Concatenção de UF e Município (\code{v0001} + \code{v0002}) para criação do código IBGE completo.
#'       \item Truncamento de códigos de UF (\code{str_sub}) para normalização geográfica.
#'       \item Criação de \code{row_id} único para integridade referencial.
#'     }
#' }
#'
#' @note 
#' O Censo 2010 não possui a variável direta de "filhos nascidos mortos", que deve ser 
#' obtida por diferença entre o total de nascidos (\code{v6800}) e nascidos vivos (\code{v6633}).
#'
#' @name 02_import_microdata_censo2010
NULL

message("importando dicionário de variáveis ...")
dvar_censo2010 <-
  read_delim(
    '/tmp/etl/br_ibge_censo_2010/variables_dictionary.txt',
    delim = '|',
    show_col_types = FALSE
  ) |>
  filter(
    base=='pess'
  ) |>
  mutate(
    a_desc = str_trim(a_desc),
    a_desc = str_to_title(a_desc, locale = 'pt-br')
  ) |>
  to_duckdb()

tic()
message("harmonizando as variáveis do censo2010 ...")
subset_censo2010 <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2010/parquet/pess"
  ) |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  select(
    # expansão da amostra probabilística
    v0011, # area_ponderacao (área de ponderação)
    v0010, # peso_amostral (peso amostral)
    
    # variáveis comuns às análises demográficas e ao preditivo libras
    v0001, # uf_residencia (uf de residência)
    v0601, # sexo
    v6036, # idade
    v0606, # cor_raca (cor ou raça)
    v0627, # alfabetizado (sabe ler e escrever)
    v0640, # estado civil
    v0633, # instrucao (curso mais elevado que frequentou)
    v0614, # dif_enxergar (capacidade de enxergar)
    v0615, # dif_ouvir (capacidade de ouvir)
    v0616, # dif_locomover (capacidade de caminhar/subir escadas)

    # variáveis de arranjos domiciliares
    v0502, # relacao_resp_domicilio
    v0504, # nr_ordem_pessoa
    v0300, # id_domicilio

    # variáveis de fecundidade
    v6633, # filhos_nascidos_vivos
    v6643, # filhos_nascidos_vivos_vivos
    # filhos_nascidos_mortos indisponível em 2010, mas sai por diferença
    v6800, # filhos_nascidos
    v6660, # idade_ultimo_filho
    
    # variáveis de migração
    v6252, # uf de residência anterior
    v6262, # uf de residência data fixa
    v0623, # uf_residencia_tempo_anos
    v6222, # uf de nascimento
    v0619, # uf_naturalidade
    
    v0002, # município de residência
    v6254, # município de residência anterior
    v6264, # município de residência data fixa
    v0624, # municipio_residencia_tempo_anos
    v0618, # municipio_sempre_morou (mora neste município desde que nasceu?)
    #        e municipio_naturalidade (nasceu neste município?)
    
    v6256, # país de residência anterior
    v6266, # país de residência data fixa
    v6224, # país de nascimento
    v0620, # nacionalidade (qual é a sua nacionalidade?)
    v0621  # ano_fixou_residencia_brasil (em que ano fixou residência no brasil?)

  ) |>
  mutate(
    across(everything(), ~ str_trim(.)),
    v0010 = as.numeric(v0010),
    v0002 = paste0(v0001,v0002),
    v6222 = str_sub(v6222, start=1, end=2),
    v6252 = str_sub(v6252, start=1, end=2),
    v6262 = str_sub(v6262, start=1, end=2)
  ) |>
  to_duckdb() |>
  mutate(
    row_id = row_number()
  )
toc()






