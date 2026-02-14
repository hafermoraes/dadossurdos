
metrics <- data.frame(
  metric = c('a', 'b', 'c'),
  value = rnorm(3)
)


params <- data.frame(
  metric = c('epoch', 'n_trees', 'max_depth'),
  value = c(1000, 50, 75)
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


optimum_threshold <- 0.17653

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

