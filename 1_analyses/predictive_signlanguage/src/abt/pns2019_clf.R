
base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    'predictive_signlanguage/',
    'src/',
    'abt/'
  )

source(paste0(base_dir, 'pns2019_clf_00_load_packages.R'))
  
#source(paste0(base_dir, 'pns2019_clf_01_rawdata_survey.R'))
source(paste0(base_dir, 'pns2019_clf_01_rawdata_datatable.R'))

source(paste0(base_dir, 'pns2019_clf_02_pre_modelmatrix.R'))

source(paste0(base_dir, 'pns2019_clf_03_eda.R'))

