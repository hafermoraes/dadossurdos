# install from CRAN
install.packages("censobr")
install.packages("survey")

# or use the development version with latest features
utils::remove.packages('censobr')
remotes::install_github("ipeaGIT/censobr", ref="dev")
library(censobr)
library(survey)
library(dplyr)
library(stringr)

library(lavaan)
library(lavaanPlot)
library(piecewiseSEM)
#library(tidyverse)
#library(rjags)
library(jagsUI)
library(coda)
#library(matrixStats)
library(pals)
library(ggplot2)
library(tidyr)
library(car)


df <- read_population(
  year = 2010,
  columns = c('V6461','V6930','V0010','V0648','V6940','V6036','V6633','V6664','V0601','V6920'
              ,'V6471','V6631','V0663','V6400','V0606','V1001','V1006','V6514','V5110',
              'V1002','V1001','V0001','V0628','V0629','V0630','V0631','V0633','V1003',
              'V1004','V0011','V0002','V0300','V0632','V0634','V0635','V6513','V6526'), ##se for null vem todas as colunas
  add_labels = 'pt',
  as_data_frame = TRUE,
  showProgress = TRUE,
  cache = TRUE
)


# Open data dictionary on browser
data_dictionary(year = 2010, dataset = 'population', showProgress = FALSE)

####### mulheres de 10 até 49 anos 
mulheres_2010 <- subset(df, V0601 == 'Feminino' & V6036 >= 15 & V6036 <= 49)
mulheres_2010_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_2010)
rm(df)

mulheres_2010 <- mulheres_2010 %>%
  mutate(
    cod_mesorregiao = str_pad(V0001, 2, pad = "0") %>%
      paste0(str_pad(V1002, 2, pad = "0"))
  )

n_distinct(mulheres_2010$cod_mesorregiao)


## categ do CNAE
#https://cnae.ibge.gov.br/?option=com_cnae&view=estrutura&Itemid=6160&tipo=cnae&versao_classe=7.0.0&versao_subclasse=

# Adicionando a vari?vel categoria_cnae com base no c?digo V6471
mulheres_2010$codigo_cnae_categ <- ifelse(grepl("^(01|02|03)", mulheres_2010$V6471), "A",
                                          ifelse(grepl("^(05|06|07|08|09)", mulheres_2010$V6471), "B",
                                                 ifelse(grepl("^(10|11|12|13|14|15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33)", mulheres_2010$V6471), "C",
                                                        ifelse(grepl("^(35)", mulheres_2010$V6471), "D",
                                                               ifelse(grepl("^(36|37|38|39)", mulheres_2010$V6471), "E",
                                                                      ifelse(grepl("^(41|42|43)", mulheres_2010$V6471), "F",
                                                                             ifelse(grepl("^(45|48)", mulheres_2010$V6471), "G",#mudei
                                                                                    ifelse(grepl("^(49|50|51|52|53)", mulheres_2010$V6471), "H",
                                                                                           ifelse(grepl("^(55|56)", mulheres_2010$V6471), "I",
                                                                                                  ifelse(grepl("^(58|59|60|61|62|63)", mulheres_2010$V6471), "J",
                                                                                                         ifelse(grepl("^(64|65|66)", mulheres_2010$V6471), "K",
                                                                                                                ifelse(grepl("^(68)", mulheres_2010$V6471), "L",
                                                                                                                       ifelse(grepl("^(69|70|71|72|73|74|75)", mulheres_2010$V6471), "M",
                                                                                                                              ifelse(grepl("^(77|78|79|80|81|82)", mulheres_2010$V6471), "N",
                                                                                                                                     ifelse(grepl("^(84)", mulheres_2010$V6471), "O",
                                                                                                                                            ifelse(grepl("^(85)", mulheres_2010$V6471), "P",
                                                                                                                                                   ifelse(grepl("^(86|87|88)", mulheres_2010$V6471), "Q",
                                                                                                                                                          ifelse(grepl("^(90|91|92|93)", mulheres_2010$V6471), "R",
                                                                                                                                                                 ifelse(grepl("^(94|95|96)", mulheres_2010$V6471), "S",
                                                                                                                                                                        ifelse(grepl("^(97)", mulheres_2010$V6471), "T",
                                                                                                                                                                               ifelse(grepl("^(99)", mulheres_2010$V6471), "U",
                                                                                                                                                                                      ifelse(grepl("^(00)", mulheres_2010$V6471), "V",
                                                                                                                                                                                             'missing'))))))))))))))))))))))

# ver os dados cnae
head(mulheres_2010$codigo_cnae_categ)
mulheres_2010[!is.na(mulheres_2010$V6930) & is.na(mulheres_2010$V6471), ]

# Adicionando a vari?vel sub_grupo_cnae com base na categoria j? existente codigo_cnae_categ
mulheres_2010$sub_grupo_cnae <- ifelse(mulheres_2010$codigo_cnae_categ %in% c("missing"), "missing",
                                       ifelse(mulheres_2010$codigo_cnae_categ %in% c("O", "N"), "adm_e_gestao_publica",
                                              ifelse(mulheres_2010$codigo_cnae_categ %in% c("P"), "educacao",
                                                     ifelse(mulheres_2010$codigo_cnae_categ %in% c("Q"), "saude",
                                                            #ifelse(mulheres_2010$codigo_cnae_categ %in% c("J", "M"), "tecnologia",
                                                                   "outras"))))


## separando militares
# Corrigindo e ajustando o c?digo para criar a nova vari?vel ocupacao_v2
mulheres_2010$ocupacao_v2 <- ifelse(
  mulheres_2010$V6930 == 'Militares e funcionários públicos estatutários' & grepl("^(011|021|029|041|051|059|099)", mulheres_2010$V6461),
  'militar',
  ifelse(
    mulheres_2010$V6930 == 'Militares e funcionários públicos estatutários',
    'funcionario_publico',
    ifelse(
      mulheres_2010$V6930 == "Empregadores",
      'empregadores',
      ifelse(
        mulheres_2010$V6930 == 'Conta própria',
        'conta_propria',
        ifelse(
          mulheres_2010$V6930 == 'Empregados com carteira de trabalho assinada',
          'emprego_com_carteira',
          ifelse(
            mulheres_2010$V6930 == 'Empregados sem carteira de trabalho assinada',
            'emprego_sem_carteira',
            ifelse(
              mulheres_2010$V6930 == 'Não remunerados',
              'sem_remuneracao',
              ifelse(
                mulheres_2010$V6930 == 'Trabalhadores na produção para o próprio consumo',
                'proprio_consumo',
                NA  # Adicionando NA como valor padrao para casos nao especificados
              ))))))))

