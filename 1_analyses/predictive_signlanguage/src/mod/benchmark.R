
base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    'predictive_signlanguage/',
    'src/',
    'mod/'
    
  )

source(paste0(base_dir, 'pns2019_empty_results_directory.R'))

source(paste0(base_dir, 'pns2019_mod_00_install_packages.R'))

source(paste0(base_dir, 'pns2019_mod_00_load_packages.R'))

source(paste0(base_dir, 'pns2019_mod_01_data_import.R'))

source(paste0(base_dir, 'pns2019_mod_02_data_split.R'))

source(paste0(base_dir, 'pns2019_mod_03_crossval.R'))

source(paste0(base_dir, 'pns2019_mod_04_preproc.R'))

source(paste0(base_dir, 'pns2019_mod_05_classifiers.R'))

source(paste0(base_dir, 'pns2019_mod_06_metrics.R'))

source(paste0(base_dir, 'pns2019_mod_07_workflow_set.R'))

source(paste0(base_dir, 'pns2019_mod_08m_fit_workflowmap.R'))

source(paste0(base_dir, 'pns2019_mod_08r_fit_racing.R'))

source(paste0(base_dir, 'pns2019_mod_09_finalize_models.R'))

source(paste0(base_dir, 'pns2019_mod_10_optimize_threshold.R'))

source(paste0(base_dir, 'pns2019_mod_11_calibrate_model.R'))
