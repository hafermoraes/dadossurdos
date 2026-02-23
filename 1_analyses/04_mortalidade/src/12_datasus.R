
## # remotes::install_github("rfsaldanha/microdatasus")
library(microdatasus)
library(dplyr)
library(purrr)
library(readr)
library(tictoc)
library(scales)
library(stringr)

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





# 1. Preparar os dados (ordenados do maior para o menor)
pareto_data <- sim_2000_2010 %>%
  group_by(CAPITULO_CID10) %>%
  summarise(total_mortes = sum(obitos, na.rm = TRUE)) %>%
  arrange(desc(total_mortes)) %>%
  mutate(
    percent_acumulada = cumsum(total_mortes) / sum(total_mortes) * 100,
    # Quebra o texto a cada 25 caracteres para facilitar a leitura em 90 graus
    capitulo_wrap = str_wrap(CAPITULO_CID10, width = 15),
    capitulo_wrap = factor(capitulo_wrap, levels = unique(capitulo_wrap))
  )

# 2. Ajuste de escala para alinhar barras e linha
max_mortes <- max(pareto_data$total_mortes)
ratio <- max_mortes / 100

# 3. Gráfico Vertical
ggplot(pareto_data, aes(x = capitulo_wrap)) +
  # Barras de frequência
  geom_col(aes(y = total_mortes), fill = "grey40", alpha = 0.8) +
  # Linha de Pareto
  geom_line(aes(y = percent_acumulada * ratio, group = 1), color = "black", size = 0.5) +
  geom_point(aes(y = percent_acumulada * ratio), color = "black", size = 1) +
  # Rótulos de porcentagem na linha
  geom_text(aes(y = percent_acumulada * ratio, 
                label = paste0(round(percent_acumulada, 1), "%")),
            vjust = -1.5, color = "black", size = 3) +
  # Eixos e Escalas
  scale_y_continuous(
    name = "Total de Óbitos",
    labels = label_number(scale = 1e-6, suffix = " mi."),
    expand = expansion(mult = c(0, 0.2)),
    sec.axis = sec_axis(
      ~ . / ratio, 
      name = "Porcentagem Acumulada", 
      breaks = seq(0, 100, by = 20),
      labels = label_percent(scale = 1, suffix = "%")
    )
  ) +
  #theme_minimal() +
  labs(
    x = "Capítulo da CID-10"
  ) +
  theme(
    axis.text.x = element_text(angle = 90, vjust = 0.5, hjust = 1, size = 9),
    axis.title.y.right = element_text(color = "black"),
    axis.text.y.right = element_text(color = "black"),
    panel.grid.minor = element_blank()
  )
