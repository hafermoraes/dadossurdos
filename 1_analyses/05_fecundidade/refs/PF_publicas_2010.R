####################################
##### Aula de correcao de dados ####
########### P/F-Brass    ###########
dado=read.table(file.choose(),sep='\t', header=T)

View(dado)

## Retira o total
dado=dado[-8,]
#####

#### Passo 1) Estimar parturicoes medias e fecundidade corrente #### 

## Estimando P ###
dado$P=dado$nasc.v/dado$mulheres

## Estimando fecundidade corrente ###
dado$fi=dado$nasc.12/dado$mulheres

## TFT ###
TFT=sum(dado$fi)*5
#####

#### Passo 2) Estimando parametros auxiliares #### 

## Idade media a fecundidade ###
idade=seq(15,45,5)
dado[,'pont.m']=idade+2.5
idad.m=sum(dado$pont.m*dado$fi)/sum(dado$fi)

## Razao entre os dois primeiros Ps ###
razao.p=dado$P[1]/dado$P[2]

## Parametros para estimar os multiplicadores de ajuste de idades  
## que serio usados mais a frente
## Idade media a fecundidade e razao P1/P2
#####

#### Passo 3) Encontrar os multiplicadores k ####
mult=read.table(file.choose(),sep='\t', header=T)

## Encontrando os parametros dentro do intervalo

### Para as razoes entre P's ###
findInterval(razao.p,mult[8,2:9]);mult[8,2:9]
# Ponto no terceiro intervalo, entre 0.09 e 0.143

### Para idade media ###
findInterval(idad.m,sort(mult[10,2:9])); sort(mult[10,2:9])
# Entre intervalo 1 e 2, entre 31.7 e 30.7
#####

### Passo 4) Grupo de interpolacoes para achar os multiplicadores k #### 

## Para os tres primeiros grupos etarios ate 29 anos ### 

#alfa(intervalo superior)-alfa(intervalo inferior)+(intervalo inferior)
mult.3=mult[1:3,7:8]

alfa=(razao.p-0.330)/(0.330-0.268)

# K para os tres primeiros grupos #
mult.3$ks=alfa*(mult.3$Int7)-alfa*(mult.3$Int6)+(mult.3$Int6)

## Para os quatro ultimos grupos etarios ### 

#alfa(intervalo inferior)-alfa(intervalo superior)+(intervalo superior)
mult.4=mult[4:7,4:5]

alfa.n=(idad.m-29.7)/(29.7-28.7)

## K para os ultimos grupos
mult.4$ks=alfa.n*(mult.4$Int3)-alfa.n*(mult.4$Int4)+(mult.4$Int4)

## Combinando os multiplicadores num unico vetor
ks=c(mult.3$ks,mult.4$ks)
ks
#####

#### Passo 5) Estimar o P/F ####

## Os multiplicadores ###
dado$ki=ks

## Estimando o Fi ###
## Acumulando as fecundidades fs

dado[,'delta']=0
for (i in 1:6) {dado[i+1,'delta']<-(dado[i,'fi'])*5+(dado[i,'delta'])}

## Fi = delta + ki x fi 
dado$Fi = dado$delta+dado$ki*dado$fi

### P/F ###
dado$P_F=dado$P/dado$Fi
#####

#### Passo 6) Ajustando a fecundidade ####
## Selecionando um grupo de ajuste, 20-24 anos.

dado$fi.aj=dado$P_F[2]*dado$fi
#####

#### Passo 7) Ajuste de 6 meses entre o tempo de nascimentos####

## criando os fatores de ajuste para Dados observados e corrigidos ###
fobs.aj=c((dado$fi[1]+dado$fi[2])/20,(dado$fi[3]-dado$fi[1])/20,
          (dado$fi[4]-dado$fi[2])/20,(dado$fi[5]-dado$fi[3])/20,
          (dado$fi[6]-dado$fi[4])/20,(dado$fi[7]-dado$fi[5])/20,
          (-dado$fi[6]-dado$fi[7])/20) 

fest.aj=c((dado$fi.aj[1]+dado$fi.aj[2])/20,(dado$fi.aj[3]-dado$fi.aj[1])/20,
          (dado$fi.aj[4]-dado$fi.aj[2])/20,(dado$fi.aj[5]-dado$fi.aj[3])/20,
          (dado$fi.aj[6]-dado$fi.aj[4])/20,(dado$fi.aj[7]-dado$fi.aj[5])/20,
          (-dado$fi.aj[6]-dado$fi.aj[7])/20) 
#####

## Passo 8) Taxas finais ajustadas pelo P/F com o ajuste de 6 meses ####
resultado=round(cbind(idade=seq(15,45,5),
                      fi=dado$fi+fobs.aj,
                      fi.aj=dado$fi.aj+fest.aj,P_F=dado$P_F),digits=4)
resultado

## Estimando TFTs observada e corrigida ###
TFT.n=sum(resultado[,'fi'])*5
TFT.c=sum(resultado[,'fi.aj'])*5
#####

### Graficos de analise #####
y=range(resultado[,'fi.aj'],resultado[,'fi'])

## Das taxas
windows(height = 10,width=10)
windows(height = 10, width = 10)
plot(resultado[,'idade'], resultado[,'fi'], xlab='Grupos de Idade', type='l', ylim=y, ylab='TEF', lwd=2, main='Mulheres Setor Público, 2010 - TEF observadas e ajustadas pelo P/F')
lines(resultado[,'idade'], resultado[,'fi.aj'], lwd=2, col='red', lty=2)
legend('topright', c('TEF observada', 'TEF ajustada pelo P/F'),
       bty='n', lwd=c(2, 2), col=c('black', 'red'), lty=c(1, 2))


## Grafico da serie P/F
windows(height = 10,width = 10)
plot(resultado[,'idade'],dado$P_F, ylab='Razão P/F', xlab='Grupos de Idade',type='l',main='Série P/F - evolução, Setor Público, ',ylim=c(0.5,2.5),lwd=2)

### Serie PF para v?rios tempos ###
serie=read.table(file.choose(),sep='\t', header=T)

windows(height = 20,width = 20)
matplot(serie[,-1],type ='l',col=c('black','red','blue','grey','forestgreen'),
        lwd=2, ylim=c(0.5,2.5), lty=c(1,2,3,4,5), main='S?ries PF no tempo',
        xlab='Distribuição da série P/F', ylab='Razão PF') 
grid(7,5,lwd=2)
legend("topleft", legend=c('tempo 1','tempo 2','tempo 3','tempo 4','tempo 5'),
       col=c('black','red','blue','grey','forestgreen'), 
       lty=c(1,2,3,4,5)) 
#####

