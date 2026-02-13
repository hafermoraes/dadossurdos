

libras <-
  read_csv(
    paste0(
      base_dir, 
      'data/pns2019_02_modelmatrix.csv'
      ),
    show_col_types = FALSE
  ) |>
  mutate(
    # https://workflowsets.tidymodels.org/reference/workflow_set.html
    case_weights = importance_weights(case_weights),
    libras = factor(
      libras,
      levels = c('nao', 'sim')
    ),
    dif_ouvir = factor(
      dif_ouvir,
      levels = c('nenhuma', 'alguma', 'grande', 'incapaz'),
      ordered=TRUE
    ),
    instrucao = factor(
      instrucao,
      levels = c('outros', 'fundamental', 'medio', 'superior'),
      ordered=TRUE
    )
  ) |>
  filter(idade <=40)
  
# passo 1.1: redução do dataset para prototipagem de tidymodels
if(FALSE){
  libras <-
    bind_rows(
      libras |> filter(libras == 'nao') |> head(100),
      libras |> filter(libras == 'sim') |> head(100)
    )
}

