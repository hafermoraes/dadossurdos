
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
    libras = relevel(libras, 'sim'),
    instrucao = as.factor( instrucao, levels = c('outros', 'fundamental', 'medio', 'superior'))
  ) 
  
# passo 1.1: redução do dataset para prototipagem de tidymodels
if(FALSE){
  libras <-
    bind_rows(
      libras |> filter(libras == 'nao') |> head(100),
      libras |> filter(libras == 'sim') |> head(100)
    )
}

