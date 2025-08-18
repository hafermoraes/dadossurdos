
# https://www.ons.gov.uk/methodology/methodologicalpublications/generalmethodology/onsworkingpaperseries/onsmethodologyworkingpaperseriesno9guidetocalculatingstandarderrorsforonssocialsurveys
# https://stats.oarc.ucla.edu/r/seminars/survey-data-analysis-with-r/

# alternativa para acelerar os cálculos
# fastsurvey instalado via
## remotes::install_github("bschneidr/fastsurvey", force=TRUE)
## library(fastsurvey)

# subset tomando ainda muito espaço em disco

# source('./censo2000_data_import.R')

library(survey)
library(srvyr)

# desenho amostral
surveydesign <-
  subset |>
    transmute(
      peso_amostral,
      dif_ouvir = case_when(
        v0412 == '1' ~ 'incapaz',
        v0412 == '2' ~ 'grande',
        v0412 == '3' ~ 'alguma',
        v0412 == '4' ~ 'nenhuma',
        TRUE ~ NA
      ),
      nasceu_municipio = if_else(v0415=="2", 0, 1)
    ) |>
    as_survey_design(
      ids = 1,
      weights = peso_amostral
    )

# expansão da amostra
surveydesign |>
  group_by(dif_ouvir) |>
  summarise(
    pct_nascido_municipio = survey_mean(nasceu_municipio, vartype = 'ci')
  )


teste <-
  svyby(
    formula = ~nasceu_municipio,
    by = ~dif_ouvir,
    design = surveydesign,
    FUN = svymean,
    keep.var = TRUE
  ) 


svymean(~nasceu_municipio, surveydesign)