# Criando os intervalos
intervalos <- c(14, 19, 24, 29, 34, 39, 44, 49)
rotulos <- c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49")

mulheres_2010$V6036<-as.numeric(mulheres_2010$V6036)

# Criando a vari?vel de categoria da dade da mulher
mulheres_2010$idade_categ <- cut(mulheres_2010$V6036, breaks = intervalos, labels = rotulos, include.lowest = TRUE)
#table(mulheres_2010$idade_categ)

## criando a varuavel de ever born
# Definindo os intervalos para categoriza??o
int_filhos <- c(0, 1, 2, 3, 4, Inf)

# Criando a vari?vel categorizada
mulheres_2010$filhos_ever_born <- cut(mulheres_2010$V6633, breaks = int_filhos, labels = c("0", "1", "2", "3", "4+"), right = FALSE)
#table(mulheres_2010$filhos_ever_born)

# Criando uma flag de funcionario publico - 1 (sim), 0 (n?o)

mulheres_2010$flag_func_publico <- ifelse(mulheres_2010$ocupacao_v2 == 'funcionario_publico','1','0')


# categorizando a escolaridade

# Cria uma nova coluna 'categoria_educacao' baseada nos n?veis de educa??o
mulheres_2010$categoria_educacao <- with(mulheres_2010, ifelse(is.na(mulheres_2010$V6400), 
                                                               "-1.Seminformacao",
                                                               ifelse(V6400 %in% c("Sem instrucao e fundamental incompleto", 
                                                                                   "Fundamental completo e medio incompleto"),
                                                                      '1.at?_medio_incompleto',
                                                                      ifelse(V6400 == "Medio completo e superior incompleto", 
                                                                             '2.ate_superior_incompleto', 
                                                                             '3.Superior_completo'))))

#table(mulheres_2010$categoria_educacao,useNA = 'always')
# Supondo que mulheres_2010 seja o seu dataframe e V6514 seja a vari?vel de sal?rios m?nimos
mulheres_2010$categorias_salarios2 <- ifelse(is.na(mulheres_2010$V6514), "-1. Sem informacao",
                                             ifelse(mulheres_2010$V6514 == 0, "0",
                                                    cut(mulheres_2010$V6514, 
                                                        breaks = c(-Inf, 1, 3, 5, Inf), 
                                                        labels = c("1. Ate 1", "2. De 2 a 3", "3. De 4 a 5", "4. Acima de 5"), 
                                                        right = TRUE)))

mulheres_2010$categorias_salarios <- ifelse(is.na(mulheres_2010$V6514), "-1.Seminformacao",
                                            ifelse(mulheres_2010$V6514 == 0, "0",
                                                   ifelse(mulheres_2010$V6514 <= 1, "1.At?1",
                                                          ifelse(mulheres_2010$V6514 <= 3, "2.De2a3",
                                                                 ifelse(mulheres_2010$V6514 <= 5, "3.De4a5",
                                                                        "4.Acimade5")))))

# Verificando o resultado
head(mulheres_2010$V5120)
#table(mulheres_2010$V6514,useNA = 'always')


# Criando a nova vari?vel ocupacao_v3 com base na ocupacao_v2 e V5110
mulheres_2010$ocupacao_v3 <- ifelse(
  mulheres_2010$ocupacao_v2 == 'militar',
  'militar',
  ifelse(
    mulheres_2010$ocupacao_v2 == 'funcionario_publico',
    'funcionario_publico',
    ifelse(
      mulheres_2010$ocupacao_v2 == 'empregadores' & mulheres_2010$V5110 == '1',
      'setor_privado_formal',
      ifelse(
        mulheres_2010$ocupacao_v2 == 'empregadores' & mulheres_2010$V5110 == '2',
        'informal',
        ifelse(
          mulheres_2010$ocupacao_v2 == 'conta_propria' & mulheres_2010$V5110 == '1',
          'setor_privado_formal',
          ifelse(
            mulheres_2010$ocupacao_v2 == 'conta_propria' & mulheres_2010$V5110 == '2',
            'informal',
            ifelse(
              mulheres_2010$ocupacao_v2 == 'emprego_com_carteira',
              'setor_privado_formal',
              ifelse(
                mulheres_2010$ocupacao_v2 == 'emprego_sem_carteira',
                'informal',
                ifelse(
                  mulheres_2010$ocupacao_v2 == 'proprio_consumo',
                  'proprio_consumo',
                  ifelse(mulheres_2010$ocupacao_v2 == 'sem_remuneracao','sem_remuneracao',
                         NA  # Adicionando NA como valor padr?o para casos n?o especificados
                  ))))))))))

#ferreirasoares01@gmail.com 

################################################################
########### SOMENTE FUNCIONARIAS PUBLICAS v2 ######################
################################################################
library(dplyr)
library(survey)

mulheres_func_pub <- subset(mulheres_2010,  ocupacao_v3 == 'funcionario_publico')
mulheres_func_pub$flag_nasc_12m <- ifelse(mulheres_func_pub$V6664=='Não','0','1')#Total de filhos nascidos vivos


mulheres_func_pub <-mulheres_func_pub %>%
  mutate(
    flag_nasc_12m = as.numeric(as.character(flag_nasc_12m))
  )

mulheres_func_pub_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_func_pub)


# Flag 1 se funcionária pública, 0 c.c.
mulheres_func_pub <- mulheres_func_pub %>%
  mutate(func_pub = ifelse(ocupacao_v3 == "funcionario_publico", 1, 0))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(idade_30_mais = ifelse(V6036 >=30, 1, 0))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(idade_35_mais = ifelse(V6036 >=35, 1, 0))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(urbana = ifelse(V1006 == 1, 1, 0))

mulheres_func_pub <-mulheres_func_pub %>%
  mutate(
    flag_nasc_12m = as.numeric(as.character(flag_nasc_12m))
  )

