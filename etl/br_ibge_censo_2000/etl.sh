#!/bin/bash

# (https://askubuntu.com/a/1455039)
set -eu

echo "extração e preparação dos microdados para =br-ibge-censo-2000=\n"

# endereço na internet no qual estão armazenados os microdados e o dicionário de variáveis
base_url=ftp://ftp.ibge.gov.br
base_url=${base_url}/Censos
base_url=${base_url}/Censo_Demografico_2000
base_url=${base_url}/Microdados
mdata_url=${base_url}
vdict_url=${base_url}/1_Documentacao_20170908.zip

# diretórios nos quais serão armazenados os dados brutos (raw), tratados (data) e
# convertidos no formato parquet para agilidade e menor espaço
src_dir=/tmp/etl/br_ibge_censo_2000
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
    mkdir -p ${parq_data}
    mkdir -p ${parq_data}/dom
    mkdir -p ${parq_data}/pes
    mkdir -p ${parq_data}/fami

}

fetch_variables_dictionary(){

    echo "Baixando o dicionário de variáveis de $vdict_url..."
    R --quiet --vanilla -e "curl::curl_download( '${vdict_url}', '${raw_data}/vdict.zip' )"

    echo 'Descompactando o dicionário de variáveis do arquivo =vdict.zip=...'
    unzip ${raw_data}/vdict.zip -d ${raw_data}

    echo 'Removendo da pasta temporária o arquivo compactado =vdict.zip= file...'
    rm -rf ${raw_data}/vdict.zip

    echo 'Removendo caracteres dos scripts SAS para melhor tratamento no R...'
    # https://stackoverflow.com/a/1806950
    for s in ${raw_data}/SAS/*; do
        mv "$s" `echo $s | sed -e 's/ /_/g'`;
    done

    # é necessário remover tabs (\t), aspas duplas, comentários (/* */) e cifrões ($)
    for f in $(find ${raw_data}/SAS -type f | grep sas); do
        cat ${f} | \
                sed 's/\t/    /g' | \
                sed 's/\$//g' | \
                sed 's/\"//g' | \
                sed 's/\/\*//g' | \
                sed 's/\*\///g' > /tmp/aux
        mv /tmp/aux $f
    done

}

parse_variables_dictionary_using_GNU_R(){

    echo 'Prepara o dicionário de variáveis e tratamento dos microdados usando o GNU R'

    for gnur_script in ./gnur_vardict*.R
    do
        echo "Executando $gnur_script..."
        R CMD BATCH --quiet --vanilla $gnur_script
    done

    echo 'Consolidando os dicionários de variáveis tratadas em um único arquivo...'
    R CMD BATCH --quiet --vanilla ./gnur_aggregating_variables_dictionary.R

    rm -rf *.Rout

}

