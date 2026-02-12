
tic()
message("importando microdados da PNS2019...")
microdados_dt <- open_dataset(
  "/tmp/etl/br_ibge_pns_2019/parquet"
) |>
  rename_with(tolower) |>
  filter(v0015 == '01', !is.na(v0015), m001 == '1', !is.na(m001)) |>
  select(
    v0024,v0029,upa_pns,v00292,v00293, # expansão da amostra probabilística
    v0001,  # uf de residência
    c006,   # sexo
    c008,   # idade
    c009,   # cor ou raça
    d001,   # alfabetizado
    c011,   # estado civil
    d00901, # instrução
    g046,   # dificuldade de enxergar
    g047,   # dificuldade de enxergar
    g057,   # dificuldade de ouvir
    g058,   # dificuldade de ouvir
    g070,   # dificuldade de locomover
    g071,   # dificuldade de locomover
    g05801  # sabe libras
  ) |>
  mutate(
    across(
      c(v0024,v0029,upa_pns,v00292,v00293), 
      as.numeric
    )
  ) |>
  collect() |>
  as.data.table()
toc()



tic()
message("configurando o delineamento amostral nos microdados...")
popc.types <- microdados_dt[, .(Freq = unique(v00292)), by = v00293]
sum_weights <- microdados_dt[, .(sumw = sum(v0029)), by = v00293]
strata_weights <- merge(popc.types, sum_weights, by = "v00293")
strata_weights[, scale := as.numeric(Freq) / as.numeric(sumw)]
microdados_dt <- merge(microdados_dt, strata_weights[, .(v00293, scale)], by = "v00293", all.x = TRUE)
microdados_dt[, weight := v0029 * scale]
toc()


tic()
message("importando dicionário de variáveis da PNS2019...")
# importação das unidades da federação
uf <-
  read_delim(
    '/tmp/etl/br_ibge_pns_2019/variables_dictionary.txt',
    delim='|',
    show_col_types = FALSE
  ) |>
  filter( q_code == 'v0001') |>
  transmute( cod_uf = a_code, uf = a_desc)
toc()



