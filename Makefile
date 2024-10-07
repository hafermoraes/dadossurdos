
# global variables
uid=$(shell id -u)
gid=$(shell id -g)
etl=${HOME}/git/dadossurdos/etl
etl_docker_image=rocker/tidyverse:4.4.1

# individual targets
br_ibge_pns_2019=/tmp/etl/br_ibge_pns_2019/data/microdata.parquet \
		 /tmp/etl/br_ibge_pns_2019/data/variables_dictionary.txt

br_ibge_pnadc_2022t3=/tmp/etl/br_ibge_pnadc_2022t3/data/microdata.parquet \
		     /tmp/etl/br_ibge_pnadc_2022t3/data/variables_dictionary.txt

# complete list of targets
targets=$(br_ibge_pns_2019) $(br_ibge_pnadc_2022t3)

all: $(targets)

# build Rstudio container when all sources are processed
build: $(targets)
	docker buildx build -t dadossurdos -f ${HOME}/git/dadossurdos/docker/Dockerfile /
	docker run -it --rm \
		--detach \
		--publish 8787:8787 \
		--env DISABLE_AUTH=true \
		dadossurdos
	@echo "Access RStudio web by visiting http://localhost:8787 ..."


# download and process data from 'br_ibge_pns_2019'
$(br_ibge_pns_2019): $(etl)/br_ibge_pns_2019/etl.org
	docker run -it --rm \
		--volume /tmp/:/tmp/ \
		--volume $(etl)/:/etl/ \
		--user ${uid}:${gid} \
		$(etl_docker_image) \
		sh -c "cd /etl/br_ibge_pns_2019 && sh etl.sh"

# download and process data from 'br_ibge_pnadc_2022t3'
$(br_ibge_pnadc_2022t3): $(etl)/br_ibge_pnadc_2022t3/etl.org
	docker run -it --rm \
		--volume /tmp/:/tmp/ \
		--volume $(etl)/:/etl/ \
		--user ${uid}:${gid} \
		$(etl_docker_image) \
		sh -c "cd /etl/br_ibge_pnadc_2022t3 && sh etl.sh"


