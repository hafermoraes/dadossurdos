#' @title Calibração Amostral e Estimativa de Prevalência de Libras
#' 
#' @description
#' Este script realiza o processamento avançado dos microdados da PNS 2019 via \code{arrow} 
#' e \code{data.table}, configurando o design amostral complexo. O foco principal é a 
#' aplicação da técnica de pós-estratificação para corrigir os pesos amostrais e 
#' calcular estatísticas robustas de prevalência (Libras) segmentadas por idade e 
#' funcionalidade auditiva.
#'
#' @section Detalhes Amostrais:
#' \itemize{
#'   \item \bold{Variáveis de Peso}: Utiliza o conjunto \code{v0028} (Peso do morador selecionado) 
#'   e \code{v00282/v00283} para calibração populacional.
#'   \item \bold{Pós-estratificação}: Ajusta as estimativas da amostra para que os totais 
#'   por estratos coincidam com as projeções populacionais oficiais.
#' }
#'
#' @section Transformações em Tempo Real:
#' \itemize{
#'   \item \bold{Recodificação}: Consolida as variáveis de dificuldade auditiva (\code{g057/g058}) 
#'   e binariza o uso de Libras.
#'   \item \bold{Faixa Etária}: Aplica o corte demográfico (\code{0-4}, \code{4-40}, \code{40+}) 
#'   diretamente no objeto de survey.
#' }
#'
#' @section Métricas de Saída:
#' Calcula a média ponderada (\code{survey_mean}) com erro padrão (\code{se}) e 
#' intervalo de confiança (\code{ci}) de 95%.
#'
#' @name 02_survey_calibration
NULL

microdados_dt <- open_dataset(
  "/tmp/etl/br_ibge_pns_2019/parquet"
) |>
  rename_with(tolower) |> 
  select(
    v0024,v0029,upa_pns,v00292,v00293, # expansão da amostra probabilística
    v0028,v00282,v00283, # expansão da amostra probabilística
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
    g05801  # sabe libras
  ) |>
  mutate(
    across(everything(), str_trim),
    across(
      everything(), 
      ~as.numeric(if_else(.x == "", 0, .x))
    )
  ) |>
  collect() |>
  as.data.table()


pns2019_prior <-
  survey::svydesign(
    ids = ~upa_pns, 
    strata = ~v0024, 
    data = subset(microdados_dt, !is.na(v0028)), 
    weights = ~v0028, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00283=as.character(unique(microdados_dt$v00283)), 
    Freq=as.numeric(unique(microdados_dt$v00282))
  )
popc.types <- popc.types[order(popc.types$v00283),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00283, 
    population=popc.types
  )


pns2019_posterior |>
  as_survey() |>
  mutate(
    idade = cut(c008, c(0,4,40,140)),
    dif_ouvir = case_when(
      g057 == 0 ~ g058,
      g058 == 0 ~ g057
    ),
    libras_01 = case_when(
      g05801 == 1 ~ 1,
      g05801 == 2 ~ 0,
      TRUE ~ NA
    )
  ) |>
  # filter(idade >=5 & idade <= 40) |>
  group_by(dif_ouvir, idade) |>
  summarise(
    n = survey_mean(libras_01, na.rm = TRUE, vartype=c('se','ci'))
  )

