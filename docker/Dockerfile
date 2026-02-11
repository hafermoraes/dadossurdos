
# etl is to be orchestrated from a Makefile using
#     docker run -it --rm \
#            -v /tmp/:/tmp/ \
#            -v $HOME/git/dadossurdos/etl/:/etl/ \
#            rocker/tidyverse:4.4.1 \
#            sh -c "cd /etl/br_ibge_pns_2019 && sh etl.sh"



# from the repo's base directory, build image with:
#    docker buildx build -t dadossurdos -f ~/git/dadossurdos/docker/Dockerfile /

# run Rstudio inside container with
#    docker run -it --rm -p 8787:8787 -e DISABLE_AUTH=true dadossurdos

# Note: This rocker image contains all needed packages for etl and analyses purposes
FROM rocker/tidyverse:4.4.1

RUN apt-get update \
    && apt-get install -y --no-install-recommends \
    libudunits2-dev \
    libproj-dev \
    libgdal-dev \
    libglpk-dev \
    && rm -rf /var/lib/apt/lists/*

RUN Rscript -e "install.packages(\
    c( \
    'survey', \
    'srvyr', \
    'tictoc', \
    'censobr', \
    'tidymodels', \
    'vip', \
    'ggmosaic', \
    'arrow', \
    'duckdb', \
    'probably', \
    'discrim', \
    'geobr', \
    'DDM', \
    'corrr', \
    'mosaic', \
    'textrecipes', \
    'janitor', \
    'themis', \
    'lightgbm', \
    'xgboost', \
    'glmnet', \
    'ranger', \
    'naivebayes', \
    'finetune', \
    'doParallel', \
    'earth', \
    'lme4', \
    'kernlab', \
    'betacal', \
    'NeuralNetTools', \
    'parsnip', \
    'hardhat', \
    'sparsevctrs', \
    'bonsai', \
    'baguette', \
    'brulee', \
    'solitude', \
    'tailor'\
    )\
    )"

WORKDIR /home/rstudio/

ENV host_git_repo=/home/rmoraes/git/dadossurdos

# build container with ./analyses folder into it
# COPY $host_git_repo/analyses/ .

# Data Ingestion
ENV data_folder=/tmp/etl

# IBGE/PNS2013 processed data
ENV br_ibge_pns_2013=$data_folder/br_ibge_pns_2013/
COPY $br_ibge_pns_2013 $br_ibge_pns_2013

# IBGE/PNS2019 processed data
ENV br_ibge_pns_2019=$data_folder/br_ibge_pns_2019/
COPY $br_ibge_pns_2019 $br_ibge_pns_2019

# IBGE/PNADC2022t3 processed data
ENV br_ibge_pnadc_2022t3=$data_folder/br_ibge_pnadc_2022t3/
COPY $br_ibge_pnadc_2022t3 $br_ibge_pnadc_2022t3

# IBGE/Censo2000 processed data
ENV br_ibge_censo_2000=$data_folder/br_ibge_censo_2000/
COPY $br_ibge_censo_2000 $br_ibge_censo_2000

# IBGE/Censo2010 processed data
ENV br_ibge_censo_2010=$data_folder/br_ibge_censo_2010/
COPY $br_ibge_censo_2010 $br_ibge_censo_2010
