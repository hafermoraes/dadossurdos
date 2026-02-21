

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


tic()
message("pirâmides etárias comparativas (faixas de 5 anos) usando facet_grid...")

censo_mortalidade |>
  # Cria faixas de 5 anos (0-4, 5-9, etc.)
  mutate(faixa_etaria = cut(idade, 
                            breaks = seq(0, 105, by = 5), 
                            right = FALSE, 
                            labels = paste(seq(0, 100, by = 5), seq(4, 104, by = 5), sep = "-"))) |>
  # Agrupa para somar a população em cada nova faixa
  group_by(ano, subgrp, faixa_etaria, sexo) |>
  summarise(n = sum(n, na.rm = TRUE), .groups = "drop") |>
  # Prepara o valor negativo para o lado masculino ou feminino
  mutate(n_plot = ifelse(sexo == "feminino", -n, n)) |>
  ggplot(aes(x = faixa_etaria, y = n_plot, fill = sexo)) +
  geom_col(width = 0.8) + 
  coord_flip() +
  scale_y_continuous(labels = abs) +
  facet_grid(ano ~ subgrp, scales = "free_x") +
  scale_fill_brewer(palette = "Set1") +
  labs(title = "Evolução da Estrutura Etária (Faixas de 5 Anos)",
       x = "Faixa Etária", y = "População", fill = "Sexo") +
  theme_light() +
  theme(legend.position = "bottom")
toc()





tic()
message("Pirâmide de linhas por subgrupo e ano...")

censo_mortalidade |>
  filter(subgrp %in% c('surdo')) |>
  # 1. Criar faixas de 5 anos
  mutate(faixa_etaria_num = (idade %/% 5) * 5) |>
  # 2. Agrupar e somar
  group_by(ano, subgrp, sexo, faixa_etaria_num) |>
  summarise(n = sum(n, na.rm = TRUE), .groups = "drop") |>
  # 3. Inverter sinal para o formato de pirâmide
  mutate(n_plot = ifelse(sexo == "feminino", -n, n)) |>
  # 4. Plotar
  ggplot(aes(x = faixa_etaria_num, y = n_plot, color = subgrp, group = interaction(subgrp, sexo))) +
  geom_path(size = 1) + 
  coord_flip() +
  scale_y_continuous(labels = abs) +
  facet_wrap(~ ano) +
  scale_color_brewer(palette = "Dark2") +
  labs(title = "Pirâmide Etária: Comparação de Subgrupos",
       subtitle = "Linhas por subgrupo (agrupado em 5 anos)",
       x = "Idade", y = "População (Esq: Feminino | Dir: Masculino)", 
       color = "Subgrupo") +
  theme_light() +
  theme(legend.position = "bottom")
toc()





