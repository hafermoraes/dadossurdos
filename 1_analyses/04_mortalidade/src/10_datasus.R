if(PARETO_DATASUS_DATA){
  
  anos <- 2000:2010
  ufs <- c("AC", "AL", "AP", "AM", "BA", "CE", "DF", "ES", "GO", "MA", 
           "MT", "MS", "MG", "PA", "PB", "PR", "PE", "PI", "RJ", "RN", 
           "RS", "RO", "RR", "SC", "SP", "SE", "TO")

  processar_capitulo_manual <- function(input_df) {

    names(input_df) <- toupper(names(input_df))
    
    input_df |>
      mutate(LETRA = substr(trimws(CAUSABAS), 1, 1)) |>
      mutate(CAPITULO_CID10 = case_when(
        LETRA %in% c("A", "B") ~ "I. Infecciosas e parasitárias",
        LETRA == "C" | (LETRA == "D" & as.numeric(substr(CAUSABAS, 2, 3)) <= 48) ~ "II. Neoplasias",
        LETRA == "D" & as.numeric(substr(CAUSABAS, 2, 3)) >= 50 ~ "III. Doenças sangue/imunes",
        LETRA == "E" ~ "IV. Endócrinas, nutricionais e metabólicas",
        LETRA == "F" ~ "V. Transtornos mentais",
        LETRA == "G" ~ "VI. Sistema nervoso",
        LETRA == "H" & as.numeric(substr(CAUSABAS, 2, 3)) <= 59 ~ "VII. Olho e anexos",
        LETRA == "H" & as.numeric(substr(CAUSABAS, 2, 3)) >= 60 ~ "VIII. Ouvido",
        LETRA == "I" ~ "IX. Aparelho circulatório",
        LETRA == "J" ~ "X. Aparelho respiratório",
        LETRA == "K" ~ "XI. Aparelho digestivo",
        LETRA == "L" ~ "XII. Pele e tecido subcutâneo",
        LETRA == "M" ~ "XIII. Sistema osteomuscular",
        LETRA == "N" ~ "XIV. Aparelho geniturinário",
        LETRA == "O" ~ "XV. Gravidez e parto",
        LETRA == "P" ~ "XVI. Período perinatal",
        LETRA == "Q" ~ "XVII. Malformações congênitas",
        LETRA == "R" ~ "XVIII. Sintomas e achados anormais",
        LETRA %in% c("S", "T") ~ "XIX. Lesões e envenenamentos",
        LETRA %in% c("V", "W", "X", "Y") ~ "XX. Causas externas",
        LETRA == "Z" ~ "XXI. Contatos com serviços de saúde",
        TRUE ~ "Não classificado"
      ))
  }

  extrair_dados <- function(uf, ano) {
    tryCatch({
      message(paste("Baixando:", uf, ano))
      dados <- fetch_datasus(
        year_start = ano,
        year_end = ano,
        uf = uf, 
        information_system = "SIM-DO",
        vars = c("CAUSABAS")
      )
      
      if (is.null(dados) || nrow(dados) == 0) return(NULL)
      
      dados |>
        processar_capitulo_manual() |>
        group_by(CAPITULO_CID10) |>
        summarise(obitos = n(), .groups = "drop") |>
        mutate(ano = ano)
    }, error = function(e) {
      message(paste("Erro em", uf, ano, ":", e$message))
      return(NULL)
    })
  }

  sim_2000_2010 <-
    map2_df(
      rep(ufs, each = length(anos)), 
      rep(anos, times = length(ufs)), 
      extrair_dados
    )

  tic()
  message("consolidando as informações por ano e por capítulo da CID-10...")
  sim_2000_2010_grp <-
    sim_2000_2010 |>
    group_by(ano, CAPITULO_CID10) |>
    summarise(
      total_obitos = sum(obitos),
      .groups = "drop"
    )
  toc()

  tic()
  message("escrevendo as informações consolidadas em disco...")
  sim_2000_2010_grp |>
    write_csv(
      paste0(
        data_dir,
        "sim_2000_2010_grp.csv"
      )
    )
  toc()

} # if(PARETO_DATASUS_DATA)


if(PARETO_DATASUS_PLOT){
  
  sim_2000_2010_grp <-
    read_csv(
      paste0(
        data_dir,
        "sim_2000_2010_grp.csv"
      ),
      show_col_types = FALSE
    )
  
  tic()
  message("exportando gráfico de pareto das causas básicas de morte (Datasus/SIM, 2000-2010)...")
  export_plot_pareto(
    input_df = sim_2000_2010_grp,
    plot_width = 12,
    plot_height = 6,
    output_file = paste0(
      results_dir,
      "pareto_capcid10_sim20002010.pdf"
    )
  )
  toc()
}


# sim_2000_2010_grp |>
#   group_by(CAPITULO_CID10) |>
#   summarise(s = sum(total_obitos)) |>
#   arrange(desc(s)) |>
#   mutate(
#     p = s/sum(s)*100.0,
#     c = cumsum(p)
#   )

  
