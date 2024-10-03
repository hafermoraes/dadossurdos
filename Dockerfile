# docker buildx build -t dadossurdos -f Dockerfile .

# FROM rocker/rstudio:4.4.1

# RUN Rscript -e "Sys.setenv('NOT_CRAN' = 'true'); install.packages('arrow')"

# RUN mkdir -p /home/rstudio/br_ibge_pns_2019

# COPY pns/data/* /home/rstudio/br_ibge_pns_2019/


FROM rhub/r-minimal:4.5

RUN apk add curl

RUN installr -d readr readxl tidyr dplyr stringr arrow

RUN mkdir -p /home/etl/br_ibge_pns_2019

COPY ./br_ibge_pns_2019/etl.sh ./br_ibge_pns_2019/parse_variables_dictionary.R /home/etl/br_ibge_pns_2019/

