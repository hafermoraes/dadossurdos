
message("importando dicionário de variáveis ...")
dvar_censo2010 <-
  read_delim(
    '/tmp/etl/br_ibge_censo_2010/variables_dictionary.txt',
    delim = '|'
  ) |>
  filter(
    base=='pess'
  ) |>
  mutate(
    a_desc = str_trim(a_desc),
    a_desc = str_to_title(a_desc, locale = 'pt-br')
  ) |>
  to_duckdb()

tic()
message("harmonizando as variáveis do censo2010 ...")
subset_censo2010 <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2010/parquet/pess"
  ) |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  select(
    # expansão da amostra probabilística
    v0011, # area_ponderacao (área de ponderação)
    v0010,  # peso_amostral (peso amostral)
    
    # variáveis comuns às análises demográficas e ao preditivo libras
    v0001, # uf_residencia (uf de residência)
    v0601, # sexo
    v6036, # idade
    v0606, # cor_raca (cor ou raça)
    v0627, # alfabetizado (sabe ler e escrever)
    v0640, # estado civil
    v0633, # instrucao (curso mais elevado que frequentou)
    v0614, # dif_enxergar (capacidade de enxergar)
    v0615, # dif_ouvir (capacidade de ouvir)
    v0616, # dif_locomover (capacidade de caminhar/subir escadas)

    # TODO
    # variáveis de arranjos domiciliares
    v0402, # relacao_resp_domicilio
    v0400, # nr_ordem_pessoa
    v0300, # id_domicilio

    # TODO
    # variáveis de fecundidade
    v4620, # filhos_nascidos_vivos
    v0463, # filhos_nascidos_vivos_vivos
    v4670, # filhos_nascidos_mortos
    v4690, # filhos_nascidos
    
    # variáveis de migração
    v6252, # OK uf de residência anterior
    v6262, # OK uf de residência data fixa
    v0623, # OK uf_residencia_tempo_anos
    v6222, # OK uf de nascimento
    v0619, # OK uf_naturalidade
    
    v0002, # OK município de residência
    v6254, # OK município de residência anterior
    v6264, # OK município de residência data fixa
    v0624, # OK municipio_residencia_tempo_anos
    v0618, # OK municipio_sempre_morou (mora neste município desde que nasceu?)
    #         e municipio_naturalidade (nasceu neste município?)
    
    v6256, # OK país de residência anterior
    v6266, # OK país de residência data fixa
    v6224, # OK país de nascimento
    v0620, # OK nacionalidade (qual é a sua nacionalidade?)
    v0621  # OK ano_fixou_residencia_brasil (em que ano fixou residência no brasil?)

  ) |>
  mutate(
    across(everything(), ~ str_trim(.)),
    v0010 = as.numeric(v0010),
    v0002 = paste0(v0001,v0002),
    v6222 = str_sub(v6222, start=1, end=2),
    v6252 = str_sub(v6252, start=1, end=2),
    v6262 = str_sub(v6262, start=1, end=2)
  ) |>
  to_duckdb() |>
  mutate(
    row_id = row_number()
  )
toc()






