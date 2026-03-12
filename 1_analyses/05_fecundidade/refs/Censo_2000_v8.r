# install from CRAN
install.packages("censobr")

# or use the development version with latest features
#utils::remove.packages('censobr')
#remotes::install_github("ipeaGIT/censobr", ref="dev")
library(censobr)
library(survey)
library(dplyr)
library(lavaan)
library(lavaanPlot)
library(piecewiseSEM)
library(tidyverse)
library(rjags)
library(jagsUI)
library(coda)
library(matrixStats)
library(pals)
library(ggplot2)
library(tidyr)
library(car)

df <- read_population(
  year = 2000,
  columns = NULL, ##se for null vem todas as colunas
  add_labels = NULL,
  as_data_frame = TRUE,
  showProgress = TRUE,
  cache = TRUE
)


mulheres_2000 <- subset(df, V0401 == '2' & V4752 >= 15 & V4752 <= 49)
rm(df) 
mulheres_2000$flag_nasc_12m <- ifelse(mulheres_2000$V4654>0,'0','1')#Total de filhos nascidos vivos


mulheres_2000 <- mulheres_2000 %>% filter(!is.na(PES_PESSOA))

# Open data dictionary on browser
data_dictionary(year = 2000, dataset = 'population', showProgress = TRUE, cache = TRUE)

# Adicionando a vari?vel ocupacao_v2 com base nas condi??es fornecidas
mulheres_2000$ocupacao_v2 <- 
  ifelse(mulheres_2000$V0447 == '8', 'sem_remuneracao',
         ifelse(mulheres_2000$V0447 == '9', 'proprio_consumo',
                ifelse(mulheres_2000$V0447 == '5', 'empregadores',
                       ifelse(mulheres_2000$V0447 == '6', 'conta_propria',
                              ifelse(mulheres_2000$V0447 == '1' | mulheres_2000$V0447 == '3', 'emprego_com_carteira',
                                     ifelse(mulheres_2000$V0447 == '2' | mulheres_2000$V0447 == '7', 'emprego_sem_carteira',
                                            ifelse(mulheres_2000$V0448 == '1' & mulheres_2000$V4452  %in% c('0100','0200','0300','0401','0402','0403','0411','0412','0413','0501','0502','0503','0511','0512','0513'), 'militar',
                                                   ifelse(mulheres_2000$V0448 == '1', 'funcionario_publico',
                                                          'emprego_sem_carteira'
                                                   ))))))))
#criando a ocupacao
# Criando a nova vari?vel ocupacao_v3 com base na ocupacao_v2 e V0450
mulheres_2000$ocupacao_v3 <- ifelse(
  mulheres_2000$ocupacao_v2 == 'militar',
  'militar',
  ifelse(
    mulheres_2000$ocupacao_v2 == 'funcionario_publico',
    'funcionario_publico',
    ifelse(
      mulheres_2000$ocupacao_v2 == 'empregadores' & mulheres_2000$V0450 == '1',
      'setor_privado_formal',
      ifelse(
        mulheres_2000$ocupacao_v2 == 'empregadores' & mulheres_2000$V0450 == '2',
        'informal',
        ifelse(
          mulheres_2000$ocupacao_v2 == 'conta_propria' & mulheres_2000$V0450 == '1',
          'setor_privado_formal',
          ifelse(
            mulheres_2000$ocupacao_v2 == 'conta_propria' & mulheres_2000$V0450 == '2',
            'informal',
            ifelse(
              mulheres_2000$ocupacao_v2 == 'emprego_com_carteira',
              'setor_privado_formal',
              ifelse(
                mulheres_2000$ocupacao_v2 == 'emprego_sem_carteira',
                'informal',
                ifelse(
                  mulheres_2000$ocupacao_v2 == 'proprio_consumo',
                  'proprio_consumo',
                  ifelse(mulheres_2000$ocupacao_v2 == 'sem_remuneracao','sem_remuneracao',
                         NA  # Adicionando NA como valor padr?o para casos n?o especificados
                  ))))))))))

