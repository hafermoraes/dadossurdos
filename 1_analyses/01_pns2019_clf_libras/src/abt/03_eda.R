
tic()
message("tratando os microdados para fins de AED...")
niveis_instrucao <- c('outros','fundamental','medio','superior')
niveis_dificuldade <- c('nenhuma','alguma','grande','incapaz')

pre_modelmatrix <-
  microdados |>
  mutate(
    instrucao = factor(instrucao, levels=niveis_instrucao, ordered=TRUE),
    across(
      c(dif_ouvir, dif_enxergar, dif_locomover),
      \(x) factor(x, levels=niveis_dificuldade, ordered=TRUE)
    ),
    across(where(is.character), as.factor),
    libras_01 = if_else(libras=='sim',1,0),
    faixa_idade = cut(
      idade, 
      breaks = c(0,4,40,140), 
      labels = c("0-4", 
                 "5-40", 
                 "40+"
                 ),
      include.lowest = TRUE)
  ) |>
  filter(
    !is.na(libras)
  )
toc()


tic()
message("expandindo probabilicamente a amostra nos microdados...")

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <-
  survey::svydesign(
    ids = ~upa_pns, 
    strata = ~v0024, 
    data = subset(pre_modelmatrix, v0028 != 0), 
    weights = ~v0028, 
    nest = TRUE
  )
# Post-stratification
popc.types <-
  data.frame( 
    v00283=as.character(unique(pre_modelmatrix$v00283)), 
    Freq=as.numeric(unique(pre_modelmatrix$v00282))
  )
popc.types <- popc.types[order(popc.types$v00283),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior, 
    strata=~v00283, 
    population=popc.types
  )
toc()



tic()
message("determinando a quantidade de pessoas que usam libras no país...")
svytotal(
  ~libras,
  design=pns2019_posterior,
)
toc()


tic()
message("reproduzindo Tabela 8, p. 40, de 'Pesquisa Nacional de Saúde 2019: Ciclos de Vida'...")
pns2019_posterior |>
  as_survey() |>
  filter(idade >= 5 , idade <= 40) |>
  group_by(dif_ouvir) |>
  summarise(
    n = survey_mean(libras_01, na.rm = TRUE, vartype=c('se','ci'))
  )
toc()


tic()
message("mesma análise, agora exportando para tabelas e arquivos LaTeX para uso posterior na tese...")
pns2019_usuarios_libras <-
  pns2019_posterior |>
  as_survey() |>
  summarise(
    n = survey_total(libras_01, na.rm = TRUE, vartype=c('se','ci')),
    pct = survey_mean(libras_01, na.rm = TRUE, vartype=c('se','ci'))
  ) |>
  mutate(
    across(
      starts_with("n"),
      label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")
    ),
    across(
      starts_with("pct"),
      label_percent(accuracy = 0.01, big.mark = ".", decimal.mark = ",")
    )
  )
# pns2019_usuarios_libras
# paste0("(erro padrão: ", pns2019_usuarios_libras$n_se, ", IC 95%: [", pns2019_usuarios_libras$n_low, "; ", pns2019_usuarios_libras$n_upp, "])")
# paste0("(erro padrão: ", pns2019_usuarios_libras$pct_se, ", IC 95%: [", pns2019_usuarios_libras$pct_low, "; ", pns2019_usuarios_libras$pct_upp, "])")
toc()


# message("Class imbalance for response variable libras (g05801): ")
# # TODO exportar para LaTeX
# microdados |>
#   group_by(libras) |>
#   summarise( n =sum(case_weights)) |>
#   mutate( pct = n/sum(n)) |>
#   print()




tic()
message("produzindo as análises exploratórias para a tese...")

