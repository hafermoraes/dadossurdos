
fert_age_structure <- function(){
  fert_breaks <- c(seq(from=15, to=49, by=5), 49)

  age_low <- seq(from=15, to=45, by=5)
  age_upp <- seq(from=19, to=49, by=5)
  
  fert_labels <- c(
    paste(
      age_low, 
      age_upp, 
      sep = "-"
    )
  )
  return(
    list(
      breaks = fert_breaks,
      labels = fert_labels,
      midpts = (age_low + age_upp + 1) / 2.0
    )
  )
} # fert_age_structure <- function()

