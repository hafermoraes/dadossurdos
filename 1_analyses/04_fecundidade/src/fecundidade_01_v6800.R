
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
    'fecundidade/',
    'src/'
  )

source(paste0(base_dir, 'fecundidade_00_load_packages.R'))
source(paste0(base_dir, 'fecundidade_00_subset_censo2010.R'))


# expansão da amostra
surveydesign <-
  subset_censo2010 |> 
  select(peso_amostral, dif_ouvir, filhos_nascidos) |>
  as_survey_design(
    ids = 1,
    weights = peso_amostral
  )

gc()

# % e IC por dif_ouvir dos filhos nascidos
surveydesign |>
  group_by(dif_ouvir) |>
  summarise(
    qtde = survey_mean(filhos_nascidos, vartype = 'ci', na.rm = TRUE)
  )

