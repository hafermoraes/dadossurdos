library(ggplot2)
library(dplyr)
library(tidyr)

# Dados do gráfico
dados <- data.frame(
  faixa_etaria = factor(c("<30", "30-39", "40-49"),
                        levels = c("<30", "30-39", "40-49")),
  mean_actual = c(0.87, 1.17, 1.62),
  difference  = c(0.98, 0.79, 0.70)
)

# Transformar para formato longo
dados_long <- dados %>%
  pivot_longer(
    cols = c(mean_actual, difference),
    names_to = "tipo",
    values_to = "valor"
  )

# Gráfico
ggplot(dados_long, aes(x = faixa_etaria, y = valor, fill = tipo)) +
  geom_col(width = 0.45) +
  geom_text(
    aes(label = sprintf("%.2f", valor)),
    position = position_stack(vjust = 0.5),
    color = "white",
    size = 4
  ) +
  scale_fill_manual(
    values = c(
      mean_actual = "#1f77b4",  # azul
      difference  = "#d62728"   # vermelho
    ),
    labels = c(
      mean_actual = "Número médio de filhos",
      difference  = "Diferença (tidos-desejados)"
    )
  ) +
  labs(
    x = NULL,
    y = NULL,
    fill = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.major.y = element_line(color = "grey90", linewidth = 0.6),
    panel.grid.minor.y = element_line(color = "grey95", linewidth = 0.4),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    
    # REMOVE eixo Y
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    
    legend.position = "bottom"
  )




################################
library(ggplot2)
library(dplyr)
library(tidyr)

# Dados do gráfico (Apêndice) — mesmo padrão das funcionárias públicas
dados_ap <- data.frame(
  faixa_etaria = factor(c("<30", "30-39", "40-49"),
                        levels = c("<30", "30-39", "40-49")),
  mean_actual = c(0.61, 1.48, 1.99),
  difference  = c(1.25, 0.64, 0.31)
)

dados_long_ap <- dados_ap %>%
  pivot_longer(
    cols = c(mean_actual, difference),
    names_to = "tipo",
    values_to = "valor"
  )

ggplot(dados_long_ap, aes(x = faixa_etaria, y = valor, fill = tipo)) +
  geom_col(width = 0.45) +
  geom_text(
    aes(label = sprintf("%.2f", valor)),
    position = position_stack(vjust = 0.5),
    color = "white",
    size = 4
  ) +
  scale_fill_manual(
    values = c(
      mean_actual = "#1f77b4",  # azul
      difference  = "#d62728"   # vermelho
    ),
    labels = c(
      mean_actual = "Número médio de filhos",
      difference  = "Diferença (tidos-desejados)"
    )
  ) +
  labs(
    x = NULL,
    y = NULL,
    fill = NULL
  ) +
  theme_minimal(base_size = 13) +
  theme(
    panel.grid.major.y = element_line(color = "grey90", linewidth = 0.6),
    panel.grid.minor.y = element_line(color = "grey95", linewidth = 0.4),
    panel.grid.major.x = element_blank(),
    panel.grid.minor.x = element_blank(),
    axis.text.y  = element_blank(),
    axis.ticks.y = element_blank(),
    legend.position = "bottom"
  )

