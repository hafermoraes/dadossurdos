# docker buildx build -t dadossurdos -f Dockerfile .

# FROM rocker/rstudio:4.4.1

# RUN Rscript -e "Sys.setenv('NOT_CRAN' = 'true'); install.packages('arrow')"

# RUN mkdir -p /home/rstudio/br_ibge_pns_2019

# COPY pns/data/* /home/rstudio/br_ibge_pns_2019/


FROM rhub/r-minimal:4.5

RUN apk add curl coreutils

RUN installr -d readr readxl tidyr dplyr stringr

# https://github.com/r-hub/r-minimal/blob/main/examples/arrow/Dockerfile
RUN mkdir -p ~/.R && echo "LDFLAGS+=-fPIC" >> ~/.R/Makevars

RUN installr -d \
    -t "make openssl-dev cmake linux-headers apache-arrow-dev" \
    -a "openssl libarrow_dataset libarrow" arrow@14.0.2.1

WORKDIR /home/etl/br_ibge_pns_2019

COPY ./br_ibge_pns_2019/etl.sh ./br_ibge_pns_2019/parse_variables_dictionary.R /home/etl/br_ibge_pns_2019/

RUN sh etl.sh

