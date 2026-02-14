
library(janitor)
library(stringr)
library(xtable)

metrics <- data.frame(
  metric = c('a', 'b', 'c'),
  value = rnorm(3)
)

params <- data.frame(
  metric = c('epoch', 'n_trees', 'max_depth'),
  value = c(1000, 50, 75)
)

optimum_threshold <- 0.17653

confmat <- data.frame(
  nao = c(1300.87, 50.98798),
  sim = c(60.223, 1400.3123142)
) |>
  transmute(
    predito = c('nao','sim'),
    nao, sim
  )



export_specs_to_latex <-
  function(
           input_table,
           model,
           classifier,
           specification,
           output_file
           ) {

    # modelo
    MOD <- stringr::str_split_i(model, "[_/]", 2)

    # classificador
    CLF <- classifier

    # especificação (métrica/hiperparâmetro/threshold)
    SPEC <- specification

    # nome da variável no latex
    latex_var <- paste0("\\MOD",MOD,"CLF",CLF,"SPEC",SPEC)
    
    cat(
      paste0(
        "\n\n\\newcommand{",latex_var,"}{\n  \\begingroup\n  \\tiny\n  \\begin{tabular}{ll}\n"
      ),
      file = output_file,
      append = TRUE
    )

    input_table[[2]] <- format(
      round(as.numeric(input_table[[2]]), 3), # Arredonda para 3 casas
      big.mark = ".", 
      decimal.mark = ",", 
      nsmall = 0,           # Não força zeros se não precisar
      drop0trailing = TRUE, # Remove zeros extras (ex: 50,000 vira 50)
      scientific = FALSE
    )
    
    print(
      xtable( 
        input_table
      ),
      sanitize.text.function = function(x) {
        xtable::sanitize(x) 
      },
      only.contents=TRUE,
      include.rownames=FALSE,
      include.colnames=FALSE,
      hline.after=NULL,
      comment=FALSE,
      file=output_file,
      append=TRUE
    )
    
    cat(
      paste0(
        "\\end{tabular}\n  \\endgroup\n}"
      ),
        file = output_file,
        append = TRUE
    )
}




export_threshold_to_latex <-
  function(
           threshold,
           model,
           classifier,
           specification,
           output_file
           ) {

    # modelo
    MOD <- stringr::str_split_i(model, "[_/]", 2)

    # classificador
    CLF <- classifier

    # especificação (métrica/hiperparâmetro/threshold)
    SPEC <- specification

    # nome da variável no latex
    latex_var <- paste0("\\MOD",MOD,"CLF",CLF,"SPEC",SPEC)

    N_DIGITS <- 4
    
    cat(
      paste0(
        "\n\n\\newcommand{",
        latex_var,
        "}{",
        round(threshold, N_DIGITS),
        "}\n\n"
      ),
      file = output_file,
      append = TRUE
    )
}




export_confmat_to_latex <-
  function(
           input_table,
           model,
           classifier,
           output_file
           ) {

    # modelo
    MOD <- stringr::str_split_i(model, "[_/]", 2)

    # classificador
    CLF <- classifier

    # nome da variável no latex
    latex_var_prefix <- paste0("\\MOD",MOD,"CLF",CLF,"CONFMAT")

    # opções
    PCT_DIGITS <- 1
    CNT_DIGITS <- 0
    
    # cálculos
    PCTs <- input_table |>
      adorn_totals(where = c("row", "col")) |>
      adorn_percentages(denominator = "all") |>
      adorn_pct_formatting(digits = PCT_DIGITS) |>
      mutate(across(-1, \(x) str_remove(x, "%")))

    CNTs <- confmat |>
      adorn_totals(where = c("row", "col")) |>
      mutate(
        across(
          -1, 
          \(x) format(
            round(x, CNT_DIGITS),
            big.mark = ".",
            decimal.mark = ",",
            scientific = FALSE
          )
        )
      )

##   \newcommand{\confmat}{
##   \begingroup
##   \tiny
##   \begin{tabular}{m{0.1cm}cccc}
##     & & \multicolumn{2}{c}{Real} & \\
##     & & Não & Sim &  \\
    
##     \multirow{2}{*}{\rotatebox{90}{Predito}}
##     & Não
##     & \makecell{33,07\% \\ \textcolor{\cor}{(8.737.116)}}
##     & \makecell{0,15\% \\ \textcolor{\cor}{(39.062)}}  \\
    
##     & Sim
##     & \makecell{63,46\% \\ \textcolor{\cor}{(16.766.127)}}
##     & \makecell{3,32\% \\ \textcolor{\cor}{(876.836)}}  \\
##   \end{tabular}
##   \endgroup
## }

    # matriz de confusão sem as margens
    cat(
      paste0(
        "\n\n\\newcommand{",
        latex_var_prefix, "minimal}",
        "{\n  \\begingroup",
        "\n  \\tiny\n",
        "  \\begin{tabular}{m{0.1cm}cccc}\n",
        "    & & \\multicolumn{2}{c}{Real} & \\\\\n",
        "    & & Não & Sim & \\\\\n\n",
        "    \\multirow{2}{*}{\\rotatebox{90}{Predito}}\n",
        "    & Não\n",
        "    & \\makecell{", PCTs[1,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,2],")}}\n",
        "    & \\makecell{", PCTs[1,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,3],")}} \\\\ \n\n",
        "    & Sim\n",
        "    & \\makecell{", PCTs[2,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,2],")}}\n",
        "    & \\makecell{", PCTs[2,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,3],")}} \\\\ \n\n",
        "  \\end{tabular}\n",
        "  \\endgroup\n",
        "}\n\n"
      ),
      file = output_file,
      append = TRUE
    )

}












export_specs_to_latex(
  input_table=metrics,
  model="mod01_unico/",
  classifier="logres",
  specification="metrics",
  output_file = paste0(
    results_dir,
    "vars_unico.tex"
  )
)



export_specs_to_latex(
  input_table=params,
  model="mod01_unico/",
  classifier="logres",
  specification="params",
  output_file = paste0(
    results_dir,
    "vars_unico.tex"
  )
)


export_threshold_to_latex(
  threshold=optimum_threshold,
  model="mod01_unico/",
  classifier="logres",
  specification="threshold",
  output_file = paste0(
    results_dir,
    "vars_unico.tex"
  )
)


export_confmat_to_latex(
  input_table = confmat,
  model="mod01_unico/",
  classifier="logres",
  output_file = paste0(
    results_dir,
    "vars_unico.tex"
  )
)