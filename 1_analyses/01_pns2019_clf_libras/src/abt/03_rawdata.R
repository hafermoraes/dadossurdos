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
    ## # Variáveis utilizadas na fecundidade (mulheres acima de 15 anos)
    r031,   # relações sexuais últimos 12 meses
    r032,   # grupo planejamento familiar últimos 12 meses
    r033,   # parceiro grupo planejamento familiar últimos 12 meses
    r034,   # usa método para evitar gravidez? 1 sim 2 não
    ## # motivo não evitar gravidez (r034 == 2)
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
    r038,    # quanto tempo tentando engravidar    
    # Variáveis usadas nas análises de Mortalidade/Morbidade
    # Módulo Q - Doenças Crônicas
    q00201,  # diagnóstico de hipertensão arterial
    q03001,  # diagnóstico de diabetes
    q060,    # diagnóstico de colesterol alto
    q06306,  # diagnóstico de uma doença no coração (infarto q06307, angina q06308, insuf q06309, arritmia q06310)
    q068,    # diagnóstico de AVC/derrame
    q074,    # diagnóstico de asma (bronquite asmática)
    q079,    # diagnóstico de artrite ou reumatismo
    q088,    # diagnóstico de DORT
    q092,    # diagnóstico de depressão por médico
    q11006,  # diagnóstico de doença mental (esquizofrenia q11007, transtorno bipolar q11008, TOC q11009)
    q11604,  # diagnóstico de doença crônica pulmão (enfisema pulmonar q11605, bronquite crônica q11606)
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
    t004     # diagnóstico de doença sexualmente transmissível
    
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




tic()
message("importando dicionário de variáveis da PNS2019...")
# importação das unidades da federação
uf <-
  read_delim(
    '/tmp/etl/br_ibge_pns_2019/variables_dictionary.txt',
    delim='|',
    show_col_types = FALSE
  ) |>
  filter( q_code == 'v0001') |>
  transmute( cod_uf = a_code, uf = a_desc)
toc()


