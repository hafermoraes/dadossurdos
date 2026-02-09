
base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    'predictive_signlanguage/'
  )

source(paste0(base_dir, 'src/abt/01_load_packages.R'))
  
#source(paste0(base_dir, 'src/abt/02_rawdata_survey.R'))

source(paste0(base_dir, 'src/abt/02_rawdata_datatable.R'))

source(paste0(base_dir, 'src/abt/03_pre_modelmatrix.R'))

source(paste0(base_dir, 'src/abt/04_eda.R'))

source(paste0(base_dir, 'src/abt/05_modelmatrix.R'))
