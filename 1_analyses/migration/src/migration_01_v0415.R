
# https://www.ons.gov.uk/methodology/methodologicalpublications/generalmethodology/onsworkingpaperseries/onsmethodologyworkingpaperseriesno9guidetocalculatingstandarderrorsforonssocialsurveys
# https://stats.oarc.ucla.edu/r/seminars/survey-data-analysis-with-r/

# alternativa para acelerar os cálculos
# fastsurvey instalado via
# remotes::install_github("bschneidr/fastsurvey", force=TRUE)
# library(fastsurvey)

# subset tomando ainda muito espaço em disco

base_dir <-
  paste0(
    '1_analyses/',
    'migration/',
    'src/'
  )

source(paste0(base_dir, 'migration_00_load_packages.R'))
source(paste0(base_dir, 'migration_00_subset_censo2000.R'))


# expansão da amostra
surveydesign <-
  subset_censo2000 |>
  select(peso_amostral, dif_ouvir, sempre_morou) |>
  as_survey_design(
    ids = 1,
    weights = peso_amostral
  )

gc()

# % e IC por dif_ouvir dos nascidos no município de residência
surveydesign |>
  group_by(dif_ouvir) |>
  summarise(
    pct = survey_mean(sempre_morou, vartype = 'ci', na.rm = TRUE)
  )

