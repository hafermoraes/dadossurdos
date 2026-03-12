library(ggplot2)
library(dplyr)
library(tidyr)

# -----------------------------
# 1) Dados (Funcionárias públicas 40–49)
# -----------------------------
dados_td <- data.frame(
  progressao = c("0-1", "1-2", "2-3", "3-4"),
  atual    = c(0.724, 0.740, 0.348, 0.344),
  desejado = c(0.924, 0.857, 0.359, 0.455)
)

progressao_levels <- c("0-1", "1-2", "2-3", "3-4")

# -----------------------------
# 2) Long format
# -----------------------------
dados_long <- dados_td %>%
  pivot_longer(
    cols = c(atual, desejado),
    names_to = "serie",
    values_to = "PPR"
  ) %>%
  mutate(
    progressao = factor(progressao, levels = progressao_levels),
    serie = dplyr::recode(
      serie,
      atual = "Filhos Tidos",
      desejado = "Filhos Desejados"
    )
  )

# -----------------------------
# 3) Estilo (igual ao exemplo)
# -----------------------------
linhas <- c("Filhos Tidos" = "solid", "Filhos Desejados" = "dashed")
cores  <- c("Filhos Tidos" = "#1f77b4", "Filhos Desejados" = "#d62728")  # azul e vermelho

ggplot(
  dados_long,
  aes(
    x = progressao,
    y = PPR,
    color = serie,
    linetype = serie,
    group = serie
  )
) +
  geom_line(linewidth = 2.0) +             # linha mais grossa
  scale_color_manual(values = cores) +
  scale_linetype_manual(values = linhas) +
  coord_cartesian(ylim = c(0, 1)) +
  scale_y_continuous(breaks = seq(0, 1, 0.25)) +
  labs(
    x = "Progressão",
    y = "PPR",
    color = NULL,
    linetype = NULL
  ) +
  theme_minimal(base_size = 12) +
  theme(
    # grade bem clarinha e só horizontal
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    panel.grid.minor.y = element_blank(),
    panel.grid.major.y = element_line(color = "grey85", linewidth = 0.8),
    
    # eixos e textos como no exemplo
    axis.title.x = element_text(size = 12),
    axis.title.y = element_text(size = 12),
    axis.text = element_text(size = 12),
    
    # legenda fora (se quiser igual ao exemplo sem legenda, muda pra "none")
    legend.position = "bottom"
  )