eda_stats_by_variable <- function(column) {

  # tabela de cálculo da quantidade de pessoas, número e percentual de usuários de libras
  # bem como intervalos de confiança de 95%
  base_table <- 
    suppressWarnings(
      pns2019_posterior |>
      as_survey() |>
      group_by(across(all_of(column))) |>
      summarise(
        n = survey_total(na.rm = TRUE, vartype = 'ci'),
        l = survey_total(libras_01, na.rm = TRUE, vartype = 'ci'),
        p = survey_mean(libras_01, na.rm = TRUE, vartype = 'ci')
      ) |>
      rename(value = 1) |>
      mutate(key = column)
    )
  
  summary_table <-
    base_table |>
    mutate(
        across(
          c(n, n_low, n_upp, l, l_low, l_upp), 
          label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")
        ),
        across(
          c(p, p_low, p_upp), 
          label_percent(accuracy = 0.1, big.mark = ".", decimal.mark = ",")
        )
      ) |>
      transmute(
        key,
        value,
        n,
        n_95ci = paste0("[", n_low, "; ", n_upp, "]"),
        l,
        l_95ci = paste0("[", l_low, "; ", l_upp, "]"),
        p,
        p_95ci = paste0("[", p_low, "; ", p_upp, "]")
      )

  return(
    list(
      base_table = base_table, 
      summary_table = summary_table
      )
    )
}

eda_export_latex <- function(eda_summary, to_file = "eda_summary.tex", append_flag) {
  print(
    xtable( 
      eda_summary, 
      digits = c(
        0, # row name
        0, # key
        0, # value
        0, # n
        0, # n_95ci
        0, # l
        0, # l_95ci
        0, # p
        0  # p_95ci
      )
    ),
    sanitize.text.function = NULL,
    only.contents=TRUE,
    include.rownames=FALSE,
    include.colnames=FALSE,
    hline.after=NULL,
    comment=FALSE,
    append=append_flag,
    file=paste0(
      eda_dir,
      to_file
    )
  )
}
toc()






COLUMNS <- c(
  'sexo',
  'alfabetizado',
  'estado_civil',
  'instrucao',
  'cor_raca',
  'dif_enxergar',
  'dif_ouvir',
  'dif_locomover',
  'uf',
  'faixa_idade'
)

APPEND <- FALSE

eda_base <- 
  tribble(
    ~value, ~n, ~n_low, ~n_upp, ~l, ~l_low, ~l_upp, ~p, ~p_low, ~p_upp, ~key, 
  )

for(arg_column in COLUMNS){
  tic()
  message("preparando análise exploratória da variável '", arg_column, "'...")
  eda_stats <- eda_stats_by_variable(column=arg_column)
  
  eda_base <- bind_rows(eda_base, eda_stats$base_table)
  
  eda_export_latex(
    eda_summary = eda_stats$summary_table |> as.data.frame(), 
    to_file = "eda_summary.tex", 
    append_flag=APPEND
  )
  
  cat('\n\\midrule\n\n', file = paste0(eda_dir, "eda_summary.tex"), append=TRUE)
  toc()
  
  APPEND <- TRUE
  
  gc()
  
}


# facets com geom_errorbar
# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
tic()
message("exportando EDA gráfica (facet) em disco...")
(
  eda_base |>
    mutate(
      key = factor(
        key, 
        levels = c(
          "alfabetizado", 
          "instrucao", 
          "sexo",
          "faixa_idade",
          "cor_raca",
          "estado_civil",
          "dif_ouvir",
          "dif_enxergar",
          "dif_locomover",
          "uf"
          )
        )
      ) |> 
    select(p, p_low, p_upp, !where(is.numeric)) |>
    ggplot(aes(x=value, y=p, color=p)) +
    geom_point() +
    geom_errorbar(aes(ymin = p_low, ymax = p_upp), width = 0.1) +
    annotate(
      "rect", 
      ymin = pns2019_pct_libras$pct_low, 
      ymax = pns2019_pct_libras$pct_upp, 
      xmin = -Inf, xmax = Inf, 
      fill = "red", alpha = 0.1
    ) +
    geom_hline(
      yintercept = pns2019_pct_libras$pct, 
      linetype='dashed', 
      linewidth=0.5, 
      color='red'
      ) +
    theme(legend.position = "none") + 
    facet_wrap(
      ~key, 
      nrow = 5, 
      scales = 'free'
    ) +
    scale_y_continuous(
      labels = scales::percent_format(accuracy = 0.1)
      ) +
    coord_flip() + 
    theme(
      axis.text.y = element_text(size = 6),
      axis.text.x = element_text(size = 6)
    )+
    labs(
      title = 'Análise exploratória de dados', 
      subtitle = 'Etapa prévia à Modelagem Preditiva',
      y = 'percentual de usuários de libras',
      x = ''
      ) 
) |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_facet.pdf"
    ),
    width=8,
    height=10
  )
toc()



