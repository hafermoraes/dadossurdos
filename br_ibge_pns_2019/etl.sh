#!/bin/bash

# shell script configs
set -eu

echo "Extract-Transform Scripts for IBGE/PNS2019\n"

# microdata (in text format)
mdata=ftp://ftp.ibge.gov.br/PNS/2019/Microdados/Dados/PNS_2019_20220525.zip

# dictionary of variables (needed to parse microdata)
vdict=ftp://ftp.ibge.gov.br/PNS/2019/Microdados/Documentacao/Dicionario_e_input_20220530.zip

# temporary directory
data=pns
tmpdir=/tmp/${data}/raw

# target directory
tgtdir=/tmp/$data/data

# sql query
query=/tmp/$data/data/create_tables.sql

check_if_dependencies_are_installed(){
    i=0

    if ! command -v curl >/dev/null 2>&1
    then
        echo "please install 'curl' to continue."
        i=1
    fi

    if ! command -v unzip >/dev/null 2>&1
    then
        echo "please install 'unzip' to continue."
        i=1
    fi

    if [ $i -gt 0 ];
    then
        echo 'please install the missing dependencies before proceeding.'
        exit 1
    fi
}

create_temporary_directories(){

    echo "Creating temporary directory $tmpdir..."
    rm -rf ${tmpdir}
    mkdir -p ${tmpdir}

    echo "DONE.\nCreating temporary directory $tgtdir..."
    rm -rf ${tgtdir}
    mkdir -p ${tgtdir}

    echo "DONE."
}

fetch_microdata(){

    echo "Fetching the microdata from $mdata..."
    curl ${mdata} -o ${tmpdir}/mdata.zip

    echo '  DONE. Unziping the microdata...'
    unzip ${tmpdir}/mdata.zip -d ${tmpdir}

    echo '  DONE. Deleting the downloaded microdata zip file...'
    rm -rf ${tmpdir}/mdata.zip
    echo 'DONE.'

}

fetch_variables_dictionary(){
    
    echo "Fetching the dictionary of variables from $vdict..."
    curl ${vdict} -o ${tmpdir}/vdict.zip

    echo '  DONE. Unziping the data dictionary...'
    unzip ${tmpdir}/vdict.zip -d ${tmpdir}
    
    echo '  DONE. Deleting the downloaded data dictionary zip file...'
    rm -rf ${tmpdir}/vdict.zip

}

parse_variables_dictionary_using_GNU_R(){

    echo 'Parsing the variables dictionary using GNU R'
    Rscript parse_variables_dictionary.R

    echo 'DONE.'    
}

prepare_microdata_for_data_ingestion(){

    echo 'Transforming microdata from fixed width format to delimited file...'

    # 'characters' argument from 'cut' function
    CHARACTERS_ARG=$(cat /tmp/pns/data/cut_characters)

    # from fixed width format to pipe (|) delimited text file
    cut \
        --output-delimiter='|' \
        --characters=$CHARACTERS_ARG \
        /tmp/pns/raw/PNS_2019.txt > \
        /tmp/pns/data/pns2019_microdata.txt

    echo 'DONE.'

}

prepare_data_ingestion_sql_query(){

    echo "Preparing SQL script for creating the database schema and tables..."
    
    cat > ${query} <<EOF
-- cria schema ~pns2019~ para a edição 2019 da PNS
          create schema pns2019;

-- dicionário de dados (explicação de colunas e respostas)
-- drop table if exists ed2019.datadict;
           create table pns2019.datadict (
                        part text,
                        module text,
                        var text,
                        q_code text,
                        q_desc text,
                        a_code text,
                        a_desc text
                        );

-- importa dicionário de dados brutos na tabela ~datadict~
EOF

    echo "copy pns2019.datadict from '${tgtdir}/pns2019_variables_dictionary.txt' delimiter '|' csv; -- dados sem cabeçalho\n" >> ${query}

    cat >> ${query} <<EOF
-- microdados separados por variavel
--   drop table if exists ed2019.microdata;
           create table pns2019.microdata (
EOF

    cat ${tgtdir}/create_table_fields >> ${query}
    
    cat >> ${query} <<EOF
);

-- importa microdados brutos na tabela microdata
EOF

    echo "copy pns2019.microdata from '${tgtdir}/pns2019_microdata.txt' delimiter '|' csv; -- microdados sem cabeçalho\n" >> ${query}

    echo "DONE."
}

main(){

    check_if_dependencies_are_installed

    create_temporary_directories
    
    fetch_microdata
    
    fetch_variables_dictionary

    parse_variables_dictionary_using_GNU_R

    prepare_microdata_for_data_ingestion

    prepare_data_ingestion_sql_query
}

main

exit 0
