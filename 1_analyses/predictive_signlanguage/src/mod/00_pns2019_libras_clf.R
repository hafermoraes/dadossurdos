
base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    'predictive_signlanguage/'
  )

source(paste0(base_dir, 'src/mod/01_empty_results_directory.R'))

source(paste0(base_dir, 'src/mod/02_install_packages.R'))

source(paste0(base_dir, 'src/mod/03_load_packages.R'))

source(paste0(base_dir, 'src/mod/04_data_import.R'))

source(paste0(base_dir, 'src/mod/05_data_split.R'))

source(paste0(base_dir, 'src/mod/06_crossval.R'))

source(paste0(base_dir, 'src/mod/07_preproc.R'))

source(paste0(base_dir, 'src/mod/08_classifiers.R'))

source(paste0(base_dir, 'src/mod/09_metrics.R'))

source(paste0(base_dir, 'src/mod/10_workflow_set.R'))

source(paste0(base_dir, 'src/mod/11m_fit_workflowmap.R'))

source(paste0(base_dir, 'src/mod/11r_fit_racing.R'))

source(paste0(base_dir, 'src/mod/12_finalize_models.R'))

source(paste0(base_dir, 'src/mod/13_optimize_threshold.R'))

source(paste0(base_dir, 'src/mod/14_calibrate_model.R'))

