# 1. Seus dados brutos
lf_data <-
  censo_mortalidade |>
  filter(subgrp == "deficiente_auditivo")

# 2. Padronização e Sobrevivência
# Calculamos quanto cada grupo representa do total do ano
total_00 <- sum(lf_data$feminino_2000)
total_10 <- sum(lf_data$feminino_2010)

lt_fem <- lf_data %>%
  select(fx_idade, pop00 = feminino_2000, pop10 = feminino_2010) %>%
  mutate(
    p00 = pop00 / total_00,
    p10 = pop10 / total_10,
    # Razão de Sobrevivência (10 anos): Coorte x em 2000 -> x+10 em 2010
    # Pulamos 2 linhas pois cada linha = 5 anos
    S_x = lead(p10, 2) / p00,
    # Ajuste: se Sx > 1, mortalidade = 0 (usamos 0.999)
    S_x = pmin(S_x, 0.999)
  )

# 3. Funções da Tábua de Vida (n=5, intervalo de 10 anos para Sx)
# nmx = -log(nSx) / t (t=10 anos)
lt_fem <- lt_fem %>%
  filter(!is.na(S_x)) %>%
  mutate(
    nmx = -log(S_x) / 10,
    nqx = 1 - exp(-5 * nmx) # Probabilidade de morte em 5 anos
  )

# 4. Iteração para lx (Sobreviventes) e dx (Óbitos)
radix <- 100000
lt_fem$lx <- 0
lt_fem$dx <- 0
lt_fem$lx[1] <- radix

for(i in 1:(nrow(lt_fem)-1)) {
  lt_fem$dx[i] <- lt_fem$lx[i] * lt_fem$nqx[i]
  lt_fem$lx[i+1] <- lt_fem$lx[i] - lt_fem$dx[i]
}

# 5. Esperança de Vida (ex)
lt_fem <- lt_fem %>%
  mutate(
    nLx = (lx + lead(lx, default = 0)) / 2 * 5,
    Tx = rev(cumsum(rev(nLx))),
    ex = Tx / lx
  )

# Resultado Final
lt_fem %>% select(fx_idade, S_x, nqx, lx, ex) %>% View()

