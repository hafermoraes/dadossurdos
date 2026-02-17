#' Módulo de Exportação para LaTeX
#'
#' @description
#' Este módulo contém funções para converter resultados de modelos (tabelas de métricas, 
#' thresholds e matrizes de confusão) em comandos personalizados do LaTeX (\code{\\newcommand}).
#' Facilita a automação de relatórios dinâmicos garantindo a formatação numérica no padrão brasileiro.
#'
#' @details
#' As funções utilizam o pacote \code{xtable} para conversão de tabelas e \code{stringr} 
#' para manipulação de strings. Os comandos gerados são apensados (\code{append = TRUE}) 
#' ao arquivo de destino.
#'
#' @name mod_export_latex
NULL

message("carregando as funções de apoio para o latex...")


#' Exporta Tabelas de Especificações para LaTeX
#'
#' @description
#' Gera um comando LaTeX \code{\\newcommand} contendo uma tabela formatada (\code{tabular}).
#' A função trata automaticamente a limpeza de caracteres especiais, formatação de números
#' no padrão brasileiro (ponto como milhar e vírgula como decimal) e remoção de zeros 
#' excedentes.
#'
#' @param input_table Um \code{data.frame} ou \code{tibble} com duas colunas. A segunda 
#' coluna deve conter os valores numéricos a serem formatados.
#' @param model String com o caminho do modelo (ex: 'mod01_unico/'). A função extrai 
#' apenas o nome central (ex: 'unico') para compor o nome do comando.
#' @param classifier Nome do classificador (ex: 'rf', 'logres').
#' @param specification Tipo de especificação (ex: 'params', 'metrics').
#' @param output_file Caminho do arquivo \code{.tex} onde o comando será apensado.
#'
#' @details 
#' O nome do comando gerado segue o padrão: \code{\\MOD[modelo]CLF[classificador]SPEC[especificacao]}.
#' Os números são arredondados para até 3 casas decimais, mas zeros à direita são 
#' removidos (ex: 50,000 vira 50). Caracteres como '_' são escapados automaticamente.
#'
#' @return A função não retorna objetos no R, agindo apenas sobre o sistema de arquivos.
#' @export
#'
#' @examples
#' \dontrun{
#' export_specs_to_latex(df_params, "mod01_unico/", "rf", "params", "tabelas.tex")
#' }
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
        "\n\n\\newcommand{",latex_var,"}{\n",
        "  \\begingroup\n",
        "  \\tiny\n",
        "  \\begin{tabular}{ll}\n"
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
        "\\end{tabular}\n",
        "  \\endgroup\n",
        "}"
      ),
        file = output_file,
        append = TRUE
    )
} # closing... export_specs_to_latex



#' Exporta um valor de Threshold para comando LaTeX
#'
#' @description
#' Extrai o nome do modelo a partir do caminho do arquivo, combina com o classificador 
#' e a especificação para criar um comando \code{\\newcommand} no formato LaTeX. 
#' O valor do threshold é arredondado para 4 casas decimais.
#'
#' @param threshold Valor numérico do ponto de corte (threshold).
#' @param model String contendo o caminho do modelo (ex: 'diretorio/modelo/'). 
#' A função extrai o texto entre a última barra e o caractere anterior.
#' @param classifier Nome do classificador utilizado (ex: 'random_forest').
#' @param specification Nome da especificação ou métrica (ex: 'best_threshold').
#' @param output_file Caminho para o arquivo \code{.tex} onde o comando será apensado.
#'
#' @return A função não retorna um valor no R, mas escreve uma linha no arquivo 
#' especificado em \code{output_file}.
#' 
#' @examples
#' export_threshold_to_latex(0.54321, "mod01_unico/", "logres", "thresh", "params.tex")
#' 
#' @export
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
        "\n\n\\newcommand{",latex_var,"}{",round(threshold, N_DIGITS),"}\n\n"
      ),
      file = output_file,
      append = TRUE
    )
} # closing... export_threshold_to_latex



