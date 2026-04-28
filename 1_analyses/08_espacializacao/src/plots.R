
ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_surdo), color = NA) + # 'color = NA' remove as bordas das cidades para não poluir
  scale_fill_viridis_c(
    option = "magma", 
    name = "População Surda",
    direction = -1,
    labels = scales::label_number(big.mark = ".", decimal.mark= ',')
  ) +
  labs(
    title = "Distribuição da População Surda por Município",
    subtitle = "Brasil",
    caption = "Fonte: Dados espaciais consolidados"
  ) +
  theme_minimal() +
  theme(
    panel.grid = element_blank(),
    axis.text = element_blank(),
    axis.ticks = element_blank()
  )


ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_surdo), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Criamos um degradê que vai do branco para o rosa vibrante até um roxo bem escuro (Magma style)
    # Sem passar pelo amarelo.
    colors = c("white", "#f768a1", "#ae017e", "#49006a"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = ".", decimal.mark=','),
    # Ajusta para que o branco não "pule" direto para a cor forte
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw() 




ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o azul celeste, azul real e azul meia-noite
    colors = c("white", "#9ecae1", "#2171b5", "#08306b"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Garante que o branco predomine nos valores muito baixos
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()



ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o coral, vermelho vivo e bordô (vinho escuro)
    colors = c("white", "#fb9a99", "#e31a1c", "#67000d"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Mantém a transição suave para o branco no início
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()



ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o verde menta, verde grama e verde floresta fechada
    colors = c("white", "#a1d99b", "#238b45", "#00441b"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Transição suave para destacar o branco nos valores próximos de zero
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()



ggplot(data = spatial_muni) +
  geom_sf(aes(fill = N_incapaz), color = NA) +
  geom_sf(data = UF_geom, fill = NA, color = "black", size = 0.1) +
  scale_fill_gradientn(
    # Do branco para o cinza claro, cinza grafite e preto/chumbo
    colors = c("white", "#bdbdbd", "#636363", "#252525"), 
    name = "População Surda",
    labels = scales::label_number(big.mark = "."),
    # Ajuste fino para o branco cobrir o zero e o preto os picos
    values = c(0, 0.05, 0.4, 1) 
  ) +
  theme_bw()





