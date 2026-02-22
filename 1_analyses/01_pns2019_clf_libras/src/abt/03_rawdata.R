#' @title Processamento de Microdados da PNS 2019
#' 
#' @description
#' Este script realiza a extração dos microdados brutos em formato Parquet, 
#' a decodificação das variáveis categóricas conforme o dicionário oficial do IBGE 
#' e a exportação de um arquivo processado para modelagem.
#'
#' @section Etapas do Processamento:
#' \itemize{
#'   \item \bold{Extração}: Leitura de dataset via \code{arrow} e seleção de variáveis de interesse (demografia, saúde e deficiência).
#'   \item \bold{Dicionário}: Importação e parse do arquivo de variáveis para mapeamento das Unidades da Federação (UF).
#'   \item \bold{Transformação}: 
#'     \itemize{
#'       \item Recodificação de níveis (Instrução, Estado Civil, Cor/Raça).
#'       \item Consolidação de graus de dificuldade (Enxergar, Ouvir, Locomover).
#'       \item Tratamento de missing values (NAs) para categorias padrão (ex: 'nenhuma' ou 'outros').
#'     }
#'   \item \bold{Carga}: Exportação dos dados limpos para \code{pns2019_01_rawdata.csv}.
#' }
#'
#' @section Variáveis Alvo:
#' \itemize{
#'   \item \code{libras}: Variável dependente (Sabe usar Libras).
#'   \item \code{v0024...v00283}: Pesos e variáveis de amostragem complexa.
#' }
#' 
#' @name 02_rawdata
NULL

tic()
message("importando microdados da PNS2019...")
rawdata <- open_dataset(
  "/tmp/etl/br_ibge_pns_2019/parquet"
) |>
  rename_with(tolower) |>
  select(
    v0024,v0028,upa_pns,v00282,v00283, # expansão da amostra probabilística
    v0001,  # uf de residência
    c006,   # sexo
    c008,   # idade
    c009,   # cor ou raça
    d001,   # alfabetizado
    c011,   # estado civil
    d00901, # instrução
    g046,   # dificuldade de enxergar
    g047,   # dificuldade de enxergar
    g057,   # dificuldade de ouvir
    g058,   # dificuldade de ouvir
    g070,   # dificuldade de locomover
    g071,   # dificuldade de locomover
    g05801, # sabe libras
    # Variáveis utilizadas na fecundidade (mulheres acima de 15 anos)
    r031,   # relações sexuais últimos 12 meses
    r032,   # grupo planejamento familiar últimos 12 meses
    # r033,   # parceiro grupo planejamento familiar últimos 12 meses
    r034,   # usa método para evitar gravidez? 1 sim 2 não
    # motivo não evitar gravidez (r034 == 2)
    ## r035 == 1 quer engravidar
    ## r035 == 2 motivos religiosos
    ## r035 == 3 não sabe como evitar
    ## r035 == 4 não sabe aonde ir ou quem procurar para lhe dar orientações
    ## r035 == 5 está grávida
    ## r035 == 6 ligou as trompas
    ## r035 == 7 companheiro fez vasectomia
    ## r035 == 8 não tem relações sexuais com homens
    r035,
    # métodos contraceptivos (r034 == 1)
    r03601,  # pílula
    r03602,  # tabela
    r03603,  # camisinha masculina
    r03604,  # camisinha feminina
    r03605,  # diafragma
    r03606,  # DIU
    r03607,  # contraceptivo injetável
    r03608,  # implantes (norplant)
    r03609,  # creme / óvulo
    r03610,  # pílula do dia seguinte
    # tratamento para engravidar
    r037,    # tratamento para engravidar
    ## r038,    # quanto tempo tentando engravidar    
    # Variáveis usadas nas análises de Mortalidade/Morbidade
    # Módulo Q - Doenças Crônicas
    q00201,  # diagnóstico de hipertensão arterial
    q03001,  # diagnóstico de diabetes
    q060,    # diagnóstico de colesterol alto
    q06306,  # diagnóstico de uma doença no coração
    q06307,  #  infarto
    q06308,  #  angina
    q06309,  #  insuf
    q06310,  #  arritmia
    q068,    # diagnóstico de AVC/derrame
    q074,    # diagnóstico de asma (bronquite asmática)
    q079,    # diagnóstico de artrite ou reumatismo
    q088,    # diagnóstico de DORT
    q092,    # diagnóstico de depressão por médico
    q11006,  # diagnóstico de doença mental
    q11007,  #  esquizofrenia
    q11008,  #  transtorno bipolar
    q11009,  #  TOC
    q11604,  # diagnóstico de doença crônica pulmão
    q11605,  #  enfisema pulmonar
    q11606,  #  bronquite crônica
    q120,    # diagnóstico de câncer
    q12102,  # diagnóstico de câncer de pele
    q12104,  # diagnóstico de câncer de pulmão
    q12105,  # diagnóstico de câncer de cólon ou reto
    q12106,  # diagnóstico de câncer de estômago
    q12107,  # diagnóstico de câncer de mama
    q12108,  # diagnóstico de câncer de cólon de útero
    q12109,  # diagnóstico de câncer de próstata
    q121010, # diagnóstico de câncer de boca, orofaringe ou laringe
    q121011, # diagnóstico de câncer de bexiga
    q121012, # diagnóstico de câncer de linfoma ou leucemia
    q121013, # diagnóstico de câncer de cérebro
    q121014, # diagnóstico de câncer de ovário
    q121015, # diagnóstico de câncer de tireóide
    q124,    # diagnóstico de doença renal crônica
    # Módulo V - Violência
    v00201,  # ofendido/humilhado/ridicularizado últimos 12meses
    v00202,  # grito/xingamento últimos 12meses
    v00203,  # ameçadado redes sociais últimos 12meses
    v00204,  # ameaça verbal últimos 12meses
    v00205,  # destruir posso últimos 12 meses
    # Módulo T - Doenças Transmissíveis
    t003,    # diagnóstico de doença de chagas
    t004,    # diagnóstico de doença sexualmente transmissível
    # Módulo W - Antropometria
    w00203,  # Altura - Final (em cm)(3 inteiros e 1 casa decimal)
    w00103   # Peso - Final (em kg)(3 inteiros e 1 casa decimal)
  ) |>
  mutate(
    across(everything(), str_trim),
    across(
      c(v0024,v0028,upa_pns,v00282,v00283,c008),
      ~as.numeric(if_else(.x == "", 0, .x))
    )
  ) |>
  collect() |>
  as.data.table()
toc()


tic()
message("salvando os microdados não tratados em disco...")
rawdata |>
  write_csv(
    paste0(
      data_dir,
      'pns2019_00_subset_rawdata.csv'
    )
  )
toc()

