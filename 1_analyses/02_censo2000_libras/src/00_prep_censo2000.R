base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '02_censo2000_libras/'
  )

src_dir <-
  paste0(
    base_dir,
    'src/'
  )

data_dir <-
  paste0(
    base_dir,
    'data/'
  )


source(paste0(src_dir, '01_load_packages.R'))

source(paste0(src_dir, '02_import_microdata.R'))

source(paste0(src_dir, '03_vars_survey_expansion.R'))

source(paste0(src_dir, '04_vars_commons.R'))

source(paste0(src_dir, '05_vars_family_arrangements.R'))

source(paste0(src_dir, '06_vars_fertility.R'))

source(paste0(src_dir, '07_vars_migration.R'))

source(paste0(src_dir, '08_vars_libras_clf.R'))

source(paste0(src_dir, '09_export_abt.R'))

