gc()

ANO_CENSO <- 2010

censo2010_abt <-
  open_dataset(
    paste0(
      data_dir,
      "censo2010_abt.parquet"
    )
  ) |>
  to_duckdb()


tic()
message("estimação dos usuários de libras no censo", ANO_CENSO)
censo2010_stats_svydesign <-
  censo2010_abt |>
  # filter(
  #   dif_ouvir %in% c('grande', 'incapaz') # reduz tempo de processamento consideravelmente...
  # ) |> 
  transmute(
    across( 
      c(peso_amostral, categ_ouvinte, categ_deficiente_auditivo, categ_surdo, categ_surdocego), 
      as.numeric 
    )
  ) |>
  as_survey_design(
    ids = 1,
    weights = peso_amostral,
    check_strata = FALSE
  ) 
toc()





tic()
censo2010_N_Nci95_ouvinte <- 
  censo2010_stats_svydesign |>
  summarise(
    N = survey_total(categ_ouvinte, na.rm=TRUE, vartype = 'ci')
  ) |>
  collect()
toc()



tic()
censo2010_N_Nci95_deficiente_auditivo <- 
  censo2010_stats_svydesign |>
  summarise(
    N = survey_total(categ_deficiente_auditivo, na.rm=TRUE, vartype = 'ci')
  ) |>
  collect()
toc()



tic()
censo2010_N_Nci95_surdo <- 
  censo2010_stats_svydesign |>
  summarise(
    N = survey_total(categ_surdo, na.rm=TRUE, vartype = 'ci')
  ) |>
  collect()
toc()



tic()
censo2010_N_Nci95_surdocego <- 
  censo2010_stats_svydesign |>
  summarise(
    N = survey_total(categ_surdocego, na.rm=TRUE, vartype = 'ci')
  ) |>
  collect()
toc()


tic()
message("consolidando as informações para a tese...")
censo2010_stats <-
  bind_rows(
    censo2010_N_Nci95_ouvinte |> 
      mutate(
        censo=ANO_CENSO, 
        cat="Ouvinte", 
        .before = 1
      ),
    censo2010_N_Nci95_deficiente_auditivo |> 
      mutate(
        censo=ANO_CENSO, 
        cat="Deficiente Auditivo", 
        .before = 1
      ),
    censo2010_N_Nci95_surdo |> 
      mutate(
        censo=ANO_CENSO, 
        cat="Surdo", 
        .before = 1
      ),
    censo2010_N_Nci95_surdocego |> 
      mutate(
        censo=ANO_CENSO, 
        cat="Surdo-cego", 
        .before = 1
      )
  )

censo2010_stats |>
  mutate(
    across(
      c(N,N_low,N_upp),
      label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")     
    )
  ) |>
  write_csv(
    paste0(
      results_dir,
      "censo2010_stats.csv"
    )
  )

toc()
