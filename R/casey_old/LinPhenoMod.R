LinPhenoMod <- function(x,G_init,a,b,c,d) {
  
  n <- length(x)
  
  # Parameters
  beta <- a *x * (x > 100 & x <= 130) +
    d * (x > 310 | x <= 100)
  
  delta <- b * (x > 130 & x <= 290) +
    c * x * (x > 290 & x <= 310)
  
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