#' Exporta Matrizes de Confusão para LaTeX
#'
#' @description
#' Gera dois comandos LaTeX personalizados (\code{\\newcommand}) contendo matrizes de confusão:
#' uma versão "minimal" (apenas o núcleo da matriz) e uma versão "withmargins" (incluindo totais
#' e linhas de grade). Os valores são apresentados como porcentagens com a contagem absoluta
#' logo abaixo em uma cor secundária.
#'
#' @param input_table Um \code{data.frame} ou matriz numérica 2x2 contendo as contagens 
#' da matriz de confusão.
#' @param model String com o caminho do modelo (ex: 'mod01_unico/'). A função extrai 
#' o termo entre '_' e '/' para o nome do comando.
#' @param classifier Nome do classificador (ex: 'logres', 'random_forest').
#' @param output_file Caminho do arquivo \code{.tex} onde os comandos serão apensados.
#'
#' @details 
#' A função gera dois comandos baseados no prefixo \code{\\MOD[modelo]CLF[classificador]CONFMAT}:
#' \itemize{
#'   \item \code{...minimal}: Tabela compacta com Real vs Predito.
#'   \item \code{...withmargins}: Tabela completa com marginais de soma (Totais), 
#'   incluindo \code{\\midrule} e \code{\\cmidrule}.
#' }
#' 
#' @note 
#' O código LaTeX gerado requer os seguintes pacotes no preâmbulo:
#' \code{\\usepackage{makecell, multirow, graphicx, xcolor, booktabs, array}}.
#' Além disso, a cor \code{cor} deve estar definida (ex: \code{\\definecolor{cor}{HTML}{666666}}).
#'
#' @return A função não retorna valor, escrevendo diretamente no arquivo de saída.
#' @export
#'
#' @examples
#' \dontrun{
#' conf_data <- data.frame(nao = c(1300, 50), sim = c(60, 1400))
#' export_confmat_to_latex(conf_data, "mod01_unico/", "logres", "tabelas.tex")
#' }
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
    PCTs <-
      input_table$table |>
      as.data.frame() |>
      pivot_wider(names_from = Truth, values_from = Freq) |>
      adorn_totals(where = c("row", "col")) |>
      adorn_percentages(denominator = "all") |>
      adorn_pct_formatting(digits = PCT_DIGITS) |>
      mutate(across(-1, \(x) str_remove(x, "%")))
    
    CNTs <-
      input_table$table |>
      as.data.frame() |>
      pivot_wider(names_from = Truth, values_from = Freq) |>
      adorn_totals(where = c("row", "col")) |>
      mutate(
        across(
          -1, 
          \(x) format(
            round(x, CNT_DIGITS),
            big.mark = ".",
            decimal.mark = ",",
            scientific = FALSE,
            trim = TRUE
          )
        )
      )

    # matriz de confusão sem as margens
    cat(
      paste0(
        "\n\n\\newcommand{",latex_var_prefix, "minimal}{\n",
        "  \\begingroup\n",
        "  \\tiny\n",
        "  \\begin{tabular}{m{0.1cm}ccc}\n",
        "    & & \\multicolumn{2}{c}{Real} \\\\\n",
        "    & & Não & Sim \\\\\n\n",
        "    \\multirow{2}{*}{\\rotatebox{90}{Predito}}\n",
        "    & Não\n",
        "    & \\makecell{", PCTs[1,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,2],")}}\n",
        "    & \\makecell{", PCTs[1,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,3],")}} \\\\ \n\n",
        "    & Sim\n",
        "    & \\makecell{", PCTs[2,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,2],")}}\n",
        "    & \\makecell{", PCTs[2,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,3],")}} \\\\ \n\n",
        "  \\end{tabular}\n",
        "  \\endgroup\n",
        "}",
        "\n\n"
      ),
      file = output_file,
      append = TRUE
    )

    # matriz de confusão com as margens
    cat(
      paste0(
        "\n\n\\newcommand{",latex_var_prefix, "withmargins}{\n",
        "  \\begin{tabular}{m{0.1cm}cccc}\n\n",
        "    & & \\multicolumn{2}{c}{Real} & \\\\\n",
        "    \\cmidrule(lr){3-4}\n",
        "    & & Não & Sim & \\\\",
        "    \\midrule\n\n",
        "    \\multirow{2}{*}{\\rotatebox{90}{Predito}}\n",
        "    & Não\n",
        "    & \\makecell{", PCTs[1,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,2],")}}\n",
        "    & \\makecell{", PCTs[1,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,3],")}}\n",
        "    & \\makecell{", PCTs[1,4], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,4],")}} \\\\ \n\n",
        "    & Sim\n",
        "    & \\makecell{", PCTs[2,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,2],")}}\n",
        "    & \\makecell{", PCTs[2,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,3],")}}\n",
        "    & \\makecell{", PCTs[2,4], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,4],")}} \\\\ \n\n",
        "    \\midrule\n\n",
        "    & \n",
        "    & \\makecell{", PCTs[3,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[3,2],")}}\n",
        "    & \\makecell{", PCTs[3,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[3,3],")}}\n",
        "    & \\makecell{", PCTs[3,4], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[3,4],")}} \\\\ \n\n",        
        "  \\end{tabular}\n",
        "}\n\n"
      ),
      file = output_file,
      append = TRUE
    )
} # closing... export_confmat_to_latex



