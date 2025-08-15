
library(dplyr)   # |>, mutate, glimpse
library(readr)   # read_csv
library(tidyr)   # pivot_longer
library(ggplot2) # ggplot

# importação da matriz de modelo
rawdata <-
  read_csv(
    '1_analyses/predictive_signlanguage/data/pns2019_modelmatrix.csv'
  ) |> 
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


# facets com geom_errorbar
# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/

rawdata %>% 
  select(libras,!where(is.numeric)) %>%
  mutate(
    across(everything(), as.character),
    libras = if_else( libras == 'sim', 1, 0)
  ) %>%
  #drop_na() %>% 
  pivot_longer(2:8, names_to = "Variables", values_to = "Values") %>%
  group_by(Variables, Values) %>% 
  summarise(mean = mean(libras),
            conf_int = 1.96*sd(libras)/sqrt(n())) %>% 
  ggplot(aes(x=Values, y=mean, color=Values)) +
  geom_point() +
  geom_errorbar(aes(ymin = mean - conf_int, ymax = mean + conf_int), width = 0.1) +
  #theme_minimal() +
  theme(legend.position = "none")+ 
  scale_color_viridis_d(aesthetics = c("color", "fill"), end = 0.5) +
  facet_wrap(~Variables, scales = 'free') +
  labs(title = 'Categorical Variable Analysis', subtitle = 'With 95% Confidence Intervals') + 
  coord_flip()

# correlações
install.packages('corrr')
library(corrr)
library(recipes)

recipe_basic <-
  recipe(libras ~ ., data = rawdata) |>
  step_dummy(all_nominal_predictors())

recipe <- prep(recipe_basic, training = rawdata)
imputed <- bake(recipe, rawdata)

# adaptado de https://towardsdatascience.com/bank-customer-churn-with-tidymodels-part-1-model-development-cdec4eeb131c/
x <- 
  imputed %>% 
  mutate(
    libras = if_else( libras == 'sim', 1, 0)
  ) %>% 
  select(-case_weights) %>% 
  corrr::correlate() 

x <- corrr::rearrange(x, absolute = FALSE) 

x<- corrr::shave(x) 

corrr::rplot(x, print_cor = T) +
  scale_color_gradient2(low = 'orange', high = 'light blue') + 
  theme(axis.text.x = element_text(angle = 90)) +
  labs(title = "Correlation Plot")
