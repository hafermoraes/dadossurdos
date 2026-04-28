
tic("relacionando a base georeferenciada com os dados de população surda...")
spatial_df <-
  BR_geom %>% 
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