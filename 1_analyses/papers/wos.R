
library(readxl)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)

BASE_DIR <- "1_analyses/papers/"

APPEND <- FALSE

FILES <-
  list.files(
    paste0(BASE_DIR,"raw/"),
    full.names = FALSE
  )

for(file in FILES){

  name <- strsplit(file, split="\\.")[[1]]
  split <- strsplit(name, split="_")[[1]]
  journal <- split[1]
  filter <- split[2]

  raw <- read_excel(
    path = paste0(BASE_DIR, "raw/", file),
    col_types = "text" 
  ) %>%
    transmute(
      journal = journal,
      filter = filter,
      journaltitle = str_to_title(`Source Title`),
      author = Authors,
      title = `Article Title`,
      year = `Publication Year`
    )

  raw %>%
    write_delim(
      file = paste0(BASE_DIR, "wos.psv"),
      delim = "|",
      append = APPEND
    )

  APPEND <- TRUE
  
}

dat <-
  read_delim(
    file = paste0(BASE_DIR, "wos.psv"),
    delim = "|",
  )

dat %>% 
  count(journal, filter) %>%
  pivot_wider(
    id_cols = journal,
    names_from = filter,
    values_from = n,
    values_fill = 0
  ) %>%
  select(
    journal,
    overall,
    disab,
    deaf,
    sign
  ) %>%
  ## mutate(
  ##   disab_pct = disab/overall,
  ##   deaf_pct = deaf/overall,
  ##   sign_pct = sign/overall,
  ##   ) %>%
  View


dat %>%
  group_by(journal) %>%
  mutate(
    period = paste0(min(year),'-',max(year))
  ) %>%
  ungroup() %>%
  count(journal, period, filter) %>%
  pivot_wider(
    id_cols = c('journal', 'period'),
    names_from = filter,
    values_from = n,
    values_fill = 0
  ) %>%
  select(
    journal,
    period,
    overall,
    disab,
    deaf,
    sign
  ) %>%
  View
