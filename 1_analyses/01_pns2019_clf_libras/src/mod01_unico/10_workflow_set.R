
tic()
message("unificando o pipeline de tratamento e ajuste (tidymodels/workflowsets)...")
# https://workflowsets.tidymodels.org/reference/workflow_set.html#see-also

# wflow_set <- 
#   workflow_set(
#     preproc = list(
#       basic = recipe_basic
#     ),
#     models = list(
#       model_null = model_null,
#       model_dt = model_dt,
#       model_lgb = model_lgb,
#       model_logres = model_logres,
#       model_mars = model_mars,
#       model_mlp = model_mlp,
#       model_nb = model_nb,
#       model_rf = model_rf,
#       model_svm = model_svm,
#       model_xgb = model_xgb
#     ),
#     cross = TRUE,
#     case_weights = "case_weights"
#   ) 

wflow_set <- 
  workflow_set(
    preproc = list(
      basic = recipe_basic
    ),
    models = list(
      model_logres = model_logres
    ),
    cross = TRUE,
    case_weights = "case_weights"
  ) 


toc()