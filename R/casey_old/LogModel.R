# Phenology Model - NEON Challenge

PhenoModel <- function(x,G_init,a,b,r,K) {
  
  n <- length(x)
  
  # Create Vectors
  G <- rep(0,n)
  N <- rep(0,n)
  
  # Initial conditions
  G[1] = G_init
  N[1] = 1 - G_init
  
  # Parameters
  beta <- a * (x > 100 & x <= 130)      # Green Up
  
  delta <- b * (x > 130 & x <= 290) +   # Leaf maturation
    r * ( (K - G[x-1]) / K ) * (x > 290)
  
  # Model sim
  for ( i in 2:n ) {
    
    G[i] = (1 - delta[i]) * G[i-1] + beta[i] * N[i-1]
    N[i] = (1 - beta[i]) * N[i-1] + delta[i] * G[i-1]
    
  }
  return(G)
  
}


# Run model

x <- 1:364
G_init <- 0.2
a <- 0.0054031551
b <- 0.0005266447
r <- 0.0055
K <- 0.2

out <- PhenoModel(x,G_init,a,b,r,K)

plot(x,out,ylim=c(0,1),type="l",col="green")

# Add some observation error
# Suggest logit scale with Normal distribution for error
sd_obs <- 0.4
simdat <- rnorm(length(out$G),log(out$G/(1-out$G)),sd_obs)
simdat <- exp(simdat) / (1 + exp(simdat))

points(x,simdat,col="green")

