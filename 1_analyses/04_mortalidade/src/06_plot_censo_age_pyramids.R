
SUBGRPs <- c('total','ouvinte','surdo','deficiente_auditivo','surdocego')


tic()
agepyramid_1y_unsmoothed <-
  piramides_mortalidade |> 
  select(-n_sprague) |> 
  rename(n=n_original)

for(SUBGRP in SUBGRPs){
  message("pirâmides etárias comparativas com n_original e idades simples para ", SUBGRP,"...")
  export_plot_age_pyramid_comparison(
    arg_input_df = agepyramid_1y_unsmoothed,
    arg_subgrp = SUBGRP,
    plot_width = 12,
    plot_height = 5,
    output_file = paste0(
      results_dir,
      "agepyramid_1y_unsmoothed_",
      SUBGRP,
      ".pdf"
    )
  )
}
toc()


tic()
agepyramid_1y_smoothed <-
  piramides_mortalidade |> 
  select(-n_original) |> 
  rename(n=n_sprague)

for(SUBGRP in SUBGRPs){
  message("pirâmides etárias comparativas com n_sprague e idades simples para ", SUBGRP,"...")
  export_plot_age_pyramid_comparison(
    arg_input_df = agepyramid_1y_smoothed,
    arg_subgrp = SUBGRP,
    plot_width = 12,
    plot_height = 5,
    output_file = paste0(
      results_dir,
      "agepyramid_1y_smoothed_",
      SUBGRP,
      ".pdf"
    )
  )
}
toc()





tic()
agepyramid_5y_unsmoothed <-
  piramides_mortalidade |> 
  select(-n_sprague) |> 
  rename(n=n_original) |>
  mutate(
    fx_idade = cut(
      idade, 
      breaks = lt_spec$breaks, 
      labels = lt_spec$labels, 
      right = FALSE, 
      ordered_result = TRUE
    )
  ) |> 
  select(-idade) |>
  rename(idade = fx_idade) |>
  group_by(subgrp,ano,sexo,idade) |>
  summarise(n=sum(n, na.rm=TRUE), .groups = 'drop')

for(SUBGRP in SUBGRPs){
  message("pirâmides etárias comparativas com n_original e idades quinquenais para ", SUBGRP,"...")
  export_plot_age_pyramid_comparison(
    arg_input_df = agepyramid_5y_unsmoothed,
    arg_subgrp = SUBGRP,
    plot_width = 12,
    plot_height = 5,
    output_file = paste0(
      results_dir,
      "agepyramid_5y_unsmoothed_",
      SUBGRP,
      ".pdf"
    )
  )
}
toc()





tic()
agepyramid_5y_smoothed <-
  piramides_mortalidade |> 
  select(-n_original) |> 
  rename(n=n_sprague) |>
  mutate(
    fx_idade = cut(
      idade, 
      breaks = lt_spec$breaks, 
      labels = lt_spec$labels, 
      right = FALSE, 
      ordered_result = TRUE
    )
  ) |> 
  select(-idade) |>
  rename(idade = fx_idade) |>
  group_by(subgrp,ano,sexo,idade) |>
  summarise(n=sum(n, na.rm=TRUE), .groups = 'drop')

for(SUBGRP in SUBGRPs){
  message("pirâmides etárias comparativas com n_sprague e idades quinquenais para ", SUBGRP,"...")
  export_plot_age_pyramid_comparison(
    arg_input_df = agepyramid_5y_smoothed,
    arg_subgrp = SUBGRP,
    plot_width = 12,
    plot_height = 5,
    output_file = paste0(
      results_dir,
      "agepyramid_5y_smoothed_",
      SUBGRP,
      ".pdf"
    )
  )
}
toc()







