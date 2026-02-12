
base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '01_pns2019_clf_libras/'
  )

src_dir <-
  paste0(
    base_dir,
    'src/abt/'
  )

data_dir <-
  paste0(
    base_dir,
    'data/'
  )

eda_dir <-
  paste0(
    base_dir,
    "eda/"
  )


source(paste0(src_dir, '01_load_packages.R'))
  
#source(paste0(src_dir, '02_rawdata_survey.R'))

source(paste0(src_dir, '02_rawdata_datatable.R'))

source(paste0(src_dir, '03_eda.R'))

source(paste0(src_dir, '04_modelmatrix.R'))
