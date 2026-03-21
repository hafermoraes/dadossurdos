
ARG_SUBGRP <- 'surdo'
ARG_ANO <- 2010
ARG_KEY <- 'gompertz_relacional_modificado'

ARG_OUTPUT_FILE <- fec_models_output_file
ARG_APPEND <- TRUE

ANALYSIS <- 'fec_GompertzRelMod_surdo_2010'

#############################################
#### Aula Gompertz Relacional modificado ####
#############################################
options(scipen=999)

### Vizualizacao dos dados ####
dado=read.table(
  # results/fec_dados_GompertzRelMod_surdo_2010.txt
  sep='\t',
  header=T,
  text="
Idade	Pi	TEF
10-14	NA	NA
15-19	0.13	0.044
20-24	0.558	0.076
25-29	1.056	0.069
30-34	1.593	0.049
35-39	1.653	0.023
40-44	1.7	0.01
45-49	2.266	0.001
NA	NA	1.36
")

## Retira TFT
dado=dado[-9,]

## Descricao dos dados ##### 
## Pi a parturicao media estimada 
## TEF fecundidade corrente estimada 
#####

### Valores padrao tabulado - Modificado pela Zaba ####
padrao=read.csv(sep=',',header=T,text="
grupos,Pp,grupos1,Fp_des,grupos2,Fp_semdes
10-14,0.0003,14.5,0.00128,15,0.00313
15-19,0.0522,19.5,0.11404,20,0.13584
20-24,0.2549,24.5,0.35277,25,0.37731
25-29,0.4957,29.5,0.58724,30,0.60861
30-34,0.7067,34.5,0.78001,35,0.79618
35-39,0.8681,39.5,0.9199,40,0.93019
40-44,0.9679,44.5,0.9893,45,0.99188
45-49,0.9977,49.5,0.999999,50,0.999999
50-54,1,,,,
")

### Para F(x), ou Pontos F

#####

### Estimando parametros graficos que serao utilizados na equacao da reta ####
#####

### e(x), g(x) e z(x) para F ####
### Para grupos etarios deslocados meio ano da data do censo
names(padrao)

## Selecionando idades e fatores multiplicativos
## Tornam o F equivalente a P
dat = padrao[-9, c('grupos1','Fp_des')]

## Fazendo o primeiro logito
dat$Ys.x = -log(-log(dat$Fp_des))

## Fx/Fx+5, razao de logitos de grupos adjacentes
dat$razao=NA
for(i in 1:7){dat$razao[i]=dat$Fp_des[i]/dat$Fp_des[i+1]}

## logito das razoes, chamei de phi. Utilizo mais a frente para encontrar e(x)
dat$Ys.xr = -log(-log(dat$razao))

## Encontrar parametros phi' e phi''
# phi'= (exp(Ys.x)*Ys.x+5)-Ys.x*exp(Ys.x+5))/(exp(Ys.x)-exp(Ys.x+5))

dat$phi.1 = NA
for(i in 1:7){dat$phi.1[i]=((exp(dat$Ys.x[i])*dat$Ys.x[i+1])-dat$Ys.x[i]*exp(dat$Ys.x[i+1]))/(exp(dat$Ys.x[i])-exp(dat$Ys.x[i+1]))}
## phi'= g(x)

# phi''= (Ys.x-Ys.x+5)^2*exp(Ys.x+Ys.x+5)/(exp(Ys.x)-exp(Ys.x+5))^2

## Valores constantes entre as idades 15 a 30 anos. A media deles produz o parametro c
## Para os grupos de 15 a 30 anos apenas
dat$phi.2=NA

for(i in 2:4){dat$phi.2[i]=((dat$Ys.x[i]-dat$Ys.x[i+1])^2*exp(dat$Ys.x[i]+dat$Ys.x[i+1]))/(exp(dat$Ys.x[i])-exp(dat$Ys.x[i+1]))^2}

mean(dat$phi.2, na.rm = T)
## Valor medio 0.9574986. Parametro usado para estimar alfa

## e(x) = Diferenca entre logito das razoes phi e phi' 
dat$ex = dat$Ys.xr - dat$phi.1

## Encontramos dois parametros, e(x) e g(x), falta apenas o z(x)

### Parametro z(x). Vem de dados observados

###############################
### Dados observados ##########
###############################

## Acumulado das taxas medias (Fx), e para o primeiro grupo = 0
dat$Fx=c(0,5*cumsum(na.omit(dado$TEF)))

## Retirando as razoes entre acumulados em x e x+5
dat$Fx_Fx5=NA

for(i in 1:7){dat$Fx_Fx5[i]=dat$Fx[i]/dat$Fx[i+1]}

## Estimando z(x), logito das razoes acumuladas
dat$zx=c(NA,(-log(-log(dat$Fx_Fx5[2:7]))),NA)
#####

#### Gerando os parametros graficos dos pontos F ####

### Subtraindo z(x) e e(x)
zx.ex = dat$zx - dat$ex

## g(x) = phi'
gx = dat$phi.1

## Resumo dos pontos F
PontsF = as.data.frame(cbind(idade=seq(14.5,49.5,5),gx,zx.ex))

## Grafico, lembrando os eixos, g(x) = X e z(x)-e(x) = Y

# #window(height = 15,width = 15)
# pdf(file = paste0(results_dir, ANALYSIS, '_PontosF.pdf'), width = 7, height = 4)
# plot(PontsF$gx[2:7],PontsF$zx.ex[2:7], pch=10, col='blue', xlab='g(x)', ylab='z(x)-e(x)', main='Pontos F')
# abline(lm(PontsF$zx.ex[2:7]~PontsF$gx[2:7]), col='blue', lwd=2)
# dev.off()
# #####

### Procedimento parecido P(i) => P(i)/P(i+1), os Pontos P ####
### e(i), g(i) e z(i)

### Sem deslocamento de grupos de idade
names(padrao)

## Selecionando idades e fatores
dat.p=padrao[-9,c('grupos','Pp')]

## Fazendo o primeiro logito
dat.p$Ys.i = -log(-log(dat.p$Pp))

## razoes entre Ps, Pi/Pi+1
dat.p$razao=NA
for(i in 1:7){dat.p$razao[i]=dat.p$Pp[i]/dat.p$Pp[i+1]}

## Para ultima idade, Pi/1
dat.p$razao[8] = dat.p$Pp[8]/1

## logito das razoes, phi
dat.p$Ys.ir = -log(-log(dat.p$razao))

# phi'= (exp(Ys.i)*Ys.i+1)-Ys.i*exp(Ys.i+1))/(exp(Ys.i)-exp(Ys.i+1))
dat.p$phi.1=NA
for(i in 1:7){dat.p$phi.1[i]=((exp(dat.p$Ys.i[i])*dat.p$Ys.i[i+1])-dat.p$Ys.i[i]*exp(dat.p$Ys.i[i+1]))/(exp(dat.p$Ys.i[i])-exp(dat.p$Ys.i[i+1]))}

## Para o ultimo repete o valor do ultimo logito
dat.p$phi.1[8] = dat.p$Ys.i[8]

## phi'= g(i)

# phi''= (Ys.i-Ys.i+1)^2*exp(Ys.i+Ys.i+1)/(exp(Ys.i)-exp(Ys.i+1))^2
## Entre as idades 15 a 30 anos. A media deles produz o parametro c
dat.p$phi.2=NA
for(i in 2:4){dat.p$phi.2[i]=((dat.p$Ys.i[i]-dat.p$Ys.i[i+1])^2*exp(dat.p$Ys.i[i]+dat.p$Ys.i[i+1]))/(exp(dat.p$Ys.i[i])-exp(dat.p$Ys.i[i+1]))^2}

mean(dat.p$phi.2, na.rm = T)

## e(i) = Diferenca entre logito das razoes (phi) e phi' 
dat.p$ei=dat.p$Ys.ir - dat.p$phi.1

### Para o grafico necessita dos pares z(i)-e(i) e g(i)

### Dados observados para encontra z(i)
## Retirando as razoes entres Ps, Pi e Pi+1
dat.p$Pi_Pi1=NA
for(i in 1:7){dat.p$Pi_Pi1[i]=dado$Pi[i]/dado$Pi[i+1]}

## Estimando z(i), logito das razoes Pi/Pi+1
dat.p$zi=c(NA,(-log(-log(dat.p$Pi_Pi1[2:7]))),NA)
#####

#### Gerando os parametros graficos dos pontos P ####

### Subtraindo z(i) e e(i)
zi.ei = dat.p$zi-dat.p$ei

## g(i)
gi = dat.p$phi.1

PontsP = as.data.frame(cbind(idade=seq(14.5,49.5,5),gi,zi.ei))

# ## Grafico, lembrando os eixos g(i) = X e z(i)-e(i) = Y
# pdf(file = paste0(results_dir, ANALYSIS, '_PontosP.pdf'), width = 7, height = 4)
# plot(PontsP$gi[2:6],PontsP$zi.ei[2:6], pch=10, col='red', xlab='g(i)', 
#      ylab='z(i)-e(i)', main='Pontos P')
# abline(lm(PontsP$zi.ei[2:6]~PontsP$gi[2:6]), col='red', lwd=2)
# dev.off()
# #####




### Passo 3) Analise grafica ####
## Dois graficos juntos para encontrar uma sequencia de pontos F e P
## Grafico
lim.y=range(PontsP$zi.ei[2:7],PontsF$zx.ex[2:7])
lim.x=range(PontsP$gi[1:8],PontsF$gx[1:7])

# # Pontos F
# pdf(file = paste0(results_dir, ANALYSIS, '_PontosFeP.pdf'), width = 7, height = 4)
# plot(PontsF$gx[2:7],PontsF$zx.ex[2:7], pch=10, col='blue', ylim = lim.y, 
#      xlim=lim.x,xlab='g()', ylab='z()-e()', 
#      main='Gráfico de diagnóstico entre Pontos F e P')
# abline(lm(PontsF$zx.ex[2:7]~PontsF$gx[2:7]), col='blue', lwd=2)
# text(PontsF$gx[2:7],PontsF$zx.ex[2:7],
#      labels=round(PontsF$zx.ex[2:7],digits=3),cex=0.6,pos=3)
# # Pontos P
# points(PontsP$gi[2:7],PontsP$zi.ei[2:7], pch=10, col='red')
# abline(lm(PontsP$zi.ei[2:7]~PontsP$gi[2:7]), col='red', lwd=2)
# text(PontsP$gi[2:7],PontsP$zi.ei[2:7], 
#      labels=round(PontsP$zi.ei[2:7],digits=3),cex=0.6,pos=3)
# dev.off()
# ### O que o grafico me diz? Quais pontos considero?
# #####




### Analise em base estatistica, RMSE ####
#install.packages('hydroGOF')
library(hydroGOF)

pontos.P=cbind(y=PontsP$zi.ei[2:7],x=PontsP$gi[2:7])
pontos.F=cbind(y=PontsF$zx.ex[2:7],x=PontsF$gx[2:7])

### Para os pontos F
rmseF=NULL
for(i in 1:6){rmseF[i]=rmse(pontos.F[i,1],pontos.F[i,2])}
cbind(pontos.F,rmseF)

### Para os pontos P
rmseP=NULL
for(i in 1:6){rmseP[i]=rmse(pontos.P[i,1],pontos.P[i,2])}
cbind(pontos.P,rmseP)
#####

## Considerando pontos escolhidos de cada grupo ####
Pontos=rbind(cbind(x=pontos.F[1:5,'x'],y=pontos.F[1:5,'y']),
             cbind(x=pontos.P[1:5,'x'],y=pontos.P[1:5,'y']))

l.y=range(Pontos[,'y'])
l.x=range(Pontos[,'x'])

# # Pontos combinados
# pdf(file = paste0(results_dir, ANALYSIS, '_PontosCombinados.pdf'), width = 7, height = 4)
# plot(Pontos[,'x'],Pontos[,'y'], pch=10, col='blue', ylim = lim.y, 
#      xlim=lim.x,xlab='g()', ylab='z()-e()', 
#      main='Grafico de diagnostico entre Pontos F e P')
# abline(lm(Pontos[,'y']~Pontos[,'x']), col='black', lwd=2)
# dev.off()
# #####


### Regressao para encontrar o alfa e o beta ######
#numero de pontos F = 5 
#numero de pontos P = 5
soma.y=c(FP=sum(Pontos[,'y']),F=sum(pontos.F[1:5,'y']),
  P=sum(pontos.P[1:5,'y']))

soma.x=c(FP=sum(Pontos[,'x']),F=sum(pontos.F[1:5,'x']),
         P=sum(pontos.P[1:5,'x']))

soma.xy=c(FP=crossprod(Pontos[,'x'],Pontos[,'y']),
          F=crossprod(pontos.F[1:5,'x'],pontos.F[1:5,'y']),
          P=crossprod(pontos.P[1:5,'x'],pontos.P[1:5,'y']))

soma.xx=c(FP=crossprod(Pontos[,'x'],Pontos[,'x']),
          F=crossprod(pontos.F[1:5,'x'],pontos.F[1:5,'x']),
          P=crossprod(pontos.P[1:5,'x'],pontos.P[1:5,'x']))

## estimando o beta para o F, P e combinacao 
#beta=(soma.xy-(soma.x*soma.y)/n)/(soma.xx-(soma.x*soma.x)/n)
beta.F=(soma.xy['F']-(soma.x['F']*soma.y['F'])/5)/
  (soma.xx['F']-(soma.x['F']*soma.x['F'])/5)

beta.P=(soma.xy['P']-(soma.x['P']*soma.y['P'])/5)/
  (soma.xx['P']-(soma.x['P']*soma.x['P'])/5)

## Beta combinado
beta.FP=(soma.xy['FP']-(soma.x['FP']*soma.y['FP'])/10)/
  (soma.xx['FP']-(soma.x['FP']*soma.x['FP'])/10)

## estimando o alfa para F, P e combinacao de pontos
# alfa = soma.y/n - beta*soma.x/n
alfa.F=soma.y['F']/5-beta.F*soma.x['F']/5

alfa.P=soma.y['P']/5-beta.P*soma.x['P']/5

## Alfa combinado, assumindo que beta da padrao igual 1   
alfa.FP=soma.y['FP']/10-beta.FP*soma.x['FP']/10
#####

### Re-estimando o P e o F (agora utilizando grupos etarios exatos) ####

## Re-estimando o P
dados.P=dat.p[,c('grupos','Ys.i')]

### Re-estimando o logito com base no alfa e beta
dados.P$Yjust=alfa.FP+beta.FP*dados.P$Ys.i

## voltar o processo com o exp (anti-logito)
# exp(-exp(-logito))
dados.P$Pi_P= exp(-exp(-dados.P$Yjust))

## Achar o nivel P atraves do relacionamento de informacao do P-medio do periodo com os Ps proporcionais, estimados pelo alfa e beta, entre as idades 15-44 anos (pode testar outras idades)

acumulado.P = dado$Pi[2:7]/dados.P$Pi_P[2:7]
## Nivel correto da fecundidade no periodo, definido por P
ajust.n=mean(acumulado.P)
ajust.n

dados.P$Pm.nova = dados.P$Pi_P*ajust.n # obtendo os Ps estimados

dado$Pi.n=round(dados.P$Pm.nova, digits=3)

### Re-estimando o F (para grupos de idades convencionais)
dados.F=padrao[-9,c('grupos2','Fp_semdes')]


dados.F$Ys.x= -log(-log(dados.F$Fp_semdes))

dados.F$Yjust = alfa.FP + beta.FP*dados.F$Ys.x

## Anti-log
dados.F$Fx_F = exp(-exp(-dados.F$Yjust))

### ajustar pelo nivel, dado por P
dados.F$Fx = dados.F$Fx_F*ajust.n ## Gerando novas taxas acumuladas

##Volta o processo para gerar taxas especificas no periodo
dados.F$fxm=NA

## Taxas, primeiro grupo apenas dividir o acumulado por 5
dados.F$fxm[1]=dados.F$Fx[1]/5

## Para os demais, apenas fazer a subtracao entre grupos adjacentes e dividir pelo tempo de exposicao
for(i in 2:8){dados.F$fxm[i]=(dados.F$Fx[i]-dados.F$Fx[i-1])/5}

## Taxa em idades convencionais
dado$fxm=round(dados.F$fxm,digits = 5)

## TFT
sum(dado$TEF, na.rm = T)*5
sum(dado$fxm[2:8], na.rm = T)*5

y.lim=range(dado$TEF,dado$fxm,na.rm = T)

# ### Comparando as duas distribuicoes
# pdf(file = paste0(results_dir, ANALYSIS, '_CompDistr.pdf'), width = 7, height = 4)
# plot(seq(15,45,5),dado$TEF[2:8], ylim=y.lim, type = 'l', col='red',lwd=2,
#      xlab='idades',ylab = 'TEF')
# lines(seq(15,45,5),dado$fxm[2:8], lwd=2, col='blue')
# legend('topright',c('taxa com desvio', 'taxa ajustada'),col=c('red','blue'),lwd=c(2))
# dev.off()
# ####



## Qual é a diferença com o PF original?

### Estimar P/F ####
zaba=read.csv(sep=',',header=T,text="
x,Yx,Fx,Px.x_5
10,-100000,,
10.5,-50002,,
11,-3.1709,0.0000,
11.5,-2.9567,0.0000,
12,-2.7426,0.0000,
12.5,-2.5555,0.0000,
13,-2.3685,0.0000,
13.5,-2.2047,0.0001,
14,-2.0408,0.0005,
14.5,-1.8964,0.0013,
15,-1.7521,0.0031,0.00034
15.5,-1.6225,0.0063,0.00082
16,-1.4929,0.0117,0.00172
16.5,-1.3717,0.0194,0.00327
17,-1.2506,0.0304,0.00576
17.5,-1.1477,0.0428,0.00942
18,-1.0448,0.0583,0.01448
18.5,-0.9520,0.0749,0.02113
19,-0.8593,0.0943,0.02956
19.5,-0.7753,0.1140,0.03989
20,-0.6913,0.1358,0.05217
20.5,-0.6123,0.1581,0.06639
21,-0.5333,0.1819,0.08249
21.5,-0.4592,0.2054,0.10030
22,-0.3852,0.2299,0.11957
22.5,-0.3147,0.2541,0.14011
23,-0.2442,0.2790,0.16171
23.5,-0.1760,0.3035,0.18417
24,-0.1078,0.3283,0.20730
24.5,-0.0411,0.3528,0.23094
25,0.0256,0.3773,0.25495
25.5,0.0921,0.4017,0.27920
26,0.1585,0.4260,0.30359
26.5,0.2250,0.4500,0.32802
27,0.2915,0.4737,0.35244
27.5,0.3583,0.4972,0.37678
28,0.4252,0.5201,0.40099
28.5,0.4931,0.5429,0.42502
29,0.5610,0.5652,0.44884
29.5,0.6305,0.5872,0.47241
30,0.7000,0.6086,0.49570
30.5,0.7714,0.6298,0.51867
31,0.8427,0.6502,0.54128
31.5,0.9164,0.6704,0.56351
32,0.9901,0.6897,0.58532
32.5,1.0671,0.7089,0.60671
33,1.1441,0.7272,0.62765
33.5,1.2252,0.7455,0.64814
34,1.3063,0.7627,0.66814
34.5,1.3925,0.7800,0.68766
35,1.4787,0.7962,0.70668
35.5,1.5715,0.8124,0.72519
36,1.6643,0.8275,0.74319
36.5,1.7651,0.8427,0.76067
37,1.8660,0.8566,0.77764
37.5,1.9775,0.8707,0.79407
38,2.0889,0.8835,0.80998
38.5,2.2144,0.8965,0.82535
39,2.3399,0.9082,0.84017
39.5,2.4830,0.9199,0.85443
40,2.6260,0.9302,0.86813
40.5,2.7905,0.9405,0.88123
41,2.9550,0.9493,0.89372
41.5,3.1419,0.9577,0.90556
42,3.3287,0.9648,0.91672
42.5,3.5443,0.9715,0.92717
43,3.7598,0.9770,0.93688
43.5,4.0074,0.9820,0.94582
44,4.2550,0.9859,0.95398
44.5,4.5323,0.9893,0.96134
45,4.8097,0.9919,0.96790
45.5,5.1114,0.9940,0.97366
46,5.4131,0.9956,0.97865
46.5,5.7709,0.9969,0.98292
47,6.1286,0.9978,0.98653
47.5,6.5994,0.9986,0.98954
48,7.0702,0.9992,0.99200
48.5,7.8593,0.9996,0.99399
49,8.6484,0.9998,0.99557
49.5,11.8242,1.0000,0.99680
50,15.0000,1.0000,0.99774
50.5,99999,1.0000,0.99845
51,99999,1.0000,0.99897
51.5,99999,1.0000,0.99935
52,99999,1.0000,0.99961
52.5,99999,1.0000,0.99979
53,99999,1.0000,0.99990
53.5,100000,1.0000,
")


P=dado$Pi 

## gerar F, com base no alfa e beta do padrao

### Re-estimando o F (grupos de idade nao-convencional)
dados.F1=padrao[-9,c('grupos1','Fp_des')]


dados.F1$Ys.x=-log(-log(dados.F1$Fp_des))

dados.F1$Yjust=alfa.FP+beta.FP*dados.F1$Ys.x

## Anti-log
dados.F1$Fx_F=exp(-exp(-dados.F1$Yjust))

### ajustar pelo nivel, dado por P
dados.F1$Fx=dados.F1$Fx_F*ajust.n ## Novo acumulado

## Taxas, primeiro grupo apenas dividir o acumulado por 5
dados.F1$fxm[1]=dados.F1$Fx[1]/5

## Para os demais apenas fazer a subtracao entre grupos adjacentes e dividir pelo tempo de exposicao
for(i in 2:8){dados.F1$fxm[i]=(dados.F1$Fx[i]-dados.F1$Fx[i-1])/5}

## Taxas especificas deslocadas em meio ano e ajustadas pelo P

## Para o P/F ---------
## Achar o nivel F atraves do relacionamento de informacao do F-medio do periodo com os Fs proporcionais, estimados pelo alfa e beta, entre as idades 15-44 anos (pode testar outras idades)

#vetor de taxas acumuludas frutos dos dados observados
dados.F1$Fi=NA 
dados.F1$Fi[2:8]=cumsum(dado[2:8,'TEF'])

## Gerando o F acumulado
# 5/Anti.log*Fi(observado)
dados.F1$acumulado.F=NA  
  for (i in 2:7) {dados.F1[i,'acumulado.F']<-5/(dados.F1[i,'Fx_F'])*
                                                  (dados.F1[i,'Fi'])}
## Nivel da fecundidade definido pelo F
ajust.nF=mean(na.omit(dados.F1$acumulado.F))
ajust.nF

### Gerando F 
#Fx*(exp(-exp(-(alfa+beta*Yxp))))
PF = as.data.frame(cbind(x=seq(12.5,47.5,5),P))
PF.n = merge(PF, zaba, by = "x", all.x = T)
## 
F=ajust.nF*(exp(-exp(-(alfa.F+beta.F*PF.n$Yx))))

PF$F=round(F,digits=3)
PF$P.F=(PF$P/PF$F)
PF
#####
dado$PF=PF$P.F





# refatoração dos gráficos em ggplot2


message("exportando Gompertz Relacional Modificado em Disco para ", ARG_SUBGRP, " ano ", ARG_ANO)
dado |>
  as_tibble() |>
  filter(Idade != '10-14') |>
  transmute(
    subgrp = ARG_SUBGRP,
    fx_idade = Idade,
    ano = ARG_ANO,
    key = ARG_KEY,
    value = fxm
  ) |>
  write_csv(
    file = ARG_OUTPUT_FILE,
    append = ARG_APPEND
  )


message("exportando gráfico dos pontos F em disco para ", ARG_SUBGRP, " ano ", ARG_ANO)
(
  PontsF |>
  as_tibble() |>
  filter( idade != 14.5, idade != 49.5) |>
  ggplot( aes(x=gx, y=zx.ex)) + 
  geom_point(size=4, shape=10, color = 'blue') + 
  geom_text(aes(label = round(zx.ex, 3)), vjust = -1, size = 3, show.legend = FALSE, color='blue') +
  geom_smooth(method = "lm", se = FALSE, color = "blue", linewidth=0.5) + 
  labs(
    x = 'g(x)',
    y = 'z(x) - e(x)'
  )
) |>
  ggsave(
    file = paste0(results_dir, ANALYSIS, '_PontosF.pdf'),
    width = 7,
    height = 4
  )


message("exportando gráfico dos pontos P em disco para ", ARG_SUBGRP, " ano ", ARG_ANO)
(
  PontsP |>
    as_tibble() |>
    filter( idade != 14.5, idade != 49.5) |>
    ggplot( aes(x=gi, y=zi.ei)) + 
    geom_point(size=4, shape=10, color = 'red') + 
    geom_text(aes(label = round(zi.ei, 3)), vjust = -1, size = 3, show.legend = FALSE, color='red') +
    geom_smooth(method = "lm", se = FALSE, color = "red", linewidth=0.5) + 
    labs(
      x = 'g(i)',
      y = 'z(i) - e(i)'
    )
) |>
  ggsave(
    file = paste0(results_dir, ANALYSIS, '_PontosP.pdf'),
    width = 7,
    height = 4
  )



message("exportando gráfico dos pontos F e P em disco para ", ARG_SUBGRP, " ano ", ARG_ANO)
(
  bind_rows(
    PontsF[2:7, ] |> transmute(g = gx, z_e = zx.ex, tipo = "Pontos F"), 
    PontsP[2:7, ] |> transmute(g = gi, z_e = zi.ei, tipo = "Pontos P")
  ) |>
  ggplot(aes(x = g, y = z_e, color = tipo)) +
  geom_point(shape = 10, size = 3) +
  geom_smooth(method = "lm", se = FALSE, linewidth = 0.5) +
  geom_text(aes(label = round(z_e, 3)), vjust = -1, size = 3, show.legend = FALSE) +
  scale_color_manual(values = c("Pontos F" = "blue", "Pontos P" = "red")) +
  scale_y_continuous(limits = lim.y*1.1) +
  scale_x_continuous(limits = lim.x*1.1) +
  labs(
    title = "",
    x = "g()", 
    y = "z()-e()",
    color = ""
  ) + 
  theme(
    legend.position = 'top'
  )
) |>
  ggsave(
    file = paste0(results_dir, ANALYSIS, '_PontosFeP.pdf'),
    width = 7,
    height = 4
  )



message("exportando gráfico dos pontos F e P combinados em disco para ", ARG_SUBGRP, " ano ", ARG_ANO)
(
  Pontos |>
    as_tibble() |>
    ggplot( aes(x=x, y=y)) + 
    geom_point(size=4, shape=1, color = 'black') + 
    geom_text(aes(label = round(y, 3)), vjust = -1, size = 3, show.legend = FALSE, color='black') +
    geom_smooth(method = "lm", se = FALSE, color = "black", linewidth=0.5) + 
    labs(
      x = 'g()',
      y = 'z() - e()'
    )
) |>
  ggsave(
    file = paste0(results_dir, ANALYSIS, '_PontosCombinados.pdf'),
    width = 7,
    height = 4
  )



message("exportando gráfico compartativo das TEF observadas e ajustadas GRM em disco para ", ARG_SUBGRP, " ano ", ARG_ANO)
plt <-
  dado |>
  as_tibble() |>
  filter( Idade != '10-14') |>
  rename(fx_idade = Idade) |>
  select(fx_idade, TEF, fxm) |>
  pivot_longer(
    cols = c(TEF, fxm)
  ) |>
  mutate(
    name = case_match(
      name,
      'TEF' ~ 'TEF Observada',
      'fxm' ~ 'TEF Ajustada Gompertz Relacional Modificado'
    )
  ) |>
  ggplot(aes(x = fx_idade, y=value, group = name, linetype = name)) + 
  geom_line() + 
  labs(
    x = 'Faixa etária',
    title = '',
    y = 'Taxa Específica de Fecundidade',
    linetype = ''
  ) + 
  theme( legend.position = 'top')

ggsave(
  filename = paste0(results_dir, ANALYSIS, '_TEF_comp.pdf'),
  plot = plt,
  width = 7,
  height = 4
)
