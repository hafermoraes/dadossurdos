

tic()
message("determinando a quantidade de pessoas que usam libras no país...")
svytotal(
  ~libras,
  design=pns2019_posterior,
)
toc()


message("reproduzindo Tabela 8, p. 40, de 'Pesquisa Nacional de Saúde 2019: Ciclos de Vida'...")

tic()
message("para todas as idades...")
pns2019_dif_ouvir_libras_all_ages <- 
  pns2019_posterior |>
  as_survey() |>
  group_by(dif_ouvir) |>
  summarise(
    N = survey_total(na.rm = TRUE),
    p = survey_mean(
      na.rm = TRUE,
      proportion=TRUE,
      prop_method='xlogit',
      vartype = 'ci'
    ),
    l = survey_mean(
      libras_01,
      proportion=TRUE,
      prop_method='xlogit',
      na.rm = TRUE,
      vartype='ci'
    )
  )

export_dif_ouvir_libras_all_ages <-
  pns2019_dif_ouvir_libras_all_ages |>
  mutate(
    across( c(N, N_se), 
            label_number(accuracy = 1, big.mark = ".", decimal.mark = ",") ),
    across( c(p, p_low, p_upp, l, l_low, l_upp), 
            \(x) 100.0*x ),
    across( c(p, p_low, p_upp, l, l_low, l_upp),  
            label_number(accuracy = 0.01, big.mark = ".", decimal.mark = ","))
  ) |>
  select(-N_se) |>
  transmute(
    dif_ouvir,
    N,
    p,
    p_ic95 = paste0("[", p_low, "; ", p_upp, "]"),
    l,
    l_ic95 = paste0("[", l_low, "; ", l_upp, "]")
  )

print(
  xtable( 
    export_dif_ouvir_libras_all_ages, 
    digits = c(
      0, # row name
      0, # dif_ouvir
      0, # N
      0, # p
      0, # p_ic95
      0, # l
      0  # l_ic95
    )
  ),
  sanitize.text.function = NULL,
  only.contents=TRUE,
  include.rownames=FALSE,
  include.colnames=FALSE,
  hline.after=NULL,
  comment=FALSE,
  append=FALSE,
  file=paste0(
    eda_dir,
    "eda_dif_ouvir_libras_all_ages.tex"
  )
)
toc()


tic()
message("para as idades 5-40...")
pns2019_dif_ouvir_libras_ages_5_40 <- 
  pns2019_posterior |>
  as_survey() |>
  filter(idade >= 5 , idade <= 40) |>
  group_by(dif_ouvir) |>
  summarise(
    N = survey_total(na.rm = TRUE),
    p = survey_mean(
      na.rm = TRUE,
      proportion=TRUE,
      prop_method='xlogit',
      vartype = 'ci'
    ),
    l = survey_mean(
      libras_01,
      proportion=TRUE,
      prop_method='xlogit',
      na.rm = TRUE,
      vartype='ci'
    )
  )

export_dif_ouvir_libras_ages_5_40 <-
  pns2019_dif_ouvir_libras_ages_5_40 |>
  mutate(
    across( c(N, N_se), 
            label_number(accuracy = 1, big.mark = ".", decimal.mark = ",") ),
    across( c(p, p_low, p_upp, l, l_low, l_upp), 
            \(x) 100.0*x ),
    across( c(p, p_low, p_upp, l, l_low, l_upp),  
            label_number(accuracy = 0.01, big.mark = ".", decimal.mark = ","))
  ) |>
  select(-N_se) |>
  transmute(
    dif_ouvir,
    N,
    p,
    p_ic95 = paste0("[", p_low, "; ", p_upp, "]"),
    l,
    l_ic95 = paste0("[", l_low, "; ", l_upp, "]")
  )

print(
  xtable( 
    export_dif_ouvir_libras_ages_5_40, 
    digits = c(
      0, # row name
      0, # dif_ouvir
      0, # N
      0, # p
      0, # p_ic95
      0, # l
      0  # l_ic95
    )
  ),
  sanitize.text.function = NULL,
  only.contents=TRUE,
  include.rownames=FALSE,
  include.colnames=FALSE,
  hline.after=NULL,
  comment=FALSE,
  append=FALSE,
  file=paste0(
    eda_dir,
    "eda_dif_ouvir_libras_ages_0_40.tex"
  )
)
toc()

  


