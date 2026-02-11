
FILE <- "censo2010_family_arrangements"

tic()
message("preparando ", FILE, " no duckdb...")
censo2010_family_arrangements <-
  subset_censo2010 |>
  # joins com dicionário de variáveis
  # v0502: relação de convivência existente com a pessoa responsável pelo domicílio
  left_join(
    dvar_censo2010 |>
      filter(base == 'pess', q_code=='v0502') |>
      transmute(v0502 = a_code, relacao_resp_domicilio = a_desc) |>
      distinct(v0502, .keep_all=TRUE),
    keep=FALSE
  ) |> 
  # finalização da tabela de análises
  transmute(
    row_id,
    # ......... Variáveis referentes ao Arranjo Domiciliar .........
    id_relacao_resp_domicilio = v0502,
    relacao_resp_domicilio,
    nr_ordem_pessoa = v0504,
    id_domicilio = v0300
  )
toc()

tic()
message("exportando ", FILE, " em disco...")
censo2010_family_arrangements |>
  collect() |>
  write_csv(
    file = paste0(data_dir, "censo2010_family_arrangements.csv"),
    na = ""
  )
toc()

gc()

