## gnur_vardict_typeC_v0502.R
##
##
## br_ibge_censo_2010
##
## -------------------------------------------------------------------
## Preparação da variável "relação de parentesco ou de convivência
## com a pessoa responsável pelo domicílio"
## -------------------------------------------------------------------
##

## pacotes (e suas funções) do GNU R usados no tratamento dos dados
library(dplyr)    # %>%
library(readr)    # write_delim
library(tibble)   # tribble

base_dir <- '/tmp/etl/br_ibge_censo_2010/'

tribble(
  ~var,    ~a_code, ~a_desc,
  'v0502',    '01', 'Pessoa responsável pelo domicílio',
  'v0502',    '02', 'Cônjuge ou companheiro(a) de sexo diferente',
  'v0502',    '03', 'Cônjuge ou companheiro(a) do mesmo sexo',
  'v0502',    '04', 'Filho(a) do responsável e do cônjuge',
  'v0502',    '05', 'Filho(a) somente do responsável',
  'v0502',    '06', 'Enteado(a)',
  'v0502',    '07', 'Genro ou nora',
  'v0502',    '08', 'Pai, mãe, padrasto ou madrasta',
  'v0502',    '09', 'Sogro(a)',
  'v0502',    '10', 'Neto(a)',
  'v0502',    '11', 'Bisneto(a)',
  'v0502',    '12', 'Irmão ou irmã',
  'v0502',    '13', 'Avô ou avó',
  'v0502',    '14', 'Outro parente',
  'v0502',    '15', 'Agregado(a)',
  'v0502',    '16', 'Convivente',
  'v0502',    '17', 'Pensionista',
  'v0502',    '18', 'Empregado(a) doméstico(a)',
  'v0502',    '19', 'Parente do(a) empregado(a)  doméstico(a)',
  'v0502',    '20', 'Individual em domicílio coletivo',
  ) %>%
  write_delim(
    file = paste0(
      base_dir,
      'data/',
      'vdict_typeC_v0502.txt'
    ),
    delim = '|'
  )
