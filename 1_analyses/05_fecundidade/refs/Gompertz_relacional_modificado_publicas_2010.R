#############################################
#### Aula Gompertz Relacional modificado ####
#############################################
options(scipen=999)

### Vizualizacao dos dados ####
dado=read.csv('dado_gompertz_relacional.csv', sep=',',header=T)
dado=read.table(file.choose(),sep='\t',header=T)
View(dado)

## Retira TFT
dado=dado[-9,]

## Descricao dos dados ##### 
## Pi a parturicao media estimada 
## TEF fecundidade corrente estimada 
#####

### Valores padrao tabulado - Modificado pela Zaba ####
padrao=read.csv('padrao_Booth_GS.csv',sep=',',header=T)
padrao=read.table(file.choose(),sep=',',header=T)
View(padrao)

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
View(dat)

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

windows(height = 15,width = 15)
plot(PontsF$gx[2:7],PontsF$zx.ex[2:7], pch=10, col='blue', xlab='g(x)', ylab='z(x)-e(x)', main='Pontos F')
abline(lm(PontsF$zx.ex[2:7]~PontsF$gx[2:7]), col='blue', lwd=2)
#####

### Procedimento parecido P(i) => P(i)/P(i+1), os Pontos P ####
### e(i), g(i) e z(i)

### Sem deslocamento de grupos de idade
names(padrao)

## Selecionando idades e fatores
dat.p=padrao[-9,c('grupos','Pp')]

View(dat.p)

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

## Grafico, lembrando os eixos g(i) = X e z(i)-e(i) = Y
windows(height = 10,width = 10)
plot(PontsP$gi[2:6],PontsP$zi.ei[2:6], pch=10, col='red', xlab='g(i)', 
     ylab='z(i)-e(i)', main='Pontos P')
abline(lm(PontsP$zi.ei[2:6]~PontsP$gi[2:6]), col='red', lwd=2)
#####

### Passo 3) Analise grafica ####
## Dois graficos juntos para encontrar uma sequencia de pontos F e P
## Grafico

lim.y=range(PontsP$zi.ei[2:7],PontsF$zx.ex[2:7])
lim.x=range(PontsP$gi[1:8],PontsF$gx[1:7])

pontos.P=cbind(y=PontsP$zi.ei[2:7],x=PontsP$gi[2:7])
pontos.F=cbind(y=PontsF$zx.ex[2:7],x=PontsF$gx[2:7])

# Consolidando o cálculo do RMSE para Pontos F e P
p1=2
pn=5
f1=1
fn=4
# Calcular o RMSE final combinando Pontos F e P
rmse_total <- function(pontos_F, pontos_P) {
  # Calcular os erros quadráticos para Pontos F
  erro_F <- sum((pontos_F[f1:fn, 'y'] - pontos_F[f1:fn, 'x'])^2)
  
  # Calcular os erros quadráticos para Pontos P
  erro_P <- sum((pontos_P[p1:pn, 'y'] - pontos_P[p1:pn, 'x'])^2)
  
  # Soma dos erros quadráticos
  soma_quadrados <- erro_F + erro_P
  
  # Número total de pontos utilizados (4 pontos F e 3 pontos P)
  n_pontos <- length(pontos_F[f1:fn, 'x']) + length(pontos_F[p1:pn, 'x'])
  
  # Calcular o RMSE total
  rmse_total <- sqrt(soma_quadrados / n_pontos)
  
  return(rmse_total)
}

# Calcular o RMSE total
rmse_final <- rmse_total(pontos.F, pontos.P)

# Resultado
print(paste("RMSE Total:", round(rmse_final, 4)))


p11=p1+1
pn1=pn+1
f11=f1+1
fn1=fn+1

# Pontos F
windows(height = 20,width = 20)
plot(PontsF$gx[f11:fn1],PontsF$zx.ex[f11:fn1], pch=10, col='blue', ylim = lim.y, 
     xlim=lim.x,xlab='g()', ylab='z()-e()',main = 'Melhores Pontos P e F - Setor Público, 2010')
abline(lm(PontsF$zx.ex[f11:fn1]~PontsF$gx[f11:fn1]), col='blue', lwd=2)
text(PontsF$gx[f11:fn1],PontsF$zx.ex[f11:fn1],
     labels=round(PontsF$zx.ex[f11:fn1],digits=2),cex=0.6,pos=3)
# Pontos P
points(PontsP$gi[p11:pn1],PontsP$zi.ei[p11:pn1], pch=10, col='red')
abline(lm(PontsP$zi.ei[p11:pn1]~PontsP$gi[p11:pn1]), col='red', lwd=2,lty=2)
text(PontsP$gi[p11:pn1],PontsP$zi.ei[p11:pn1], 
     labels=round(PontsP$zi.ei[p11:pn1],digits=2),cex=0.6,pos=3)
