# Phenology Model - NEON Challenge

# Input parameters:
  # t = day of year
  # gdd = daily growing degree day value
  # total_days = Accumulated number of growing degree days
  # rolling_avg = 7 day avg GDD 
  # G_init = Initial green value
  # a, b, c, d = growth and death rates (fit)
  # t1, t2, t3, t4 = Timing thresholds (fit)

PhenoModel <- function(GDD,G_init,a,b,c,d,t1,t2,t3,t4) {

  gdd = GDD$GDDdaily
  total_days = GDD$GDDdays
  rolling_avg = GDD$MovAvg_GDDdaily
  n <- length(gdd)
  
  # Parameters
  beta <- a * gdd * (total_days > t1 & total_days <= t2) +          # Green up
    d * ((rolling_avg < t4 & total_days > t3) | total_days <= t1)   # Dormancy
  
  delta <- b * (total_days > t2 & total_days <= t3) +               # Leaf Maturation
    c * (total_days > t3 & rolling_avg > t4)                        # Senescence
  
  # Create Vectors
  G <- rep(0,n)
  N <- rep(0,n)
  
  # Initial conditions
  G[1] = G_init
  N[1] = 1 - G_init
  
  # Model sim
  for ( i in 2:n ) {
    
    G[i] = (1 - delta[i]) * G[i-1] + beta[i] * N[i-1]
    N[i] = (1 - beta[i]) * N[i-1] + delta[i] * G[i-1]
    
  }
  return(G)
  
}
