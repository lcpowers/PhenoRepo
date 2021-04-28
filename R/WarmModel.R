# Phenology Model - Spring and Summer Only

# Input parameters:
# t = day of year
# gdd = daily growing degree day value
# total_days = Accumulated number of growing degree days
# rolling_avg = 7 day avg GDD 
# G_init = Initial green value
# a, b, c, d = growth and death rates (fit)
# t1, t2, t3, t4 = Timing thresholds (fit)

WarmModel <- function(GDD,G_init,a,b,t1,t2) {
  
  gdd = GDD$GDDdaily
  total_days = GDD$GDDdays
  rolling_avg = GDD$MovAvg_GDDdaily
  n <- length(gdd)
  
  # Parameters
  beta <- a * gdd * (total_days > t1 & total_days <= t2)  # Green up
  
  delta <- b * (total_days > t2)       # Leaf Maturation
  
  # Create Data Frame
  output_df <- data.frame(date = GDD$date,
                          G = rep(NA,n),
                          N = rep(NA,n))

  
  # Model sim
  for ( i in 1:n ) {
    
    # Reset to initial conditions on 2/14 every year
    ifelse (yday(GDD$date[i]) == yday(as.Date("02-14-18","%m-%d-%y")),
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

