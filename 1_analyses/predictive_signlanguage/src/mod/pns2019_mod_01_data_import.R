
# passo 1: importação da matriz de modelo
libras <-
  read_csv(
    '/home/rstudio/1_analyses/predictive_signlanguage/data/pns2019_modelmatrix.csv'
  ) |> 
  # select(-uf, -cor_raca, -estado_civil, -sexo) |>
  mutate(
    across(where(is.character), as.factor),
    # https://workflowsets.tidymodels.org/reference/workflow_set.html
    case_weights = importance_weights(case_weights),
    libras = relevel(libras, 'sim')
  ) 
  
# passo 1.1: redução do dataset para prototipagem de tidymodels
if(FALSE){
  libras <-
    bind_rows(
      libras |> filter(libras == 'nao') |> head(100),
      libras |> filter(libras == 'sim') |> head(100)
    )
}

if(FALSE){
    
  # isolation forest
  # install.packages("solitude")
  library(solitude)
  
  iso_forest <- isolationForest$new(
    num_trees = 1000,         # number of trees (default = 100)
    sample_size = 512,       # subsample size per tree (default = 256)
    max_depth = 30            # max depth per tree (default = 8)
  )
  iso_forest$fit(libras)
  iso_scores <- iso_forest$predict(libras)$anomaly_score
  libras$isolation_forest_score <- iso_scores

}
