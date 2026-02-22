
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

  
censo2000_abt_parquet <-
  paste0(
    base_dir,
    '02_censo2000_libras/',
    'data/',
    'censo2000_abt.parquet'
  )
  
censo2010_abt_parquet <-
  paste0(
    base_dir,
    '02_censo2010_libras/',
    'data/',
    'censo2010_abt.parquet'
  )
  

message("construindo a faixa etária para as análises...")

source(paste0(src_dir, 'mort_utils.R'))
lt_spec <- life_table_structure(OMEGA=95, STEP=5)


source(paste0(src_dir, '01_empty_data_and_results_directory.R'))

source(paste0(src_dir, '02_load_packages.R'))

source(paste0(src_dir, '03_import_data.R'))

source(paste0(src_dir, '04_prepare_censo2000.R'))

source(paste0(src_dir, '05_prepare_censo2010.R'))

source(paste0(src_dir, '06_unify_tables.R'))

source(paste0(src_dir, '07_plot_age_pyramids.R'))

source(paste0(src_dir, '08_life_tables.R'))