# Código em R para transformar códigos CNAE em letras até Q
mulheres_2000$codigo_cnae_categ <- 
  ifelse(grepl("^(01|02)", mulheres_2000$V4462), "A", # Agricultura, pecuária, silvicultura e exploração florestal
         ifelse(grepl("^(05)", mulheres_2000$V4462), "B", # Pesca
                ifelse(grepl("^(10|11|12|13|14)", mulheres_2000$V4462), "C", # Indústrias extrativas
                       ifelse(grepl("^(15|16|17|18|19|20|21|22|23|24|25|26|27|28|29|30|31|32|33|34|35|36|37)", mulheres_2000$V4462), "D", # Indústrias de transformação
                              ifelse(grepl("^(40|41)", mulheres_2000$V4462), "E", # Eletricidade, gás e água
                                     ifelse(grepl("^(45)", mulheres_2000$V4462), "F", # Construção
                                            ifelse(grepl("^(50|51|52|53)", mulheres_2000$V4462), "G", # Comércio; reparação de veículos automotores, objetos pessoais e domésticos
                                                   ifelse(grepl("^(55)", mulheres_2000$V4462), "H", # Alojamento e alimentação
                                                          ifelse(grepl("^(60|61|62|63|64)", mulheres_2000$V4462), "I", # Transporte, armazenagem e comunica??es
                                                                 ifelse(grepl("^(65|66|67)", mulheres_2000$V4462), "J", # Intermediação financeira
                                                                        ifelse(grepl("^(70|71|72|73|74)", mulheres_2000$V4462), "K", # Atividades imobiliárias, aluguéis e serviços prestados às empresas
                                                                               ifelse(grepl("^(75)", mulheres_2000$V4462), "L", # Administração pública, defesa e seguridade social
                                                                                      ifelse(grepl("^(80)", mulheres_2000$V4462), "M", # Educação
                                                                                             ifelse(grepl("^(85)", mulheres_2000$V4462), "N", # Saúde e serviços sociais
                                                                                                    ifelse(grepl("^(90|91|92|93)", mulheres_2000$V4462), "O", # Outros serviços coletivos, sociais e pessoais
                                                                                                           ifelse(grepl("^(95)", mulheres_2000$V4462), "P", # Serviços domésticos
                                                                                                                  ifelse(grepl("^(99)", mulheres_2000$V4462), "Q", # Organismos internacionais e outras instituições extraterritoriais
                                                                                                                         ifelse(grepl("^(00)", mulheres_2000$V4462), "R",
                                                                                                                                "missing"))))))))))))))))))
codigos_cbo <- c(
  # Profissionais da Inform?tica
  "2121", "2122", "2123", "2124", "2125",
  
  # Profissionais da Informa??o e Comunica??o
  "2611", "2612", "2616", # Jornalismo e editora??o digital
  
  # Cientistas, Matem?ticos e Estat?sticos
  "2111", "2112",
  
  # Engenheiros e Arquitetos
  "2011", "2012", "2140", "2141", "2142", "2143", "2144", "2145", "2146", "2147", "2148", "2149",
  
  # F?sicos, Qu?micos e Afins
  "2131", "2132", "2133", "2134",
  
  # T?cnicos em Inform?tica
  "3171", "3172",
  
  # T?cnicos em Eletricidade, Eletr?nica e Telecomunica??es
  "3134", "3135", "3173", # Adi??o de t?cnicos em redes de computadores
  
  # T?cnicos em Ci?ncias F?sicas, Qu?micas e Engenharia
  "3111", "3112",
  
  # Profissionais de Marketing e Publicidade
  "2531", # Marketing digital e publicidade
  
  # Profissionais de Design e Produ??o Audiovisual
  "2621", "2622", "2624", "2625", # Design e produ??o digital
  
  # T?cnicos em Fot?nica e Automa??o
  "3137", "3152"
)


mulheres_2000$sub_grupo_cnae <- ifelse(mulheres_2000$codigo_cnae_categ %in% c("missing"), "missing",
                                       ifelse(mulheres_2000$codigo_cnae_categ %in% c("L"), "adm_e_gestao_publica",
                                              ifelse(mulheres_2000$codigo_cnae_categ %in% c("M"), "educacao",
                                                     ifelse(mulheres_2000$codigo_cnae_categ %in% c("N"), "saude",
                                                            #ifelse(grepl("^(64|72|73|74)", mulheres_2000$V4462) & mulheres_2000$V4452 %in% codigos_cbo, "tecnologia",
                                                                   "outras"))))

#se tiver informação de setor (func publica, sem carteira, ect), necessariamente tem valor na variavel do Cnae, mesmo que seja na categoria 'atividades nao especificadas'
dim(mulheres_2000[!is.na(mulheres_2000$V0447) & is.na(mulheres_2000$V4462), ])
# Adicionando a vari?vel sub_grupo_cnae com base nas letras de A a Q 
mulheres_2000$sub_grupo_cnae2 <- ifelse(mulheres_2000$codigo_cnae_categ %in% c("missing"), "missing",
                                        ifelse(mulheres_2000$codigo_cnae_categ %in% c("L"), "adm_e_gestao_publica"
                                               , ifelse(mulheres_2000$codigo_cnae_categ %in% c("M"), "educacao", 
                                                        ifelse(mulheres_2000$codigo_cnae_categ %in% c("N"), "saude", 
                                                               ifelse(mulheres_2000$codigo_cnae_categ %in% c("I", "K"), "tecnologia2",
                                                                      "outras"))))) 


