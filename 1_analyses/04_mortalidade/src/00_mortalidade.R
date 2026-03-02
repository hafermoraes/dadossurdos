
message("removendo todos os objetos prévios...")
rm(list = ls(all.names = TRUE))


PNS2019_PREVALENCES_DATA <- FALSE
PNS2019_PREVALENCES_PLOT <- FALSE

PNS2019_PREVALENCES_BY_AGE_DATA <- FALSE
PNS2019_PREVALENCES_BY_AGE_PLOT <- FALSE

PARETO_DATASUS_DATA <- FALSE
PARETO_DATASUS_PLOT <- FALSE

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

pns2019_parsed_csv <-
  paste0(
    base_dir,
    '01_pns2019_clf_libras/',
    'data/',
    'pns2019_01_parsed.csv'
  )


message("construindo a faixa etária para as análises...")

source(paste0(src_dir, 'mort_utils.R'))

lt_spec <- life_table_structure(OMEGA=95, STEP=5)

source(paste0(src_dir, '01_empty_data_and_results_directory.R'))

source(paste0(src_dir, '02_load_packages.R'))

source(paste0(src_dir, '03_import_data.R'))

source(paste0(src_dir, '04_prepare_censo2000.R'))

source(paste0(src_dir, '04_prepare_censo2010.R'))

source(paste0(src_dir, '04_prepare_pns2019.R'))

source(paste0(src_dir, '05_unify_treated_sources.R'))

source(paste0(src_dir, '06_plot_censo_age_pyramids.R'))

source(paste0(src_dir, '07_intercensal_life_tables.R'))

source(paste0(src_dir, '08_morbidity.R'))

source(paste0(src_dir, '09_morbidity_by_age.R'))

source(paste0(src_dir, '10_datasus.R'))

source(paste0(src_dir, '11_logit_brass.R'))


