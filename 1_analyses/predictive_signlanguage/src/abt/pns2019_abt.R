library(dplyr)   # manipulação de dados
library(survey)  # amostragem complexa
library(tictoc)  # tempo de execução dos comandos
library(tidyr)   # pivot_wider
library(readr)   # write_csv
library(arrow)   # read_parquet, open_dataset, to_duckdb, collect
library(duckdb)

microdados <-
  open_dataset(
    "/tmp/etl/br_ibge_pns_2019/parquet"
  ) |>
  rename_with(tolower) |>
  filter(v0015 == '01', !is.na(v0015), m001 == '1', !is.na(m001)) |>
  select(
    v0024,v0029,upa_pns,
    v00292,v00293,
    v0001,c006,c008,c009,d001,c011,d00901,g058,g05801
  ) |>
  mutate(v0029=as.numeric(v0029)) |>
  collect()

## Survey design (source: https://rdrr.io/cran/PNSIBGE/src/R/pns_design.R, accessed on September, 2nd 2022)
options(survey.lonely.psu="adjust")
options(survey.adjust.domain.lonely=TRUE)

pns2019_prior <- survey::svydesign(
  ids = ~upa_pns,
  strata = ~v0024,
  data = microdados,
  weights = ~v0029,
  nest = TRUE
)

# Post-stratification
popc.types <-
  data.frame(
    v00293=as.character(unique(microdados$v00293)),
    Freq=as.numeric(unique(microdados$v00292))
  )
popc.types <- popc.types[order(popc.types$v00293),]
pns2019_posterior <-
  survey::postStratify(
    design=pns2019_prior,
    strata=~v00293,
    population=popc.types
  )



## matriz de modelo preditivo libras
abt <-
  svytable(
  formula=~v0001+c006+c008+c009+d001+c011+d00901+g058+g05801,
  design=pns2019_posterior
  ) |>
  as_tibble() |>
  filter(n>0) |>
  group_by(across(-n)) |>
  summarise(n=sum(n)) |>
  arrange(desc(n)) |>
  ungroup()

## abt |>
##   group_by(g05801) |>
##   summarise(count=sum(n))


pns2019_modelmatrix <-
  abt |>
  transmute(
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
      d00901 == '01' ~ 'outros',      # Creche
      d00901 == '02' ~ 'outros',      # Pré-escola
      d00901 == '03' ~ 'outros',      # Classe de alfabetização – CA
      d00901 == '04' ~ 'outros',      # Alfabetização de jovens e adultos
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
    # ___ tem dificuldade permanente de ouvir? (Para moradores com 5 anos ou mais de idade.)OU___ tem dificuldade permanente de ouvir sons como vozes ou música? (Para moradores com 2 a 4 anos de idade.)
    dif_ouvir = case_when(
      g058 == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
      g058 == '3' ~ 'grande',    # Sim, muita dificuldade
      g058 == '2' ~ 'alguma',    # Sim, alguma dificuldade
      g058 == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
      g058 == '9' ~ 'ignorado',  # ignorado
      TRUE ~ NA
    ),
    # . ___ tem dificuldade permanente de enxergar mesmo usando óculos, lentes de contato ou lupas?
    # dif_enxergar = case_when(
    #   g047 == '4' ~ 'incapaz',   # Sim, não consegue de modo algum
    #   g047 == '3' ~ 'grande',    # Sim, muita dificuldade
    #   g047 == '2' ~ 'alguma',    # Sim, alguma dificuldade
    #   g047 == '1' ~ 'nenhuma',   # Não, nenhuma dificuldade
    #   g047 == '9' ~ 'ignorado',  # ignorado
    #   TRUE ~ NA
    # ),
    # Sabe usar a Língua Brasileira de Sinais – Libras? (Para moradores com 5 anos ou mais de idade.)
    libras = case_when(
      g05801 == 1 ~ 'sim',
      g05801 == 2 ~ 'nao',
      TRUE ~ NA
    ),
    n
  ) |>
  group_by(across(-n)) |>
  summarise(n=sum(n)) |>
  arrange(desc(n)) |>
  ungroup() |>
  rename(case_weights = n)


pns2019_modelmatrix |> glimpse()

## cor_raca com categorias muito pequenas --> colapsar amarela+indigena+outros em 'outros'
pns2019_modelmatrix |>
  group_by(cor_raca) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))

## sexo
pns2019_modelmatrix |>
  group_by(sexo) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))

## alfabetizado
pns2019_modelmatrix |>
  group_by(alfabetizado) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))

## instrucao
pns2019_modelmatrix |>
  group_by(instrucao) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))

## estado_civil (juntar separado+viuvo)
pns2019_modelmatrix |>
  group_by(estado_civil) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))

## dif_ouvir
pns2019_modelmatrix |>
  group_by(dif_ouvir) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))

## libras
pns2019_modelmatrix |>
  group_by(libras) |>
  summarise(count=sum(case_weights)) |>
  mutate(pct=count/sum(count))


pns2019_modelmatrix %>% 
  select(libras,!where(is.numeric)) %>%
  mutate(
    across(everything(), as.character),
    libras = if_else( libras == 'sim', 1, 0)
  ) %>%
  drop_na() %>%
  pivot_longer(-libras, names_to = "Variables", values_to = "Values") %>%
  group_by(Variables, Values) %>% 
  summarise(mean = mean(libras),
            conf_int = 1.96*sd(libras)/sqrt(n())) %>% 
  ggplot(aes(x=Values, y=mean, color=Values)) +
  geom_point() +
  geom_errorbar(aes(ymin = mean - conf_int, ymax = mean + conf_int), width = 0.1) +
  theme(legend.position = "none") + 
  scale_color_viridis_d(aesthetics = c("color", "fill"), end = 0.5) +
  facet_wrap(~Variables, scales = 'free') +
  labs(title = 'Categorical Variable Analysis', subtitle = 'With 95% Confidence Intervals') + 
  coord_flip()



# importação das unidades da federação
uf <-
  read_delim(
    '/tmp/etl/br_ibge_pns_2019/variables_dictionary.txt',
    delim='|'
  ) |>
  filter( q_code == 'v0001') |>
  transmute( cod_uf = a_code, uf = a_desc)


pns2019_modelmatrix |>
  mutate(
    cor_raca = case_when(
      cor_raca == 'amarela' ~ 'outros',
      cor_raca == 'indigena' ~ 'outros',
      TRUE ~ as.character(cor_raca)
    ),
    estado_civil = case_when(
      estado_civil == 'separado' ~ 'outros',
      estado_civil == 'viuvo' ~ 'outros',
      TRUE ~ as.character(estado_civil)
    )
  ) |>
  left_join(uf, by=c('cod_uf'), keep = FALSE) |>
  select(-cod_uf) |>
  write_csv(
    '1_analyses/predictive_signlanguage/pns2019_modelmatrix.csv'
  )