# Criando os intervalos da idade
intervalos <- c(14, 19, 24, 29, 34, 39, 44, 49)
rotulos <- c("15-19", "20-24", "25-29", "30-34", "35-39", "40-44", "45-49")

mulheres_2000$V4752<-as.numeric(mulheres_2000$V4752)
# Criando a variável de categoria da dade da mulher
mulheres_2000$idade_categ <- cut(mulheres_2000$V4752, breaks = intervalos, 
                                 labels = rotulos, include.lowest = TRUE)
table(mulheres_2000$V4752)

## everborn flag
mulheres_2000$flag_ever_born <- ifelse(mulheres_2000$V4620>0,'1','0')#Total de filhos nascidos vivos
#mulheres_2000$flag_ever_born2 <- ifelse(mulheres_2000$V4690>0,'1','0')#Total de filhos nascidos 
#https://sidra.ibge.gov.br/tabela/2870#resultado -- que tiveram filhos
#https://sidra.ibge.gov.br/tabela/2571#resultado -- mulheres total

## criando a varuavel de ever born
# Definindo os intervalos para categoriza??o
int_filhos <- c(0, 1, 2, 3, 4, Inf)

# Criando a vari?vel categorizada
mulheres_2000$filhos_ever_born <- cut(mulheres_2000$V4620, breaks = int_filhos, labels = c("0", "1", "2", "3", "4+"), right = FALSE)
table(mulheres_2000$filhos_ever_born)

##filhos tidos nos ultmos 12 meses
mulheres_2000$flag_nasc_12m <- ifelse(mulheres_2000$V4654>0,'0','1')#Total de filhos nascidos vivos

table(mulheres_2000$V4752)
#V0464 - Sexo do ?ltimo filho nascido vivo

#categorizando a escolaridade
mulheres_2000$categoria_educacao <- with(mulheres_2000, ifelse(is.na(V0432),'-1.Seminformação',
                                                               ifelse(V0432 %in% c(1, 2, 3, 4, 5) | (V0432 == 6 & V0434 == 2) | V0432 == 9, '1.até_médio_incompleto',
                                                                      ifelse((V0432 == 6 & V0434 == 1) | (V0432 == 7 & V0434 == 2), '2.até_superior_incompleto',
                                                                             ifelse((V0432 == 7 & V0434 == 1) | V0432 == 8,
                                                                                    '3.Superior_completo', NA)))))

mulheres_2000$categorias_salarios <- ifelse(is.na(mulheres_2000$V4514), "-1.Seminformação",
                                            ifelse(mulheres_2000$V4514 == 0, "0",
                                                   ifelse(mulheres_2000$V4514 <= 1, "1.Até1",
                                                          ifelse(mulheres_2000$V4514 <= 3, "2.De2a3",
                                                                 ifelse(mulheres_2000$V4514 <= 5, "3.De4a5",
                                                                        "4.Acimade5")))))

################################################################
########### SOMENTE FUNCIONARIAS PUBLICAS v2 ######################
################################################################

mulheres_func_pub <- subset(mulheres_2000, ocupacao_v3 == 'funcionario_publico')

# Flag 1 se funcionária pública, 0 c.c.
mulheres_func_pub <- mulheres_func_pub %>%
  mutate(func_pub = ifelse(ocupacao_v3 == "funcionario_publico", 1, 0))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(idade_30_mais = ifelse(V4752 >=30, 1, 0))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(idade_35_mais = ifelse(V4752 >=35, 1, 0))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(urbana = ifelse(V1006 == 1, 1, 0))

mulheres_func_pub <-mulheres_func_pub %>%
  mutate(
    flag_nasc_12m = as.numeric(as.character(flag_nasc_12m))
  )

# Criar objeto de desenho amostral
mulheres_func_pub_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_func_pub)

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
mulheres_1filho <- subset(mulheres_func_pub, V4620 == 1)
mulheres_1filho_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_1filho)
data.frame(svytable(~idade_categ , design = mulheres_1filho_aux))
svytable(~idade_categ+sub_grupo_cnae , design = mulheres_1filho_aux)
svytable(~idade_categ+sub_grupo_cnae,design = mulheres_func_pub_aux)#total de mulheres por grupo cnae

