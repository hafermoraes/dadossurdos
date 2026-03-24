
ARG_SUBGRP <- 'surdo'
ARG_ANO <- 2005 # Intercensitário
ARG_KEY <- 'gompertz_sintetico'

ARG_OUTPUT_FILE <- fec_models_output_file
ARG_APPEND <- TRUE

ANALYSIS <- 'fec_GompertzSintetico_2000_2010_surdo'

#################################
#### Aula Gompertz Sintetico ####
#################################
options(scipen=999)

### Vizualizacao dos dados ####
dado=read.table(
  # results/fec_dados_GompertzSintetico_2000_2010_surdo.txt
  sep='\t',
  header=T,
  text="
Idades	Pm1	Pm2	f1	f2
10-14	NA	NA	NA	NA
15-19	0.1216	0.1301	0.0449	0.0435
20-24	0.5187	0.5582	0.0782	0.0761
25-29	1.0259	1.0558	0.078	0.0693
30-34	1.549	1.5931	0.0506	0.0486
35-39	1.6773	1.6535	0.0232	0.023
40-44	1.0887	1.7001	0.0185	0.0102
45-49	3.3035	2.2661	0.0031	0.0012
50+	NA	NA	NA	NA
")

dado=dado[-9,]

dado$Pm1[7] <- 0.95 * dado$Pm1[6] + 0.05 * dado$Pm1[8]

## Descricao dos dados ##### 
## Pm1 a parturicao media estimada no primeiro censo - 1989
## Pm2 a parturicao media estimada no segundo censo - 1999
## f1 fecundidade corrente estimada no primeiro censo - 1989
## f2 fecundidade corrente estimada no segundo censo - 1999 
#####

### Passo 1) Estimando Parturicoes entre o periodo e taxas especificas medias ####
### Parturicao media da coorte hipotetica
# deltaP(i+2) = P(i+2,2) - P(i,1)
#Se o intervalo intercensal de 10 anos, entao os sobreviventes da coorte inicial da faixa etaria i na primeira pesquisa sera as mulheres em faixa etaria (i+2) na segunda.

## Para os dois primeiros grupos de idade 
#deltaP(1s)=deltaP(1)=deltaP(1,2)
#deltaP(2s)=deltaP(2)=deltaP(2,2)

dado$Pis=NA
for(i in 2:3){dado$Pis[i]=dado$Pm2[i]}

# 15-19 e 20-24 estao mais proximos aos Pis do 2o censo;
# grupo de 25-29 vai ser o 25-29 (2o censo) + 15-19 (2o censo) - 15-19 (1o censo)
# etc

##Para os demais grupos de idade
#DeltaP(3s)= DeltaP(1)+DeltaP(3)
#          = DeltaP(1)+P3(t2)-P1(t1)
# ...
for(i in 4:8){dado$Pis[i]=(sum(ifelse(i>=6,dado$Pm2[i-6],0),
                              ifelse(i>=4,dado$Pm2[i-4],0),
                              ifelse(i>=2,dado$Pm2[i-2],0),
                              dado$Pm2[i],na.rm = T))- 
                                (sum(ifelse(i>=6,dado$Pm1[i-6],0),
                                    ifelse(i>=4,dado$Pm1[i-4],0),
                                    ifelse(i>=2,dado$Pm1[i-2],0),
                                    na.rm = T))}
## Taxas medias no periodo  
dado$fm=(dado$f1+dado$f2)/2

### Valores padrao tabulado
padrao=read.csv(
  # 'padrao_Booth_GS.csv'
  sep=',',
  header=T,
  text="
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

### Passo 2) Estimando parametros graficos ####
#####

### 2.1) e(x), g(x) e z(x) para F ####
### Para grupos etarios deslocados meio ano da data do censo
names(padrao)

## Selecionando idades e fatores
dat=padrao[-9,c('grupos1','Fp_des')]

## Fazendo o primeiro logito
dat$Ys.x = -log(-log(dat$Fp_des))

## Fx/Fx+5
dat$razao=NA
for(i in 1:7){dat$razao[i]=dat$Fp_des[i]/dat$Fp_des[i+1]}

## logito das razoes, chamei de phi
dat$Ys.xr=-log(-log(dat$razao))

## encontrar parametros phi' e phi''
# phi'= (exp(Ys.x)*Ys.x+5)-Ys.x*exp(Ys.x+5))/(exp(Ys.x)-exp(Ys.x+5))

dat$phi.1=NA
for(i in 1:7){dat$phi.1[i]=((exp(dat$Ys.x[i])*dat$Ys.x[i+1])-dat$Ys.x[i]*exp(dat$Ys.x[i+1]))/(exp(dat$Ys.x[i])-exp(dat$Ys.x[i+1]))}
## phi'= g(x)

# phi''= (Ys.x-Ys.x+5)^2*exp(Ys.x+Ys.x+5)/(exp(Ys.x)-exp(Ys.x+5))^2
## Valores constantes entre as idades 15 a 30 anos. A media deles produz o parametro c
## Para os grupos de 15 a 30 anos apenas
dat$phi.2=NA
for(i in 2:4){dat$phi.2[i]=((dat$Ys.x[i]-dat$Ys.x[i+1])^2*exp(dat$Ys.x[i]+dat$Ys.x[i+1]))/(exp(dat$Ys.x[i])-exp(dat$Ys.x[i+1]))^2}

mean(dat$phi.2, na.rm = T) ## Valor de 'c'

## e(x) = Diferenca entre logito das razoes (phi) e phi' 
dat$ex=dat$Ys.xr-dat$phi.1

### Parametro z(x)

### Dados observados
## Acumulado das taxas medias, e para o primeiro grupo = 0
dat$Fx=c(0,5*cumsum(na.omit(dado$fm)))

## Retirando as raz?es entre acumulados em x e x+5
dat$Fx_Fx5=NA
for(i in 1:7){dat$Fx_Fx5[i]=dat$Fx[i]/dat$Fx[i+1]}

dat$Fx_Fx5[8]=1

## Estimando z(x), logito das razoes acumuladas
dat$zx=c(NA,(-log(-log(dat$Fx_Fx5[2:7]))),NA)

########################################
#### Gerando os parametros graficos ####
########################################

### Subtraindo z(x) e e(x)
zx.ex = dat$zx-dat$ex

## g(x) = phi'
gx=dat$phi.1

## Resumo dos pontos F
PontsF=as.data.frame(cbind(idade=seq(14.5,49.5,5),gx,zx.ex))

# ## Grafico, lembrando g(x) = X e z(x)-e(x) = Y
# pdf(file = paste0(results_dir, ANALYSIS, '_PontosF.pdf'), width = 7, height = 4)
# plot(gx[2:7],zx.ex[2:7],pch=10,col='blue',xlab='g(x)',ylab='z(x)-e(x)', main='Pontos F')
# abline(lm(zx.ex[2:7]~gx[2:7]), col='blue', lwd=2)
# dev.off()
# #####

### 2.2) Procedimento parecido P(i) => P(i)/P(i+1), os Pontos P ####
### e(i), g(i) e z(i)

### Sem deslocamento de grupos de idade
names(padrao)

## Selecionando idades e fatores
dat.p=padrao[-9,c('grupos','Pp')]

## Fazendo o primeiro logito
dat.p$Ys.i=-log(-log(dat.p$Pp))

## razoes entre Ps, Pi/Pi+1
dat.p$razao=NA
for(i in 1:7){dat.p$razao[i]=dat.p$Pp[i]/dat.p$Pp[i+1]}

## Para ultima idade, Pi/1
dat.p$razao[8]=dat.p$Pp[8]/1

## logito das razoes, phi
dat.p$Ys.ir=-log(-log(dat.p$razao))

# phi'= (exp(Ys.i)*Ys.i+1)-Ys.i*exp(Ys.i+1))/(exp(Ys.i)-exp(Ys.i+1))
dat.p$phi.1=NA
for(i in 1:7){dat.p$phi.1[i]=((exp(dat.p$Ys.i[i])*dat.p$Ys.i[i+1])-dat.p$Ys.i[i]*exp(dat.p$Ys.i[i+1]))/(exp(dat.p$Ys.i[i])-exp(dat.p$Ys.i[i+1]))}

## Para o ultimo repete o valor do ultimo logito
dat.p$phi.1[8]=dat.p$Ys.i[8]

## phi'= g(i)

# phi''= (Ys.i-Ys.i+1)^2*exp(Ys.i+Ys.i+1)/(exp(Ys.i)-exp(Ys.i+1))^2
## Entre as idades 15 a 30 anos. A media deles produz o parametro c
dat.p$phi.2=NA
for(i in 2:4){dat.p$phi.2[i]=((dat.p$Ys.i[i]-dat.p$Ys.i[i+1])^2*exp(dat.p$Ys.i[i]+dat.p$Ys.i[i+1]))/(exp(dat.p$Ys.i[i])-exp(dat.p$Ys.i[i+1]))^2}

mean(dat.p$phi.2, na.rm = T) # Valor de 'c'

## e(i) = Diferen?a entre logito das razoes (phi) e phi' 
dat.p$ei=dat.p$Ys.ir-dat.p$phi.1

### Para o grafico necessita dos pares z(i)-e(i) e g(i)

### Dados observados
## Retirando as razoes entres Ps, Pi e Pi+1
dat.p$Pi_Pi1=NA
for(i in 1:7){dat.p$Pi_Pi1[i]=dado$Pis[i]/dado$Pis[i+1]}

## Estimando z(i), logito das razoes Pi/Pi+1
dat.p$zi=c(NA,(-log(-log(dat.p$Pi_Pi1[2:6]))),NA,NA)

### Subtraindo z(i) e e(i)
zi.ei = dat.p$zi-dat.p$ei

## g(i)
gi=dat.p$phi.1

PontsP=as.data.frame(cbind(idade=seq(14.5,49.5,5),gi,zi.ei))

# ## Grafico
# pdf(file = paste0(results_dir, ANALYSIS, '_gi_zi_m_ei.pdf'), width = 7, height = 4)
# plot(gi[2:6],zi.ei[2:6], pch=10, col='red', xlab='g(i)', 
#      ylab='z(i)-e(i)')
# abline(lm(zi.ei[2:6]~gi[2:6]), col='red', lwd=2)
# dev.off()
# #####

### Passo 3) Analise grafica ####
## Dois graficos juntos para encontrar uma sequencia de pontos F e P
## Grafico
lim.y=range(PontsP$zi.ei[2:6],PontsF$zx.ex[2:7])
lim.x=range(dat.p$gi[1:8],PontsF$gx[1:7])

# # Pontos F
# pdf(file = paste0(results_dir, ANALYSIS, '_PontosFeP.pdf'), width = 7, height = 4)
# plot(PontsF$gx[2:7],PontsF$zx.ex[2:7], pch=10, col='blue', ylim = lim.y, xlim=lim.x, xlab='g()', ylab='z()-e()')
# abline(lm(PontsF$zx.ex[2:7]~PontsF$gx[2:7]), col='blue', lwd=2)
# text(PontsF$gx[2:7],PontsF$zx.ex[2:7], labels=round(PontsF$zx.ex[2:7],digits=3),cex=0.6,pos=3)
# # Pontos P
# points(PontsP$gi[2:6],PontsP$zi.ei[2:6], pch=10, col='red')
# abline(lm(PontsP$zi.ei[2:6]~PontsP$gi[2:6]), col='red', lwd=2)
# text(PontsP$gi[2:6],PontsP$zi.ei[2:6], labels=round(PontsP$zi.ei[2:6],digits=3),cex=0.6,pos=3)
# dev.off()
# ### RMSE

pontos.P=cbind(y=PontsP$zi.ei[2:6],x=PontsP$gi[2:6])
pontos.F=cbind(y=PontsF$zx.ex[2:7],x=PontsF$gx[2:7])

### Para os pontos F
rmseF=NULL
for(i in 1:6){rmseF[i]=rmse(pontos.F[i,1],pontos.F[i,2])}
cbind(pontos.F,rmseF)

### Para os pontos P

rmseP=NULL
for(i in 1:5){rmseP[i]=rmse(pontos.P[i,1],pontos.P[i,2])}
cbind(pontos.P,rmseP)
#####

## Considerando pontos escolhidos de cada grupo ####
# F-pontos, 4 pontos, entre as idades 20 a 40 anos
# P-pontos, primeiros tres pontos
Pontos=rbind(cbind(x=pontos.F[2:5,'x'],y=pontos.F[2:5,'y']),
             cbind(x=pontos.P[2:4,'x'],y=pontos.P[2:4,'y']))

l.y=range(Pontos[,'y'])
l.x=range(Pontos[,'x'])

# # Pontos combinados
# pdf(file = paste0(results_dir, ANALYSIS, '_PontosComb.pdf'), width = 7, height = 4)
# plot(Pontos[,'x'],Pontos[,'y'], pch=10, col='blue', ylim = lim.y, 
#      xlim=lim.x,xlab='g()', ylab='z()-e()', 
#      main='Grafico de diagnostico entre Pontos F e P')
# abline(lm(Pontos[,'y']~Pontos[,'x']), col='black', lwd=2)
# dev.off()

### Passo 4) Regressao para encontrar o alfa e o beta ######
#numero de pontos F = 4 (20 a 40 anos)
#numero de pontos P = 3 (primeiros tr?s pontos)

soma.y=c(FP=sum(Pontos[,'y']),F=sum(pontos.F[2:5,'y']),
         P=sum(pontos.P[2:4,'y']))

soma.x=c(FP=sum(Pontos[,'x']),F=sum(pontos.F[2:5,'x']),
         P=sum(pontos.P[2:4,'x']))

soma.xy=c(FP=crossprod(Pontos[,'x'],Pontos[,'y']),
          F=crossprod(pontos.F[2:5,'x'],pontos.F[2:5,'y']),
          P=crossprod(pontos.P[2:4,'x'],pontos.P[2:4,'y']))

soma.xx=c(FP=crossprod(Pontos[,'x'],Pontos[,'x']),
          F=crossprod(pontos.F[2:5,'x'],pontos.F[2:5,'x']),
          P=crossprod(pontos.P[2:4,'x'],pontos.P[2:4,'x']))

## estimando o beta com 7 pontos
#beta=(soma.xy-(soma.x*soma.y)/n)/(soma.xx-(soma.x*soma.x)/n)
beta=(soma.xy['FP']-(soma.x['FP']*soma.y['FP'])/7)/(soma.xx['FP']-(soma.x['FP']*soma.x['FP'])/7)

## estimando o alfa com 7 pontos
#alfa=soma.y/n-beta*soma.x/n
alfa=soma.y['FP']/7-beta*soma.x['FP']/7
#####

### Passo 5) Re-estimando o P e o F (agora utilizando grupos etarios exatos) ####

## Re-estimando o P
dados.P=dat.p[,c('grupos','Ys.i')]


### Re-estimando o logito com base no alfa e beta
dados.P$Yjust=alfa+beta*dados.P$Ys.i

## voltar o processo com o exp (anti-logi)
# exp(-exp(-logi))
dados.P$Pi_P=exp(-exp(-dados.P$Yjust))

## Achar o nivel P, atraves do relacionamento de informacao do P-medio do periodo com os Ps proporcionais, estimados pelo alfa e beta, entre as idades 20-39 anos.
acumulado.P=dado$Pis[3:6]/dados.P$Pi_P[3:6]
acumulado.P
## Nivel correto da fecundidade no periodo, definido por P
ajust.n=mean(acumulado.P)

dados.P$Pm.novo = dados.P$Pi_P*ajust.n

### Re-estimando o F (para grupos de idades convencionais)
dados.F=padrao[-9,c('grupos2','Fp_semdes')]


dados.F$Ys.x=-log(-log(dados.F$Fp_semdes))

dados.F$Yjust=alfa+beta*dados.F$Ys.x

## Anti-logito
dados.F$Fx_F=exp(-exp(-dados.F$Yjust))

### ajustar Fnovo pelo nivel, dado por P
dados.F$Fx=dados.F$Fx_F*ajust.n

##Taxas especificas do periodo
dados.F$fxm=NA
dados.F$fxm[1]=dados.F$Fx[1]/5

## taxa final
for(i in 2:8){dados.F$fxm[i]=(dados.F$Fx[i]-dados.F$Fx[i-1])/5}

dado$fxm=round(dados.F$fxm,digits = 5)

## TFT
sum(dado$fm, na.rm = T)*5
sum(dado$fxm[2:8], na.rm = T)*5

y.lim=range(dado$fm,dado$fxm,na.rm = T)
# ### Comparando as duas distribuicoes
# pdf(file = paste0(results_dir, ANALYSIS, '_CompDistr.pdf'), width = 7, height = 4)
# plot(seq(15,45,5),dado$fm[2:8], ylim=y.lim, type = 'l', col='red',lwd=2,xlab='idades',ylab = 'TEF intercensitaria')
# lines(seq(15,45,5),dado$fxm[2:8], lwd=2, col='blue')
# legend('topright',c('taxa media no periodo', 'taxa ajustada'),col=c('red','blue'),lwd=c(2))
# dev.off()
# #####










# refatoração dos gráficos em ggplot2


message("exportando Gompertz Sintético em Disco para ", ARG_SUBGRP, " ano ", ARG_ANO)
dado |>
  as_tibble() |>
  filter(Idades != '10-14') |>
  transmute(
    subgrp = ARG_SUBGRP,
    fx_idade = Idades,
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
    drop_na() |> #filter( idade != 14.5, idade != 49.5) |>
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
    drop_na() |> #filter( idade != 14.5, idade != 49.5) |>
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
  drop_na() |>
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
    legend.title = element_blank(),
    legend.position = "inside",
    legend.position.inside = c(0.8, 0.2),
    legend.background = element_rect(fill = "white", color = "grey80")
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
  filter( Idades != '10-14') |>
  rename(fx_idade = Idades) |>
  select(fx_idade, fm, fxm) |>
  pivot_longer(
    cols = c(fm, fxm)
  ) |>
  mutate(
    name = case_match(
      name,
      'fm' ~ 'TEF Média no Período',
      'fxm' ~ 'TEF Ajustada Gompertz Sintético'
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


message("exportando em disco os parâmetros da regressão linear de gompertz")

models <- list()

models[["F"]] <- lm( y ~ x, data = as.data.frame(pontos.F[1:5,])) # ok, validado
models[["P"]] <- lm( y ~ x, data = as.data.frame(pontos.P[1:5,])) # ok, validado
models[["FP"]] <- lm( y ~ x, data = as.data.frame(Pontos)) # ok, validado

alfa <- list()
beta <- list()
rsquared <- list()
mse <- list()

for(arg_point in c('F','P','FP')){
  alfa[[arg_point]] <- coef(models[[arg_point]])[1] |> as.numeric()
  beta[[arg_point]] <- coef(models[[arg_point]])[2] |> as.numeric()
  rsquared[[arg_point]] <- summary(models[[arg_point]])$r.squared |> as.numeric()
  mse[[arg_point]] <- mean(residuals(models[[arg_point]])^2)
}

ARG_MODEL <- "GRS"

bind_rows(
  tibble(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    model = ARG_MODEL,
    key = "alpha",
    value = alfa$FP
  ),
  tibble(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    model = ARG_MODEL,
    key = "beta",
    value = beta$FP
  ),
  tibble(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    model = ARG_MODEL,
    key = "rsquared",
    value = rsquared$FP
  ),
  tibble(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    model = ARG_MODEL,
    key = "mse",
    value = mse$FP
  )
) |>
  write_csv(
    file = paste0(results_dir, "fec_metrics_gompertz_models.csv"),
    append=TRUE
  )
