#' Phenology Model - Spring and Summer Only
#'
#' Input parameters:
#' @param GDD daily growing degree day values
#' @param G_init Initial green value
#' @param a FIT 
#' @param b FIT
#' @param t1 FIT start greenup
#' @param t2 FIT start leaf maturation
#' @param spring_date Date to restart model each year. Should be in "-MM-DD" format, with dashes included
#' 

WarmModel <- function(GDD,G_init,a,b,t1,t2,spring_date) {
  
  gdd = GDD$GDDdaily
  total_days = GDD$GDDdays
  gdd_total = GDD$GDDtotal
  date = GDD$date
  days_passed <- GDD$day - GDD$day[1] + 1
  gdd_days_passed <- GDD$GDDdays - min(GDD$GDDdays) + 1
  time_inverse <- 1/gdd_days_passed
  n <- length(gdd)
  
  # Parameters
  beta <- a * days_passed^2 * (total_days > t1 & total_days <= t2)    # Green up
  
  delta <- b * time_inverse * (total_days > t2)           # Leaf Maturation
  
  # Create Data Frame
  output_df <- data.frame(date = GDD$date,
                          G = rep(NA,n),
                          N = rep(NA,n))

  
  # Model sim
  for ( i in 1:n ) {
    
    # Reset to initial conditions on 2/14 every year
    ifelse (str_detect(GDD$date[i],spring_date),
      # Initial conditions
      {
      output_df$G[i] = G_init
      output_df$N[i] = 1 - G_init
      },
    # Otherwise, calculate following day from equations
      {
      output_df$G[i] = (1 - delta[i]) * output_df$G[i-1] + beta[i] * output_df$N[i-1]
      output_df$N[i] = (1 - beta[i]) * output_df$N[i-1] + delta[i] * output_df$G[i-1]
    })
  }
  return(output_df)
  
}

