# Phenology Model - NEON Challenge

PhenoModel <- function(x,G_init,a,b,c) {
  
  n <- length(x)
  
  # Parameters
  beta <- a * x * (x > 100 & x <= 130) +
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


# Run model

x <- 1:364
G_init <- 0.2
a <- 0.1
b <- 0.1
c <- 0.1

out <- PhenoModel(x,G_init,a,b,c)

plot(x,out$G,ylim=c(0,1),type="l",col="green")

# Add some observation error
# Suggest logit scale with Normal distribution for error
sd_obs <- 0.4
simdat <- rnorm(length(out$G),log(out$G/(1-out$G)),sd_obs)
simdat <- exp(simdat) / (1 + exp(simdat))

points(x,simdat,col="green")

