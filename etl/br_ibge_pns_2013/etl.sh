#!/bin/bash

# shell script configs
set -eu

echo "=microdata= preparation scripts for br-ibge-pns-2013\n"

# urls where microdata and variables dictionary are located
mdata_url=ftp://ftp.ibge.gov.br/PNS/2013/Microdados/Dados/PNS_2013.zip
vdict_url=ftp://ftp.ibge.gov.br/PNS/2013/Microdados/Documentacao/Dicionario_e_input_20200930.zip

# source and directories where raw and processed data are to be stored
src_dir=/tmp/etl/br_ibge_pns_2013
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

    rm -rf ${parq_data}
    mkdir -p ${parq_data}

    echo "DONE."
}

fetch_microdata(){

    echo "Fetching the =microdata= from $mdata_url..."
    #curl ${mdata_url} -o ${raw_data}/mdata.zip
    R --quiet --vanilla -e "curl::curl_download( '${mdata_url}', '${raw_data}/mdata.zip' )"

    echo '  DONE. Unziping the =microdata=...'
    unzip ${raw_data}/mdata.zip -d ${raw_data}

    echo '  DONE. Deleting the downloaded =microdata= zip file...'
    rm -rf ${raw_data}/mdata.zip
    echo 'DONE.'

}

fetch_variables_dictionary(){

    echo "Fetching the dictionary of variables from $vdict_url..."
    # curl ${vdict_url} -o ${raw_data}/vdict.zip
    R --quiet --vanilla -e "curl::curl_download( '${vdict_url}', '${raw_data}/vdict.zip' )"

    echo '  DONE. Unziping the data dictionary...'
    unzip ${raw_data}/vdict.zip -d ${raw_data}

    echo '  DONE. Deleting the downloaded data dictionary zip file...'
    rm -rf ${raw_data}/vdict.zip

}

parse_variables_dictionary_using_GNU_R(){

    echo 'Parsing the variables dictionary using GNU R'
    cp ./gnur_parse_variables_dictionary.R ${src_dir}/gnur_parse_variables_dictionary.R
    R CMD BATCH --quiet --vanilla ${src_dir}/gnur_parse_variables_dictionary.R
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
        ${raw_data}/PNS_2013.txt > \
        ${proc_data}/microdata.txt

    echo 'DONE.'
}

convert_microdata_to_parquet_using_arrow_and_GNU_R(){

    echo 'Converting the processed microdata to .parquet format using GNU R and arrow library...'
    cp ./gnur_transform_microdata_into_parquet.R ${src_dir}/gnur_transform_microdata_into_parquet.R
    R CMD BATCH --quiet --vanilla ${src_dir}/gnur_transform_microdata_into_parquet.R
    rm *.Rout
    echo 'DONE.'
}

main(){

    create_temporary_directories

    fetch_microdata

    fetch_variables_dictionary

    parse_variables_dictionary_using_GNU_R

    prepare_microdata_for_data_ingestion

    convert_microdata_to_parquet_using_arrow_and_GNU_R

}

main

exit 0
