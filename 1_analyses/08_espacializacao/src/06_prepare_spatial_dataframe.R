
tic("relacionando a base georeferenciada (área de ponderação) com os dados de população surda...")
spatial_df <-
  AP_geom %>% 
  left_join(
    censo2010_df, 
    by = c("code_weighting" = "area_ponderacao")
  ) %>% 
  mutate(across(starts_with("N"), ~replace_na(.x, 0)))
toc()



tic("garantindo que totais de 'N' coincidem em 'spatial_df' e 'censo2010_df")
assert_that(
  sum(spatial_df$N) == sum(censo2010_df$N),
  msg = "'N' deve coincidir em 'spatial_df' e 'censo2010_df'"
)
toc()



tic("garantindo que totais de 'N_incapaz' coincidem em 'spatial_df' e 'censo2010_df")
assert_that(
  sum(spatial_df$N_incapaz) == sum(censo2010_df$N_incapaz),
  msg = "'N_incapaz' deve coincidir em 'spatial_df' e 'censo2010_df'"
)
toc()


tic("garantindo que totais de 'N_surdo' coincidem em 'spatial_df' e 'censo2010_df")
assert_that(
  sum(spatial_df$N_surdo) == sum(censo2010_df$N_surdo),
  msg = "'N_surdo' deve coincidir em 'spatial_df' e 'censo2010_df'"
)
toc()



tic("agregando informações por município...")

sf_use_s2(FALSE)

spatial_muni <- 
  spatial_df %>%
  group_by(code_muni, name_muni, code_state, abbrev_state, code_region, name_region) %>%
  summarise(
    N = sum(N, na.rm = TRUE),
    N_incapaz = sum(N_incapaz, na.rm = TRUE),
    N_surdo = sum(N_surdo, na.rm = TRUE),
    .groups = "drop"
  )

sf_use_s2(TRUE)

toc()


tic("garantindo que totais de 'N' coincidem em 'spatial_muni' e 'censo2010_df")
assert_that(
  sum(spatial_muni$N) == sum(censo2010_df$N),
  msg = "'N' deve coincidir em 'spatial_muni' e 'censo2010_df'"
)
toc()



tic("garantindo que totais de 'N_incapaz' coincidem em 'spatial_muni' e 'censo2010_df")
assert_that(
  sum(spatial_muni$N_incapaz) == sum(censo2010_df$N_incapaz),
  msg = "'N_incapaz' deve coincidir em 'spatial_muni' e 'censo2010_df'"
)
toc()


tic("garantindo que totais de 'N_surdo' coincidem em 'spatial_muni' e 'censo2010_df")
assert_that(
  sum(spatial_muni$N_surdo) == sum(censo2010_df$N_surdo),
  msg = "'N_surdo' deve coincidir em 'spatial_muni' e 'censo2010_df'"
)
toc()
