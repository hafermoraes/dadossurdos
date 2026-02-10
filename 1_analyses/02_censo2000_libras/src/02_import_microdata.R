
# dicionário de variáveis
dvar_censo2000 <-
  read_delim(
    '/tmp/etl/br_ibge_censo_2000/variables_dictionary.txt',
    delim = '|'
  ) |>
  filter(
    base=='pes'
  ) |>
  mutate(
    a_desc = str_trim(a_desc),
    a_desc = str_to_title(a_desc, locale = 'pt-br')
  ) |>
  to_duckdb()

# harmonização das variáveis do censo2000
subset_censo2000 <-
  open_dataset(
    "/tmp/etl/br_ibge_censo_2000/parquet/pes"
  ) |>
  rename_with(tolower) |>  # converte nomes de colunas para minúsculas
  select(
    # expansão da amostra probabilística
    areap, # area_ponderacao (área de ponderação)
    p001,  # peso_amostral (peso amostral)
    
    # variáveis comuns às análises demográficas e ao preditivo libras
    v0102, # uf_residencia (uf de residência)
    v0401, # sexo
    v4572, # idade
    v0408, # cor_raca (cor ou raça)
    v0428, # alfabetizado (sabe ler e escrever)
    v0438, # estado civil
    v0432, # instrucao (curso mais elevado que frequentou)
    v0411, # dif_enxergar (capacidade de enxergar)
    v0412, # dif_ouvir (capacidade de ouvir)
    v0413, # dif_locomover (capacidade de caminhar/subir escadas)

    # variáveis de arranjos domiciliares
    v0402, # relacao_resp_domicilio
    v0400, # nr_ordem_pessoa
    v0300, # id_domicilio

    # variáveis de fecundidade
    v4620, # filhos_nascidos_vivos
    v0463, # filhos_nascidos_vivos_vivos
    v4670, # filhos_nascidos_mortos
    v4690, # filhos_nascidos
    
    # variáveis de migração
    v4230, # uf-país de residência anterior (qual é a unidade da federação ou país estrangeiro de residência anterior?)
    v4260, # uf-país de residência data fixa
    v0422, # uf_residencia_tempo_anos (há quanto tempo mora sem interrupção nesta unidade da federação?)
    v4210, # uf-país de nascimento (qual é a unidade da federação ou país estrangeiro de nascimento?)
    v0418, # uf_naturalidade (nasceu nesta unidade da federação?)

    v1103, # município de residência
    v4250, # município de residência data fixa
    v0416, # municipio_residencia_tempo_anos (há quanto tempo mora sem interrupção neste município?)
    v0417, # municipio_naturalidade (nasceu neste município?)    
    v0415, # municipio_sempre_morou (mora neste município desde que nasceu?)
    
    v0419, # nacionalidde (qual é a sua nacionalidade?)
    v0420  # ano_fixou_residencia_brasil (em que ano fixou residência no brasil?)
  ) |>
  mutate(
    across(everything(), ~ str_trim(.))
  ) |>
  to_duckdb() |>
  mutate(
    row_id = row_number()
  )
  






