
PARALLEL <- FALSE

KFOLD <- FALSE
KFOLD_NR <- 5

BOOTSTRAP_TIMES <- 50

METRIC <- "j_index"

CONF_MAT_SUB <- FALSE

VARIABLE_IMPORTANCE <- FALSE

base_dir <-
  paste0(
    '/home/rstudio/',
    '1_analyses/',
    '01_pns2019_clf_libras/'
  )

model <- 'mod03_alguma/'

results_dir <-
  paste0(
    base_dir,
    'results/',
    model
  )

src_dir <-
  paste0(
    base_dir,
    'src/',
    model
  )

source(paste0(src_dir, '01_empty_results_directory.R'))

source(paste0(src_dir, '02_install_packages.R'))

source(paste0(src_dir, '03_load_packages.R'))

source(paste0(src_dir, '04_data_import.R'))

source(paste0(src_dir, '05_data_split.R'))

source(paste0(src_dir, '06_crossval.R'))

source(paste0(src_dir, '07_preproc.R'))

source(paste0(src_dir, '08_classifiers.R'))

source(paste0(src_dir, '09_metrics.R'))

source(paste0(src_dir, '10_workflow_set.R'))

source(paste0(src_dir, '11m_fit_workflowmap.R'))

source(paste0(src_dir, '11r_fit_racing.R'))

source(paste0(src_dir, '12_finalize_models.R'))

source(paste0(src_dir, '13_optimize_threshold.R'))

source(paste0(src_dir, '14_calibrate_model.R'))