fetch_and_convert_microdata_to_parquet_format(){

    # Censo 2000 possui 3 arquivos por estado:
    #  - dom, base de domicílios
    #  - pes, base de pessoas
    #  - fami, base de famílias
    base="dom pes fami"

    for uf in AC AL AM AP BA CE DF ES GO MA MG MS MT PA PB PE PI PR RJ RN RO RR RS SC SE SP TO; do

        echo "Baixando os microdados de ${mdata_url}/${uf}.zip..."
        R --quiet --vanilla -e "curl::curl_download( '${mdata_url}/$uf.zip', '${raw_data}/${uf}.zip' )"

        echo "Descompactando os microdados do arquivo ${uf}.zip em ${raw_data}/${uf}..."
        unzip -o ${raw_data}/$uf.zip -d ${raw_data}

        echo "Removendo da pasta temporária o arquivo compactado ${uf}.zip..."
        rm -rf ${raw_data}/$uf.zip
        
        echo "Descompactando os arquivos zip dentro do arquivo ${uf}.zip..."
        for z in $(find ${raw_data}/ -print | grep -i zip ); do
            unzip -o $z -d ${raw_data}
            rm -rf $z
        done

        if [ "$uf" = "RN" ]; then
            echo "Ignorando duplicidade de PB (cod_uf == 25) no RN.zip..."
            for dup in $(find ${raw_data}/ -print | grep -i txt | grep 25); do
                rm -rf $dup
            done
        fi

        echo "Tratando as bases de ${uf}..."

        for b in ${base}; do

            echo "  Base: ${b}"
            cut_args=$(cat ${proc_data}/cut_character_args_${b}.txt )

            for f in $(find ${raw_data}/ -print | grep -i txt | grep -i ${b}); do

                line_count=$(wc -l ${f} | cut -d' ' -f1)

                # os arquivos originais postados pelo ibge em seu servidor ftp
                # contém caracteres binários (^M, ^Z, \r) introduzidos no
                # momento da gravação em disco provavelmente no sistema
                # operacional windows.
                # Antes de qualquer outro passo, esses caracteres precisam ser
                # removidos, sem o que não é possível seguir com o tratamento
                # dos microdados em sistemas operacionais livres como GNU/Linux

                echo "    Removendo caracteres especiais de ${f}..."
                sed -e 's/\r//g' ${f} | \
                    tr -d '\032' > \
                       /tmp/mdata

                mv -f /tmp/mdata ${f}
                
                # cada arquivo precisa ter um tamanho fixo de linhas
                #   fami: 118
                #     dom: 170
                #      pes: 390
                # esse passo é necessário pois há linhas de arquivos com menos
                # caracteres conforme relação acima.
                #
                # esses números estão no argumento LRECL na linha que começa
                # com FILENAME dos scripts do SAS.
                #
                # quando esta regra é violada isso indica que o arquivo original
                # postado pelo IBGE contém linhas com menos caracteres do que o
                # o número indicado no próprio dicionário de variáveis e o
                # tratamento de dados não é mais possível.

                # a variável line_length abaixo retorna os comprimentos de linha
                # distintos do arquivo de microdados.
                #
                # se a contagem é igual a 1 então 100% das linhas têm o mesmo
                # comprimento.
                #
                # se a contagem não é igual a 1 é necessário
                # preencher as linhas com espaços à direita até que o comprimento
                # seja atingido.
                #
                # sem isso o tratamento dos dados quebra...
                #
                line_length=$(awk '{print length}' ${f} | uniq | wc -l)
                # linha-a-linha demora muito e inviabiliza o tratamento dos dados
                #
                #    while read -r line; do
                #        printf "%-170s\n" "$line" >> /tmp/tmpfix;
                #    done < ${f}
                #    mv -f /tmp/tmpfix ${f}
                
                # variante com awk é muito mais rápida...
                #   https://www.linuxquestions.org/questions/programming-9/shell-question-pad-end-of-each-line-with-spaces-to-%3D-80-chars-875082/
                #
                #   awk -F '|' '{printf "%-170s\n", $1}' ${f} > /tmp/tmpfix
                #

                if [ "$b" = "dom" ]; then
                    if [ $line_length != 1 ]; then

                        # completa cada linha da base de domicílios com 170 caracteres
                        # linhas com menos de 170 serão completadas com espaços ' ' à
                        # direita.

                        echo "    Consertando linha a linha as ${line_count} linhas do txt original..."

                        awk -F '|' '{printf "%-170s\n", $1}' ${f} > /tmp/tmpfix
                        mv -f /tmp/tmpfix ${f}                        
                    fi
                fi

                if [ "$b" = "fami" ]; then
                    if [ $line_length != 1 ]; then

                        # completa cada linha da base de famílias com 118 caracteres
                        # linhas com menos de 118 serão completadas com espaços ' ' à
                        # direita.
                        
                        echo "    Consertando linha a linha as ${line_count} linhas do txt original..."

                        awk -F '|' '{printf "%-118s\n", $1}' ${f} > /tmp/tmpfix
                        mv -f /tmp/tmpfix ${f}
                    fi
                fi

                if [ "$b" = "pes" ]; then
                    if [ $line_length != 1 ]; then
                        # completa cada linha da base de pessoas com 390 caracteres
                        # linhas com menos de 390 serão completadas com espaços ' ' à
                        # direita.

                        echo "    Consertando linha a linha as ${line_count} linhas do txt original..."

                        awk -F '|' '{printf "%-390s\n", $1}' ${f} > /tmp/tmpfix
                        mv -f /tmp/tmpfix ${f}
                        
                    fi
                fi

                echo "    Convertendo para csv o arquivo ${f}..."
                cut \
                    --output-delimiter=',' \
                    --characters=$cut_args \
                    ${f} | \
                    tr -d ' ' > \
                    ${proc_data}/microdata_${b}_${uf}.csv

                echo "    Removendo arquivo original ${f}..."
                rm -rf ${f}

                echo "    Convertendo a base de csv para parquet em ${parq_data}/${b}/${uf}..."
                R CMD BATCH --quiet --vanilla "--args base='${b}' uf='${uf}'" ./gnur_transform_csv_into_parquet.R

                echo "    Removendo o arquivo ${proc_data}/microdata_${b}_${uf}.csv..."
                rm -rf ${proc_data}/microdata_${b}_${uf}.csv
            done
        done

    done

    # remove arquivos temporários do GNU R do diretório
    rm -rf *.{Rout,out}
}

remove_temporary_steps(){

    echo "Removing the temporary intermediate files"
    rm -rf ${raw_data}
    rm -rf ${proc_data}
    echo "DONE."
}

main(){

    create_temporary_directories

    fetch_variables_dictionary

    parse_variables_dictionary_using_GNU_R

    fetch_and_convert_microdata_to_parquet_format

    remove_temporary_steps

}

main

exit 0
