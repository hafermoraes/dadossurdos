
censo2000_family_arrangements <-
  subset_censo2000 |>
  transmute(
    row_id,
    # ......... Variáveis referentes ao Arranjo Domiciliar .........
    relacao_resp_domicilio = v0402,
    nr_ordem_pessoa = v0400,
    id_domicilio = v0300
  )
