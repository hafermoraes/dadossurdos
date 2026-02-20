
censo2000_stats <-
  read_csv(
    paste0(
      base_dir,
      "02_censo2000_libras/",
      "results/",
      "censo2000_stats.csv"
    )
  )

censo2010_stats <-
  read_csv(
    paste0(
      base_dir,
      "02_censo2010_libras/",
      "results/",
      "censo2010_stats.csv"
    )
  )


censo_stats <- 
  censo2000_stats |>
  transmute(
    cat, 
    N_2000 = N,
    N_ci95_2000 = paste0("[", N_low, "; ", N_upp, "]")
    ) |>
  left_join(
  censo2010_stats |>
    transmute(
      cat, 
      N_2010 = N,
      N_ci95_2010 = paste0("[", N_low, "; ", N_upp, "]")
    ) 
  )

print(
  xtable( censo_stats ),
  sanitize.text.function = NULL,
  only.contents=TRUE,
  include.rownames=FALSE,
  include.colnames=FALSE,
  hline.after=NULL,
  comment=FALSE,
  file=paste0(results_dir, "censo_stats_by_categ.tex")
)

output_str <- capture.output(
  print(
    xtable(censo_stats),
    sanitize.text.function = NULL,
    only.contents = TRUE,
    include.rownames = FALSE,
    include.colnames = FALSE,
    hline.after = NULL,
    comment = FALSE
  )
)

output_str[length(output_str)] <- gsub("\\\\ \\\\", "", output_str[length(output_str)])

# 1. Identifica a última linha que não é apenas espaço em branco
idx <- max(which(grepl("[^[:space:]]", output_str)))

# 2. Remove o " \\ " apenas desta linha (o R mostra \\\\ porque escapa a barra)
output_str[idx] <- gsub("\\\\\\\\ *$", "", output_str[idx])

# 3. Remove a linha vazia residual (opcional)
output_str <- output_str[1:idx]

# 4. Salva
cat(output_str, sep = "\n", file = paste0(results_dir, "censo_stats_by_categ.tex"))


writeLines(output_str, paste0(results_dir, "censo_stats_by_categ.tex"))
