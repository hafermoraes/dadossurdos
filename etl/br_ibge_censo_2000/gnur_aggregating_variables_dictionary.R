## gnur_aggregating_variables_dictionary.R
##
## br_ibge_censo_2000

library(readr)  # read_delim, write_delim
library(dplyr)  # bind_rows
library(tibble) # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2000/'

vdict_paths <-
  list.files(
    path = base_dir,
    pattern = 'files',
    ignore.case = TRUE,
    full.names = TRUE
  )

vdict <- tribble(
  ~base, ~q_code, ~a_code, ~a_desc,
)

for (f in vdict_paths){
  vdict <- bind_rows(
    vdict,
    read_delim(
      file = f,
      delim = '|',
      col_names = TRUE,
      col_types = cols(.default = 'c')
    )
  )
}

vdict %>%
  write_delim(
    file = paste0(base_dir, 'data/variables_dictionary.txt'),
    delim = '|',
    col_names = TRUE
  )