tic()
message("renomeando as variáveis e tratando seus dados...")
microdados <-
  rawdata |>
  transmute(
    v0024,v0028,upa_pns,v00282,v00283, # expansão da amostra probabilística
    # unidade da federação
    cod_uf = v0001,
    # idade calculada em anos completos - a partir de 1 ano
    idade = c008,
    # sexo
    sexo = case_when(
      c006 == '1' ~ 'masculino',
      c006 == '2' ~ 'feminino',
      TRUE ~ NA
    ),
    # Sabe ler e escrever
    alfabetizado = case_when(
      d001 == '1' ~ 'sim',
      d001 == '2' ~ 'nao',
      TRUE ~ NA
    ),
    # Qual é o estado civil de ___?
    estado_civil = case_when(
      c011 == '1' ~ 'casado',    # Casado(a)
      c011 == '2' ~ 'separado',  # Divorciado(a) ou desquitado(a) ou separado(a) judicialmente
      c011 == '3' ~ 'viuvo',     # Viúvo(a)
      c011 == '4' ~ 'solteiro',  # Solteiro(a)
      TRUE ~ NA
    ),
    # Qual foi o curso mais elevado que ___frequentou
    instrucao = case_when(
      d00901 == '01' ~ 'outros',      # Creche
      d00901 == '02' ~ 'outros',      # Pré-escola
      d00901 == '03' ~ 'outros',      # Classe de alfabetização – CA
      d00901 == '04' ~ 'outros',      # Alfabetização de jovens e adultos
      d00901 == '05' ~ 'fundamental', # Antigo primário (elementar)
      d00901 == '06' ~ 'fundamental', # Antigo ginasial (médio 1º ciclo)
      d00901 == '07' ~ 'fundamental', # Regular do ensino fundamental ou do 1º grau
      d00901 == '08' ~ 'fundamental', # Educação de jovens e adultos (EJA) ou supletivo do ensino fundamental
      d00901 == '09' ~ 'medio',       # Antigo científico, clássico etc. (médio 2º ciclo)
      d00901 == '10' ~ 'medio',       # Regular do ensino médio ou do 2º grau
      d00901 == '11' ~ 'medio',       # Educação de jovens e adultos (EJA) ou supletivo do ensino médio
      d00901 == '12' ~ 'superior',    # Superior – graduação
      d00901 == '13' ~ 'superior',    # Especialização de nível superior (duração mínima de 360 horas)
      d00901 == '14' ~ 'superior',    # Mestrado
      d00901 == '15' ~ 'superior',    # Doutorado
      TRUE ~ NA
    ),
    # cor ou raça
    cor_raca = case_when(
      c009 == '1' ~ 'branca',
      c009 == '2' ~ 'preta',
      c009 == '3' ~ 'amarela',
      c009 == '4' ~ 'parda',
      c009 == '5' ~ 'indigena',
      c009 == '9' ~ 'outros',
      TRUE ~ NA
    ),
    # . ___ tem dificuldade permanente de enxergar mesmo usando óculos, lentes de contato ou lupas?
    dif_enxergar = case_when(
      g046 == '' ~ g047,
      g047 == '' ~ g046,
      TRUE ~ NA
    ),
    dif_enxergar = case_when(
      dif_enxergar == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      dif_enxergar == '3' ~ 'grande',    # Sim, muita dificuldade
      dif_enxergar == '2' ~ 'alguma',    # Sim, alguma dificuldade
      dif_enxergar == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      dif_enxergar == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # ___ tem dificuldade permanente de ouvir mesmo usando aparelhos auditivos? (Para moradores com 5 anos ou mais de idade.) OU ___ tem dificuldade permanente para ouvir sons como vozes ou música, mesmo usando aparelhos auditivos? (Para moradores com 2 a 4 anos de idade.)
    dif_ouvir = case_when(
      g057 == '' ~ g058,
      g058 == '' ~ g057,
      TRUE ~ NA
    ),
    dif_ouvir = case_when(
      dif_ouvir == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      dif_ouvir == '3' ~ 'grande',    # Sim, muita dificuldade
      dif_ouvir == '2' ~ 'alguma',    # Sim, alguma dificuldade
      dif_ouvir == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      dif_ouvir == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # ___ tem dificuldade permanente de caminhar ou subir degraus, mesmo usando prótese, bengala ou outro aparelho de auxílio? (Para moradores com 5 anos ou mais de idade.)OUComparado com crianças da mesma idade, ___ tem dificuldade permanente para caminhar, mesmo usando prótese, bengala ou aparelho de auxílio? (Para moradores com 2 a 4 anos de idade.)
    dif_locomover = case_when(
      g070 == '' ~ g071,
      g071 == '' ~ g070,
      TRUE ~ NA
    ),
    dif_locomover = case_when(
      dif_locomover == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      dif_locomover == '3' ~ 'grande',    # Sim, muita dificuldade
      dif_locomover == '2' ~ 'alguma',    # Sim, alguma dificuldade
      dif_locomover == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      dif_locomover == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # Sabe usar a Língua Brasileira de Sinais – Libras? (Para moradores com 5 anos ou mais de idade.)
    libras = case_when(
      g05801 == '1' ~ 'sim',
      g05801 == '2' ~ 'nao',
      TRUE ~ NA
    )
  ) |>
  left_join(uf, by=c('cod_uf'), keep = FALSE) |>
  select(-cod_uf) |>
  mutate(
    instrucao = case_when(
      is.na(instrucao) ~ 'outros',
      TRUE ~ as.character(instrucao)
    ),
    dif_ouvir = case_when(
      is.na(dif_ouvir) ~ 'nenhuma',
      TRUE ~ as.character(dif_ouvir)
    ),
    dif_enxergar = case_when(
      is.na(dif_enxergar) ~ 'nenhuma',
      TRUE ~ as.character(dif_enxergar)
    ),
    dif_locomover = case_when(
      is.na(dif_locomover) ~ 'nenhuma',
      TRUE ~ as.character(dif_locomover)
    )
  )
toc()

tic()
message("salvando os microdados em disco")

microdados |>
  write_csv(
    paste0(
      data_dir,
      'pns2019_01_parsed.csv'
    )
  )

rm(uf)

toc()

gc()
