
# global variables
etl=${HOME}/git/dadossurdos/etl
etl_docker_image=rocker/tidyverse:4.4.1

# individual targets
br_ibge_pns_2019=/tmp/etl/br_ibge_pns_2019/data/microdata.parquet \
		 /tmp/etl/br_ibge_pns_2019/data/variables_dictionary.txt

# complete list of targets
targets=$(br_ibge_pns_2019)

all: $(targets)

# download and process data from 'br_ibge_pns_2019'
$(br_ibge_pns_2019): $(etl)/br_ibge_pns_2019/etl.org
	docker run -it --rm \
		--volume /tmp/:/tmp/ \
		--volume $(etl)/:/etl/ \
		$(etl_docker_image) \
		sh -c "cd /etl/br_ibge_pns_2019 && sh etl.sh"