## proporcao de sem filhos
svytable(~idade_categ , design = mulheres_func_pub_aux)
## sem filhos - childless
mulheres_0filho <- subset(mulheres_func_pub, V4620 == 0)
mulheres_0filho_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_0filho)
data.frame(svytable(~idade_categ , design = mulheres_0filho_aux))
svytable(~idade_categ+sub_grupo_cnae , design = mulheres_0filho_aux)
svytable(~idade_categ+sub_grupo_cnae,design = mulheres_func_pub_aux)#total de mulheres por grupo cnae

## parturição
svytable(~filhos_ever_born+idade_categ, design = mulheres_func_pub_aux)
svytable(~filhos_ever_born+idade_categ+sub_grupo_cnae, design = mulheres_func_pub_aux)

###############################################################################
########### VARIÁVEL RESPOSTA (TFT) - Considerando apenas Funcionárias públicas
###############################################################################

##################################################################
################## TFT Coorte -- somente funcionárias públicas

mulheres_func_pub_4549 <- subset(mulheres_func_pub, idade_categ == "45-49") 
mulheres_func_pub_4549_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_func_pub_4549)

ufs <- sort(unique(mulheres_func_pub_4549$V1002))
tft_resultados <- data.frame()

for (uf in ufs) {
  tabela <- mulheres_func_pub_4549 %>%
    filter(V1002 == uf) %>%
    group_by(filhos_ever_born) %>%
    summarise(qtd_mulheres = sum(PES_PESSOA, na.rm = TRUE)) %>%
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
  
  tft_resultados <- bind_rows(tft_resultados, data.frame(V1002 = uf, TFT_coorte = tft))
}

##################################################################
################## TFT Período -- somente funcionárias públicas
library(dplyr)
library(survey)

# 1. Ponto médio por faixa etária
ponto_medio <- c(
  "15-19" = 17.5, "20-24" = 22.5, "25-29" = 27.5,
  "30-34" = 32.5, "35-39" = 37.5, "40-44" = 42.5, "45-49" = 47.5
)

# Criar variável auxiliar
mulheres_func_pub$one <- 1

# 2. Subconjunto para TFT de coorte (mulheres 45–49)
mulheres_func_pub_4549 <- subset(mulheres_func_pub, idade_categ == "45-49") 
ufs <- sort(unique(mulheres_func_pub_4549$V1002))

# 3. Inicializar listas
resultado_lista <- list()

# 4. Loop por UF
for (uf in ufs) {
  cat("\n==================== UF:", uf, "====================\n")
  
  ## -------- TFT COORTE --------
  coorte_tab <- mulheres_func_pub_4549 %>%
    filter(V1002 == uf) %>%
    group_by(filhos_ever_born) %>%
    summarise(qtd_mulheres = sum(PES_PESSOA, na.rm = TRUE)) %>%
    arrange(filhos_ever_born) %>%
    mutate(
      acumulado = rev(cumsum(rev(qtd_mulheres))),
      razao_parturicao = lead(acumulado) / acumulado
    )
  
  r <- coorte_tab$razao_parturicao[1:4]
  tft_coorte <- round(r[1] + r[1]*r[2] + r[1]*r[2]*r[3] + r[1]*r[2]*r[3]*r[4], 2)
  cat("TFT coorte:", tft_coorte, "\n")
  
  ## -------- BASE E DESIGNS --------
  dados_uf <- subset(mulheres_func_pub, V1002 == uf)
  design_uf <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = dados_uf)
  
  ## -------- IDADE MÉDIA À FECUNDIDADE (12m) --------
  total_mulheres <- svyby(~one, ~idade_categ, design_uf, svytotal, na.rm = TRUE)
  names(total_mulheres)[2] <- "total_mulheres"
  
  dados_nasc_12m <- subset(dados_uf, flag_nasc_12m == 1)
  design_nasc_12m <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = dados_nasc_12m)
  
  nascidos_12m <- svyby(~one, ~idade_categ, design_nasc_12m, svytotal, na.rm = TRUE)
  names(nascidos_12m)[2] <- "nasc_12m"
  
  tabela_fec <- left_join(nascidos_12m, total_mulheres, by = "idade_categ") %>%
    mutate(
      TEF = nasc_12m / total_mulheres,
      ponto_medio = ponto_medio[as.character(idade_categ)],
      idade_media_parte = TEF * ponto_medio
    )
  
  idade_media_fec <- round(
    sum(tabela_fec$idade_media_parte, na.rm = TRUE) / 
      sum(tabela_fec$TEF, na.rm = TRUE), 1)
  
  tft_periodo <- round(sum(tabela_fec$TEF, na.rm = TRUE), 2)
  
  cat("Idade média fec (12m):", idade_media_fec, "\n")
  cat("TFT período:", tft_periodo, "\n")
  
  ## -------- IDADE MÉDIA DE COORTE (PARIDADE 1) --------
  design_1filho <- subset(design_uf, V4620 == 1)
  um_filho_tab  <- svytable(~idade_categ, design_1filho)
  um_filho_df   <- as.data.frame(um_filho_tab)
  names(um_filho_df) <- c("idade_categ", "n_1filho")
  
  total_tab <- total_mulheres %>% select(idade_categ, total_mulheres)
  
  tabela_coorte <- left_join(um_filho_df, total_tab, by = "idade_categ") %>%
    mutate(
      TEF = n_1filho / total_mulheres,
      ponto_medio = ponto_medio[as.character(idade_categ)],
      idade_media_parte = TEF * ponto_medio
    )
  
  idade_media_coorte <- round(
    sum(tabela_coorte$idade_media_parte, na.rm = TRUE) / 
      sum(tabela_coorte$TEF, na.rm = TRUE), 1)
  
  cat("Idade média coorte:", idade_media_coorte, "\n")
  
  ## -------- SALVAR RESULTADO --------
  resultado_lista[[as.character(uf)]] <- data.frame(
    V1002 = uf,
    TFT_coorte = tft_coorte,
    TFT_periodo = tft_periodo,
    idade_media_fec = idade_media_fec,
    idade_media_coorte = idade_media_coorte
  )
}

