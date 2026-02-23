# 1. Define Standard (logit of l_x standard)
# Assume age groups 0, 1, 5, 10... up to 85+
# This is a dummy example; replace with actual l_x^s
ages <- seq(0, 85, by = 5)
standard_lx <- c(1.0, 0.9, 0.85, 0.84, 0.83, 0.80, 0.75, 0.70, 0.60, 0.50, 0.40, 0.30, 0.20, 0.10, 0.05, 0.02, 0.01, 0)
# Logit function: 0.5 * ln((1-lx)/lx)
logit <- function(p) {
  p <- pmax(0.001, pmin(0.999, p)) # Handle edge cases
  0.5 * log((1 - p) / p)
}
logit_std <- logit(standard_lx)

# 2. Create Grid of Alpha and Beta
alpha_range <- seq(-1, 1, length.out = 50)
beta_range <- seq(0.5, 1.5, length.out = 50)
grid <- expand.grid(alpha = alpha_range, beta = beta_range)

# 3. Calculate Target Variable (e.g., Logit of Survival at Age 30)
# Here, we look at the 7th age group (30-34)
age_index <- 7
logit_target <- grid$alpha + grid$beta * logit_std[age_index]
z_matrix <- matrix(logit_target, nrow = length(alpha_range), ncol = length(beta_range))


filled.contour(x = alpha_range, y = beta_range, z = z_matrix,
               color.palette = terrain.colors,
               xlab = "Alpha (Level)",
               ylab = "Beta (Pattern)",
               main = "Brass Logit Model: Logit(l_30)")


library(ggplot2)

# Convert matrix to data frame
plot_data <- expand.grid(alpha = alpha_range, beta = beta_range)
plot_data$z <- as.vector(z_matrix)

ggplot(plot_data, aes(x = alpha, y = beta, z = z)) +
  geom_contour_filled() +
  geom_contour(color = "white", alpha = 0.5) +
  labs(title = "Brass Model Surface",
       x = "Alpha (Mortality Level)",                
       y = "Beta (Age Pattern)",
       fill = "Logit(l_30)") +
  theme_minimal()



# 00000000000000000000000000

# 1. Funções Logit de Brass
logit <- function(p) 0.5 * log((1 - p) / p)
inv_logit <- function(y) 1 / (1 + exp(2 * y))

# 2. Definir uma tábua de vida padrão (Exemplo: Tábua de Coale-Demeny ou UN)
# Aqui usamos uma curva de sobrevivência hipotética (lx_std)
age <- 0:100
lx_std <- exp(-0.02 * age) # Modelo de decaimento simples para ilustração
logit_std <- logit(lx_std)

# 3. Função para calcular e0 com base em Alpha e Beta
calc_e0 <- function(a, b, logit_std) {
  # Gera novos lx baseados no modelo de Brass
  lx_new <- inv_logit(a + b * logit_std)
  # Trata lx=1 na idade 0 e garante que lx não seja NA
  lx_new[1] <- 1
  lx_new[is.na(lx_new)] <- 0
  
  # Calcula a expectativa de vida (área sob a curva lx)
  # Aproximação simples: média de lx_i e lx_{i+1}
  e0 <- sum((lx_new[1:(length(lx_new)-1)] + lx_new[2:length(lx_new)]) / 2)
  return(e0)
}

# 4. Configurar o grid de parâmetros
alpha_seq <- seq(-0.8, 0.8, length.out = 50)
beta_seq <- seq(0.6, 1.4, length.out = 50)

# 5. Calcular a matriz de e0
z_e0 <- outer(alpha_seq, beta_seq, Vectorize(function(a, b) calc_e0(a, b, logit_std)))

# 6. Gerar o Gráfico de Contorno
filled.contour(x = alpha_seq, y = beta_seq, z = z_e0,
               xlab = "Alpha (Nível de Mortalidade)",
               ylab = "Beta (Relação Infância vs Adulto)",
               main = "Expectativa de Vida ao Nascer (e0)",
               color.palette = terrain.colors,
               key.title = title(main = "Anos"))


library(ggplot2)
library(dplyr)
library(tidyr)

# 1. Preparar os dados (expandir o grid)
plot_data <- expand.grid(alpha = alpha_seq, beta = beta_seq) %>%
  mutate(e0 = mapply(calc_e0, alpha, beta, MoreArgs = list(logit_std = logit_std)))

# 2. Criar o gráfico com ggplot2
ggplot(plot_data, aes(x = alpha, y = beta, z = e0)) +
  # Preenchimento colorido por faixas de e0
  geom_contour_filled() +
  # Linhas de contorno pretas sutis
  geom_contour(color = "white", alpha = 0.3) +
  # Etiquetas e estilo
  labs(
    title = "Expectativa de Vida ao Nascer (e0)",
    subtitle = "Modelo Relacional de Brass",
    x = expression(alpha ~ "(Nível de Mortalidade)"),
    y = expression(beta ~ "(Padrão Etário)"),
    fill = "e0 (Anos)"
  ) +
  theme_minimal() +
  scale_fill_viridis_d(option = "viridis") # Escala de cor mais legível


# 8888888888888888888888888888888888

library(ggplot2)
library(viridis)

# 1. Funções Logit
logit <- function(p) 0.5 * log((1 - p) / p)
inv_logit <- function(y) 1 / (1 + exp(2 * y))

# 2. Definir Grid: Idade (x) vs Nível de Mortalidade (alpha)
idades <- 0:80
alphas <- seq(-1, 1, length.out = 100)
beta_fixo <- 1.0  # Mantendo o padrão etário constante

# Tábua padrão simplificada
lx_std <- exp(-0.015 * idades)
logit_std <- logit(lx_std)

# 3. Criar os dados da Superfície
lexis_data <- expand.grid(Idade = idades, Alpha = alphas) %>%
  mutate(
    # Aplicar o modelo de Brass para cada combinação
    lx = inv_logit(Alpha + beta_fixo * logit_std[Idade + 1])
  )

# 4. Plotar a Superfície de Lexis (Heatmap/Contour)
ggplot(lexis_data, aes(x = Idade, y = Alpha, fill = lx)) +
  geom_raster(interpolate = TRUE) +
  geom_contour(aes(z = lx), color = "white", alpha = 0.2, breaks = seq(0, 1, 0.1)) +
  scale_fill_viridis(option = "magma", name = "Sobrevivência (lx)") +
  labs(
    title = "Superfície de Lexis: Modelo de Brass",
    subtitle = expression(paste("Impacto de ", alpha, " na curva de sobrevivência (", beta, " = 1.0)")),
    x = "Idade (x)",
    y = expression(alpha ~ "(Parâmetro de Nível)")
  ) +
  theme_minimal()
