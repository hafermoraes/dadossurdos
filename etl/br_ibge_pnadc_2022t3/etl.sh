#!/bin/bash

# shell script configs
set -eu

echo "=microdata= preparation scripts for br-ibge-pnadc-2022t3\n"

# urls where microdata and variables dictionary are located
base_url=ftp://ftp.ibge.gov.br/
base_url=${base_url}Trabalho_e_Rendimento/
base_url=${base_url}Pesquisa_Nacional_por_Amostra_de_Domicilios_continua/
base_url=${base_url}Anual/
base_url=${base_url}Microdados/
base_url=${base_url}Trimestre/
base_url=${base_url}Trimestre_3
mdata_url=${base_url}/Dados/PNADC_2022_trimestre3.zip
vdict_url=${base_url}/Documentacao/dicionario_PNADC_microdados_trimestre3_20240619.xls

# source and directories where raw and processed data are to be stored
src_dir=/tmp/etl/br_ibge_pnadc_2022t3
raw_data=${src_dir}/raw
proc_data=${src_dir}/data
parq_data=${src_dir}/parquet

create_temporary_directories(){

    echo "Creating temporary directory for raw data at $raw_data..."
    rm -rf ${raw_data}
    mkdir -p ${raw_data}

    echo "DONE.\nCreating temporary directory for processed data at $proc_data..."
    rm -rf ${proc_data}
    mkdir -p ${proc_data}
    mkdir -p ${parq_data}

    echo "DONE."
}

fetch_microdata(){

    echo "Fetching the =microdata= from $mdata_url..."
    R --quiet --vanilla -e "curl::curl_download( '${mdata_url}', '${raw_data}/mdata.zip' )"

    echo '  DONE. Unziping the =microdata=...'
    unzip ${raw_data}/mdata.zip -d ${raw_data}

    echo '  DONE. Deleting the downloaded =microdata= zip file...'
    rm -rf ${raw_data}/mdata.zip
    echo 'DONE.'

}

fetch_variables_dictionary(){

    echo "Fetching the dictionary of variables from $vdict_url..."
    R --quiet --vanilla -e "curl::curl_download( '${vdict_url}', '${raw_data}/vdict.xls' )"

    echo '  DONE.'

}

parse_variables_dictionary_using_GNU_R(){

    echo 'Parsing the variables dictionary using GNU R'
    R CMD BATCH --quiet --vanilla ./gnur_parse_variables_dictionary.R
    rm *.Rout

    echo 'DONE.'
}

prepare_microdata_for_data_ingestion(){

    echo 'Transforming microdata from fixed width format to delimited file...'

    # 'characters' argument from 'cut' function
    CHARACTERS_ARG=$(cat ${proc_data}/cut_characters_argument.txt)

    # from fixed width format to pipe (|) delimited text file
    cut \
        --output-delimiter=',' \
        --characters=$CHARACTERS_ARG \
        ${raw_data}/PNADC_2022_trimestre3.txt > \
        ${proc_data}/microdata.txt

    echo 'DONE.'
}

convert_microdata_to_parquet_using_arrow_and_GNU_R(){

    echo 'Converting the processed microdata to .parquet format using GNU R and arrow library...'
    R CMD BATCH --quiet --vanilla ./gnur_transform_microdata_into_parquet.R
    rm *.Rout

    echo 'DONE.'
}

remove_temporary_steps(){

    echo "Removing the temporary intermediate files"
    rm -rf ${raw_data}
    rm -rf ${proc_data}
    echo "DONE."
}

main(){

    create_temporary_directories

    fetch_microdata

    fetch_variables_dictionary

    parse_variables_dictionary_using_GNU_R

    prepare_microdata_for_data_ingestion

    convert_microdata_to_parquet_using_arrow_and_GNU_R

    remove_temporary_steps

}

main

exit 0
