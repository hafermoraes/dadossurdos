
ARG_SUBGRP <- 'deficiente_auditivo'
ARG_ANO <- 2000
ARG_KEY <- 'pf_brass'

ARG_OUTPUT_FILE <- fec_models_output_file
ARG_APPEND <- TRUE

ANALYSIS <- "fec_PFbrass_deficiente_auditivo_2000"

####################################
##### Aula de correcao de dados ####
########### P/F-Brass    ###########

dado <- 
  read.table(
  sep='\t', 
  header=T,
  # results/fec_dados_PFbrass_deficiente_auditivo_2000.txt
  text="
idade	mulheres	nasc.v	nasc.12
15-19	18748	2280	842
20-24	18643	9670	1459
25-29	18231	18488	1365
30-34	17899	27407	901
35-39	16901	37334	502
40-44	20926	56007	306
45-49	22680	76491	45
Total	134027	227676	5417
")

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
mult <-
  read.table(
    header=T,
    text="
Idade   Int1	Int2	Int3	Int4	Int5	Int6	Int7	Int8
'15 a 19' 1.12	1.31	1.615	1.95	2.305	2.64	2.925	3.17
'20 a 24'	2.555	2.69	2.78	2.84	2.89	2.925	2.96	2.985
'25 a 29'	2.925	2.96	2.985	3.01	3.035	3.055	3.075	3.095
'30 a 34'	3.055	3.075	3.095	3.12	3.14	3.165	3.19	3.215
'35 a 39'	3.165	3.19	3.215	3.245	3.285	3.325	3.375	3.435
'40 a 44'	3.325	3.375	3.435	3.51	3.61	3.74	3.915	4.15
'45 a 49'	3.64	3.895	4.15	4.395	4.63	4.84	4.985	5
'P1/P2'	0.014	0.045	0.09	0.143	0.205	0.268	0.33	0.387
'f1/f2'	0.036	0.113	0.213	0.33	0.46	0.605	0.764	0.939
'm'	31.7	30.7	29.7	28.7	27.7	26.7	25.7	24.7
")

## Encontrando os parametros dentro do intervalo

### Para as razoes entre P's ###
findInterval(razao.p, mult[8,2:9])
mult[8,2:9]
# Ponto no terceiro intervalo, entre 0.205 e 0.268

### Para idade media ###
findInterval(idad.m, sort(mult[10,2:9] |> unlist()))
sort(mult[10,2:9] |> unlist())
# Entre intervalo 1 e 2, entre 27.7 e 26.7
#####

### Passo 4) Grupo de interpolacoes para achar os multiplicadores k #### 

## Para os tres primeiros grupos etarios ate 29 anos ### 

#alfa(intervalo superior)-alfa(intervalo inferior)+(intervalo inferior)
mult.3=mult[1:3,4:5]

alfa=(razao.p-0.205)/(0.268-0.205)

# K para os tres primeiros grupos #
mult.3$ks=alfa*(mult.3$Int4)-alfa*(mult.3$Int3)+(mult.3$Int3)

## Para os quatro ultimos grupos etarios ### 

#alfa(intervalo inferior)-alfa(intervalo superior)+(intervalo superior)
mult.4=mult[4:7,2:3]

alfa.n=(idad.m-26.7)/(27.7-26.7)

## K para os ultimos grupos
mult.4$ks=alfa.n*(mult.4$Int1)-alfa.n*(mult.4$Int2)+(mult.4$Int2)

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
                      fi.aj=dado$fi.aj+fest.aj),digits=4)
resultado

## Estimando TFTs observada e corrigida ###
TFT.n=sum(resultado[,'fi'])*5
TFT.c=sum(resultado[,'fi.aj'])*5
#####

### Graficos de analise #####
y=range(resultado[,'fi.aj'],resultado[,'fi'])

# ## Das taxas
# pdf(file = paste0(results_dir, ANALYSIS, '_TEF_comp.pdf'), width = 7, height = 4)
# plot(resultado[,'idade'],resultado[,'fi'], xlab='Grupos de Idade',type='l', ylim=y,      ylab='TEF', lwd=2,main='Gráfico comparativo entre \n TEF observadas e ajustadas pelo P/F')
# lines(resultado[,'idade'],resultado[,'fi.aj'], lwd=2, col='red')
# legend('topright',c('TEF observada','TEF ajustada pelo P/F'),
#        bty='n',lwd=c(2,2), col=c('black','red'))
# dev.off()

