

RUN_BOOTSTRAP <- FALSE

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
    '05_fecundidade/',
    'src/'
  )

data_dir <-
  paste0(
    base_dir,
    '05_fecundidade/',
    'data/'
  )

results_dir <-
  paste0(
    base_dir,
    '05_fecundidade/',
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

source(paste0(src_dir, 'fert_utils.R'))

source(paste0(src_dir, '01_empty_data_and_results_directory.R'))

source(paste0(src_dir, '02_load_packages.R'))

source(paste0(src_dir, '03_import_data.R'))

source(paste0(src_dir, '04_prepare_censo2000.R'))

source(paste0(src_dir, '04_prepare_censo2010.R'))

source(paste0(src_dir, '04_prepare_pns2019.R'))

source(paste0(src_dir, '05_unify_treated_sources.R'))

source(paste0(src_dir, '06_adjust_el_badry.R'))

source(paste0(src_dir, '07_calculate_cohort_measures.R'))

source(paste0(src_dir, '08_calculate_period_measures.R'))

source(paste0(src_dir, '09_simulate_bootstrap_samples.R'))

source(paste0(src_dir, '10_graphical_analyses.R'))

source(paste0(src_dir, '11_summaries_latex.R'))

source(paste0(src_dir, '12_prepare_fertility_models.R'))






