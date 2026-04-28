
message("removendo todos os objetos prévios...")
rm(list = ls(all.names = TRUE))


REGIONS <-
  c(
    "Norte",
    "Nordeste",
    "Sudeste",
    "Sul",
    "Centro Oeste"
  )


base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/'
  )

src_dir <-
  paste0(
    base_dir,
    '08_espacializacao/',
    'src/'
  )

data_dir <-
  paste0(
    base_dir,
    '08_espacializacao/',
    'data/'
  )

results_dir <-
  paste0(
    base_dir,
    '08_espacializacao/',
    'results/'
  )

  
censo2010_abt_parquet <-
  paste0(
    base_dir,
    '02_censo2010_libras/',
    'data/',
    'censo2010_abt.parquet'
  )


source(paste0(src_dir, 'spatial_utils.R'))

source(paste0(src_dir, '01_empty_data_and_results_directory.R'))

source(paste0(src_dir, '02_load_packages.R'))

source(paste0(src_dir, '03_import_geometries.R'))

source(paste0(src_dir, '04_import_cil.R'))

source(paste0(src_dir, '05_import_censo2010.R'))

source(paste0(src_dir, '06_prepare_spatial_dataframe.R'))






