
# passo 6: criação dos fluxos de trabalho
# https://workflowsets.tidymodels.org/reference/workflow_set.html#see-also

wflow_set <- 
  workflow_set(
    preproc = list(
      basic = recipe_basic
    ),
    models = list(
      model_null = model_null,
      model_logres = model_logres,
      model_mlp = model_mlp,
      model_lgb = model_lgb,
      model_dt = model_dt,
      model_xgb = model_xgb
      # model_rf = model_rf,
      # model_mars = model_mars,
      # model_cb = model_cb,
      # model_bc5 = model_bc5,
      # model_svm = model_svm,
      # model_gam = model_gam,
      # model_bart = model_bart,
      # model_mlp2 = model_mlp2,
      # model_bagc50 = model_bagc50,
      # model_bagrpart = model_bagrpart,
      #model_nb = model_nb
    ),
    cross = TRUE,
    case_weights = "case_weights"
  ) 