# Criar objeto de desenho amostral
mulheres_func_pub_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_func_pub)


###############################################################################
###############################################################################
## todas as mulheres por grupo cnae
data.frame(svytable(~sub_grupo_cnae,design = mulheres_func_pub_aux))#total de mulheres por flag)
### Medidades de fecundidade

## TFT, funcionarias publicas
svytable(~idade_categ,design = mulheres_func_pub_aux)#total de mulheres
svytable(~idade_categ+flag_nasc_12m,design = mulheres_func_pub_aux)#total de mulheres por flag
svytable(~idade_categ+sub_grupo_cnae,design = mulheres_func_pub_aux)#total de mulheres por grupo cnae
svytable(~idade_categ+flag_nasc_12m+sub_grupo_cnae,design = mulheres_func_pub_aux)

## idade media ao primeiro filho
svytable(~idade_categ , design = mulheres_func_pub_aux)
## so um filho
mulheres_1filho <- subset(mulheres_func_pub, V6633 == 1)
mulheres_1filho_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_1filho)
data.frame(svytable(~idade_categ , design = mulheres_1filho_aux))
svytable(~idade_categ+sub_grupo_cnae , design = mulheres_1filho_aux)
svytable(~idade_categ+sub_grupo_cnae,design = mulheres_func_pub_aux)#total de mulheres por grupo cnae

## proporcao de sem filhos
svytable(~idade_categ , design = mulheres_func_pub_aux)
## sem filhos - childless
mulheres_0filho <- subset(mulheres_func_pub, V6633 == 0)
mulheres_0filho_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_0filho)
data.frame(svytable(~idade_categ , design = mulheres_0filho_aux))
svytable(~idade_categ+sub_grupo_cnae , design = mulheres_0filho_aux)
svytable(~idade_categ+sub_grupo_cnae,design = mulheres_func_pub_aux)#total de mulheres por grupo cnae

## parturição
svytable(~filhos_ever_born+idade_categ, design = mulheres_func_pub_aux)
svytable(~filhos_ever_born+idade_categ+sub_grupo_cnae, design = mulheres_func_pub_aux)
###############################################################################
########### VARIÁVEL RESPOSTA (TFT) - Considerando apenas Funcionárias públicas
###############################################################################

### TFT COORTE

mulheres_func_pub_4549 <- subset(mulheres_func_pub, idade_categ == "45-49") 
mulheres_func_pub_4549_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_func_pub_4549)

ufs <- sort(unique(mulheres_func_pub_4549$cod_mesorregiao))
tft_resultados <- data.frame()

for (uf in ufs) {
  tabela <- mulheres_func_pub_4549 %>%
    filter(cod_mesorregiao == uf) %>%
    group_by(filhos_ever_born) %>%
    summarise(qtd_mulheres = sum(V0010, na.rm = TRUE)) %>%
    arrange(desc(filhos_ever_born)) %>%
    mutate(acumulado = cumsum(qtd_mulheres)) %>%
    arrange(filhos_ever_born) %>%
    mutate(
      razao_parturicao = lead(acumulado) / acumulado
    )
  
  r <- tabela$razao_parturicao[1:4]
  tft <- round(r[1] + r[1]*r[2] + r[1]*r[2]*r[3] + r[1]*r[2]*r[3]*r[4], 2)
  
  # Imprimir tabela por UF
  cat("\n=====================\n")
  cat("UF:", uf, "\n")
  print(tabela)
  cat("TFT de coorte:", tft, "\n")
  
  tft_resultados <- bind_rows(tft_resultados, data.frame(cod_mesorregiao  = uf, TFT_coorte = tft))
}

##################################################################
################## TFT Período -- somente funcionárias públicas
###############################################################
# Ponto médio por faixa etária
###############################################################
ponto_medio <- c(
  "15-19" = 17.5, "20-24" = 22.5, "25-29" = 27.5,
  "30-34" = 32.5, "35-39" = 37.5, "40-44" = 42.5, "45-49" = 47.5
)

# Criar variável auxiliar
mulheres_func_pub$one <- 1

# Lista final de resultados
resultado_meso_lista <- list()

# Lista de mesorregiões
ufs <- sort(unique(mulheres_func_pub$cod_mesorregiao))

###############################################################
# LOOP POR MESORREGIÃO (UF)
###############################################################