# 5. Resultado final
df_tef_resumo <- bind_rows(resultado_lista)
cat("\n\n===== TABELA FINAL POR UF =====\n")
print(df_tef_resumo)


##################################################################################
########### COVARIÁVEIS - Considerando todas as mulheres ocupadas de 45 a 49 anos
##################################################################################

mulheres_func_pub <-mulheres_func_pub %>%
  mutate(
    #anos_estudo = as.numeric(as.character(V4300)),
    #anos_estudo = ifelse(anos_estudo %in% c(20, 30), -1, anos_estudo),
    flag_nasc_12m = as.numeric(as.character(flag_nasc_12m))
  )

#### ESCOLARIDADE EM CONTÍNUA

mulheres_func_pub$V0429 <- as.numeric(mulheres_func_pub$V0429)
mulheres_func_pub$V0430 <- as.numeric(mulheres_func_pub$V0430)
mulheres_func_pub$V0431 <- as.numeric(mulheres_func_pub$V0431)
mulheres_func_pub$V0432 <- as.numeric(mulheres_func_pub$V0432)
mulheres_func_pub$V0433 <- as.numeric(mulheres_func_pub$V0433)


# Criar a variável 'anest' (anos de estudo) em 'mulheres_func_pub'
mulheres_func_pub <- mulheres_func_pub %>%
  mutate(
    anest = case_when(
      # Anos de estudo = 0
      (V0430 %in% c(1, 2, 3, 4)) | (V0432 == 1 | V0432 == 9) | (V0429 == 4) | 
        ((V0430 %in% c(5, 6, 7)) & V0431 == 1) ~ 0,
      
      # Anos de estudo = 1
      ((V0430 %in% c(5, 6, 7)) & V0431 == 2) | ((V0432 == 2 | V0432 == 5) & V0433 == 1) ~ 1,
      
      # Anos de estudo = 2
      ((V0430 %in% c(5, 6, 7)) & V0431 == 3) | ((V0432 == 2 | V0432 == 5) & V0433 == 2) ~ 2,
      
      # Anos de estudo = 3
      ((V0430 %in% c(5, 6, 7)) & V0431 == 4) | ((V0432 == 2 | V0432 == 5) & V0433 == 3) ~ 3,
      
      # Anos de estudo = 4
      ((V0430 %in% c(5, 6, 7)) & V0431 == 5) | 
        ((V0432 == 2 & V0433 >= 4 & V0433 < 9) | (V0432 == 5 & V0433 == 4)) ~ 4,
      
      # Anos de estudo = 5
      ((V0430 %in% c(5, 6, 7)) & V0431 == 6) | (V0432 == 3 & V0433 == 1) | (V0432 == 5 & V0433 == 5) ~ 5,
      
      # Anos de estudo = 6
      ((V0430 %in% c(5, 6, 7)) & V0431 == 7) | (V0432 == 3 & V0433 == 2) | (V0432 == 5 & V0433 == 6) ~ 6,
      
      # Anos de estudo = 7
      ((V0430 %in% c(5, 6, 7)) & V0431 == 8) | (V0432 == 3 & V0433 == 3) | (V0432 == 5 & V0433 == 7) ~ 7,
      
      # Anos de estudo = 8
      ((V0430 %in% c(8, 9, 10)) & V0431 == 1) | (V0432 == 3 & V0433 >= 4 & V0433 < 9) | 
        (V0432 == 5 & V0433 == 8) | ((V0430 %in% c(9, 10)) & V0431 == 9) | (V0432 == 6 & V0433 == 9) ~ 8,
      
      # Anos de estudo = 9
      ((V0430 %in% c(8, 9, 10)) & V0431 == 2) | ((V0432 == 4 | V0432 == 6) & V0433 == 1) ~ 9,
      
      # Anos de estudo = 10
      ((V0430 %in% c(8, 9, 10)) & (V0431 >= 3 & V0431 < 9)) | ((V0432 == 4 | V0432 == 6) & V0433 == 2) ~ 10,
      
      # Anos de estudo = 11
      (V0430 == 11) | (V0430 == 12 & V0431 == 1) | ((V0432 == 4 | V0432 == 6) & (V0433 >= 3 & V0433 < 9)) ~ 11,
      
      # Anos de estudo = 12
      (V0430 == 12 & V0431 == 2) | (V0432 == 7 & V0433 == 1) ~ 12,
      
      # Anos de estudo = 13
      (V0430 == 12 & V0431 == 3) | (V0432 == 7 & V0433 == 2) ~ 13,
      
      # Anos de estudo = 14
      (V0430 == 12 & V0431 >= 4 & V0431 < 9) | (V0432 == 7 & V0433 == 3) ~ 14,
      
      # Anos de estudo = 15
      ((V0432 == 7 & V0433 >= 4 & V0433 < 9) | (V0430 == 13)) ~ 15,
      
      # Anos de estudo = 16
      (V0432 == 8) ~ 16,
      
      # complementando
      (V0430 %in% c(6,7)) ~ 8,
      (V0432 == 5 & V0434 == 1) ~ 8,
      (V0432 == 5 & V0434 == 2) ~ 6,
      
      # Caso não se encaixe em nenhuma condição, mantém como NA
      TRUE ~ NA_integer_
    )
  )


