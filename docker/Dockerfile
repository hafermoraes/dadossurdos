
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

RUN R --quiet --vanilla -e "install.packages( c( 'survey', 'srvyr' ) )"

WORKDIR /home/rstudio/

ENV host_git_repo=/home/rmoraes/git/dadossurdos

# build container with ./analyses folder into it
COPY $host_git_repo/analyses/ .

# Data Ingestion
ENV data_folder=/tmp/etl

# IBGE/PNS2019 processed data
ENV br_ibge_pns_2019=$data_folder/br_ibge_pns_2019/data
COPY $br_ibge_pns_2019/microdata.parquet $br_ibge_pns_2019/variables_dictionary.txt $br_ibge_pns_2019/
