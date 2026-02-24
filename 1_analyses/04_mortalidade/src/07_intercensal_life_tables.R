


tic()
message("tábuas de vida intercensitárias...")
toc()

for(arg_subgrp in c('total','ouvinte','deficiente_auditivo','surdo','surdocego')){
  
  export_mort_razao_sobrevivencia(
    categ = arg_subgrp, 
    output_file = paste0(
      results_dir,
      "mort_rs_2000_2010_",
      arg_subgrp,
      ".tex"
    )
  )
  
}

  