toc()


tic()
message("mesma análise, agora exportando para tabelas e arquivos LaTeX para uso posterior na tese...")
pns2019_pct_libras <-
  pns2019_posterior |>
  as_survey() |>
  summarise(
    n = survey_total(
      libras_01,
      na.rm = TRUE,
      vartype=c('se','ci')
    ),
    pct = survey_mean(
      libras_01,
      proportion=TRUE,
      prop_method='xlogit',
      na.rm = TRUE,
      vartype=c('se','ci')
    )
  ) |>
  mutate(
    n_low = pmax(0, n_low)
  )

pns2019_usuarios_libras <-
  pns2019_pct_libras |>
  mutate(
    across(
      starts_with("n"),
      label_number(accuracy = 1, big.mark = ".", decimal.mark = ",")
    ),
    across(starts_with("pct"), \(x) 100*x),
    across(
      starts_with("pct"),
      label_number(accuracy = 0.01, big.mark = ".", decimal.mark = ",")
    )
  )

eda_vars <- paste0(eda_dir, "eda_vars.tex")
cat(
  paste0(
    "\n\n\\newcommand{\\LibrasPCT}{",
    pns2019_usuarios_libras$pct,
    "\\%}\n"
  ),
  file = eda_vars,
  append = FALSE
)
cat(
  paste0(
    "\\newcommand{\\LibrasPCTfootnote}{",
    paste0(
      "erro padrão: ", 
      pns2019_usuarios_libras$pct_se, 
      "\\%, IC 95\\%: [", 
      pns2019_usuarios_libras$pct_low, 
      "\\%; ", 
      pns2019_usuarios_libras$pct_upp, "\\%]"
      ),
    "}\n\n"
  ),
  file = eda_vars,
  append = TRUE
)
cat(
  paste0(
    "\\newcommand{\\LibrasCNT}{",
    pns2019_usuarios_libras$n,
    "}\n"
  ),
  file = eda_vars,
  append = TRUE
)
cat(
  paste0(
    "\\newcommand{\\LibrasCNTfootnote}{",
    paste0(
      "erro padrão: ", 
      pns2019_usuarios_libras$n_se, 
      ", IC 95\\%: [", 
      pns2019_usuarios_libras$n_low, 
      "; ", 
      pns2019_usuarios_libras$n_upp, "]"
    ),
    "}\n\n"
  ),
  file = eda_vars,
  append = TRUE
)
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


#' @title Calcular Estatísticas Descritivas com Pesos Amostrais
#' 
#' @description
#' Esta função automatiza o cálculo de totais populacionais, contagem de usuários 
#' de Libras e proporções de uso, segmentados por uma variável específica. Ela 
#' utiliza o objeto de desenho amostral pós-estratificado para garantir a 
#' validade estatística das estimativas.
#'
#' @param column String. O nome da coluna (variável preditora) pela qual os 
#'   dados serão agrupados (ex: 'sexo', 'instrucao').
#'
#' @return Uma \code{list} contendo dois objetos:
#' \itemize{
#'   \item \code{base_table}: Tibble com os valores numéricos brutos e intervalos de confiança.
#'   \item \code{summary_table}: Tibble formatada com strings prontas para publicação 
#'   (ex: "1.234.567", "[0,1%; 0,3%]").
#' }
#' 
#' @details 
#' A função realiza três cálculos principais via \code{srvyr}:
#' \enumerate{
#'   \item \bold{n}: Total da população no nível da variável.
#'   \item \bold{l}: Estimativa do total de pessoas que sabem Libras (\code{libras_01}).
#'   \item \bold{p}: Proporção (média) de usuários de Libras na população.
#' }
#' Utiliza \code{suppressWarnings} para evitar mensagens de categorias vazias durante 
#' o processamento de subgrupos pequenos.
#'
#' @note 
#' Requer que o objeto \code{pns2019_posterior} esteja disponível no ambiente global 
#' e que as funções \code{label_number} e \code{label_percent} (pacote \code{scales}) 
#' estejam carregadas.
#'
#' @export
#'
#' @examples
#' # stats <- eda_stats_by_variable("instrucao")
#' # print(stats$summary_table)
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
          p = survey_mean(
            libras_01,
            proportion=TRUE,
            prop_method='xlogit',
            na.rm = TRUE,
            vartype = 'ci')
        ) |>
        rename(value = 1) |>
        mutate(
          key = column,
          n_low = pmax(0, n_low),
          l_low = pmax(0, l_low)
        )
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