for (uf in ufs) {
  
  cat("\n====================== MESORREGIÃO:", uf, "======================\n")
  
  dados_uf <- subset(mulheres_func_pub, cod_mesorregiao == uf)
  dados_uf$one <- 1
  dados_uf$ponto_medio <- ponto_medio[as.character(dados_uf$idade_categ)]
  
  design_uf <- svydesign(ids = ~1, weights = ~V0010, data = dados_uf)
  
  #################################################################
  # 1) TABELA E IMPRESSÃO — IDADE MÉDIA À FECUNDIDADE (PERÍODO 12m)
  #################################################################
  
  cat("\n--- Tabela: IDADE MÉDIA À FECUNDIDADE (periodo 12m) ---\n")
  
  # Subset com mulheres que tiveram filhos nos últimos 12 meses
  dados_nasc_12m <- subset(dados_uf, flag_nasc_12m == 1)
  design_nasc_12m <- svydesign(ids = ~1, weights = ~V0010, data = dados_nasc_12m)
  
  # Nascimentos por idade
  nascidos_12m <- svyby(~one, ~idade_categ, design_nasc_12m, svytotal, na.rm = TRUE)
  names(nascidos_12m)[2] <- "nasc_12m"
  
  # Total de mulheres por idade
  total_mulheres <- svyby(~one, ~idade_categ, design_uf, svytotal, na.rm = TRUE)
  names(total_mulheres)[2] <- "total_mulheres"
  
  # Tabela período
  tabela_fec <- left_join(nascidos_12m, total_mulheres, by = "idade_categ") %>%
    mutate(
      TEF = nasc_12m / total_mulheres,
      ponto_medio = ponto_medio[as.character(idade_categ)],
      idade_media_parte = TEF * ponto_medio
    )
  
  print(tabela_fec)
  
  # Idade média à fecundidade
  idade_media_fec <- round(
    sum(tabela_fec$idade_media_parte, na.rm = TRUE) /
      sum(tabela_fec$TEF, na.rm = TRUE),
    1
  )
  
  cat("Idade média à fecundidade - Mesorregião", uf, ":", idade_media_fec, "\n")
  
  # TFT
  TFT <- round(sum(tabela_fec$TEF, na.rm = TRUE) * 5, 2)
  cat("TFT da Mesorregião:", TFT, "\n")
  
  
  #################################################################
  # 2) TABELA E IMPRESSÃO — IDADE MÉDIA DE COORTE (V6633 == 1)
  #################################################################
  
  cat("\n--- Tabela: IDADE MÉDIA DE COORTE (V6633 == 1) ---\n")
  
  # Filtrar mulheres com EXACTAMENTE 1 filho vivo (V6633 == 1)
  design_1filho <- subset(design_uf, V6633 == 1)
  
  um_filho_tab <- svytable(~idade_categ, design_1filho)
  um_filho_df  <- as.data.frame(um_filho_tab)
  names(um_filho_df) <- c("idade_categ", "n_1filho")
  
  total_mulheres_tab <- total_mulheres %>% select(idade_categ, total_mulheres)
  
  # Tabela de coorte
  tabela_coorte <- left_join(um_filho_df, total_mulheres_tab, by = "idade_categ") %>%
    mutate(
      TEF = n_1filho / total_mulheres,
      ponto_medio = ponto_medio[as.character(idade_categ)],
      idade_media_parte = TEF * ponto_medio
    )
  
  print(tabela_coorte)
  
  # Idade média de coorte
  idade_media_coorte <- round(
    sum(tabela_coorte$idade_media_parte, na.rm = TRUE) /
      sum(tabela_coorte$TEF, na.rm = TRUE),
    1
  )
  
  cat("Idade média de coorte (V6633==1) - Mesorregião", uf, ":", idade_media_coorte, "\n")
  
  
  #################################################################
  # 3) ARMAZENAR RESULTADOS
  #################################################################
  
  resultado_meso_lista[[as.character(uf)]] <- data.frame(
    cod_mesorregiao = uf,
    TFT_periodo = TFT,
    idade_media_fec = idade_media_fec,
    idade_media_coorte = idade_media_coorte
  )
}

###############################################################
# TABELA FINAL
###############################################################
df_tef_resumo <- bind_rows(resultado_meso_lista)

cat("\n====================== RESULTADO FINAL ======================\n")
print(df_tef_resumo)




##################################################################################
########### COVARIÁVEIS - Considerando todas as mulheres ocupadas de 45 a 49 anos
##################################################################################


library(dplyr)

