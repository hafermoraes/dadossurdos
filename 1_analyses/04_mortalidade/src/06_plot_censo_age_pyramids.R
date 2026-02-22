

tic()
SUBGRPs <- c('total','ouvinte','surdo','deficiente_auditivo','surdocego')
for(SUBGRP in SUBGRPs){
  message("pirâmides etárias comparativas usando facet_wrap para ", SUBGRP,"...")
  export_plot_age_pyramid_comparison(
    arg_subgrp = SUBGRP,
    plot_width = 8,
    plot_height = 5,
    output_file = paste0(
      results_dir,
      "agepyramid_",
      SUBGRP,
      ".pdf"
    )
  )
}
toc()









