
message("removendo todos os objetos prévios...")
rm(list = ls(all.names = TRUE))

base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/'
  )

src_dir <-
  paste0(
    base_dir,
    '03_valida_censo_pns/',
    'src/'
  )

data_dir <-
  paste0(
    base_dir,
    '03_valida_censo_pns/',
    'data/'
  )

results_dir <-
  paste0(
    base_dir,
    '03_valida_censo_pns/',
    'results/'
  )


pns2019_csv <-
  paste0(
    base_dir,
    '01_pns2019_clf_libras/',
    'data/',
    'pns2019_02_modelmatrix.csv'
  )
  
censo2000_parquet <-
  paste0(
    base_dir,
    '02_censo2000_libras/',
    'data/',
    'censo2000_abt.parquet'
  )
  
censo2010_parquet <-
  paste0(
    base_dir,
    '02_censo2010_libras/',
    'data/',
    'censo2010_abt.parquet'
  )
  

source(paste0(src_dir, '01_empty_data_and_results_directory.R'))

source(paste0(src_dir, '02_load_packages.R'))

source(paste0(src_dir, '03_import_data.R'))

source(paste0(src_dir, '04_prepare_pns2019.R'))

source(paste0(src_dir, '05_prepare_censo2000.R'))

source(paste0(src_dir, '06_prepare_censo2010.R'))

source(paste0(src_dir, '07_compare_distributions.R'))

source(paste0(src_dir, '08_censo2000_censo2010_stats.R'))