tic()
message("renomeando as variáveis e tratando seus dados...")
microdados_dt <-
  microdados_dt |>
  transmute(
    v0024,v0029,upa_pns,v00292,v00293, # expansão da amostra probabilística
    # unidade da federação
    cod_uf = v0001,
    # idade calculada em anos completos - a partir de 1 ano
    idade = as.numeric(c008),
    # sexo
    sexo = case_when(
      c006 == '1' ~ 'masculino',
      c006 == '2' ~ 'feminino',
      TRUE ~ NA
    ),
    # Sabe ler e escrever
    alfabetizado = case_when(
      d001 == '1' ~ 'sim',
      d001 == '2' ~ 'nao',
      TRUE ~ NA
    ),
    # Qual é o estado civil de ___?
    estado_civil = case_when(
      c011 == '1' ~ 'casado',    # Casado(a)
      c011 == '2' ~ 'separado',  # Divorciado(a) ou desquitado(a) ou separado(a) judicialmente
      c011 == '3' ~ 'viuvo',     # Viúvo(a)
      c011 == '4' ~ 'solteiro',  # Solteiro(a)
      TRUE ~ NA
    ),
    # Qual foi o curso mais elevado que ___frequentou
    instrucao = case_when(
      d00901 == '01' ~ 'outros',      # Creche
      d00901 == '02' ~ 'outros',      # Pré-escola
      d00901 == '03' ~ 'fundamental', # Classe de alfabetização – CA
      d00901 == '04' ~ 'fundamental', # Alfabetização de jovens e adultos
      d00901 == '05' ~ 'fundamental', # Antigo primário (elementar)
      d00901 == '06' ~ 'fundamental', # Antigo ginasial (médio 1º ciclo)
      d00901 == '07' ~ 'fundamental', # Regular do ensino fundamental ou do 1º grau
      d00901 == '08' ~ 'fundamental', # Educação de jovens e adultos (EJA) ou supletivo do ensino fundamental
      d00901 == '09' ~ 'medio',       # Antigo científico, clássico etc. (médio 2º ciclo)
      d00901 == '10' ~ 'medio',      # Regular do ensino médio ou do 2º grau
      d00901 == '11' ~ 'medio',      # Educação de jovens e adultos (EJA) ou supletivo do ensino médio
      d00901 == '12' ~ 'superior',   # Superior – graduação
      d00901 == '13' ~ 'superior',   # Especialização de nível superior (duração mínima de 360 horas)
      d00901 == '14' ~ 'superior',   # Mestrado
      d00901 == '15' ~ 'superior',   # Doutorado
      TRUE ~ NA
    ),
    # cor ou raça
    cor_raca = case_when(
      c009 == '1' ~ 'branca',
      c009 == '2' ~ 'preta',
      c009 == '3' ~ 'amarela',
      c009 == '4' ~ 'parda',
      c009 == '5' ~ 'indigena',
      c009 == '9' ~ 'outros',
      TRUE ~ NA
    ),
    # . ___ tem dificuldade permanente de enxergar mesmo usando óculos, lentes de contato ou lupas?
    dif_enxergar = case_when(
      g047 == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      g047 == '3' ~ 'grande',    # Sim, muita dificuldade
      g047 == '2' ~ 'alguma',    # Sim, alguma dificuldade
      g047 == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      g047 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # ___ tem dificuldade permanente de ouvir mesmo usando aparelhos auditivos? (Para moradores com 5 anos ou mais de idade.) OU ___ tem dificuldade permanente para ouvir sons como vozes ou música, mesmo usando aparelhos auditivos? (Para moradores com 2 a 4 anos de idade.)
    dif_ouvir = case_when(
      g058 == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      g058 == '3' ~ 'grande',    # Sim, muita dificuldade
      g058 == '2' ~ 'alguma',    # Sim, alguma dificuldade
      g058 == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      g058 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # ___ tem dificuldade permanente de caminhar ou subir degraus, mesmo usando prótese, bengala ou outro aparelho de auxílio? (Para moradores com 5 anos ou mais de idade.)OUComparado com crianças da mesma idade, ___ tem dificuldade permanente para caminhar, mesmo usando prótese, bengala ou aparelho de auxílio? (Para moradores com 2 a 4 anos de idade.)
    dif_locomover = case_when(
      g071 == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      g071 == '3' ~ 'grande',    # Sim, muita dificuldade
      g071 == '2' ~ 'alguma',    # Sim, alguma dificuldade
      g071 == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      g071 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # Sabe usar a Língua Brasileira de Sinais – Libras? (Para moradores com 5 anos ou mais de idade.)
    libras = case_when(
      g05801 == 1 ~ 'sim',
      g05801 == 2 ~ 'nao',
      TRUE ~ NA
    ),
    case_weights = weight
  ) |>
  left_join(uf, by=c('cod_uf'), keep = FALSE) |>
  select(-cod_uf) |>
  mutate(
    instrucao = case_when(
      is.na(instrucao) ~ 'outros',
      TRUE ~ as.character(instrucao)
    ),
    dif_ouvir = case_when(
      is.na(dif_ouvir) ~ 'nenhuma',
      TRUE ~ as.character(dif_ouvir)
    ),    
    dif_enxergar = case_when(
      is.na(dif_enxergar) ~ 'nenhuma',
      TRUE ~ as.character(dif_enxergar)
    ),    
    dif_locomover = case_when(
      is.na(dif_locomover) ~ 'nenhuma',
      TRUE ~ as.character(dif_locomover)
    )
  )
toc()



tic()
message("exportando microdados tratados em disco...")
rawdata <- microdados_dt[
  , 
  .(n = sum(case_weights)), 
  by = c(
    "uf",            # uf <<< cod_uf <<< v0001 
    "sexo",          # c006
    "idade",         # c008 
    "cor_raca",      # c009
    "alfabetizado",  # d001 
    "estado_civil",  # c011
    "instrucao",     # d00901 
    "dif_enxergar",  # g047
    "dif_ouvir",     # g071
    "dif_locomover", # g058
    "libras"         # g05801
  )
][n > 0][order(-n)]

rawdata |>
  write_csv(
    paste0(
      data_dir,
      'pns2019_01_rawdata.csv'
    )
  )
toc()

rm(uf)
rm(sum_weights, strata_weights)

gc()

