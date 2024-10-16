## gnur_vardict_typeA_metro.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "código da região metropolitana"
## cujo conteúdo nos microdados é formado por 2 caracteres
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # transmute, unique, rename,
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

## v1004 Código da Região Metropolitana (2 caracteres)
##
## Observação:
##  - embora indicado no dicionário de variáveis oficial do IBGE,
##    não consta dos arquivos a tabela com os códigos das regiões
##    metropolitanas, motivo pelo qual é necessário recorrer a
##    fontes não oficiais.
##    os dados são provenientes do repositório 'censobr' do ipeaGIT
##    https://github.com/ipeaGIT/censobr/blob/3a3fab5e97bc3a4baae3bb3ea5e3154e2651cebf/R/add_labels_families.R#L17
##    e foram acessados em 09.10.2024 às 18:35 (horário de Brasília)
##
tribble(
  ~var,    ~a_code, ~a_desc,
  'v1004',    '01', 'Belém',
  'v1004',    '02', 'Grande São Luís',
  'v1004',    '03', 'Fortaleza',
  'v1004',    '04', 'Natal',
  'v1004',    '05', 'Recife',
  'v1004',    '06', 'Maceió',
  'v1004',    '07', 'Salvador',
  'v1004',    '08', 'Belo Horizonte',
  'v1004',    '09', 'Colar Metropolitano da RM de Belo Horizonte',
  'v1004',    '10', 'Vale do Aço',
  'v1004',    '11', 'Colar Metropolitano da RM do Vale do Aço',
  'v1004',    '12', 'Grande Vitória',
  'v1004',    '13', 'Rio de Janeiro',
  'v1004',    '14', 'São Paulo',
  'v1004',    '15', 'Baixada Santista',
  'v1004',    '16', 'Campinas',
  'v1004',    '17', 'Curitiba',
  'v1004',    '18', 'Londrina',
  'v1004',    '19', 'Maringá',
  'v1004',    '20', 'Florianópolis',
  'v1004',    '21', 'Área de Expansão Metropolitana da RM de Florianópolis',
  'v1004',    '22', 'Núcleo Metropolitano da RM Vale do Itajaí',
  'v1004',    '23', 'Área de Expansão Metropolitana da RM Vale do Itajaí',
  'v1004',    '24', 'Norte/Nordeste Catarinense',
  'v1004',    '25', 'Área de Expansão Metropolitana da RM Norte/Nordeste Catarinense',
  'v1004',    '26', 'Porto Alegre',
  'v1004',    '27', 'Goiânia',
  'v1004',    '28', 'RIDE (Região Integrada de Desenvolvimento do Distrito Federal e Entorno)'
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeA_v1004.txt'
    ),
    delim = '|'
  )
