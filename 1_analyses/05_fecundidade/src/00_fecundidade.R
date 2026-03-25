
message("removendo todos os objetos prévios...")
rm(list = ls(all.names = TRUE))

RUN_BOOTSTRAP <- FALSE

PNS2019_PREVALENCES_DATA <- FALSE

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



source(paste0(src_dir, '13a_deficiente_auditivo_2000_PF_Brass.R'))

source(paste0(src_dir, '13b_deficiente_auditivo_2000_GompertzRelMod.R'))

source(paste0(src_dir, '13c_deficiente_auditivo_2010_PF_Brass.R'))

source(paste0(src_dir, '13d_deficiente_auditivo_2010_GompertzRelMod.R'))

source(paste0(src_dir, '13e_deficiente_auditivo_2000_2010_GompertzSintetico.R'))



source(paste0(src_dir, '14a_surdo_2000_PF_Brass.R'))

source(paste0(src_dir, '14b_surdo_2000_GompertzRelMod.R'))

source(paste0(src_dir, '14c_surdo_2010_PF_Brass.R'))

source(paste0(src_dir, '14d_surdo_2010_GompertzRelMod.R'))

source(paste0(src_dir, '14e_surdo_2000_2010_GompertzSintetico.R'))



source(paste0(src_dir, '15a_surdocego_2000_PF_Brass.R'))

source(paste0(src_dir, '15b_surdocego_2000_GompertzRelMod.R'))

source(paste0(src_dir, '15c_surdocego_2010_PF_Brass.R'))

source(paste0(src_dir, '15d_surdocego_2010_GompertzRelMod.R'))

source(paste0(src_dir, '15e_surdocego_2000_2010_GompertzSintetico.R'))



source(paste0(src_dir, '16a_pns2019_modulo_fecundidade.R'))

source(paste0(src_dir, '16b_pns2019_fecundidade_dif_ouvir.R'))



source(paste0(src_dir, '17_annex_diagnostics.R'))


source(paste0(src_dir, '18_relational_models_summaries.R'))

