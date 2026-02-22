
tic()
message("tratando os microdados para fins de AED...")
niveis_instrucao <- c('outros','fundamental','medio','superior')
niveis_dificuldade <- c('nenhuma','alguma','grande','incapaz')

pre_modelmatrix <-
  microdados |>
  mutate(
    instrucao = factor(instrucao, levels=niveis_instrucao),
    across(
      c(dif_ouvir, dif_enxergar, dif_locomover),
      \(x) factor(x, levels=niveis_dificuldade)
    ),
    across(where(is.character), as.factor),
    libras_01 = if_else(libras=='sim',1,0),
    faixa_idade = cut(
      idade, 
      breaks = c(0,4,40,140), 
      labels = c("0-4", 
                 "5-40", 
                 "40+"
                 ),
      include.lowest = TRUE)
  ) |>
  filter(
    !is.na(libras)
  )
toc()


tic()
message("expandindo probabilisticamente a amostra nos microdados...")

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <-
  survey::svydesign(
    ids = ~upa_pns, 
    strata = ~v0024, 
    data = subset(pre_modelmatrix, v0028 != 0), 
    weights = ~v0028, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00283=as.character(unique(pre_modelmatrix$v00283)), 
    Freq=as.numeric(unique(pre_modelmatrix$v00282))
  )
popc.types <- popc.types[order(popc.types$v00283),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00283, 
    population=popc.types
  )
toc()

