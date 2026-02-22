
library(DDM)

# Organizando seus dados femininos para o DDM
df_ddm <- data.frame(
  cod = "Brasil",
  sex = "f",
  year1 = 2000,
  year2 = 2010,
  age = seq(0, 95, by = 5),
  pop1 = c(6917.694, 16410.013, 21841.678, 18747.821, 18643.093, 18230.799, 
           17898.708, 16900.833, 20926.025, 22679.636, 25833.804, 27394.82, 
           32485.543, 35167.735, 42923.876, 44850.1, 44380.724, 36904.019, 
           18329.773, 9503.914),
  pop2 = c(11350.035, 21153.029, 30343.635, 31178.076, 36998.42, 39812.274, 
           43423.842, 44874.922, 50547.705, 54703.903, 62691.643, 66104.721, 
           68660.102, 70141.448, 80391.037, 87364.42, 91276.924, 70076.748, 
           40832.726, 22553.258),
  deaths = 1
)

# O DDM estima a cobertura (completeness). 
# Com deaths=1, ele dirá que a cobertura é quase zero, mas você pode extrair
# os parâmetros de crescimento (r) e a mortalidade implícita.
resultado_ddm <- ddm(df_ddm)
