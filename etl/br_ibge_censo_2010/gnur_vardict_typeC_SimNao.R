## gnur_vardict_typeC_SimNao.R
##
##
## br_ibge_censo_2010
##

## Pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  ## v0206 sanitário ou buraco para dejeções, existência
  'v0206',     '1', 'Sim',
  'v0206',     '2', 'Não',
  ## v0213 rádio, existência
  'v0213',     '1', 'Sim',
  'v0213',     '2', 'Não',
  ## v0214 televisão, existência
  'v0214',     '1', 'Sim',
  'v0214',     '2', 'Não',
  ## v0215 máquina de lavar roupa, existência
  'v0215',     '1', 'Sim',
  'v0215',     '2', 'Não',
  ## v0216 geladeira, existência
  'v0216',     '1', 'Sim',
  'v0216',     '2', 'Não',
  ## v0217 telefone celular, existência
  'v0217',     '1', 'Sim',
  'v0217',     '2', 'Não',
  ## v0218 telefone fixo, existência
  'v0218',     '1', 'Sim',
  'v0218',     '2', 'Não',
  ## v0219 microcomputador, existência
  'v0219',     '1', 'Sim',
  'v0219',     '2', 'Não',
  ## v0220 microcomputador com acesso à internet, existência
  'v0220',     '1', 'Sim',
  'v0220',     '2', 'Não',
  ## v0221 motocicleta para uso particular, existência
  'v0221',     '1', 'Sim',
  'v0221',     '2', 'Não',
  ## v0222 automóvel para uso particular, existência
  'v0222',     '1', 'Sim',
  'v0222',     '2', 'Não',
  ## v0301 alguma pessoa que morava com você(s) estava
  ##       morando em outro país em 31 de julho de 2010
  'v0301',     '1', 'Sim',
  'v0301',     '2', 'Não',
  ## v0701 de agosto de 2009 a julho de 2010, faleceu
  ##       alguma pessoa que morava com você(s) (inclusive
  ##       crianças recém-nascidas e idosos)
  'v0701',     '1', 'Sim',
  'v0701',     '2', 'Não',
  ## m0201 marca de imputação na v0201
  'm0201',     '1', 'Sim',
  'm0201',     '2', 'Não',
  ## m2011 marca de imputação na v2011
  'm2011',     '1', 'Sim',
  'm2011',     '2', 'Não',
  ## m0202 marca de imputação na v0202
  'm0202',     '1', 'Sim',
  'm0202',     '2', 'Não',
  ## m0203 marca de imputação na v0203
  'm0203',     '1', 'Sim',
  'm0203',     '2', 'Não',
  ## m0204 marca de imputação na v0204
  'm0204',     '1', 'Sim',
  'm0204',     '2', 'Não',
  ## m0205 marca de imputação na v0205
  'm0205',     '1', 'Sim',
  'm0205',     '2', 'Não',
  ## m0206 marca de imputação na v0206
  'm0206',     '1', 'Sim',
  'm0206',     '2', 'Não',
  ## m0207 marca de imputação na v0207
  'm0207',     '1', 'Sim',
  'm0207',     '2', 'Não',
  ## m0208 marca de imputação na v0208
  'm0208',     '1', 'Sim',
  'm0208',     '2', 'Não',
  ## m0209 marca de imputação na v0209
  'm0209',     '1', 'Sim',
  'm0209',     '2', 'Não',
  ## m0210 marca de imputação na v0210
  'm0210',     '1', 'Sim',
  'm0210',     '2', 'Não',
  ## m0211 marca de imputação na v0211
  'm0211',     '1', 'Sim',
  'm0211',     '2', 'Não',
  ## m0212 marca de imputação na v0212
  'm0212',     '1', 'Sim',
  'm0212',     '2', 'Não',
  ## m0213 marca de imputação na v0213
  'm0213',     '1', 'Sim',
  'm0213',     '2', 'Não',
  ## m0214 marca de imputação na v0214
  'm0214',     '1', 'Sim',
  'm0214',     '2', 'Não',
  ## m0215 marca de imputação na v0215
  'm0215',     '1', 'Sim',
  'm0215',     '2', 'Não',
  ## m0216 marca de imputação na v0216
  'm0216',     '1', 'Sim',
  'm0216',     '2', 'Não',
  ## m0217 marca de imputação na v0217
  'm0217',     '1', 'Sim',
  'm0217',     '2', 'Não',
  ## m0218 marca de imputação na v0218
  'm0218',     '1', 'Sim',
  'm0218',     '2', 'Não',
  ## m0219 marca de imputação na v0219
  'm0219',     '1', 'Sim',
  'm0219',     '2', 'Não',
  ## m0220 marca de imputação na v0220
  'm0220',     '1', 'Sim',
  'm0220',     '2', 'Não',
  ## m0221 marca de imputação na v0221
  'm0221',     '1', 'Sim',
  'm0221',     '2', 'Não',
  ## m0222 marca de imputação na v0222
  'm0222',     '1', 'Sim',
  'm0222',     '2', 'Não',
  ## m0301 marca de imputação na v0301
  'm0301',     '1', 'Sim',
  'm0301',     '2', 'Não',
  ## m0401 marca de imputação na v0401
  'm0401',     '1', 'Sim',
  'm0401',     '2', 'Não',
  ## m0402 marca de imputação na v0402
  'm0402',     '1', 'Sim',
  'm0402',     '2', 'Não',
  ## m0701 marca de imputação na v0701
  'm0701',     '1', 'Sim',
  'm0701',     '2', 'Não',
  ## v0627 sabe ler e escrever
  'v0627',     '1', 'Sim',
  'v0627',     '2', 'Não',
  ## v0632 conclusão de outro curso superior de graduação
  'v0632',     '1', 'Sim',
  'v0632',     '2', 'Não',
  ## v0634 conclusão deste curso
  'v0634',     '1', 'Sim',
  'v0634',     '2', 'Não',
  ## v0641 na semana de 25 a 31/07/10, durante pelo menos
  ##       1 hora, trabalhou ganhando em dinheiro, produtos,
  ##       mercadorias ou benefícios
  'v0641',     '1', 'Sim',
  'v0641',     '2', 'Não',
  ## v0642 na semana de 25 a 31/07/10, tinha trabalho remunerado
  ##       do qual estava temporariamente afastado(a)
  'v0642',     '1', 'Sim',
  'v0642',     '2', 'Não',
  ## v0643 na semana de 25 a 31/07/10, durante pelo menos 1 hora,
  ##       ajudou sem qualquer pagamento no trabalho remunerado
  ##       de morador do domicílio
  'v0643',     '1', 'Sim',
  'v0643',     '2', 'Não',
  ## v0644 na semana de 25 a 31/07/10, durante pelo menos 1 hora,
  ##       trabalhou na plantação, criação de animais ou pesca,
  ##       somente para alimentação dos moradores do domicílio
  ##       (inclusive caça e extração vegetal)
  'v0644',     '1', 'Sim',
  'v0644',     '2', 'Não',
  ## v0654 no período de 02 a 31 de julho de 2010, tomou alguma
  ##       providência, de fato, para conseguir  trabalho?
  'v0654',     '1', 'Sim',
  'v0654',     '2', 'Não',
  ## v0655 se tivesse conseguido trabalho, estaria disponível
  ##       para assumi-lo na semana de 25 a 31 de julho de 2010?
  'v0655',     '1', 'Sim',
  'v0655',     '2', 'Não',
  ## v0661 retorna do trabalho para casa diariamente
  'v0661',     '1', 'Sim',
  'v0661',     '2', 'Não',
  ## v0664 existência de filho tido nascido vivo no período de referência de 12 meses anteriores a 31/07/2010
  'v6664',     '1', 'Sim',
  'v6664',     '0', 'Não',
  ## marcas de imputação para as variáveis
  'm0502',     '1', 'Sim',
  'm0502',     '2', 'Não',
  'm0601',     '1', 'Sim',
  'm0601',     '2', 'Não',
  'm6033',     '1', 'Sim',
  'm6033',     '2', 'Não',
  'm0606',     '1', 'Sim',
  'm0606',     '2', 'Não',
  'm0613',     '1', 'Sim',
  'm0613',     '2', 'Não',
  'm0614',     '1', 'Sim',
  'm0614',     '2', 'Não',
  'm0615',     '1', 'Sim',
  'm0615',     '2', 'Não',
  'm0616',     '1', 'Sim',
  'm0616',     '2', 'Não',
  'm0617',     '1', 'Sim',
  'm0617',     '2', 'Não',
  'm0618',     '1', 'Sim',
  'm0618',     '2', 'Não',
  'm0619',     '1', 'Sim',
  'm0619',     '2', 'Não',
  'm0620',     '1', 'Sim',
  'm0620',     '2', 'Não',
  'm0621',     '1', 'Sim',
  'm0621',     '2', 'Não',
  'm0622',     '1', 'Sim',
  'm0622',     '2', 'Não',
  'm6222',     '1', 'Sim',
  'm6222',     '2', 'Não',
  'm6224',     '1', 'Sim',
  'm6224',     '2', 'Não',
  'm0623',     '1', 'Sim',
  'm0623',     '2', 'Não',
  'm0624',     '1', 'Sim',
  'm0624',     '2', 'Não',
  'm0625',     '1', 'Sim',
  'm0625',     '2', 'Não',
  'm6252',     '1', 'Sim',
  'm6252',     '2', 'Não',
  'm6254',     '1', 'Sim',
  'm6254',     '2', 'Não',
  'm6256',     '1', 'Sim',
  'm6256',     '2', 'Não',
  'm0626',     '1', 'Sim',
  'm0626',     '2', 'Não',
  'm6262',     '1', 'Sim',
  'm6262',     '2', 'Não',
  'm6264',     '1', 'Sim',
  'm6264',     '2', 'Não',
  'm6266',     '1', 'Sim',
  'm6266',     '2', 'Não',
  'm0627',     '1', 'Sim',
  'm0627',     '2', 'Não',
  'm0628',     '1', 'Sim',
  'm0628',     '2', 'Não',
  'm0629',     '1', 'Sim',
  'm0629',     '2', 'Não',
  'm0630',     '1', 'Sim',
  'm0630',     '2', 'Não',
  'm0631',     '1', 'Sim',
  'm0631',     '2', 'Não',
  'm0632',     '1', 'Sim',
  'm0632',     '2', 'Não',
  'm0633',     '1', 'Sim',
  'm0633',     '2', 'Não',
  'm0634',     '1', 'Sim',
  'm0634',     '2', 'Não',
  'm0635',     '1', 'Sim',
  'm0635',     '2', 'Não',
  'm6352',     '1', 'Sim',
  'm6352',     '2', 'Não',
  'm6354',     '1', 'Sim',
  'm6354',     '2', 'Não',
  'm6356',     '1', 'Sim',
  'm6356',     '2', 'Não',
  'm0636',     '1', 'Sim',
  'm0636',     '2', 'Não',
  'm6362',     '1', 'Sim',
  'm6362',     '2', 'Não',
  'm6364',     '1', 'Sim',
  'm6364',     '2', 'Não',
  'm6366',     '1', 'Sim',
  'm6366',     '2', 'Não',
  'm0637',     '1', 'Sim',
  'm0637',     '2', 'Não',
  'm0638',     '1', 'Sim',
  'm0638',     '2', 'Não',
  'm0639',     '1', 'Sim',
  'm0639',     '2', 'Não',
  'm0640',     '1', 'Sim',
  'm0640',     '2', 'Não',
  'm0641',     '1', 'Sim',
  'm0641',     '2', 'Não',
  'm0642',     '1', 'Sim',
  'm0642',     '2', 'Não',
  'm0643',     '1', 'Sim',
  'm0643',     '2', 'Não',
  'm0644',     '1', 'Sim',
  'm0644',     '2', 'Não',
  'm0645',     '1', 'Sim',
  'm0645',     '2', 'Não',
  'm6461',     '1', 'Sim',
  'm6461',     '2', 'Não',
  'm6471',     '1', 'Sim',
  'm6471',     '2', 'Não',
  'm0648',     '1', 'Sim',
  'm0648',     '2', 'Não',
  'm0649',     '1', 'Sim',
  'm0649',     '2', 'Não',
  'm0650',     '1', 'Sim',
  'm0650',     '2', 'Não',
  'm0651',     '1', 'Sim',
  'm0651',     '2', 'Não',
  'm6511',     '1', 'Sim',
  'm6511',     '2', 'Não',
  'm0652',     '1', 'Sim',
  'm0652',     '2', 'Não',
  'm6521',     '1', 'Sim',
  'm6521',     '2', 'Não',
  'm0653',     '1', 'Sim',
  'm0653',     '2', 'Não',
  'm0654',     '1', 'Sim',
  'm0654',     '2', 'Não',
  'm0655',     '1', 'Sim',
  'm0655',     '2', 'Não',
  'm0656',     '1', 'Sim',
  'm0656',     '2', 'Não',
  'm0657',     '1', 'Sim',
  'm0657',     '2', 'Não',
  'm0658',     '1', 'Sim',
  'm0658',     '2', 'Não',
  'm0659',     '1', 'Sim',
  'm0659',     '2', 'Não',
  'm6591',     '1', 'Sim',
  'm6591',     '2', 'Não',
  'm0660',     '1', 'Sim',
  'm0660',     '2', 'Não',
  'm6602',     '1', 'Sim',
  'm6602',     '2', 'Não',
  'm6604',     '1', 'Sim',
  'm6604',     '2', 'Não',
  'm6606',     '1', 'Sim',
  'm6606',     '2', 'Não',
  'm0661',     '1', 'Sim',
  'm0661',     '2', 'Não',
  'm0662',     '1', 'Sim',
  'm0662',     '2', 'Não',
  'm0663',     '1', 'Sim',
  'm0663',     '2', 'Não',
  'm6631',     '1', 'Sim',
  'm6631',     '2', 'Não',
  'm6632',     '1', 'Sim',
  'm6632',     '2', 'Não',
  'm6633',     '1', 'Sim',
  'm6633',     '2', 'Não',
  'm0664',     '1', 'Sim',
  'm0664',     '2', 'Não',
  'm6641',     '1', 'Sim',
  'm6641',     '2', 'Não',
  'm6642',     '1', 'Sim',
  'm6642',     '2', 'Não',
  'm6643',     '1', 'Sim',
  'm6643',     '2', 'Não',
  'm0665',     '1', 'Sim',
  'm0665',     '2', 'Não',
  'm6660',     '1', 'Sim',
  'm6660',     '2', 'Não',
  'm0667',     '1', 'Sim',
  'm0667',     '2', 'Não',
  'm0668',     '1', 'Sim',
  'm0668',     '2', 'Não',
  'm6681',     '1', 'Sim',
  'm6681',     '2', 'Não',
  'm6682',     '1', 'Sim',
  'm6682',     '2', 'Não',
  'm0669',     '1', 'Sim',
  'm0669',     '2', 'Não',
  'm6691',     '1', 'Sim',
  'm6691',     '2', 'Não',
  'm6692',     '1', 'Sim',
  'm6692',     '2', 'Não',
  'm6693',     '1', 'Sim',
  'm6693',     '2', 'Não',
  'm0670',     '1', 'Sim',
  'm0670',     '2', 'Não',
  'm0671',     '1', 'Sim',
  'm0671',     '2', 'Não',
  'm6800',     '1', 'Sim',
  'm6800',     '2', 'Não',
  'm6121',     '1', 'Sim',
  'm6121',     '2', 'Não',
  'm0604',     '1', 'Sim',
  'm0604',     '2', 'Não',
  'm0605',     '1', 'Sim',
  'm0605',     '2', 'Não',
  'm6462',     '1', 'Sim',
  'm6462',     '2', 'Não',
  'm6472',     '1', 'Sim',
  'm6472',     '2', 'Não',
  'm0303',     '1', 'Sim',
  'm0303',     '2', 'Não',
  'm0304',     '1', 'Sim',
  'm0304',     '2', 'Não',
  'm0305',     '1', 'Sim',
  'm0305',     '2', 'Não',
  'm3061',     '1', 'Sim',
  'm3061',     '2', 'Não',
  'm0703',     '1', 'Sim',
  'm0703',     '2', 'Não',
  'm0704',     '1', 'Sim',
  'm0704',     '2', 'Não',
  'm7051',     '1', 'Sim',
  'm7051',     '2', 'Não',
  'm7052',     '1', 'Sim',
  'm7052',     '2', 'Não',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_common_simnao.txt'
    ),
    delim = '|'
  )
