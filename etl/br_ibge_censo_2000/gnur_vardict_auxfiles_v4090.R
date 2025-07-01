## gnur_vardict_auxfiles_v4090.R
##
##
## br_ibge_censo_2000
##
## -------------------------------------------------------------------
## Preparação da variável 'código da religião'
## -------------------------------------------------------------------
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble
library(tidyr)    # expand_grid

## ftp://ftp.ibge.gov.br/Censos/Censo_Demografico_2000/Microdados/1_Documentacao_20170908.zip
## era o endereço da fonte primária no momento em que este script
## foi programado em 19.10.2024.
##
## Este arquivo é então descompactado no diretório salvo na variável
## 'base_dir' a seguir
##
base_dir <- '/tmp/etl/br_ibge_censo_2000/'

## Nota: O dicionário de variáveis da religão para o censo de 2000 está
##       disponível somente em formato Microsoft Word, inviabilizando
##       um tratamente decente dos dados usando softwares livres de forma
##       automatizada e sem intervenção humana. Por esse motivo, optou-se
##       por converter os dados manualmente em uma planilha no software
##       Libreoffice Calc e exportar os dados já tratados nas linhas de
##       código a seguir.
input <- tribble(
  ~q_code,  ~a_code, ~a_desc,
  'v4090',    '110', 'Católica Apostólica Romana',
  'v4090',    '111', 'Católica Carismática, Católica Pentecostal',
  'v4090',    '112', 'Católica Armênia; Católica Ucraniana',
  'v4090',    '120', 'Católica Apostólica Brasileira',
  'v4090',    '130', 'Católica Ortodoxa',
  'v4090',    '140', 'Ortodoxa Cristã',
  'v4090',    '149', 'Outras',
  'v4090',    '199', 'Outras Católicas',
  'v4090',    '210', 'Igrejas Luteranas',
  'v4090',    '219', 'Outras',
  'v4090',    '220', 'Igreja Evangélica Presbiteriana',
  'v4090',    '221', 'Igreja Presbiteriana Independente',
  'v4090',    '222', 'Igreja Presbiteriana do Brasil',
  'v4090',    '223', 'Igreja Presbiteriana Unida',
  'v4090',    '224', 'Presbiteriana Fundamentalista',
  'v4090',    '225', 'Presbiteriana Renovada',
  'v4090',    '229', 'Outras',
  'v4090',    '230', 'Igreja Evangélica Metodista',
  'v4090',    '231', 'Evangélica Metodista Wesleyana',
  'v4090',    '232', 'Evangélica Metodista Ortodoxa',
  'v4090',    '239', 'Outras',
  'v4090',    '240', 'Igreja Evangélica Batista',
  'v4090',    '241', 'Convenção Batista Brasileira',
  'v4090',    '242', 'Convenção Batista Nacional',
  'v4090',    '243', 'Batista Pentecostal',
  'v4090',    '244', 'Batista Bíblica',
  'v4090',    '245', 'Batista Renovada',
  'v4090',    '249', 'Outras',
  'v4090',    '250', 'Igreja Evangélica Congregacional',
  'v4090',    '251', 'Igreja Congregacional Independente',
  'v4090',    '259', 'Outras',
  'v4090',    '260', 'Igreja Evangélica Adventista do Sétimo Dia',
  'v4090',    '261', 'Igreja Evangélica Adventista Movimento de Reforma',
  'v4090',    '262', 'Igreja Evangélica Adventista da Promessa',
  'v4090',    '269', 'Outras',
  'v4090',    '270', 'Igreja Evangélica Episcopal Anglicana',
  'v4090',    '279', 'Outras',
  'v4090',    '280', 'Igreja Evangélica Menonita',
  'v4090',    '289', 'Outras',
  'v4090',    '300', 'Exército da Salvação',
  'v4090',    '310', 'Igreja Evangélica Assembléia de Deus',
  'v4090',    '311', 'Igreja Assembléia de Deus Madureira',
  'v4090',    '312', 'Igreja Assembléia de Deus Todos os Santos',
  'v4090',    '319', 'Outras',
  'v4090',    '320', 'Igreja Congregacional Cristã do Brasil',
  'v4090',    '329', 'Outras',
  'v4090',    '330', 'Igreja Evangélica Pentecostal O Brasil Para Cristo',
  'v4090',    '339', 'Outras',
  'v4090',    '340', 'Igreja Evangelho Quadrangular',
  'v4090',    '349', 'Outras',
  'v4090',    '350', 'Igreja Universal do Reino de Deus',
  'v4090',    '359', 'Outras',
  'v4090',    '360', 'Igreja Evangélica Casa da Benção',
  'v4090',    '369', 'Outras',
  'v4090',    '370', 'Igreja Evangélica Casa de Oração',
  'v4090',    '379', 'Outras',
  'v4090',    '380', 'Igreja Evangélica Pentecostal Deus é Amor',
  'v4090',    '389', 'Outras',
  'v4090',    '390', 'Igreja Evangélica Pentecostal Maranata',
  'v4090',    '399', 'Outras',
  'v4090',    '400', 'Evangélica Renovada, Restaurada e Reformada Sem Vínculo Institucional',
  'v4090',    '401', 'Pentecostal Renovada, Restaurada e Reformada Sem Vínculo Institucional',
  'v4090',    '409', 'Outras',
  'v4090',    '410', 'Evangélica Pentecostal Sem Vínculo Institucional',
  'v4090',    '419', 'Outras',
  'v4090',    '420', 'Igreja Evangélica Comunidade Cristã',
  'v4090',    '429', 'Outras',
  'v4090',    '430', 'Igreja de Origem Pentecostal Nova Vida',
  'v4090',    '439', 'Outras',
  'v4090',    '440', 'Igreja Evangélica Comunidade Evangélica',
  'v4090',    '449', 'Outras',
  'v4090',    '450', 'Outras Igrejas Evangélicas Pentecostais',
  'v4090',    '460', 'Igreja Pentecostal Avivamento Bíblico',
  'v4090',    '469', 'Outras',
  'v4090',    '470', 'Igreja Evangélica Cadeia da Prece',
  'v4090',    '479', 'Outras',
  'v4090',    '480', 'Igreja do Nazareno',
  'v4090',    '489', 'Outras',
  'v4090',    '490', 'Evangélica Não Determinada',
  'v4090',    '491', 'Evangélica Sem Vínculo Institucional',
  'v4090',    '492', 'Declaração Múltipla de Religião Evangélica',
  'v4090',    '499', 'Outros Evangélicos',
  'v4090',    '510', 'Igreja de Jesus Cristo dos Santos dos Últimos Dias/Mormons',
  'v4090',    '519', 'Outras',
  'v4090',    '520', 'Testemunha de Jeová',
  'v4090',    '529', 'Outras',
  'v4090',    '530', 'Legião da Boa Vontade/Religião de Deus',
  'v4090',    '590', 'Espiritualista',
  'v4090',    '599', 'Outras',
  'v4090',    '610', 'Espírita, Kardecista',
  'v4090',    '619', 'Outras',
  'v4090',    '620', 'Umbanda',
  'v4090',    '629', 'Outras',
  'v4090',    '630', 'Candomblé',
  'v4090',    '639', 'Outras',
  'v4090',    '640', 'Religiosidades Afro-Brasileiras',
  'v4090',    '641', 'Declaração Múltipla de Religiosidade Afro com Outras Religiosidades',
  'v4090',    '649', 'Outras',
  'v4090',    '710', 'Judaísmo',
  'v4090',    '719', 'Outras',
  'v4090',    '740', 'Hinduísmo',
  'v4090',    '741', 'Ioga',
  'v4090',    '749', 'Outras',
  'v4090',    '750', 'Budismo',
  'v4090',    '751', 'Nitiren',
  'v4090',    '752', 'Budismo Theravada',
  'v4090',    '753', 'Zen Budismo',
  'v4090',    '754', 'Budismo Tibetano',
  'v4090',    '755', 'Soka Gakkai',
  'v4090',    '759', 'Outras',
  'v4090',    '760', 'Igreja Messiânica Mundial',
  'v4090',    '761', 'Seicho No-Ie',
  'v4090',    '762', 'Perfect Liberty',
  'v4090',    '763', 'Hare Krishna',
  'v4090',    '764', 'Discipulos Oshoo',
  'v4090',    '765', 'Tenrykyo',
  'v4090',    '766', 'Mahicari',
  'v4090',    '790', 'Religiões Orientais',
  'v4090',    '791', 'Bahai',
  'v4090',    '792', 'Shintoismo',
  'v4090',    '793', 'Taoismo',
  'v4090',    '799', 'Outras',
  'v4090',    '810', 'Islamismo',
  'v4090',    '819', 'Outras',
  'v4090',    '820', 'Esotérica',
  'v4090',    '821', 'Racionalismo Cristão',
  'v4090',    '829', 'Outras',
  'v4090',    '830', 'Tradições Indígenas',
  'v4090',    '831', 'Santo Daime',
  'v4090',    '832', 'União do Vegetal',
  'v4090',    '833', 'A Barquinha',
  'v4090',    '834', 'Neoxamânica',
  'v4090',    '839', 'Outras',
  'v4090',    '850', 'Religiosidade Cristã Sem Vínculo Institucional',
  'v4090',    '890', 'Religiosidade Não Determinada/Mal Definida',
  'v4090',    '891', 'Declaração Múltipla de Religiosidade Católica/Outras Religiosidades',
  'v4090',    '892', 'Declaração Múltipla de Religiosidade Evangélica/Outras Religiosidades',
  'v4090',    '893', 'Declaração Múltipla de Religiosidade Católica/Espírita',
  'v4090',    '894', 'Declaração Múltipla de Religiosidade Católica/Umbanda',
  'v4090',    '895', 'Declaração Múltipla de Religiosidade Católica/Candomblé',
  'v4090',    '896', 'Declaração Múltipla de Religiosidade Católica/Kardecista',
  'v4090',    '990', 'SEM DECLARAÇAO',
  )

expand_grid(
  base = 'pes',
  input
) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_auxfiles_v4090.txt'
    ),
    delim = '|'
  )
