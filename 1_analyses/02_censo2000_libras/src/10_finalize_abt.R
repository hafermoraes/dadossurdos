
con <- dbplyr::remote_con(subset_censo2000)

censo2000_common <- 
  censo2000_common |> 
  compute(name = "tab_common", temporary = FALSE)

censo2000_family_arrangements <- 
  censo2000_family_arrangements |> 
  compute(name = "tab_family_arrangements", temporary = FALSE)

censo2000_fertility <- 
  censo2000_fertility |> 
  compute(name = "tab_fertility", temporary = FALSE)

censo2000_libras <- 
  censo2000_libras |> 
  compute(name = "tab_libras", temporary = FALSE)

censo2000_migration <- 
  censo2000_migration |> 
  compute(name = "tab_migration", temporary = FALSE)

censo2000_survey_expansion <- 
  censo2000_survey_expansion |> 
  compute(name = "tab_survey_expansion", temporary = FALSE)



dbExecute(con, "CREATE TABLE censo2000_common AS SELECT * FROM tab_common") 
dbExecute(con, "CREATE TABLE censo2000_family_arrangements AS SELECT * FROM tab_family_arrangements") 
dbExecute(con, "CREATE TABLE censo2000_fertility AS SELECT * FROM tab_fertility") 
dbExecute(con, "CREATE TABLE censo2000_libras AS SELECT * FROM tab_libras") 
dbExecute(con, "CREATE TABLE censo2000_migration AS SELECT * FROM tab_migration") 
dbExecute(con, "CREATE TABLE censo2000_survey_expansion AS SELECT * FROM tab_survey_expansion") 


dbExecute(con, "ALTER TABLE censo2000_common ADD PRIMARY KEY (row_id)")
dbExecute(con, "ALTER TABLE censo2000_family_arrangements ADD PRIMARY KEY (row_id)")
dbExecute(con, "ALTER TABLE censo2000_fertility ADD PRIMARY KEY (row_id)")
dbExecute(con, "ALTER TABLE censo2000_libras ADD PRIMARY KEY (row_id)")
dbExecute(con, "ALTER TABLE censo2000_migration ADD PRIMARY KEY (row_id)")
dbExecute(con, "ALTER TABLE censo2000_survey_expansion ADD PRIMARY KEY (row_id)")

dbExecute(con, "CREATE TABLE censo2000_abt AS ")


censo2000_abt <- 
  censo2000_survey_expansion |>
  left_join(
    censo2000_common, by = "row_id" 
    ) |>
  left_join(
    censo2000_family_arrangements, by = "row_id" 
  ) |>
  left_join(
    censo2000_fertility, by = "row_id" 
  ) |>
  left_join(
    censo2000_migration, by = "row_id" 
  ) |>
  left_join(
    censo2000_libras, by = "row_id" 
  ) 

censo2000_abt |>
  to_arrow() |>
  write_dataset(
    path = '/tmp/censo2000_abt',
    format = "parquet"
  )