#' @title Exportar Resumo da AED para Fragmento LaTeX
#' 
#' @description
#' Esta função converte a tabela de resumo da Análise Exploratória de Dados (AED) 
#' em um formato compatível com LaTeX utilizando o pacote \code{xtable}. O arquivo 
#' gerado contém apenas o conteúdo das linhas (sem cabeçalho ou ambiente \code{table}), 
#' facilitando a inclusão via \code{\input{}} em documentos mestres.
#'
#' @param eda_summary Um \code{data.frame} ou \code{tibble}. O resultado formatado 
#'   da função \code{eda_stats_by_variable}.
#' @param to_file String. O nome do arquivo de saída (padrão: "eda_summary.tex").
#' @param append_flag Lógico. Se \code{TRUE}, anexa o conteúdo ao final do arquivo; 
#'   se \code{FALSE}, sobrescreve o arquivo existente.
#'
#' @return A função não retorna um objeto no R, agindo apenas sobre o sistema de 
#'   arquivos ao gravar o conteúdo no diretório definido em \code{eda_dir}.
#' 
#' @details 
#' A função configura o \code{xtable} para:
#' \itemize{
#'   \item Remover nomes de linhas e cabeçalhos de colunas (\code{only.contents = TRUE}).
#'   \item Desativar linhas horizontais (\code{hline.after = NULL}) para permitir 
#'     customização manual no arquivo mestre.
#'   \item Manter a sanitização padrão desativada (\code{sanitize.text.function = NULL}) 
#'     para preservar formatações especiais de texto.
#' }
#' 
#' @note 
#' O caminho final do arquivo é composto pela variável global \code{eda_dir} 
#' concatenada com o parâmetro \code{to_file}.
#'
#' @export
#'
#' @examples
#' # eda_export_latex(stats$summary_table, "tabela_sexo.tex", append_flag = FALSE)
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
  
  eda_summary_table <-
    eda_stats$summary_table |>
    mutate(
      value = case_when(
        is.na(value) ~ 'nao_informado',
        TRUE ~ as.character(value)
      ),
      rank = case_when(
        # reordenamento para 'uf'
        key == 'uf' ~ parse_number(p, locale = locale(decimal_mark = ",")) / 100,
        # reordenamento para 'instrucao'
        value == "outros"        ~ 1,
        value == "fundamental"   ~ 2,
        value == "medio"         ~ 3,
        value == "superior"      ~ 5,
        value == "nao_informado" ~ 6,
        # reordenamento para 'dif_ouvir'
        value == "nenhuma"  ~ 1,
        value == "alguma"   ~ 2,
        value == "grande"   ~ 3,
        value == "incapaz"  ~ 4,
        value == "ignorado" ~ 5,
        # reordenamento para 'faixa_idade'
        value == "0-4"      ~ 1,
        value == "5-9"      ~ 2,
        value == "10-19"    ~ 3,
        value == "20-39"    ~ 4,
        value == "40+"      ~ 5,
        TRUE                ~ 6
      )
    ) |> 
    arrange(key, rank) |>
    mutate(
      value = gsub("___.*", "", as.character(value))
    ) |>
    select(-rank)
  
  eda_export_latex(
    eda_summary = eda_summary_table |> as.data.frame(), 
    to_file = "eda_summary.tex", 
    append_flag=APPEND
  )
  
  cat('\n\\midrule\n\n', file = paste0(eda_dir, "eda_summary.tex"), append=TRUE)
  toc()
  
  APPEND <- TRUE
  
  gc()
  
}


