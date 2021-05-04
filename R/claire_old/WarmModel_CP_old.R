# Phenology Model - Spring and Summer Only

# Input parameters:
# t = day of year
# gdd = daily growing degree day value
# total_days = Accumulated number of growing degree days
# rolling_avg = 7 day avg GDD 
# G_init = Initial green value
# a, b, c, d = growth and death rates (fit)
# t1, t2, t3, t4 = Timing thresholds (fit)

WarmModel_CP <- function(temp_df,G_init,a,b,t1,t2,spring_date,fall_date,K=1) {
  
  midday_mean <- temp_df$midday_mean
  daily_mean <- temp_df$daily_mean
  daily_diff <- temp_df$daily_diff
  date = temp_df$date
  n <- length(date)
  
  # Parameters
  beta <- a * daily_diff * (midday_mean > t1 & midday_mean <= t2) * (1 - a/K) # Green up
  
  delta <- b * daily_diff * (midday_mean > t2)                           # Leaf Maturation
   # c * ifelse(yday(date) > yday(as.Date(fall_date,"%m-%d-%y")),1,0) # Fall and winter decline
  # Create Data Frame
  output_df <- data.frame(date = date,
                          G = rep(NA,n),
                          N = rep(NA,n))

  
  # Model sim
  for (i in 1:n) {
    
    # Reset to initial conditions on spring_date every year
    ifelse(yday(GDD$date[i]) == yday(as.Date(spring_date,"%m-%d-%y")),
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