mulheres_func_pub_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_func_pub)
table(mulheres_func_pub$anest, useNA = "always")
#######################################################
#######################################################

# 1. População total por UF (contagem ponderada de pessoas
populacao_por_uf <- as.data.frame(svytable(~V1002, design = mulheres_func_pub_aux))
colnames(populacao_por_uf) <- c("V1002", "soma_populacao")

# 2. Soma de filhos nascidos vivos (V4620) por UF
filhos_nascidos_por_uf <- svyby(~V4620, ~V1002, mulheres_func_pub_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(soma_filhos_nascidos = V4620)

# 3. Soma de nascidos nos últimos 12 meses por UF (flag_nasc_12m)
nascidos_12m_por_uf <- svyby(~flag_nasc_12m, ~V1002, mulheres_func_pub_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(soma_nascidos_12m = flag_nasc_12m)

# 4. Média de renda (V4526) por UF
media_renda_por_uf <- svyby(~V4526, ~V1002, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(media_renda = V4526)

# 4. Anos médios de estudo

media_estudo_por_uf <- svyby(~anest, ~V1002, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(media_anos_estudo = anest)

# 41. Idade em anos

media_idade_por_uf <- svyby(~V4752, ~V1002, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(media_idade = V4752)


# 5. Proporção de mulheres com 30 e 35 anos ou mais por UF
proporcao_mais_30 <- svyby(~idade_30_mais, ~V1002, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(prop_mais_30 = idade_30_mais)
proporcao_mais_35 <- svyby(~idade_35_mais, ~V1002, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(prop_mais_35 = idade_35_mais)

# 6. Proporção de mulheres em área urbana por UF (V1006 == 1)
proporcao_urbana <- svyby(~urbana, ~V1002, mulheres_func_pub_aux, svymean, na.rm = TRUE, se = FALSE) %>%
  rename(prop_urbana = urbana)

# População total de funcionárias públicas por UF
populacao_total <- svyby(~PES_PESSOA, ~V1002, mulheres_func_pub_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(total_func_pub = PES_PESSOA)

# ---------- Educação ----------
educacao <- subset(mulheres_func_pub, sub_grupo_cnae == "educacao")
educacao_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = educacao)

pop_educ <- svyby(~PES_PESSOA, ~V1002, educacao_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_educacao = PES_PESSOA)

prop_educ <- left_join(pop_educ, populacao_total, by = "V1002") %>%
  mutate(prop_educacao = qtd_educacao / total_func_pub) %>%
  select(V1002, prop_educacao)

# ---------- Saúde ----------
saude <- subset(mulheres_func_pub, sub_grupo_cnae == "saude")
saude_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = saude)

pop_saude <- svyby(~PES_PESSOA, ~V1002, saude_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_saude = PES_PESSOA)

prop_saude <- left_join(pop_saude, populacao_total, by = "V1002") %>%
  mutate(prop_saude = qtd_saude / total_func_pub) %>%
  select(V1002, prop_saude)

# ---------- Administração ----------
adm <- subset(mulheres_func_pub, sub_grupo_cnae == "adm_e_gestao_publica")
adm_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = adm)

pop_adm <- svyby(~PES_PESSOA, ~V1002, adm_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_adm = PES_PESSOA)

prop_adm <- left_join(pop_adm, populacao_total, by = "V1002") %>%
  mutate(prop_administracao = qtd_adm / total_func_pub) %>%
  select(V1002, prop_administracao)

# ---------- Proporcao etnia ----------
mix_raca <- subset(mulheres_func_pub, V0408 %in% c(2, 4))
mix_raca_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mix_raca)

pop_mix_raca <- svyby(~PES_PESSOA, ~V1002, mix_raca_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_mx_raca = PES_PESSOA)

proporcao_mix_raca <- left_join(pop_mix_raca, populacao_total, by = "V1002") %>%
  mutate(prop_mix_raca = qtd_mx_raca / total_func_pub) %>%
  select(V1002, prop_mix_raca)


# ---------- Curso mais evevado que frequentou ----------

curso_elevado <- subset(mulheres_func_pub, V0432 %in% c(7,8))
curso_elevado_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = curso_elevado)

pop_curso_elevado <- svyby(~PES_PESSOA, ~V1002, curso_elevado_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_mx_raca = PES_PESSOA)

proporcao_pop_curso_elevado <- left_join(pop_curso_elevado, populacao_total, by = "V1002") %>%
  mutate(prop_curso_elevado = qtd_mx_raca / total_func_pub) %>%
  select(V1002, prop_curso_elevado)

# ---------- Mulheres sem filhos ----------

sem_filhos <- subset(mulheres_func_pub, V4620 %in% c(0) & V4752>= 40)
sem_filhos_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = sem_filhos)

pop_sem_filhos <- svyby(~PES_PESSOA, ~V1002, sem_filhos_aux, svytotal, na.rm = TRUE, se = FALSE) %>%
  rename(qtd_mx_raca = PES_PESSOA)

proporcao_sem_filhos <- left_join(pop_sem_filhos, populacao_total, by = "V1002") %>%
  mutate(prop_sem_filhos = qtd_mx_raca / total_func_pub) %>%
  select(V1002, prop_sem_filhos)

df_tef_resumo
# 7. Juntar tudo em um único dataframe fina
df_contexto_uf <- populacao_por_uf %>%
  left_join(tft_resultados, by = "V1002") %>%
  left_join(filhos_nascidos_por_uf %>% select(V1002, soma_filhos_nascidos), by = "V1002") %>%
  left_join(nascidos_12m_por_uf %>% select(V1002, soma_nascidos_12m), by = "V1002") %>%
  left_join(media_estudo_por_uf %>% select(V1002, media_anos_estudo), by = "V1002") %>%
  left_join(media_renda_por_uf %>% select(V1002, media_renda), by = "V1002") %>%
  left_join(proporcao_mais_30 %>% select(V1002,prop_mais_30), by = "V1002") %>%
  left_join(proporcao_mais_35 %>% select(V1002,prop_mais_35), by = "V1002") %>%
  left_join(proporcao_urbana %>% select(V1002,prop_urbana), by = "V1002") %>%
  left_join(df_tef_resumo %>% select(V1002, TFT_periodo, idade_media_fec)) %>%
  left_join(df_tef_resumo %>% select(V1002, idade_media_coorte)) %>%   # ⭐ NOVA LINHA AQUI ⭐
  left_join(media_idade_por_uf %>% select (V1002,media_idade)) %>%
  left_join(prop_educ, by = "V1002") %>%
  left_join(prop_saude, by = "V1002") %>%
  left_join(prop_adm, by = "V1002") %>%
  left_join(proporcao_mix_raca, by="V1002")%>%
  left_join(proporcao_pop_curso_elevado,by="V1002")%>%
  left_join(proporcao_sem_filhos,by="V1002")


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
  TFT_periodo ~ idade_media_fec+media_anos_estudo  +
    prop_saude + prop_educacao + prop_mais_35 +prop_mix_raca,
  data = df_contexto_uf
)

vif(lm_aux)

#prop_mais_35_100 <- prop_mais_35*100
#prop_mix_raca_100 <- prop_mix_raca*100
#prop_saude_100 <- prop_saude*100
#prop_educacao_100 <- prop_educacao*100

model1 <-'
  idade_media_fec ~ media_anos_estudo 
  TFT_periodo ~ idade_media_fec + media_anos_estudo + prop_mais_35 + prop_mix_raca + prop_saude + 
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

lm_aux <- lm(
  TFT_coorte ~ idade_media_coorte+media_anos_estudo +
    prop_mais_35 +prop_mix_raca+prop_saude + prop_educacao,
  data = df_contexto_uf
)

vif(lm_aux)


model1 <-'
  idade_media_coorte ~ media_anos_estudo 
  TFT_coorte ~ idade_media_coorte + media_anos_estudo  +prop_mais_35 +prop_mix_raca+ prop_saude + 
  prop_educacao 
'
labels2 <- c(idade_media_coorte = "Idade média ao primeiro filho",
             media_anos_estudo = "Média anos estudo",
             TFT_coorte = "TFT Coorte", 
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
           edge_options = list(color = "blue"),
           labels=labels2,
           #graph_options = list(rankdir = "BT"),
           node_options = list(shape = "box", fontname = "Helvetica"))



################################################
################################################
##### Modelo prop sem filhos
df_contexto_uf$prop_sem_filhos_100 <- df_contexto_uf$prop_sem_filhos * 100

lm_aux <- lm(
  prop_sem_filhos_100 ~ idade_media_coorte + media_anos_estudo+prop_mais_35 + prop_mix_raca  + prop_saude + 
    prop_educacao  ,
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

# varTable(model1.fit)


######################################################
### Descritiva
######################################################

## ocupadas
library(dplyr)
mulheres_2000 <- mulheres_2000 %>%
  mutate(flag_ocup = if_else(!is.na(V0447), "Ocupadas", "Desocupadas"))
mulheres_2000_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_2000)
svytable(~flag_ocup, design = mulheres_2000_aux)

data.frame(svytable(~ocupacao_v2, design = mulheres_2000_aux))

## sem filhos
mulheres_2000 <- mulheres_2000 %>%
  mutate(flag_0filhos = if_else(V4620 == 0, "semfilho", "comfilho"))
mulheres_2000_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_2000)