eda_base |>
  write_csv(paste0(eda_dir, "eda_base.csv"))


# facets com geom_errorbar
# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
tic()
message("exportando EDA gráfica (facet) em disco...")

eda_plot <-
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
    ),
    value = case_when(
      is.na(value) ~ "nao_informado",
      TRUE ~ as.character(value)
    )
  ) |> 
  filter( !(key == 'cor_raca' & value == 'nao_informado')) |>
  mutate(
    rank = case_when(
      # reordenamento para 'uf'
      key == 'uf' ~ p,
      # reordenamento para 'instrucao'
      value == "outros"        ~ 1,
      value == "fundamental"   ~ 2,
      value == "medio"         ~ 3,
      value == "superior"      ~ 4,
      value == "nao_informado" ~ 5,
      # reordenamento para 'dif_ouvir'
      value == "nenhuma"  ~ 1,
      value == "alguma"   ~ 2,
      value == "grande"   ~ 3,
      value == "incapaz"  ~ 4,
      value == "ignorado" ~ 5,
      # reordenamento para 'faixa_idade'
      value == "0-4"      ~ 1,
      value == "5-9"      ~ 2,
      value == "10-19"    ~ 3,
      value == "20-39"    ~ 4,
      value == "40+"      ~ 5,
      TRUE                ~ 0
    ),
    value = reorder_within(value, rank, key)
  ) |> 
  select(-rank) |>
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
  facet_wrap(
    ~key, 
    nrow = 5, 
    scales = 'free'
  ) +
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 0.1)
  ) +
  scale_x_reordered() + 
  coord_flip() + 
  theme(
    legend.position = "none",
    axis.text.y = element_text(size = 6),
    axis.text.x = element_text(size = 6)
  ) +
  labs(
    # title = 'Análise exploratória de dados', 
    # subtitle = 'Etapa prévia à Modelagem Preditiva',
    y = 'percentual de usuários de libras',
    x = ''
  ) 

 eda_plot |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_facet.pdf"
    ),
    width=8,
    height=10
  )
toc()






# geom_errorbar individuais (pedido na quali)
tic()
message("exportando EDA gráfica (individualmente) em disco...")

for(arg_column in COLUMNS){
#  arg_column <- "alfabetizado"
eda_plot <-
  eda_base |>
  filter( key == arg_column ) |>
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
    ),
    value = case_when(
      is.na(value) ~ "nao_informado",
      TRUE ~ as.character(value)
    )
  ) |> 
  mutate(
    rank = case_when(
      # reordenamento para 'uf'
      key == 'uf' ~ p,
      # reordenamento para 'instrucao'
      value == "outros"        ~ 1,
      value == "fundamental"   ~ 2,
      value == "medio"         ~ 3,
      value == "superior"      ~ 4,
      value == "nao_informado" ~ 5,
      # reordenamento para 'dif_ouvir'
      value == "nenhuma"  ~ 1,
      value == "alguma"   ~ 2,
      value == "grande"   ~ 3,
      value == "incapaz"  ~ 4,
      value == "ignorado" ~ 5,
      # reordenamento para 'faixa_idade'
      value == "0-4"      ~ 1,
      value == "5-9"      ~ 2,
      value == "10-19"    ~ 3,
      value == "20-39"    ~ 4,
      value == "40+"      ~ 5,
      TRUE                ~ 0
    ),
    value = reorder_within(value, rank, key)
  ) |> 
  select(-rank) |>
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
  scale_y_continuous(
    labels = scales::percent_format(accuracy = 0.1)
  ) +
  scale_x_reordered() + 
  coord_flip() + 
  theme(
    legend.position = "none"
  ) +
  labs(
    # title = 'Análise exploratória de dados', 
    # subtitle = 'Etapa prévia à Modelagem Preditiva',
    y = 'percentual de usuários de libras',
    x = ''
  ) 

eda_plot |>
  ggsave(
    filename = paste0(
      eda_dir,
      "eda_geombar_",
      arg_column,
      ".pdf"
    ),
    width=ifelse(arg_column != "uf", 4, 8),
    height=ifelse(arg_column != "uf", 2, 5)
  )
}
toc()


