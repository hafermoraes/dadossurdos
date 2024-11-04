
# global variables
uid=$(shell id -u)
gid=$(shell id -g)
etl=${HOME}/git/dadossurdos/etl
etl_docker_image=rocker/tidyverse:4.4.1

# individual targets
# PNS 2013
br_ibge_pns_2013=/tmp/etl/br_ibge_pns_2013/parquet/microdata.parquet \
		 /tmp/etl/br_ibge_pns_2013/variables_dictionary.txt
# PNS 2019
br_ibge_pns_2019=/tmp/etl/br_ibge_pns_2019/parquet/microdata.parquet \
		 /tmp/etl/br_ibge_pns_2019/variables_dictionary.txt
# PNADC 2022/T3
br_ibge_pnadc_2022t3=/tmp/etl/br_ibge_pnadc_2022t3/parquet/microdata.parquet \
		     /tmp/etl/br_ibge_pnadc_2022t3/variables_dictionary.txt
# Censo 2000
c2000_bases=dom pes fami
c2000_ufs=AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO
br_ibge_censo_2000=$(foreach base, $(c2000_bases), $(foreach uf, $(c2000_ufs), /tmp/etl/br_ibge_censo_2000/parquet/$(base)/$(uf).parquet))
br_ibge_censo_2000+=/tmp/etl/br_ibge_censo_2000/variables_dictionary.txt
# Censo 2010
c2010_bases=domi pess emig mort
c2010_ufs=AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP1 SP2_RM TO
br_ibge_censo_2010=$(foreach base, $(c2010_bases), $(foreach uf, $(c2010_ufs), /tmp/etl/br_ibge_censo_2010/parquet/$(base)/$(uf).parquet))
br_ibge_censo_2010+=/tmp/etl/br_ibge_censo_2010/variables_dictionary.txt

# complete list of targets
targets=$(br_ibge_pns_2013) $(br_ibge_pns_2019) $(br_ibge_pnadc_2022t3) \
         $(br_ibge_censo_2000) $(br_igbe_censo_2010)

#targets=$(br_ibge_censo_2000)

#targets=$(br_igbe_censo_2010)

print:
	@echo $(targets)

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


# download and process data from 'br_ibge_pns_2013'
$(br_ibge_pns_2013): $(etl)/br_ibge_pns_2013/etl.org
	docker run -it --rm \
		--volume /tmp/:/tmp/ \
		--volume $(etl)/:/etl/ \
		--user ${uid}:${gid} \
		$(etl_docker_image) \
		sh -c "cd /etl/br_ibge_pns_2013 && sh etl.sh"

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

# download and process data from 'br_ibge_censo_2000'
$(br_ibge_censo_2000): $(etl)/br_ibge_censo_2000/etl.org
	docker run -it --rm \
		--volume /tmp/:/tmp/ \
		--volume $(etl)/:/etl/ \
		--user ${uid}:${gid} \
		$(etl_docker_image) \
		sh -c "cd /etl/br_ibge_censo_2000 && sh etl.sh"

# download and process data from 'br_ibge_censo_2010'
$(br_ibge_censo_2010): $(etl)/br_ibge_censo_2010/etl.org
	docker run -it --rm \
		--volume /tmp/:/tmp/ \
		--volume $(etl)/:/etl/ \
		--user ${uid}:${gid} \
		$(etl_docker_image) \
		sh -c "cd /etl/br_ibge_censo_2010 && sh etl.sh"


