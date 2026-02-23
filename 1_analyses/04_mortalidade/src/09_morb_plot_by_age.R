library(stringr)

morb_prevalencias_fx_idade |> 
  filter(subgrp != "categ_total") |> 
  ggplot(aes(x = fx_idade, y = p, color = subgrp, group = subgrp)) +
  geom_point(position = position_dodge(width = 0.5), size = 2) +
  geom_errorbar(
    aes(ymin = p_low, ymax = p_upp), 
    position = position_dodge(width = 0.5), 
    width = 0.3
  ) +
  facet_wrap(~var, scales = "free", labeller = as_labeller(function(x) {
    x |> str_remove("mort_diagnostico_") |> str_replace_all("_", " ") |> str_to_sentence()
  })) +
  scale_y_continuous(labels = scales::percent) +
  coord_flip() +
  scale_color_viridis_d(option = "plasma", end = 0.7) +
  #scale_color_brewer(palette = "Dark2")+
  #theme_minimal() +
  theme(legend.position = "bottom") +
  labs(
    x = "Faixa Etária",
    y = "Prevalência (%)",
    color = "Subgrupo"
  )