# PASSO 1: Converter variáveis textuais em numéricas
mulheres_func_pub <- mulheres_func_pub %>%
  mutate(
    # V0628 - Frequenta escola ou creche
    V0628_num = case_when(
      str_trim(V0628) == "Sim, pública" ~ 1,
      V0628 == "Sim, particular" ~ 2,
      V0628 == "Não, já frequentou" ~ 3,
      V0628 == "Não, nunca frequentou" ~ 4,
      is.na(V0628) ~ NA_real_,
      TRUE ~ NA_real_  # Atribui NA para valores não mapeados ao invés de -1
    ),
    
    # V0629 - Curso que frequenta
    V0629_num = case_when(
      str_trim(V0629) == "Creche" ~ 1,
      str_trim(V0629) == "Pré-escolar (maternal e jardim da infância)" ~ 2,
      str_trim(V0629) == "Classe de alfabetização - CA" ~ 3,
      str_trim(V0629) == "Alfabetização de jovens e adultos" ~ 4,
      str_trim(V0629) == "Regular do ensino fundamental" ~ 5,
      str_trim(V0629) == "Educação de jovens e adultos - EJA - ou supletivo do ensino fundamental" ~ 6,
      str_trim(V0629) == "Regular do ensino médio" ~ 7,
      str_trim(V0629) == "Educação de jovens e adultos - EJA - ou supletivo do ensino médio" ~ 8,
      str_trim(V0629) == "Superior de graduação" ~ 9,
      str_trim(V0629) == "Especialização de nível superior ( mínimo de 360 horas )" ~ 10,
      str_trim(V0629) == "Mestrado" ~ 11,
      str_trim(V0629) == "Doutorado" ~ 12,
      is.na(V0629) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    
    # V0630 - Série/ano que frequenta (com tratamento seguro para conversão numérica)
    V0630_num = case_when(
      V0630 == "Primeiro ano" ~ 1,
      V0630 == "Primeira série - Segundo ano" ~ 2,
      V0630 == "Segunda série - Terceiro ano" ~ 3,
      V0630 == "Terceira série - Quarto ano" ~ 4,
      V0630 == "Quarta série - Quinto ano" ~ 5,
      V0630 == "Quinta série - Sexto ano" ~ 6,
      V0630 == "Sexta série - Sétimo ano" ~ 7,
      V0630 == "Sétima série - Oitavo ano" ~ 8,
      V0630 == "Oitava série - Nono ano" ~ 9,
      V0630 == "Não seriado" ~ 10,
      is.na(V0630) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    
    # V0633 - Curso mais elevado que frequentou
    V0633_num = case_when(
      V0633 == "Creche, pré-escolar (maternal e jardim de infância), classe de alfabetização - CA" ~ 1,
      V0633 == "Alfabetização de jovens e adultos" ~ 2,
      V0633 == "Antigo primário (elementar)" ~ 3,
      V0633 == "Antigo ginásio (médio 1º ciclo)" ~ 4,
      V0633 == "Ensino fundamental ou 1º grau (da 1ª a 3ª série/ do 1º ao 4º ano)" ~ 5,
      V0633 == "Ensino fundamental ou 1º grau (4ª série/ 5º ano)" ~ 6,
      V0633 == "Ensino fundamental ou 1º grau (da 5ª a 8ª série/ 6º ao 9º ano)" ~ 7,
      V0633 == "Supletivo do ensino fundamental ou do 1º grau" ~ 8,
      V0633 == "Antigo científico, clássico, etc.....(médio 2º ciclo)" ~ 9,
      V0633 == "Regular ou supletivo do ensino médio ou do 2º grau" ~ 10,
      V0633 == "Superior de graduação" ~ 11,
      V0633 == "Especialização de nível superior ( mínimo de 360 horas )" ~ 12,
      V0633 == "Mestrado" ~ 13,
      V0633 == "Doutorado" ~ 14,
      is.na(V0633) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    
    # V0631 - Série que frequentou (com tratamento seguro)
    V0631_num = case_when(
      V0631 == "Primeira série" ~ 1,
      V0631 == "Segunda série" ~ 2,
      V0631 == "Terceira série" ~ 3,
      V0631 == "Quarta série" ~ 4,
      V0631 == "Não seriado" ~ 5,
      is.na(V0631) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    V0632_num = case_when(
      V0632 == "Sim" ~ 1,
      V0632 == "Não" ~ 2,
      is.na(V0632) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    V0634_num = case_when(
      V0634 == "Sim" ~ 1,
      V0634 == "Não" ~ 2,
      is.na(V0634) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    V0635_num = case_when(
      V0635 == "Superior de graduação" ~ 1,
      V0635 == "Mestrado" ~ 2,
      V0635 == "Doutorado" ~ 3,
      is.na(V0635) ~ NA_real_,
      TRUE ~ NA_real_
    ),
    V6400_num = case_when(
      V6400 == "Sem instrução e fundamental incompleto" ~ 1,
      V6400 == "Fundamental completo e médio incompleto" ~ 2,
      V6400 == "Médio completo e superior incompleto" ~ 3,
      V6400 == "Superior completo" ~ 4,
      V6400 == "Não determinado" ~ 5,
      is.na(V6400) ~ NA_real_,
      TRUE ~ NA_real_
    ),
  )

table(mulheres_func_pub$V6400_num,mulheres_func_pub$V6400_num)
# Verificando os resultados
summary(mulheres_func_pub %>% select(ends_with("_num")))

# PASSO 2: Calcular anos de estudo (anest) com variáveis no formato V_num
mulheres_func_pub <- mulheres_func_pub %>%
  mutate(
    anest = case_when(
      
      # 0 anos – nunca frequentou ou só educação infantil/alfabetização não concluída
      V0629_num %in% c(1, 2, 3, 4) |
        (V0633_num %in% c(1, 2) & V0634_num == 2) |
        V0628_num == 4 ~ 0,
      
      # 1 a 3 anos – série que está cursando
      V0630_num == 2 | V0631_num == 1 ~ 1,
      V0630_num == 3 | V0631_num == 2 ~ 2,
      V0630_num == 4 | V0631_num == 3 ~ 3,
      
      # 1 ano – educação infantil/alfabetização concluída -- eu colocaria junto com 1 mas eh o 633, dps do 630
      V0633_num %in% c(1, 2) & V0634_num == 1 ~ 1,
      
      # 4 anos – fundamental inicial concluído
      (V0629_num %in% c(5,6) & V0630_num == 5) | 
        (V0633_num %in% c(5, 8) & V0634_num == 1) ~ 4,
      
      # 5 anos – 4ª série (5º ano) concluída
      #V6400_num == 2 & V0634_num == 2 ~ 5, # mudei aqui, vamos ver
      V0629_num %in% c(5,6) & V0630_num == 6 ~ 5,
      
      # Fundamental cursando — anos completos = ano atual - 1
      V0629_num %in% c(5,6) & V0630_num == 7 ~ 6,
      V0629_num %in% c(5,6) & V0630_num == 8 ~ 7,
      V0629_num %in% c(5,6) & V0630_num == 9 ~ 8,
      
      # Fundamental final — fallback conservador - o que for missing no 630 a gnt cobre com 633 e 634
      is.na(V0630_num) & V0633_num == 7 & V0634_num == 2 ~ 6,
      is.na(V0630_num) & V0633_num == 7 & V0634_num == 1 ~ 8,
      
      # 9 anos — ensino médio incompleto (início)
      (
        # Caminho principal: cursando ensino médio (1º ou 2º ano)
        (V0629_num %in% c(7, 8) & V0630_num %in% c(1, 2)) |
          
          # Fallback: ensino médio como curso mais elevado, não concluído
          (V0633_num %in% c(9, 10) & V0634_num == 2)
      ) ~ 9,
      
      # 10 anos — ensino médio incompleto avançado
      (V0629_num %in% c(7, 8) & V0630_num == 3) ~ 10,
      
      # 11 anos – ensino médio concluído
      V0633_num %in% c(9, 10) & V0634_num == 1 ~ 11,     
      # 11 anos — ensino médio completo (proxy via nível geral quando curso detalhado está ausente)
      V6400_num == 3 & is.na(V0633_num) ~ 11,
      
      # 12 anos — ensino superior iniciado / incompleto
      (V0633_num == 11 & V0634_num == 2) |   # graduação incompleta (curso mais elevado = graduação, não concluiu)
        (V0629_num == 9) ~ 12,                 # cursando graduação
      
      
      # 13 anos — graduação completa
      (V0633_num == 11 & V0634_num == 1) ~ 13,
      
      
      # 14 anos — especialização concluída (pós lato sensu)
      (V0633_num == 12 & V0634_num == 1) ~ 14,
      # 14 anos — mestrado incompleto (proxy)
      (V0633_num == 13 & V0634_num == 2) ~ 14,
      
      # 15 anos — mestrado concluído
      (V0633_num == 13 & V0634_num == 1) ~ 15,
      
      
      # 16 anos — doutorado concluído
      (V0633_num == 14 & V0634_num == 1) ~ 16,
      
      #proxy começando do mais avançado que concluiu
      (V0635_num == 3) ~ 16, #doutorado concluido
      (V0635_num == 2) ~ 15, #mestrado concluído
      (V0635_num == 1) ~ 13, #graduacao concluída
      
      #proxy porque continua NA
      (V0633_num == 4 & V0634_num == 1) ~ 8, #medio concluido
      (V0633_num == 4 & V0634_num == 2) ~ 6, #medio nao concluido
      (V0633_num == 3 & V0634_num == 1) ~ 4, #primario concluido
      (V0633_num == 3 & V0634_num == 2) ~ 3, #primario nao concluido
      (V0633_num == 5 & V0634_num == 2) ~ 3, #fundamental nao concluido
      (V0633_num == 5 & V0634_num == 1) ~ 7, #fundamental concluido
      
      # Fallback FINAL via V6400 (proxy conservadora)
      V6400_num == 1 ~ 3,  # sem instrução ou fund. incompleto → baixo fundamental
      V6400_num == 2 ~ 8,  # fund. completo ou médio incompleto → fund. completo
      V6400_num == 3 ~ 11, # médio completo ou superior incompleto → médio completo
      V6400_num == 4 ~ 13, # superior completo
      
      V0629_num == 7 ~ 7, #esta cursando o ensino medio
      
      
      # Casos não classificados
      TRUE ~ NA_integer_
    )
  )

# VERIFICAÇÃO DA DISTRIBUIÇÃO
table(mulheres_func_pub$anest, useNA = "always")




# filtrar somente quem ficou com anest = NA
df_na <- mulheres_func_pub %>%
  filter(is.na(anest))

# variáveis que você quer inspecionar
vars_base <- c(
  "V0628","V0629","V0630","V0631",
  "V0632","V0633","V0634","V0635","V6400"
)

# tabelas simples (uma por variável)
for (v in vars_base) {
  cat("\n==============================\n")
  cat("Tabela de", v, "(somente anest = NA)\n")
  print(table(df_na[[v]], useNA = "always"))
}

# VERIFICAÇÃO DA DISTRIBUIÇÃO
table(mulheres_func_pub$anest, useNA = "always")


mulheres_func_pub_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_func_pub)
svytable(~anest, design = mulheres_func_pub_aux)

#######################################################
#######################################################

# 1. População total por UF (contagem ponderada de pessoas
populacao_por_uf <- as.data.frame(svytable(~cod_mesorregiao, design = mulheres_func_pub_aux))
colnames(populacao_por_uf) <- c("cod_mesorregiao", "soma_populacao")

# 2. Soma de filhos nascidos vivos (V4620) por UF
filhos_nascidos_por_uf <- svyby(~V6633, ~cod_mesorregiao, mulheres_func_pub_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(soma_filhos_nascidos = V6633)

# 3. Soma de nascidos nos últimos 12 meses por UF (flag_nasc_12m)
nascidos_12m_por_uf <- svyby(~flag_nasc_12m, ~cod_mesorregiao, mulheres_func_pub_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(soma_nascidos_12m = flag_nasc_12m)

# 4. Média de renda (V6513) por UF
media_renda_por_uf <- svyby(~V6526, ~cod_mesorregiao, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(media_renda = V6526)

# 4. Anos médios de estudo

media_estudo_por_uf <- svyby(~anest, ~cod_mesorregiao, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(media_anos_estudo = anest)

# 41. Idade em anos

media_idade_por_uf <- svyby(~V6036, ~cod_mesorregiao, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(media_idade = V6036)

# 5. Proporção de mulheres com 30 e 35 anos ou mais por UF
proporcao_mais_30 <- svyby(~idade_30_mais, ~cod_mesorregiao, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(prop_mais_30 = idade_30_mais)
proporcao_mais_35 <- svyby(~idade_35_mais, ~cod_mesorregiao, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(prop_mais_35 = idade_35_mais)

# 6. Proporção de mulheres em área urbana por UF (V1006 == 1)
#proporcao_urbana <- svyby(~urbana, ~cod_mesorregiao, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
#  rename(prop_urbana = urbana)

# População total de funcionárias públicas por UF
populacao_total <- svyby(~V0010, ~cod_mesorregiao, mulheres_func_pub_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(total_func_pub = V0010)

# ---------- Educação ----------
educacao <- subset(mulheres_func_pub, sub_grupo_cnae == "educacao")
educacao_aux <- svydesign(ids = ~1, weights = ~V0010, data = educacao)

pop_educ <- svyby(~V0010, ~cod_mesorregiao, educacao_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_educacao = V0010)

prop_educ <- left_join(pop_educ, populacao_total, by = "cod_mesorregiao") %>%
  mutate(prop_educacao = qtd_educacao / total_func_pub) %>%
  select(cod_mesorregiao, prop_educacao)

# ---------- Saúde ----------
saude <- subset(mulheres_func_pub, sub_grupo_cnae == "saude")
saude_aux <- svydesign(ids = ~1, weights = ~V0010, data = saude)

pop_saude <- svyby(~V0010, ~cod_mesorregiao, saude_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_saude = V0010)

prop_saude <- left_join(pop_saude, populacao_total, by = "cod_mesorregiao") %>%
  mutate(prop_saude = qtd_saude / total_func_pub) %>%
  select(cod_mesorregiao, prop_saude)

# ---------- Administração ----------
adm <- subset(mulheres_func_pub, sub_grupo_cnae == "adm_e_gestao_publica")
adm_aux <- svydesign(ids = ~1, weights = ~V0010, data = adm)

pop_adm <- svyby(~V0010, ~cod_mesorregiao, adm_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_adm = V0010)

prop_adm <- left_join(pop_adm, populacao_total, by = "cod_mesorregiao") %>%
  mutate(prop_administracao = qtd_adm / total_func_pub) %>%
  select(cod_mesorregiao, prop_administracao)

# ---------- Proporcao etnia ----------
mix_raca <- subset(mulheres_func_pub, V0606 %in% c("Preta", "Parda"))
mix_raca_aux <- svydesign(ids = ~1, weights = ~V0010, data = mix_raca)

pop_mix_raca <- svyby(~V0010, ~cod_mesorregiao, mix_raca_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_mx_raca = V0010)

proporcao_mix_raca <- left_join(pop_mix_raca, populacao_total, by = "cod_mesorregiao") %>%
  mutate(prop_mix_raca = qtd_mx_raca / total_func_pub) %>%
  select(cod_mesorregiao, prop_mix_raca)

# ---------- Curso mais evevado que frequentou ----------

curso_elevado <- subset(mulheres_func_pub, V0633 %in% c("Especialização de nível superior ( mínimo de 360 horas )",
                                                       "Superior de graduação","Mestrado","Doutorado" ))
curso_elevado_aux <- svydesign(ids = ~1, weights = ~V0010, data = curso_elevado)

pop_curso_elevado <- svyby(~V0010, ~cod_mesorregiao, curso_elevado_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_mx_raca = V0010)

proporcao_pop_curso_elevado <- left_join(pop_curso_elevado, populacao_total, by = "cod_mesorregiao") %>%
  mutate(prop_curso_elevado = qtd_mx_raca / total_func_pub) %>%
  select(cod_mesorregiao, prop_curso_elevado)

# ---------- Mulheres sem filhos ----------

sem_filhos <- subset(mulheres_func_pub, V6633 %in% c(0) & V6036 >= 40)
sem_filhos_aux <- svydesign(ids = ~1, weights = ~V0010, data = sem_filhos)

pop_sem_filhos <- svyby(~V0010, ~cod_mesorregiao, sem_filhos_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_mx_raca = V0010)

proporcao_sem_filhos <- left_join(pop_sem_filhos, populacao_total, by = "cod_mesorregiao") %>%
  mutate(prop_sem_filhos = qtd_mx_raca / total_func_pub) %>%
  select(cod_mesorregiao, prop_sem_filhos)

# 7. Juntar tudo em um único dataframe fina


df_contexto_uf <- populacao_por_uf %>%
  left_join(tft_resultados, by = "cod_mesorregiao") %>%
  left_join(filhos_nascidos_por_uf %>% select(cod_mesorregiao, soma_filhos_nascidos), by = "cod_mesorregiao") %>%
  left_join(nascidos_12m_por_uf %>% select(cod_mesorregiao, soma_nascidos_12m), by = "cod_mesorregiao") %>%
  left_join(media_estudo_por_uf %>% select(cod_mesorregiao, media_anos_estudo), by = "cod_mesorregiao") %>%
  left_join(media_renda_por_uf %>% select(cod_mesorregiao, media_renda), by = "cod_mesorregiao") %>%
  left_join(proporcao_mais_30 %>% select(cod_mesorregiao,prop_mais_30), by = "cod_mesorregiao") %>%
  left_join(proporcao_mais_35 %>% select(cod_mesorregiao,prop_mais_35), by = "cod_mesorregiao") %>%
  #left_join(proporcao_urbana %>% select(cod_mesorregiao,prop_urbana), by = "cod_mesorregiao") %>%
  left_join(df_tef_resumo %>% select(cod_mesorregiao, TFT_periodo, idade_media_fec)) %>%
  left_join(df_tef_resumo %>% select(cod_mesorregiao, idade_media_coorte)) %>%   # ⭐ NOVA LINHA AQUI ⭐
  left_join(media_idade_por_uf %>% select (cod_mesorregiao,media_idade)) %>%
  left_join(prop_educ, by = "cod_mesorregiao") %>%
  left_join(prop_saude, by = "cod_mesorregiao") %>%
  left_join(prop_adm, by = "cod_mesorregiao")%>%
  left_join(proporcao_mix_raca, by="cod_mesorregiao")%>%
  left_join(proporcao_pop_curso_elevado,by="cod_mesorregiao")%>%
  left_join(proporcao_sem_filhos,by="cod_mesorregiao")


# Visualizar resultado
print(df_contexto_uf)


#######################################################
############## MODELO
#######################################################


###### correlaçao
vars <- df_contexto_uf %>%
  select(
    idade_media_fec,
    idade_media_coorte,
    media_anos_estudo,
    prop_mais_35,
    prop_sem_filhos,
    prop_saude,
    prop_educacao,
    prop_administracao,
    media_renda,
    prop_mix_raca
  ) %>%
  rename(
    "IMF" = idade_media_fec,
    "IMPF"  = idade_media_coorte,
    "Média escolaridade"             = media_anos_estudo,
    "% 35+ anos"      = prop_mais_35,
    "% 40+ sem filhos"               = prop_sem_filhos,
    "% área saúde"                 = prop_saude,
    "% área educação"              = prop_educacao,
    "% área administração"         = prop_administracao,
    "Renda média"                         = media_renda,
    "% pretas/pardas"            = prop_mix_raca
  )

cor(vars, use = "pairwise.complete.obs")

library(corrplot)

corrplot(
  cor(vars, use = "pairwise.complete.obs"),
  method = "color",          # cores nos quadrados
  type   = "upper",
  tl.col = "black",
  tl.cex = 0.8,
  addCoef.col = "black",     # ← adiciona os números dentro das caixas
  number.cex = 0.7,          # tamanho dos números
  diag = FALSE               # oculta diagonal, se quiser
)



################################################
################################################
##### Modelo TFT de período

library(car)

lm_aux <- lm(
  TFT_periodo ~ idade_media_fec+media_anos_estudo + prop_mais_35 +
    prop_saude + prop_educacao+prop_mix_raca,
  data = df_contexto_uf
)

vif(lm_aux)

model1 <-'
  idade_media_fec ~ media_anos_estudo 
  TFT_periodo ~ idade_media_fec + media_anos_estudo + prop_mais_35 +prop_mix_raca + prop_saude + 
  prop_educacao
'
labels2 <- c(idade_media_fec = "Idade média à fecundidade",
             media_anos_estudo = "Média anos estudo",
             #TFT_coorte = "TFT Coorte", 
             TFT_periodo = "TFT Período", 
             prop_mais_35 = "% 35 anos ou mais",
             # media_idade = "Média Idade",
             prop_educacao = "% área educação",
             prop_saude = "% área saúde",
             # media_renda = "Renda média",
             prop_mix_raca = "% Pretas/Pardas"
             )

model1.fit <- sem(model1, data = df_contexto_uf) 
summary(model1.fit, rsq = TRUE, fit.measures = TRUE, standardized = TRUE,std.nox=TRUE) 
summary(model1, std.nox=TRUE, rsquare=TRUE)
lavaanPlot(name = "model1", 
           model1.fit, 
           coefs="TRUE",
           stars = "regress",
           sig = .1,
           stand=TRUE,
           edge_options = list(color = "red"),
           labels=labels2,
           #graph_options = list(rankdir = "BT"),
           node_options = list(shape = "box", fontname = "Helvetica"))



################################################
################################################
##### Modelo TFT de coorte
library(car)

lm_aux <- lm(
  TFT_coorte ~ idade_media_coorte + media_anos_estudo + prop_mais_35  + prop_saude + 
    prop_educacao +prop_mix_raca
  ,data = df_contexto_uf
)

vif(lm_aux)

model1 <-'
  idade_media_coorte ~ media_anos_estudo 
  TFT_coorte ~ idade_media_coorte + media_anos_estudo + prop_mais_35 + prop_mix_raca + prop_saude + 
  prop_educacao  
'
labels2 <- c(idade_media_coorte = "Idade média ao primeiro filho",
             media_anos_estudo = "Média anos estudo",
             TFT_coorte = "TFT Coorte", 
             prop_mais_35 = "% 35 anos ou mais",
             #media_idade = "Média Idade",
             prop_educacao = "% área educação",
             prop_saude = "% área saúde",
             # media_renda = "Renda média"
             prop_mix_raca = "% Pretas/Pardas"
             )



model1.fit <- sem(model1, data = df_contexto_uf) 
summary(model1.fit, rsq = TRUE, fit.measures = TRUE, standardized = TRUE,std.nox=TRUE) 
summary(model1, std.nox=TRUE, rsquare=TRUE)
lavaanPlot(name = "model1", 
           model1.fit, 
           coefs=TRUE,
           stars = "regress",
           sig = .1,
           stand=TRUE,
           edge_options = list(color = "blue"),
           labels=labels2,
           #graph_options = list(rankdir = "BT"),
           node_options = list(shape = "box", fontname = "Helvetica"))


################################################
################################################
##### Modelo prop sem filhos
df_contexto_uf$prop_sem_filhos_100 <- df_contexto_uf$prop_sem_filhos * 100

lm_aux <- lm(
  prop_sem_filhos_100 ~ idade_media_coorte + media_anos_estudo + prop_mais_35  + prop_saude + 
    prop_educacao +prop_mix_raca,
  data = df_contexto_uf
)

vif(lm_aux)



model1 <-'
  idade_media_coorte ~ media_anos_estudo 
  prop_sem_filhos_100 ~ idade_media_coorte + media_anos_estudo+prop_mais_35 + prop_mix_raca  + prop_saude + 
  prop_educacao  
'
labels2 <- c(idade_media_coorte = "Idade média ao primeiro filho",
             media_anos_estudo = "Média anos estudo",
             prop_sem_filhos_100 = "Proporção 40+ sem filhos", 
             prop_mais_35 = "% 35 anos ou mais",
             #media_idade = "Média Idade",
             prop_educacao = "% área educação",
             prop_saude = "% área saúde",
             # media_renda = "Renda média",
             prop_mix_raca = "% Pretas/Pardas"
)

model1.fit <- sem(model1, data = df_contexto_uf) 
summary(model1.fit, rsq = TRUE, fit.measures = TRUE, standardized = TRUE,std.nox=TRUE) 
summary(model1, std.nox=TRUE, rsquare=TRUE)
lavaanPlot(name = "model1", 
           model1.fit, 
           coefs="TRUE",
           stars = "regress",
           sig = .1,
           stand=TRUE,
           edge_options = list(color = "purple"),
           labels=labels2,
           #graph_options = list(rankdir = "BT"),
           node_options = list(shape = "box", fontname = "Helvetica"))


######################################################
### Descritiva
######################################################
## ocupadas
library(dplyr)
mulheres_2010 <- mulheres_2010 %>%
  mutate(flag_ocup = if_else(!is.na(V6930), "Ocupadas", "Desocupadas"))
mulheres_2000_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_2010)
svytable(~flag_ocup, design = mulheres_2000_aux)

##checando a var https://sidra.ibge.gov.br/tabela/3585
data.frame(svytable(~ocupacao_v2, design = mulheres_2000_aux))

## sem filhos
mulheres_2010 <- mulheres_2010 %>%
  mutate(flag_0filhos = if_else(V6633 == 0, "semfilho", "comfilho"))
mulheres_2010_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_2010)
svytable(~flag_ocup+flag_0filhos, design = mulheres_2010_aux)



svytable(~idade_categ+flag_0filhos+flag_ocup, design = mulheres_2010_aux)

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(
    V0606_num = dplyr::recode(
      V0606,
      "Branca"   = 1,
      "Preta"    = 2,
      "Amarela"  = 3,
      "Parda"    = 4,
      "Indígena" = 5
    )
  )


mulheres_func_pub <- mulheres_func_pub %>%
  mutate(V1006_num = dplyr::recode(V1006,
                            "Urbana" = 1,
                            "Rural" = 2))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(renda_cat = case_when(
    V6526 <= 1             ~ "<=1",
    V6526 > 1  & V6526 <= 2 ~ "<=2",
    V6526 > 2  & V6526 <= 4 ~ "<=4",
    V6526 > 4  & V6526 <= 7 ~ "<=7",
    V6526 > 7             ~ "8+",
    TRUE                  ~ NA_character_
  ))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(escolar_cat = case_when(
    anest >= 0  & anest <= 7  ~ "1.0-7anos",
    anest >= 8  & anest <= 11 ~ "2.8-11anos",
    anest >= 12               ~ "3.12+anos",
    TRUE ~ NA_character_
  ))

mulheres_func_pub_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_func_pub)

##somente para as funcionárias públicas
data.frame(svytable(~V1006_num  , design = mulheres_func_pub_aux))## situação domicílio
data.frame(svytable(~V0606_num , design = mulheres_func_pub_aux))## etnia
data.frame(svytable(~V1001 , design = mulheres_func_pub_aux))## regiao
data.frame(svytable(~renda_cat , design = mulheres_func_pub_aux))## renda
data.frame(svytable(~escolar_cat , design = mulheres_func_pub_aux))## estudo

##escolaridade
##TFT
svytable(~idade_categ+flag_nasc_12m+escolar_cat, design = mulheres_func_pub_aux)
svytable(~idade_categ+escolar_cat, design = mulheres_func_pub_aux)
##parturição
svytable(~filhos_ever_born+idade_categ+escolar_cat, design = mulheres_func_pub_aux)

## parturicao
svytable(~filhos_ever_born+idade_categ, design = mulheres_func_pub_aux)
svytable(~filhos_ever_born+idade_categ+flag_ocup, design = mulheres_2000_aux)

## idade media ao primeiro filho
## so um filho
mulheres_tot_1filho <- subset(mulheres_2010, V6633 == 1)
mulheres_tot_1filho_aux <- svydesign(ids = ~1, weights = ~V0010, data = mulheres_tot_1filho)
svytable(~idade_categ+flag_ocup, design = mulheres_tot_1filho_aux)
svytable(~idade_categ+flag_ocup, design = mulheres_2010_aux)

