
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
microdados <-
  rawdata |>
  transmute(
    v0024,v0028,upa_pns,v00282,v00283, # expansão da amostra probabilística
    # unidade da federação
    cod_uf = v0001,
    # idade calculada em anos completos - a partir de 1 ano
    idade = c008,
    # sexo
    sexo = case_when(
      c006 == '1' ~ 'masculino',
      c006 == '2' ~ 'feminino',
      TRUE ~ NA_character_
    ),
    # Sabe ler e escrever
    alfabetizado = case_when(
      d001 == '1' ~ 'sim',
      d001 == '2' ~ 'nao',
      TRUE ~ NA_character_
    ),
    # Qual é o estado civil de ___?
    estado_civil = case_when(
      c011 == '1' ~ 'casado',    # Casado(a)
      c011 == '2' ~ 'separado',  # Divorciado(a) ou desquitado(a) ou separado(a) judicialmente
      c011 == '3' ~ 'viuvo',     # Viúvo(a)
      c011 == '4' ~ 'solteiro',  # Solteiro(a)
      TRUE ~ NA_character_
    ),
    # Qual foi o curso mais elevado que ___frequentou
    instrucao = case_when(
      d00901 == '01' ~ 'outros',      # Creche
      d00901 == '02' ~ 'outros',      # Pré-escola
      d00901 == '03' ~ 'outros',      # Classe de alfabetização – CA
      d00901 == '04' ~ 'outros',      # Alfabetização de jovens e adultos
      d00901 == '05' ~ 'fundamental', # Antigo primário (elementar)
      d00901 == '06' ~ 'fundamental', # Antigo ginasial (médio 1º ciclo)
      d00901 == '07' ~ 'fundamental', # Regular do ensino fundamental ou do 1º grau
      d00901 == '08' ~ 'fundamental', # Educação de jovens e adultos (EJA) ou supletivo do ensino fundamental
      d00901 == '09' ~ 'medio',       # Antigo científico, clássico etc. (médio 2º ciclo)
      d00901 == '10' ~ 'medio',       # Regular do ensino médio ou do 2º grau
      d00901 == '11' ~ 'medio',       # Educação de jovens e adultos (EJA) ou supletivo do ensino médio
      d00901 == '12' ~ 'superior',    # Superior – graduação
      d00901 == '13' ~ 'superior',    # Especialização de nível superior (duração mínima de 360 horas)
      d00901 == '14' ~ 'superior',    # Mestrado
      d00901 == '15' ~ 'superior',    # Doutorado
      TRUE ~ NA_character_
    ),
    # cor ou raça
    cor_raca = case_when(
      c009 == '1' ~ 'branca',
      c009 == '2' ~ 'preta',
      c009 == '3' ~ 'amarela',
      c009 == '4' ~ 'parda',
      c009 == '5' ~ 'indigena',
      c009 == '9' ~ 'nao_informado',
      TRUE ~ NA_character_
    ),
    # . ___ tem dificuldade permanente de enxergar mesmo usando óculos, lentes de contato ou lupas?
    dif_enxergar = case_when(
      g046 == '' ~ g047,
      g047 == '' ~ g046,
      TRUE ~ NA_character_
    ),
    dif_enxergar = case_when(
      dif_enxergar == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      dif_enxergar == '3' ~ 'grande',    # Sim, muita dificuldade
      dif_enxergar == '2' ~ 'alguma',    # Sim, alguma dificuldade
      dif_enxergar == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      dif_enxergar == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA_character_
    ),
    # ___ tem dificuldade permanente de ouvir mesmo usando aparelhos auditivos? (Para moradores com 5 anos ou mais de idade.) OU ___ tem dificuldade permanente para ouvir sons como vozes ou música, mesmo usando aparelhos auditivos? (Para moradores com 2 a 4 anos de idade.)
    dif_ouvir = case_when(
      g057 == '' ~ g058,
      g058 == '' ~ g057,
      TRUE ~ NA_character_
    ),
    dif_ouvir = case_when(
      dif_ouvir == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      dif_ouvir == '3' ~ 'grande',    # Sim, muita dificuldade
      dif_ouvir == '2' ~ 'alguma',    # Sim, alguma dificuldade
      dif_ouvir == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      dif_ouvir == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA_character_
    ),
    # ___ tem dificuldade permanente de caminhar ou subir degraus, mesmo usando prótese, bengala ou outro aparelho de auxílio? (Para moradores com 5 anos ou mais de idade.)OUComparado com crianças da mesma idade, ___ tem dificuldade permanente para caminhar, mesmo usando prótese, bengala ou aparelho de auxílio? (Para moradores com 2 a 4 anos de idade.)
    dif_locomover = case_when(
      g070 == '' ~ g071,
      g071 == '' ~ g070,
      TRUE ~ NA_character_
    ),
    dif_locomover = case_when(
      dif_locomover == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      dif_locomover == '3' ~ 'grande',    # Sim, muita dificuldade
      dif_locomover == '2' ~ 'alguma',    # Sim, alguma dificuldade
      dif_locomover == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      dif_locomover == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA_character_
    ),
    # Sabe usar a Língua Brasileira de Sinais – Libras? (Para moradores com 5 anos ou mais de idade.)
    libras = case_when(
      g05801 == '1' ~ 'sim',
      g05801 == '2' ~ 'nao',
      TRUE ~ NA_character_
    ),
    # -----------------------------------------------------------------------------
    # Variáveis para análises adicionais de Fecundidade
    #   Módulo R - Saúde da Mulher (Mulheres de 15 anos ou mais de idade) - p. 59
    # -----------------------------------------------------------------------------
    #
    # Nos últimos 12 meses, a sra teve relações sexuais?
    fec_relacao_sexual_12meses = case_when( 
      r031 == '1' ~ 1, # sim
      r031 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    #
    # Nos últimos 12 meses, a sra participou de grupo de planejamento familiar?
    fec_grupo_planejamento_familiar_12meses = case_when(
      r032 == '1' ~ 1, # sim
      r032 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    #
    # A sra usa algum método para evitar a gravidez atualmente?
    fec_evita_gravidez_atualmente = case_when(
      r034 == '1' ~ 1, # sim
      r034 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    #
    # Qual o principal motivo de não evitar a gravidez?
    fec_motivo_nao_evita_quer_engravidar = case_when(
      r034 == '2' & r035 == '1' ~ 1,
      r034 == '2' & r035 != '1' ~ 0,
      TRUE ~ NA_integer_
      ),
    fec_motivo_nao_evita_religiao = case_when(
      r034 == '2' & r035 == '2' ~ 1,
      r034 == '2' & r035 != '2' ~ 0,
      TRUE ~ NA_integer_
      ),
    fec_motivo_nao_evita_desconhecimento = case_when(
      r034 == '2' & r035 == '3' ~ 1,
      r034 == '2' & r035 == '4' ~ 1,
      r034 == '2' & (r035 != '3' & r035 != '4') ~ 0,
      TRUE ~ NA_integer_
      ),
    fec_motivo_nao_evita_gestante = case_when(
      r034 == '2' & r035 == '5' ~ 1,
      r034 == '2' & r035 != '5' ~ 0,
      TRUE ~ NA_integer_
      ),
    fec_motivo_nao_evita_ligamento_trompa = case_when(
      r034 == '2' & r035 == '6' ~ 1,
      r034 == '2' & r035 != '6' ~ 0,
      TRUE ~ NA_integer_
      ),
    fec_motivo_nao_evita_vasectomia_companheiro = case_when(
      r034 == '2' & r035 == '7' ~ 1,
      r034 == '2' & r035 != '7' ~ 0,
      TRUE ~ NA_integer_
      ),
    fec_motivo_nao_evita_homossexual = case_when(
      r034 == '2' & r035 == '8' ~ 1,
      r034 == '2' & r035 != '8' ~ 0,
      TRUE ~ NA_integer_
    ),
    # Métodos contraceptivos (r034 == 1)
    fec_motivo_evita_pilula = case_when(
      r034 == '1' & r03601 == '1' ~ 1,
      r034 == '1' & r03601 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_tabela = case_when(
      r034 == '1' & r03602 == '1' ~ 1,
      r034 == '1' & r03602 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_camisinha_masculina = case_when(
      r034 == '1' & r03603 == '1' ~ 1,
      r034 == '1' & r03603 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_camisinha_feminina = case_when(
      r034 == '1' & r03604 == '1' ~ 1,
      r034 == '1' & r03604 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_diafragma = case_when(
      r034 == '1' & r03605 == '1' ~ 1,
      r034 == '1' & r03605 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_diu = case_when(
      r034 == '1' & r03606 == '1' ~ 1,
      r034 == '1' & r03606 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_contraceptivo_injetavel = case_when(
      r034 == '1' & r03607 == '1' ~ 1,
      r034 == '1' & r03607 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_implantes_norplant = case_when(
      r034 == '1' & r03608 == '1' ~ 1,
      r034 == '1' & r03608 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_creme_ovulo = case_when(
      r034 == '1' & r03609 == '1' ~ 1,
      r034 == '1' & r03609 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    fec_motivo_evita_pilula_dia_seguinte = case_when(
      r034 == '1' & r03610 == '1' ~ 1,
      r034 == '1' & r03610 != '2' ~ 0,
      TRUE ~ NA_integer_
    ),
    #
    # A sra e/ou seu companheiro já fizeram ou fazem algum tratamento para engravidar?
    fec_tratamento_engravidar = case_when(
      r037 == '1' ~ 1, # sim, fazem atualmente
      r037 == '2' ~ 1, # sim, já fizeram
      r037 == '3' ~ 1, # nunc fizeram
      ),
    # -----------------------------------------------------------------------------
    # Variáveis para análises adicionais de Mortalidade
    #   Módulo Q - Doenças Crônicas - p. 42
    # -----------------------------------------------------------------------------
    #
    # Algum médico já lhe deu o diagnóstico de hipertensão arterial (pressão alta)? (p. 42)
    mort_diagnostico_hipertensao_arterial = case_when(
      q00201 == '1' ~ 1, # sim
      q00201 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de diabetes? (p. 45)
    mort_diagnostico_diabetes = case_when(
      q03001 == '1' ~ 1, # sim
      q03001 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de colesterol alto? (p.48)
    mort_diagnostico_colesterol_alto = case_when(
      q060 == '1' ~ 1, # sim
      q060 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de uma doença do coração, tal como infarto, angina, insuficiência cardíaca ou outra? (p. 49)
    mort_diagnostico_cardiopatia = case_when(
      q06306 == '1' ~ 1, # sim
      q06306 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q06306 == 1 (sim) , a. Infarto
    mort_cardiopata_infarto = case_when(
      q06306 == '1' & q06307 == '1' ~ 1, # sim
      q06306 == '1' & q06307 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q06306 == 1 (sim) , b. Angina
    mort_cardiopata_angina = case_when(
      q06306 == '1' & q06308 == '1' ~ 1, # sim
      q06306 == '1' & q06308 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q06306 == 1 (sim) , c. Insuficiência Cardíaca
    mort_cardiopata_insuficiencia_cardiaca = case_when(
      q06306 == '1' & q06309 == '1' ~ 1, # sim
      q06306 == '1' & q06309 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q06306 == 1 (sim) , d. Arritmia
    mort_cardiopata_arritmia = case_when(
      q06306 == '1' & q06310 == '1' ~ 1, # sim
      q06306 == '1' & q06310 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de AVC (Acidente Vascular Cerebral) ou derrame? (p. 49)
    mort_diagnostico_avc = case_when(
      q068 == '1' ~ 1, # sim
      q068 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de asma (ou bronquite asmática)? (p. 50)
    mort_diagnostico_asma = case_when(
      q074 == '1' ~ 1, # sim
      q074 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de artrite ou reumatismo? (p. 51)
    mort_diagnostico_reumatismo = case_when(
      q079 == '1' ~ 1, # sim
      q079 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de DORT? (p. 52)
    mort_diagnostico_dort = case_when(
      q088 == '1' ~ 1, # sim
      q088 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico ou profissional de saúde mental (como psiquiatra ou psicólogo) já lhe deu o diagnóstico de depressão? (p. 52)
    mort_diagnostico_depressão = case_when(
      q092 == '1' ~ 1, # sim
      q092 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico ou profissional de saúde (como psiquiatra ou psicólogo) já lhe deu o diagnóstico de outra doença mental, como transtorno de ansiedade, síndrome do pânico, esquizofrenia, transtorno bipolar, psicose ou TOC (Transtorno Obsessivo Compulsivo) etc? (p. 54)
    mort_diagnostico_doenca_mental = case_when(
      q11006 == '1' ~ 1, # sim
      q11006 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q11006 == 1 (sim), a. Esquizofrenia
    mort_doenca_mental_esquizofrenia = case_when(
      q11006 == '1' & q11007 == '1' ~ 1, # sim
      q11006 == '1' & q11007 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q11006 == 1 (sim), b. Transtorno Bipolar
    mort_doenca_mental_transtorno_bipolar = case_when(
      q11006 == '1' & q11008 == '1' ~ 1, # sim
      q11006 == '1' & q11008 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q11006 == 1 (sim), a. TOC
    mort_doenca_mental_toc = case_when(
      q11006 == '1' & q11009 == '1' ~ 1, # sim
      q11006 == '1' & q11009 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de alguma outra doença crônica no pulmão, tais como enfisema pulmonar, bronquite crônica ou DPOC (Doença Pulmonar Obstrutiva Crônica)? (p. 54)
    mort_diagnostico_doenca_pulmonar = case_when(
      q11604 == '1' ~ 1, # sim
      q11604 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q11604 == 1 (sim), a. Enfisema Pulmonar
    mort_doenca_pulmonar_enfisema = case_when(
      q11604 == '1' & q11605 == '1' ~ 1, # sim
      q11604 == '1' & q11605 == '2' ~ 0, # não
      TRUE ~ NA_integer_      
    ),
    # q11604 == 1 (sim), b. Bronquite Crônica
    mort_doenca_pulmonar_bronquite_cronica = case_when(
      q11604 == '1' & q11606 == '1' ~ 1, # sim
      q11604 == '1' & q11606 == '2' ~ 0, # não
      TRUE ~ NA_integer_      
    ),
    # Algum médico já lhe deu diagnóstico de câncer? (p. 55)
    mort_diagnostico_cancer = case_when(
      q120 == '1' ~ 1, # sim
      q120 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q12102 Câncer de Pele
    mort_cancer_pele = case_when(
      q120 == '1' & q12102 == '1' ~ 1, # sim
      q120 == '1' & q12102 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q12104 a. Pulmão
    mort_cancer_pulmao = case_when(
      q120 == '1' & q12104 == '1' ~ 1, # sim
      q120 == '1' & q12104 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q12105 b. Cólon e Reto
    mort_cancer_intestino = case_when(
      q120 == '1' & q12105 == '1' ~ 1, # sim
      q120 == '1' & q12105 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q12106 c. Estômago
    mort_cancer_estomago = case_when(
      q120 == '1' & q12106 == '1' ~ 1, # sim
      q120 == '1' & q12106 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q12107 d. Mama (só para mulheres)
    mort_cancer_mama = case_when(
      q120 == '1' & c006 == '2' & q12107 == '1' ~ 1, # sim
      q120 == '1' & c006 == '2' & q12107 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q12108 e. Cólon de Útero (só para mulheres)
    mort_cancer_colon_utero = case_when(
      q120 == '1' & c006 == '2' & q12108 == '1' ~ 1, # sim
      q120 == '1' & c006 == '2' & q12108 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q12109 f. Próstata (só para homens)
    mort_cancer_prostata = case_when(
      q120 == '1' & c006 == '1' & q12109 == '1' ~ 1, # sim
      q120 == '1' & c006 == '1' & q12109 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q121010 g. Boca, Orofaringe ou Laringe
    mort_cancer_boca_orofaringe_laringe = case_when(
      q120 == '1' & q121010 == '1' ~ 1, # sim
      q120 == '1' & q121010 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q121011 h. Bexiga
    mort_cancer_bexiga = case_when(
      q120 == '1' & q121011 == '1' ~ 1, # sim
      q120 == '1' & q121011 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q121012 i. Linfoma ou Leucemia
    mort_cancer_linfoma_ou_leucemia = case_when(
      q120 == '1' & q121012 == '1' ~ 1, # sim
      q120 == '1' & q121012 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q121013 j. Cérebro
    mort_cancer_cerebro = case_when(
      q120 == '1' & q121013 == '1' ~ 1, # sim
      q120 == '1' & q121013 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q121014 k. Ovário (só para mulheres)
    mort_cancer_ovario = case_when(
      q120 == '1' & c006 == '2' & q121014 == '1' ~ 1, # sim
      q120 == '1' & c006 == '2' & q121014 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # q120 == 1 (sim), q121015 l. Tireoide
    mort_cancer_tireoide = case_when(
      q120 == '1' & q121015 == '1' ~ 1, # sim
      q120 == '1' & q121015 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Algum médico já lhe deu o diagnóstico de doença de Chagas? (p. 71)
    mort_diagnostico_doenca_chagas = case_when(
      t003 == '1' ~ 1, # sim
      t003 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Nos últimos 12 meses, algum médico lhe deu diagnóstico de doença/infecção sexualmente transmissível? (p. 71)
    mort_diagnostico_dst_ist = case_when(
      t004 == '1' ~ 1, # sim
      t004 == '2' ~ 0, # não
      TRUE ~ NA_integer_
    ),
    # Antropometria
    antrop_imc = case_when(
      w00203 == '' ~ NA_real_,    # altura não aplicável
      w00203 == '999' ~ NA_real_, # altura com erro
      w00103 == '' ~ NA_real_,    # peso não aplicável
      w00103 == '999' ~ NA_real_, # peso com erro
      TRUE ~ as.numeric(w00103)/((as.numeric(w00203)/100.0)^2)
    )
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
message("salvando os microdados em disco")

microdados |>
  write_csv(
    paste0(
      data_dir,
      'pns2019_01_parsed.csv'
    )
  )

rm(uf)

toc()

gc()
