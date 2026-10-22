

tic("dados usados no diagrama de venn (população alvo, introdução da tese)...")
venn <-
  pns2019_posterior |>
  as_survey() |>
  filter(idade >= 2) |>
  mutate(
    grp = case_when(
      dif_ouvir %in% c('nenhuma', 'alguma') ~ 'ouvinte',
      TRUE ~ 'PcDA'
    )
  ) |>
  group_by(grp) |>
  summarise(
    N = survey_total(na.rm = TRUE, vartype=NULL),
    p = survey_mean(
      na.rm = TRUE,
      proportion=TRUE,
      prop_method='xlogit',
      vartype = NULL
    ),
    l = survey_total(
      libras_01,
      #proportion=FALSE,
      #prop_method='xlogit',
      na.rm = TRUE,
      vartype=NULL
    )
  )

message(
  "População brasileira acima de 2 anos em 2019: ", 
  scales::number( sum(venn$N), big.mark = '.', accuracy = 1, decimal.mark = ',')
)

message(
  "População brasileira usuária de libras acima de 2 anos em 2019: ", 
  scales::number( sum(venn$l), big.mark = '.', accuracy = 1, decimal.mark = ',')
)

message(
  "PcDA acima de 2 anos em 2019: ",
  scales::number( venn$N[1], big.mark = '.', accuracy = 1, decimal.mark = ',')
)

message(
  "PcDA usuária de Libras acima de 2 anos em 2019: ",
  scales::number( venn$l[1], big.mark = '.', accuracy = 1, decimal.mark = ',')
)

toc()

