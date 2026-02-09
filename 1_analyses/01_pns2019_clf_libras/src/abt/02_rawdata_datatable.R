
microdados_dt <- open_dataset(
  "/tmp/etl/br_ibge_pns_2019/parquet"
) |>
  rename_with(tolower) |>
  filter(v0015 == '01', !is.na(v0015), m001 == '1', !is.na(m001)) |>
  select(
    v0024,v0029,upa_pns,v00292,v00293, # expansão da amostra probabilística
    v0001,  # uf de residência
    c006,   # sexo
    c008,   # idade
    c009,   # cor ou raça
    d001,   # alfabetizado
    c011,   # estado civil
    d00901, # instrução
    g047,   # dificuldade de enxergar
    g058,   # dificuldade de ouvir
    g071,   # dificuldade de locomover
    g05801  # sabe libras
  ) |>
  mutate(v0029 = as.numeric(v0029)) |>
  collect() |>
  as.data.table()

# Compute pop controls
popc.types <- microdados_dt[, .(Freq = unique(v00292)), by = v00293]

# Compute sum of weights per stratum
sum_weights <- microdados_dt[, .(sumw = sum(v0029)), by = v00293]

# Merge controls and sum weights
strata_weights <- merge(popc.types, sum_weights, by = "v00293")

# Compute scaling factor: Freq / sumw
strata_weights[, scale := as.numeric(Freq) / as.numeric(sumw)]

# Merge scaling factor back
microdados_dt <- merge(microdados_dt, strata_weights[, .(v00293, scale)], by = "v00293", all.x = TRUE)

# Adjust weights: new weight is original weight * strata scaling
microdados_dt[, weight := v0029 * scale]

tic()
rawdata <- microdados_dt[
  , 
  .(n = sum(weight)), 
  by = c(
    "v0001", 
    "c006",  
    "c008", 
    "c009", 
    "d001", 
    "c011", 
    "d00901", 
    "g047", 
    "g071", 
    "g058", 
    "g05801"
  )
][n > 0][order(-n)]
toc()


rawdata |>
  write_csv(
    paste0(
      data_dir,
      'pns2019_01_rawdata.csv'
    )
  )
