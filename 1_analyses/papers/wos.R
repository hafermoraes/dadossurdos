
library(readxl)
library(dplyr)
library(tidyr)
library(readr)
library(stringr)
library(xtable)

BASE_DIR <- "1_analyses/papers/"
XLS_DIR <- paste0(BASE_DIR, "raw/")

APPEND <- FALSE

FILES <-
  list.files(
    XLS_DIR,
    full.names = FALSE
  )

for(file in FILES){
  name <- strsplit(file, split="\\.")[[1]]
  split <- strsplit(name, split="_")[[1]]
  journal <- split[1]
  context <- split[2]

  raw <-
    read_excel(
      path = paste0(XLS_DIR, file),
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
      file = paste0(BASE_DIR, "wos_papers.psv"),
      delim = "|",
      append = APPEND
    )

  APPEND <- TRUE 
}

dat <-
  read_delim(
    file = paste0(BASE_DIR, "wos_papers.psv"),
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

WOS_SUMMARY <-
  prod %>% 
  mutate(
    journal=paste0('\\', journal),
    disab=ifelse(disab==0,'-',disab),
    deaf=ifelse(deaf==0,'-',deaf),
    sign=ifelse(sign==0,'-',sign)
  ) %>%
  arrange( desc(overall))

print(
  xtable( WOS_SUMMARY ),
  sanitize.text.function = identity,
  only.contents=TRUE,
  include.rownames=FALSE,
  include.colnames=FALSE,
  hline.after=NULL,
  comment=FALSE,
  format.args = list(big.mark = ".", decimal.mark = ""),
  file=paste0(BASE_DIR, "wos_summary.tex")
)


OUTPUT_FILE <- paste0(BASE_DIR, "annex_wos_variables.tex")
cat('\n% Detalhamento da busca na Web of Science (wos)\n', file = OUTPUT_FILE, append=FALSE)
cat('\\newcommand{\\wosAccessDate}{27/01/2026} % Data de acesso\n\n', file = OUTPUT_FILE, append=TRUE)

cat('\\newcommand{\\Journal}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosSO}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosLabel}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosURLoverall}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosPAPERSoverall}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosURLdisab}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosPAPERSdisab}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosURLdeaf}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosPAPERSdeaf}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosURLsign}{}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\wosPAPERSsign}{}\n', file = OUTPUT_FILE, append=TRUE)

OUTPUT_FILE <- paste0(BASE_DIR, "wos_summary_variables.tex")

cat('% Variáveis utilizadas na quantificação de produção acadêmica\n\n', file = OUTPUT_FILE, append=FALSE)
cat('% Nomes dos periódicos\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\aps}{Asian Population Studies}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\csp}{Canadian Studies in Population}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\demography}{Demography}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\dr}{Demographic Research}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\ejp}{European Journal of Population}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\ijps}{International Journal of Population Studies}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\japs}{Journal of African Population Studies}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\pdr}{Population and Development Review}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\prpr}{Population Research and Policy Review}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\ps}{Population Studies}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\psp}{Population, Space and Place}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\rebep}{Revista Brasileira de Estudos de População}\n', file = OUTPUT_FILE, append=TRUE)
cat('\\newcommand{\\relap}{Revista Latinoamericana de Población}\n', file = OUTPUT_FILE, append=TRUE)

cat('\n% Quantificação da escassez de publicações de deficiência, surdez e língua de sinais\n', file = OUTPUT_FILE, append=TRUE)

SUM_OVERALL <- format(sum(prod$overall), big.mark = ".", decimal.mark = ",")
cat(paste0('\\newcommand{\\wosSUMoverall}{', SUM_OVERALL,'}\n'), file = OUTPUT_FILE, append=TRUE)

SUM_DISAB <- format(sum(prod$disab), big.mark = ".", decimal.mark = ",")
cat(paste0('\\newcommand{\\wosSUMdisab}{', SUM_DISAB,'}\n'), file = OUTPUT_FILE, append=TRUE)

SUM_DEAF <- format(sum(prod$deaf), big.mark = ".", decimal.mark = ",")
cat(paste0('\\newcommand{\\wosSUMdeaf}{', SUM_DEAF,'}\n'), file = OUTPUT_FILE, append=TRUE)

SUM_SIGN <- format(sum(prod$sign), big.mark = ".", decimal.mark = ",")
cat(paste0('\\newcommand{\\wosSUMsign}{', SUM_SIGN,'}\n\n'), file = OUTPUT_FILE, append=TRUE)

## 30% = 30 / 100     # porcentagem
## 30 : (100 - 30)    # proporção, razão
## 1 : (100 - 30)/30
## 1 : 100/30 -1


PROP_DISAB <-
  format(
    round(
      sum(prod$overall)/sum(prod$disab)-1,
      0
    ),
    big.mark = ".",
    decimal.mark = ","
  )
cat(paste0('\\newcommand{\\wosRATIOdisab}{', PROP_DISAB,'}\n'), file = OUTPUT_FILE, append=TRUE)

PROP_DEAF <-
  format(
    round(
      sum(prod$overall)/sum(prod$deaf)-1,
      0
    ),
    big.mark = ".",
    decimal.mark = ","
  )
cat(paste0('\\newcommand{\\wosRATIOdeaf}{', PROP_DEAF,'}\n'), file = OUTPUT_FILE, append=TRUE)

PROP_SIGN <-
  format(
    round(
      sum(prod$overall)/sum(prod$sign)-1,
      0
    ),
    big.mark = ".",
    decimal.mark = ","
  )
cat(paste0('\\newcommand{\\wosRATIOsign}{', PROP_SIGN,'}\n'), file = OUTPUT_FILE, append=TRUE)

JOURNALS <-
  read_delim(
    paste0(BASE_DIR, "wos_journals.psv"),
    delim='|'
  )

URLS <-
  read_delim(
    paste0(BASE_DIR, "wos_urls.psv"),
    delim='|'
  )

for( arg_journal in prod$journal){

  ANNEX <- paste0(BASE_DIR, "annex_", arg_journal, "_variables.tex")

  cat(
    paste0('\n% Variáveis do anexo -- ', arg_journal, '\n'),
    file = ANNEX,
    append=FALSE
  )

  cat(
    paste0(
      '\n\\renewcommand{\\Journal}{',
      filter(JOURNALS, key == arg_journal)['journal'],
      '}'
    ),
    file = ANNEX,
    append=TRUE
  )

  cat(
    paste0(
      '\n\\renewcommand{\\wosSO}{',
      filter(JOURNALS, key == arg_journal)['wos_so_argument'],
      '}'
    ),
    file = ANNEX,
    append=TRUE
  )

  cat(
    paste0(
      '\n\\renewcommand{\\wosLabel}{tab:annex_papers_',
      arg_journal,
      '}'
    ),
    file = ANNEX,
    append=TRUE
  )

  results <- filter(prod, journal == arg_journal)
  
  for( arg_context in c('overall','disab','deaf','sign')){
    
    urls <- filter(URLS, key == arg_journal, context == arg_context)
    
    if(results[arg_context]>0){
      msg <- urls['url']
    } else {
      msg <- 'Busca não retornou resultados'
    }
    
    cat(
      paste0(
        '\n\\renewcommand{\\wosURL',
        arg_context,
        '}{',
        msg,
        '}'
      ),
      file = ANNEX,
      append=TRUE
    )

    cat(
      paste0(
        '\n\\renewcommand{\\wosPAPERS',
        arg_context,
        '}{',
        results[arg_context],
        '}'
      ),
      file = ANNEX,
      append=TRUE
    )    
  }
}

