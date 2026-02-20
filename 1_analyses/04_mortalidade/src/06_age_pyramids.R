

tic()
message("pirâmides etárias comparativas usando facet_wrap...")
censo_mortalidade |>
  mutate(n_plot = ifelse(sexo == "feminino", -n, n)) |>
  ggplot(aes(x = idade, y = n_plot, fill = sexo)) +
  geom_col() +
  coord_flip() +
  scale_y_continuous(labels = abs) +
  facet_wrap(ano ~ subgrp, scales = "free_x") +
  scale_fill_manual(values = c("masculino" = "#0072B2", "feminino" = "#D55E00")) +
  labs(title = "Pirâmide Etária por Categoria e Ano",
       x = "Idade", y = "População", fill = "Sexo") +
  theme_minimal()
toc()

tic()
message("pirâmides etárias comparativas usando facet_grid...")
censo_mortalidade |>
  mutate(n_plot = ifelse(sexo == "feminino", -n, n)) |>
  ggplot(aes(x = idade, y = n_plot, fill = sexo)) +
  geom_col(width = 1) + 
  coord_flip() +
  scale_y_continuous(labels = abs) +
  facet_grid(ano ~ subgrp, scales = "free_x") +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Evolução da Estrutura Etária por Grupo",
       x = "Idade", y = "População", fill = "Sexo") +
  theme_light() +
  theme(legend.position = "bottom")
toc()




library(ggplot2)
library(dplyr)

# 1. Preparação dos dados para o efeito espelho
plot_data <- libras %>%
  mutate(
    # Converte o peso de importância em valor numérico para o gráfico
    valor = as.numeric(case_weights),
    # Homens para a esquerda (negativo), Mulheres para a direita (positivo)
    n_plot = ifelse(sexo == "masculino", -valor, valor)
  )

# 2. Construção da Pirâmide
ggplot(plot_data, aes(x = idade, y = n_plot, fill = sexo)) +
  geom_col(width = 1, alpha = 0.8) +
  coord_flip() +
  # O label abs() garante que o eixo X (população) não mostre números negativos
  scale_y_continuous(labels = abs) +
  # Diferenciando por instrução e uso de Libras
  facet_grid(instrucao ~ libras, scales = "free_x") +
  scale_fill_manual(values = c("masculino" = "#2c7bb6", "feminino" = "#d7191c")) +
  labs(
    title = "Pirâmide Etária: Distribuição de Pesos do Modelo",
    subtitle = "Segmentado por Instrução e Uso de Libras",
    x = "Idade",
    y = "Peso de Importância (Frequência Relativa)",
    fill = "Sexo"
  ) +
  theme_minimal() +
  theme(legend.position = "bottom")
