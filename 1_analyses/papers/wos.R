
library(readxl)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(xtable)

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
  context <- split[2]

  raw <- read_excel(
    path = paste0(BASE_DIR, "raw/", file),
    col_types = "text" 
  ) %>%
    transmute(
      journal = journal,
      context = context,
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


prod <-
  dat %>%
  group_by(journal) %>%
  mutate(
    period = paste0(min(year),'-',max(year))
  ) %>%
  ungroup() %>%
  count(journal, period, context) %>%
  pivot_wider(
    id_cols = c('journal', 'period'),
    names_from = context,
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
  )

print(
  xtable( prod %>% mutate(journal=paste0('\\', journal)) ),
  sanitize.text.function = identity,
  only.contents=TRUE,
  include.rownames=FALSE,
  include.colnames=FALSE,
  hline.after=NULL,
  comment=FALSE,
  format.args = list(big.mark = ".", decimal.mark = ""),
  file=paste0(BASE_DIR, "wos_results.tex")
)

cat('% Variáveis utilizadas na quantificação de produção acadêmica\n\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=FALSE)

cat('% Nomes dos periódicos\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\aps}{Asian Population Studies}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\csp}{Canadian Studies in Population}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\demography}{Demography}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\dr}{Demographic Research}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\ejp}{European Journal of Population}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\ijps}{International Journal of Population Studies}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\japs}{Journal of African Population Studies}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\pdr}{Population and Development Review}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\prpr}{Population Research and Policy Review}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\ps}{Population Studies}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\psp}{Population, Space and Place}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\rebep}{Revista Brasileira de Estudos de População}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\relap}{Revista Latinoamericana de Población}\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)

cat('\n% Detalhamento da busca na Web of Science\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\WosAccessDate}{27/01/2026} % Data de acesso\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)
cat('\\newcommand{\\WosAccessDate}{27/01/2026} % Data de acesso\n', file = paste0(BASE_DIR, "wos_vars.tex"), append=TRUE)

\newcommand{\\WosSO}{SO=(DEMOGRAPHY)}
\newcommand{\\WosUrlOverall}{https://www.webofscience.com/wos/alldb/summary/3a08855d-b53b-4d35-9277-b0ede1858ba6-019b63afd6/relevance/1}
\newcommand{\\WosUrlDisab}{https://www.webofscience.com/wos/alldb/summary/d9c82ee5-162d-46cc-86f7-ccb2c89a07d2-019b63e8de/relevance/1}
\newcommand{\\WosUrlDeaf}{https://www.webofscience.com/wos/alldb/summary/c22c68b7-4d42-47f0-9408-b1efb078b6ba-019b6404fc/relevance/1}

URLS <-
  read_delim(
    paste0(BASE_DIR, "wos_urls"),
    delim='|'
  )


arg_journal <- prod$journal[1]
arg_context <- 'overall'

for( arg_journal in prod$journal){
  for( arg_context in c('overall','disab','deaf','sign')){
    row <- filter(prod, journal == arg_journal)
    if(row[arg_context]>0){
      cat(
        paste0(
          '\\newcommand{\\Wos',
          arg_context,
          '}{27/01/2026} % Data de acesso\n'
        ),
        file = paste0(BASE_DIR, "wos_vars.tex"),
        append=TRUE
      )
    }
  }
}
