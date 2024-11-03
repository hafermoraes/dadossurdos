#!/bin/bash

# (https://askubuntu.com/a/1455039)
set -eu

echo "extração e preparação dos microdados para =br-ibge-censo-2010=\n"

# endereço na internet no qual estão armazenados os microdados e o dicionário de variáveis
base_url=ftp://ftp.ibge.gov.br
base_url=${base_url}/Censos
base_url=${base_url}/Censo_Demografico_2010
base_url=${base_url}/Resultados_Gerais_da_Amostra
base_url=${base_url}/Microdados
mdata_url=${base_url}
vdict_url=${base_url}/Documentacao.zip

# diretórios nos quais serão armazenados os dados brutos (raw), tratados (data) e
# convertidos no formato parquet para agilidade e menor espaço
src_dir=/tmp/etl/br_ibge_censo_2010
raw_data=${src_dir}/raw
proc_data=${src_dir}/data
parq_data=${src_dir}/parquet

create_temporary_directories(){

    echo "Criando diretórios temporários para dados brutos em $raw_data..."
    rm -rf ${raw_data}
    mkdir -p ${raw_data}

    echo "Criando diretórios temporários para dados tratados em $proc_data..."
    rm -rf ${proc_data}
    mkdir -p ${proc_data}

    echo "Criando diretórios temporários para dados colunares em $parq_data..."
    rm -rf ${parq_data}
    mkdir -p ${parq_data}/domi
    mkdir -p ${parq_data}/pess
    mkdir -p ${parq_data}/emig
    mkdir -p ${parq_data}/mort

}

fetch_variables_dictionary(){

    echo "Baixando o dicionário de variáveis de $vdict_url..."
    R --quiet --vanilla -e "curl::curl_download( '${vdict_url}', '${raw_data}/vdict.zip' )"

    echo 'Descompactando o dicionário de variáveis do arquivo =vdict.zip=...'
    unzip ${raw_data}/vdict.zip -d ${raw_data}

    echo 'Removendo da pasta temporária o arquivo compactado =vdict.zip= file...'
    rm -rf ${raw_data}/vdict.zip

}

parse_variables_dictionary_using_GNU_R(){

    echo 'Prepara o dicionário de variáveis e tratamento dos microdados usando o GNU R'

    for gnur_script in ./gnur_vardict*.R
    do
        echo "Executando $gnur_script..."
        R CMD BATCH --quiet --vanilla $gnur_script
    done

    R CMD BATCH --quiet --vanilla ./gnur_parse_variables_dictionary.R
    
    rm *.Rout

}

fetch_and_convert_microdata_to_parquet_format(){

    # Censo 2010 possui 4 arquivos por estado:
    #  - domi, base de domicílios
    #  - pess, base de pessoas
    #  - emig, base de emigração
    #  - mort, base de mortalidade
    base="domi pess emig mort"

    for uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP1 SP2_RM TO; do

        echo "Baixando os microdados de ${mdata_url}/${uf}.zip..."
        R --quiet --vanilla -e "curl::curl_download( '${mdata_url}/$uf.zip', '${raw_data}/${uf}.zip' )"

        echo "Descompactando os microdados do arquivo ${uf}.zip em ${raw_data}/${uf}..."
        unzip ${raw_data}/$uf.zip -d ${raw_data}

        echo "Removendo da pasta temporária o arquivo compactado ${uf}.zip..."
        rm -rf ${raw_data}/$uf.zip

        echo "Tratando as bases de ${uf}..."

        for b in ${base}; do

            echo "  Base: ${b}"
            cut_args=$(cat ${proc_data}/cut_character_args_${b}.txt )

            for f in $(find ${raw_data}/ -print | grep -i ${b}); do

                echo "    Convertendo para csv o arquivo ${f}..."
                cut \
                    --output-delimiter=',' \
                    --characters=$cut_args \
                    ${f} | \
                    tr -d ' ' > \
                    ${proc_data}/microdata_${b}_${uf}.csv

                echo "    Removendo arquivo original ${f}..."
                rm ${f}

                echo "    Convertendo a base de csv para parquet em ${parq_data}/${b}/${uf}..."
                R CMD BATCH --quiet --vanilla "--args base='${b}' uf='${uf}'" ./gnur_transform_csv_into_parquet.R

                echo "    Removendo o arquivo ${proc_data}/microdata_${b}_${uf}.csv..."
                rm ${proc_data}/microdata_${b}_${uf}.csv
            done
        done

    done

    # remove arquivos temporários do GNU R do diretório
    rm *.{Rout,out}
}

main(){

    create_temporary_directories

    fetch_variables_dictionary

    parse_variables_dictionary_using_GNU_R

    fetch_and_convert_microdata_to_parquet_format

}

main

exit 0
