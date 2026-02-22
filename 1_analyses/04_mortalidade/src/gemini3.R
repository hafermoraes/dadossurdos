library(DemoTools)
library(dplyr)

library(DemoTools)

# 1. Seus dados brutos
lt_data <-
  censo_mortalidade |>
  filter(subgrp == "deficiente_auditivo")


# 1. Dados
idades <- c(0, 5, 10, 15, 20, 25, 30, 35, 40, 45, 50, 55, 60, 65, 70, 75, 80, 85, 90, 95)
f_2000 <- c(6917.69, 16410.01, 21841.67, 18747.82, 18643.09, 18230.79, 17898.70, 16900.83, 20926.02, 22679.63, 25833.80, 27394.82, 32485.54, 35167.73, 42923.87, 44850.10, 44380.72, 36904.01, 18329.77, 9503.91)
f_2010 <- c(11350.03, 21153.02, 30343.63, 31178.07, 36998.42, 39812.27, 43423.84, 44874.92, 50547.70, 54703.90, 62691.64, 66104.72, 68660.10, 70141.44, 80391.03, 87364.42, 91276.92, 70076.74, 40832.72, 22553.25)

# 2. Cálculo da Taxa de Mortalidade Intercensitária (nMx)
# n=10 (anos entre censos). m_x = [ln(P1/P2) / n]
# Aqui calculamos a taxa de decréscimo da coorte para estimar mortalidade
n <- 10
mx_estimado <- rep(0, length(f_2000))

for(i in 1:(length(f_2000)-1)){
  # Razão de sobrevivência de coorte (aproximação m_x)
  # Nota: Em dados reais de subgrupos, isso pode dar negativo se houver migração/melhora de diagnóstico
  mx_estimado[i] <- -log(f_2010[i+1] / f_2000[i]) / n
}
# Ajuste para a última idade (95+)
mx_estimado[length(mx_estimado)] <- mx_estimado[length(mx_estimado)-1] 
mx_estimado[mx_estimado < 0] <- 0.001 # Correção para ganho populacional no subgrupo

# 3. Gerar Tábua de Vida no DemoTools
tabua_feminina <- lt_abridged(
  nMx = mx_estimado, 
  Age = idades, 
  Sex = "f", 
  axmethod = "pas"
)

# Visualizar resultado
print(tabua_feminina[,c("Age", "nMx", "n_qx", "lx", "ex")])
