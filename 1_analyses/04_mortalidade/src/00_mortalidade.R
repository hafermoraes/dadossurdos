
base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/'
  )

src_dir <-
  paste0(
    base_dir,
    '04_mortalidade/',
    'src/'
  )

data_dir <-
  paste0(
    base_dir,
    '04_mortalidade/',
    'data/'
  )

results_dir <-
  paste0(
    base_dir,
    '04_mortalidade/',
    'results/'
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
  

source(paste0(src_dir, '01_load_packages.R'))

source(paste0(src_dir, '02_import_data.R'))

source(paste0(src_dir, '03_prepare_censo2000.R'))

source(paste0(src_dir, '04_prepare_censo2010.R'))