svytable(~idade_categ+flag_0filhos+flag_ocup, design = mulheres_2000_aux)

svytable(~ocupacao_v2+flag_0filhos, design = mulheres_2000_aux)


mulheres_func_pub <- mulheres_func_pub %>%
  mutate(renda_cat = case_when(
    V4526 <= 1             ~ "<=1",
    V4526 > 1  & V4526 <= 2 ~ "<=2",
    V4526 > 2  & V4526 <= 4 ~ "<=4",
    V4526 > 4  & V4526 <= 7 ~ "<=7",
    V4526 > 7             ~ "8+",
    TRUE                  ~ NA_character_
  ))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(escolar_cat = case_when(
    anest >= 0  & anest <= 7  ~ "1.0-7anos",
    anest >= 8  & anest <= 11 ~ "2.8-11anos",
    anest >= 12               ~ "3.12+anos",
    TRUE ~ NA_character_
  ))

mulheres_func_pub <- mulheres_func_pub %>%
  mutate(
    curso_elevado_cat = case_when(
      V0432 %in% c(7, 8) ~ "gradu-mest-doc",     # graduação, mestrado, doutorado
      V0432 %in% c("", " ", NA) ~ NA_character_, # mantém NA se vier vazio/NA
      TRUE ~ "menos-esc"                         # todos os demais (1–6, 9)
    )
  )


table(mulheres_func_pub$curso_elevado_cat)

mulheres_func_pub_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_func_pub)

##somente para as funcionárias públicas
data.frame(svytable(~V1006 , design = mulheres_func_pub_aux))## situação domicílio
data.frame(svytable(~V0408 , design = mulheres_func_pub_aux))## etnia
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
mulheres_tot_1filho <- subset(mulheres_2000, V4620 == 1)
mulheres_tot_1filho_aux <- svydesign(ids = ~1, weights = ~PES_PESSOA, data = mulheres_tot_1filho)
svytable(~idade_categ+flag_ocup, design = mulheres_tot_1filho_aux)
svytable(~idade_categ+flag_ocup, design = mulheres_2000_aux)


library(ggplot2)

ggplot(df_contexto_uf, aes(y = prop_sem_filhos)) +
  geom_boxplot(fill = "#56B4E9", color = "black", alpha = 0.7) +
  theme_minimal(base_size = 14) +
  labs(
    title = "Distribuição da proporção de mulheres sem filhos",
    y = "Proporção sem filhos",
    x = ""
  )