#' Exporta Sub-Matrizes de Confusão para LaTeX
#'
#' @description
#' Gera comandos LaTeX personalizados (\code{\\newcommand}) para sub-matrizes de confusão
#' (geralmente baseadas em subgrupos ou condições específicas como 'dif_ouvir'). 
#' Assim como a função principal, exporta as versões "minimal" e "withmargins".
#'
#' @param input_table Um \code{data.frame} com as contagens da sub-matriz.
#' @param model String com o caminho do modelo (ex: 'mod01_unico/').
#' @param classifier Nome do classificador (ex: 'logres').
#' @param dif_ouvir Identificador do subgrupo ou condição (ex: 'sim', 'nao') que será 
#' incorporado ao nome da variável no LaTeX.
#' @param output_file Caminho do arquivo \code{.tex} de destino.
#'
#' @details 
#' O prefixo da variável gerada segue o padrão: 
#' \code{\\MOD[modelo]CLF[classificador]SUB[dif_ouvir]CONFMAT}.
#' Os valores de porcentagem (\code{PCTs}) são formatados com 1 casa decimal e 
#' as contagens (\code{CNTs}) usam separador de milhar brasileiro.
#' 
#' @note 
#' Requer os pacotes LaTeX: \code{makecell, multirow, graphicx, xcolor, booktabs, array}.
#' A cor \code{cor} deve estar definida no preâmbulo do seu documento .tex.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' export_subconfmat_to_latex(df_sub, "mod01_unico/", "rf", "sim", "resultados.tex")
#' }
export_subconfmat_to_latex <-
  function(
           input_table,
           model,
           classifier,
           dif_ouvir,
           output_file
           ) {

    # modelo
    MOD <- stringr::str_split_i(model, "[_/]", 2)

    # classificador
    CLF <- classifier

    # nome da variável no latex
    latex_var_prefix <- paste0("\\MOD",MOD,"CLF",CLF,"SUB", dif_ouvir,"CONFMAT")

    # opções
    PCT_DIGITS <- 1
    CNT_DIGITS <- 0
    
    # cálculos
    PCTs <-
      input_table$table |>
      as.data.frame() |>
      pivot_wider(names_from = Truth, values_from = Freq) |>
      adorn_totals(where = c("row", "col")) |>
      adorn_percentages(denominator = "all") |>
      adorn_pct_formatting(digits = PCT_DIGITS) |>
      mutate(across(-1, \(x) str_remove(x, "%")))

    CNTs <-
      input_table$table |>
      as.data.frame() |>
      pivot_wider(names_from = Truth, values_from = Freq) |>
      adorn_totals(where = c("row", "col")) |>
      mutate(
        across(
          -1, 
          \(x) format(
            round(x, CNT_DIGITS),
            big.mark = ".",
            decimal.mark = ",",
            scientific = FALSE,
            trim = TRUE
          )
        )
      )

    # matriz de confusão sem as margens
    cat(
      paste0(
        "\n\n\\newcommand{",latex_var_prefix, "minimal}{\n",
        "  \\begingroup\n",
        "  \\tiny\n",
        "  \\begin{tabular}{m{0.1cm}ccc}\n",
        "    & & \\multicolumn{2}{c}{Real} \\\\\n",
        "    & & Não & Sim \\\\\n\n",
        "    \\multirow{2}{*}{\\rotatebox{90}{Predito}}\n",
        "    & Não\n",
        "    & \\makecell{", PCTs[1,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,2],")}}\n",
        "    & \\makecell{", PCTs[1,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,3],")}} \\\\ \n\n",
        "    & Sim\n",
        "    & \\makecell{", PCTs[2,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,2],")}}\n",
        "    & \\makecell{", PCTs[2,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,3],")}} \\\\ \n\n",
        "  \\end{tabular}\n",
        "  \\endgroup\n",
        "}",
        "\n\n"
      ),
      file = output_file,
      append = TRUE
    )

    # matriz de confusão com as margens
    cat(
      paste0(
        "\n\n\\newcommand{",latex_var_prefix, "withmargins}{\n",
        "  \\begin{tabular}{m{0.1cm}cccc}\n\n",
        "    & & \\multicolumn{2}{c}{Real} & \\\\\n",
        "    \\cmidrule(lr){3-4}\n",
        "    & & Não & Sim & \\\\",
        "    \\midrule\n\n",
        "    \\multirow{2}{*}{\\rotatebox{90}{Predito}}\n",
        "    & Não\n",
        "    & \\makecell{", PCTs[1,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,2],")}}\n",
        "    & \\makecell{", PCTs[1,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,3],")}}\n",
        "    & \\makecell{", PCTs[1,4], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[1,4],")}} \\\\ \n\n",
        "    & Sim\n",
        "    & \\makecell{", PCTs[2,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,2],")}}\n",
        "    & \\makecell{", PCTs[2,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,3],")}}\n",
        "    & \\makecell{", PCTs[2,4], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[2,4],")}} \\\\ \n\n",
        "    \\midrule\n\n",
        "    & \n",
        "    & \\makecell{", PCTs[3,2], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[3,2],")}}\n",
        "    & \\makecell{", PCTs[3,3], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[3,3],")}}\n",
        "    & \\makecell{", PCTs[3,4], "\\% \\\\ \\textcolor{\\cor}{(", CNTs[3,4],")}} \\\\ \n\n",        
        "  \\end{tabular}\n",
        "}\n\n"
      ),
      file = output_file,
      append = TRUE
    )
} # closing... export_subconfmat_to_latex







if(FALSE){
  metrics <- data.frame(
    metric = c('a', 'b', 'c'),
    value = rnorm(3)
  )

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

  params <- data.frame(
    metric = c('epoch', 'n_trees', 'max_depth'),
    value = c(1000, 50, 75)
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


  confmat <- data.frame(
    nao = c(1300.87, 50.98798),
    sim = c(60.223, 1400.3123142)
  ) |>
    transmute(
      predito = c('nao','sim'),
      nao, sim
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

  export_subconfmat_to_latex(
    input_table = confmat,
    model="mod01_unico/",
    classifier="logres",
    dif_ouvir="nenhuma",
    output_file = paste0(
      results_dir,
      "vars_unico.tex"
    )
  )

} # closing... if(FALSE)
