library(tidymodels)
library(janitor)


clf_confmat_weighted

cm <- 
  clf_confmat_weighted$table |>
  as.data.frame.matrix() |>
  adorn_totals(where = c("row", "col")) |>
  adorn_percentages(denominator = "all") |>
  adorn_pct_formatting(digits = 2) |>
  adorn_ns()


library(janitor)
library(tidyr)

clf_confmat_weighted$table |>
  as.data.frame() |>
  pivot_wider(names_from = Truth, values_from = Freq) |>
  adorn_totals(where = c("row", "col")) |>
  adorn_percentages(denominator = "all") |>
  adorn_pct_formatting(digits = 2) |>
  adorn_ns()



library(dplyr)
library(tidyr)
library(janitor)

# 1. Dados base
df_base <- clf_confmat_weighted$table %>%
  as.data.frame() %>%
  pivot_wider(names_from = Truth, values_from = Freq) %>%
  adorn_totals(where = c("row", "col"))

total_geral <- as.numeric(df_base[nrow(df_base), ncol(df_base)])

# 2. Formatação manual rigorosa
df_tex <- df_base %>%
  mutate(across(-1, ~ {
    val_num <- as.numeric(.)
    pct_val <- (val_num / total_geral) * 100
    
    # Porcentagem: 2 casas, vírgula decimal
    pct_str <- formatC(pct_val, format = "f", digits = 2, decimal.mark = ",")
    
    # Contagem: Inteiro, ponto nos milhares
    # big.mark precisa de um caractere de escape em alguns contextos, aqui usamos "."
    cnt_str <- formatC(val_num, format = "d", big.mark = ".", decimal.mark = ",")
    
    # Resultado: \makecell{33,07\% \\ (8.737.116)}
    paste0("\\makecell{", pct_str, "\\% \\\\ (", cnt_str, ")}")
  }))

# 3. Gerar as linhas (ajustando os nomes das categorias para Capitalizado)
df_tex[[1]] <- c("Não", "Sim", "Total") # Ajusta a primeira coluna

rows <- apply(df_tex, 1, function(x) paste(x, collapse = " & "))

# 4. Estrutura final para o arquivo
latex_code <- c(
  "\\begin{table}[h]",
  "\\centering",
  "\\renewcommand{\\arraystretch}{1.5}",
  "\\begin{tabular}{l ccc}",
  "\\toprule",
  "Predição & Não & Sim & Total \\\\",
  "\\midrule",
  paste0(rows[1], " \\\\"), # Linha Não
  paste0(rows[2], " \\\\"), # Linha Sim
  "\\midrule",
  paste0(rows[3], " \\\\"), # Linha Total
  "\\bottomrule",
  "\\end{tabular}",
  "\\end{table}"
)

writeLines(latex_code, "matriz_final.tex")











library(tidymodels)
library(tidyverse)
library(janitor)

# 1. Preparação dos dados puros
df_base <- clf_confmat_weighted$table %>%
  as.data.frame() %>%
  pivot_wider(names_from = Truth, values_from = Freq) %>%
  adorn_totals(where = c("row", "col"))

total_geral <- as.numeric(df_base[nrow(df_base), ncol(df_base)])

# 2. Formatação das células (BR + Cinza + Makecell)
df_tex_vals <- df_base %>%
  mutate(across(-1, ~ {
    val_num <- as.numeric(.)
    pct_val <- (val_num / total_geral) * 100
    pct_str <- formatC(pct_val, format = "f", digits = 2, decimal.mark = ",")
    cnt_str <- formatC(val_num, format = "d", big.mark = ".", decimal.mark = ",")
    paste0("\\makecell{", pct_str, "\\% \\\\ \\textcolor{gray}{(", cnt_str, ")}}")
  }))

# 3. Construção das linhas com Rotação (90 graus)
# Linha 1: O \multirow com \rotatebox
# Linha 2: Primeira coluna vazia
# Linha 3: Total (alinhado abaixo das classes)

l1 <- df_tex_vals[1, ]
l2 <- df_tex_vals[2, ]
l3 <- df_tex_vals[3, ]

linha1 <- paste0("\\multirow{2}{*}{\\rotatebox{90}{\\makecell{Predito}}} & Não & ", 
                 l1[2], " & ", l1[3], " & ", l1[4])

linha2 <- paste0(" & Sim & ", 
                 l2[2], " & ", l2[3], " & ", l2[4])

linha_total <- paste0("Total & & ", 
                      l3[2], " & ", l3[3], " & ", l3[4])

# 4. Estrutura Completa do LaTeX
latex_code <- c(
  "\\begin{table}[h]",
  "\\centering",
  "\\renewcommand{\\arraystretch}{2.0}",
  "\\begin{tabular}{llccc}",
  "\\toprule",
  " & & \\multicolumn{2}{c}{Real} & \\\\",
  "\\cmidrule(lr){3-4}",
  " & & Não & Sim & Total \\\\",
  "\\midrule",
  paste0(linha1, " \\\\"),
  paste0(linha2, " \\\\"),
  "\\midrule",
  paste0(linha_total, " \\\\"),
  "\\bottomrule",
  "\\end{tabular}",
  "\\end{table}"
)

# 5. Salvar arquivo
writeLines(latex_code, "matriz_libras_final.tex")

# Visualizar
cat(paste(latex_code, collapse = "\n"))
