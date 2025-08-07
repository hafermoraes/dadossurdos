
library(dplyr)   # |>, mutate, glimpse
library(readr)   # read_csv
library(tidyr)   # pivot_longer
library(ggplot2) # ggplot

# importação das unidades da federação
uf <-
  read_delim(
    '/tmp/etl/br_ibge_pns_2019/variables_dictionary.txt',
    delim='|'
  ) |>
  filter( q_code == 'v0001') |>
  transmute( cod_uf = as.numeric(a_code), uf = a_desc)

uf |> glimpse()

# importação dos dados da pns2019
rawdata <-
  read_csv(
    '1_analyses/predictive_signlanguage/pns2019_subset.csv'
  ) |> 
  left_join(uf, by=c('cod_uf'), keep = FALSE) |>
  select(-cod_uf) |>
  mutate(across(where(is.character), as.factor))

# checagem dos dados importados
rawdata |> glimpse()

# desbalanceio de classe...
rawdata |>
  group_by(libras) |>
  summarise( n =sum(case_weights)) |>
  mutate( pct = n/sum(n))

# mosaic plots
install.packages('ggmosaic')
library(ggmosaic)

# libras vs dif_ouvir
ggplot(data = rawdata) +
  geom_mosaic(aes(x = product(dif_ouvir), fill=libras)) + 
  coord_flip() + 
  labs(title='f(dif_ouvir)')

# libras vs instrucao
ggplot(data = rawdata) +
  geom_mosaic(aes(x = product(instrucao), fill=libras)) + 
  labs(title='f(instrucao)')

# libras vs alfabetizado
ggplot(data = rawdata) +
  geom_mosaic(aes(x = product(alfabetizado), fill=libras)) + 
  labs(title='f(alfabetizado)')

# libras vs sexo
ggplot(data = rawdata) +
  geom_mosaic(aes(x = product(sexo), fill=libras)) + 
  labs(title='f(sexo)')

# libras vs cor_raca
ggplot(data = rawdata) +
  geom_mosaic(aes(x = product(cor_raca), fill=libras)) + 
  labs(title='f(cor_raca)') +
  coord_flip()

# libras vs estado_civil
ggplot(data = rawdata) +
  geom_mosaic(aes(x = product(estado_civil), fill=libras)) + 
  labs(title='f(estado_civil)')

# libras vs uf
ggplot(data = rawdata) +
  geom_mosaic(aes(x = product(uf), fill=libras)) + 
  coord_flip() +
  labs(title='f(uf)')

# libras vs idade
ggplot(data = rawdata) + 
  geom_boxplot( aes(x = libras, y=idade, fill = libras))

ggplot(data = rawdata) + 
  geom_mosaic( aes(x = product(idade), fill = libras)) + 
  coord_flip()

ggplot(data = rawdata) +
  geom_density( aes(x=idade, fill = libras), alpha = 0.2) + 
  facet_wrap( ~ dif_ouvir)


# df_long <-
#   rawdata |>
#   pivot_longer(
#     !libras, 
#     names_to = 'features', 
#     values_to = 'values'
#     )