# ## Grafico da serie P/F
# pdf(file = paste0(results_dir, ANALYSIS, '_seriePF.pdf'), width = 7, height = 4)
# plot(resultado[,'idade'],dado$P_F, ylab='Razão P/F', xlab='Grupos de Idade',type='l',main='Série P/F - evolução',ylim=c(0.5,2.5),lwd=2)
# dev.off()

### Serie PF para v?rios tempos ###
serie <-
  read.table(
    header=T,
    sep='\t',
    text="
Idade	PF.t1	PF.t2	PF.t3	PF.t4	PF.t5
15	1.56	1.19	1.13	1.08	1.19
20	1.41	1.15	1.16	1.12	1.20
25	1.46	1.14	1.26	1.14	1.24
30	1.44	1.25	1.36	1.21	1.36
35	1.42	1.47	1.57	1.34	1.45
40	1.37	1.59	1.87	1.52	1.53
45	1.40	1.69	2.22	1.75	1.70
")

# pdf(file = paste0(results_dir, ANALYSIS, '_DistPF.pdf'), width = 7, height = 4)
# matplot(serie[,-1],type ='l',col=c('black','red','blue','grey','forestgreen'),
#         lwd=2, ylim=c(0.5,2.5), lty=c(1,2,3,4,5), main='Séries PF no tempo',
#         xlab='Distribuição da série P/F', ylab='Razão PF') 
# grid(7,5,lwd=2)
# legend("topleft", legend=c('tempo 1','tempo 2','tempo 3','tempo 4','tempo 5'),
#        col=c('black','red','blue','grey','forestgreen'), 
#        lty=c(1,2,3,4,5)) 
# dev.off()
# #####

message("exportando resultados do P/F de Brass para ", ARG_SUBGRP, " ano ", ARG_ANO)
resultado |>
  as_tibble() |>
  transmute(
    subgrp = ARG_SUBGRP,
    fx_idade = paste0(idade,'-',idade+5-1),
    ano = ARG_ANO,
    key = ARG_KEY,
    value = fi.aj
  ) |>
  write_csv(
    file = ARG_OUTPUT_FILE,
    append = ARG_APPEND
  )

message("gráfico comparativo da TEF original e TEF P/F Brass para ", ARG_SUBGRP, " ano ", ARG_ANO)
plt <-
  resultado |>
  as_tibble() |>
  mutate(
    fx_idade = paste0(idade, '-', idade+5-1)
  ) |>
  pivot_longer(
    cols = c(fi, fi.aj)
  ) |>
  mutate(
    name = case_match(
      name,
      'fi' ~ 'TEF Observada',
      'fi.aj' ~ 'TEF Ajustada P/F Brass'
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


message("gráfico da série P/F Brass para ", ARG_SUBGRP, " ano ", ARG_ANO)
plt <- 
  dado |>
  as_tibble() |>
  transmute(
    fx_idade = factor(idade),
    serie_pf = P_F
  ) |>
  ggplot( aes(x=fx_idade, y=serie_pf, group = 1)) + 
  ylim(0, max(dado$P_F*1.1)) + 
  geom_line() + 
  labs(
    x = "Faixa etária",
    y = 'Razão P/F'
  )

ggsave(
  filename = paste0(results_dir, ANALYSIS, '_seriePF.pdf'),
  plot = plt,
  width = 7,
  height = 4
)


message("exportando parâmetros P/F Brass em disco...")
bind_rows(
  tibble(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    key = 'P1/P2',
    value = dado$P[1]/dado$P[2]
  ),
  tibble(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    key = 'F1/F2',
    value = dado$F[1]/dado$F[2]
  ),
  tibble(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    key = 'm',
    value = idad.m
  )
) |>
  write_csv(
    file = paste0(results_dir, "fec_params_pf.csv"),
    append=TRUE
  )

tic()
message("exportando série P/F para gráfico único...")
dado |>
  as_tibble() |>
  transmute(
    ano = ARG_ANO,
    categ = ARG_SUBGRP,
    key = factor(idade),
    value = P_F
  ) |>
  write_csv(
    paste0(results_dir, "fec_pf_series.csv"),
    append=TRUE
  )
toc()