legend('bottomright',c('Pontos P', 'Pontos F'),col=c('red','blue'),lwd=c(2), pch=c(10, 10), lty=c(2, 1))


n_pontos <- length(pontos.F[f1:fn, 'x']) + length(pontos.P[p1:pn, 'x'])
n_p_pontos <- length(pontos.P[p1:pn, 'x'])
n_f_pontos <- length(pontos.F[f1:fn, 'x'])
                     
## Considerando pontos escolhidos de cada grupo ####
Pontos=rbind(cbind(x=pontos.F[1:5,'x'],y=pontos.F[1:5,'y']),
             cbind(x=pontos.P[1:5,'x'],y=pontos.P[1:5,'y']))

l.y=range(Pontos[,'y'])
l.x=range(Pontos[,'x'])

# Pontos combinados
windows(height = 20,width = 20)
plot(Pontos[,'x'],Pontos[,'y'], pch=10, col='blue', ylim = lim.y, 
     xlim=lim.x,xlab='g()', ylab='z()-e()', 
     main='Grafico de diagnostico entre Pontos F e P')
abline(lm(Pontos[,'y']~Pontos[,'x']), col='black', lwd=2)
#####

### Regressao para encontrar o alfa e o beta ######
#numero de pontos F = 5 
#numero de pontos P = 5
soma.y=c(FP=sum(Pontos[,'y']),F=sum(pontos.F[f1:fn,'y']),
         P=sum(pontos.P[p1:pn,'y']))

soma.x=c(FP=sum(Pontos[,'x']),F=sum(pontos.F[f1:fn,'x']),
         P=sum(pontos.P[p1:pn,'x']))

soma.xy=c(FP=crossprod(Pontos[,'x'],Pontos[,'y']),
          F=crossprod(pontos.F[f1:fn,'x'],pontos.F[f1:fn,'y']),
          P=crossprod(pontos.P[p1:pn,'x'],pontos.P[p1:pn,'y']))

soma.xx=c(FP=crossprod(Pontos[,'x'],Pontos[,'x']),
          F=crossprod(pontos.F[f1:fn,'x'],pontos.F[f1:fn,'x']),
          P=crossprod(pontos.P[p1:pn,'x'],pontos.P[p1:pn,'x']))

## estimando o beta para o F, P e combinacao 
#beta=(soma.xy-(soma.x*soma.y)/n)/(soma.xx-(soma.x*soma.x)/n)
beta.F=(soma.xy['F']-(soma.x['F']*soma.y['F'])/n_f_pontos)/
  (soma.xx['F']-(soma.x['F']*soma.x['F'])/n_f_pontos)

beta.P=(soma.xy['P']-(soma.x['P']*soma.y['P'])/n_p_pontos)/
  (soma.xx['P']-(soma.x['P']*soma.x['P'])/n_p_pontos)

## Beta combinado
beta.FP=(soma.xy['FP']-(soma.x['FP']*soma.y['FP'])/n_pontos)/
  (soma.xx['FP']-(soma.x['FP']*soma.x['FP'])/n_pontos)

## estimando o alfa para F, P e combinacao de pontos
# alfa = soma.y/n - beta*soma.x/n
alfa.F=soma.y['F']/n_f_pontos-beta.F*soma.x['F']/n_f_pontos

alfa.P=soma.y['P']/n_p_pontos-beta.P*soma.x['P']/n_p_pontos

## Alfa combinado, assumindo que beta da padrao igual 1   
alfa.FP=soma.y['FP']/n_pontos-beta.FP*soma.x['FP']/n_pontos
#####

### Re-estimando o P e o F (agora utilizando grupos etarios exatos) ####

## Re-estimando o P
dados.P=dat.p[,c('grupos','Ys.i')]
View(dados.P)
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
View(dados.F)

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

### Comparando as duas distribuicoes
windows(height = 10,width = 10)
plot(seq(15,45,5),dado$TEF[2:8], ylim=y.lim, type = 'l', col='black',lwd=2,
     xlab='idades',ylab = 'TEF',main='TEF obs. e ajust. - Gompertz Relacional Mod - Setor Público, 2010')
lines(seq(15,45,5),dado$fxm[2:8], lwd=2, col='red',lty=2)
legend('topright',c('TEF observada', 'TEF ajustada'),col=c('black','red'),lwd=c(2),  lty=c(1, 2))
####

## Qual é a diferença com o PF original?

### Estimar P/F ####
#zaba=read.csv('padrao_Zaba_modificado.csv', sep=',',header=T)
zaba=read.table(file.choose(),sep=',',header=T)
View(zaba)

P=dado$Pi 

## gerar F, com base no alfa e beta do padrao

### Re-estimando o F (grupos de idade nao-convencional)
dados.F1=padrao[-9,c('grupos1','Fp_des')]
View(dados.F1)

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

