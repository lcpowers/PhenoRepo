# Phenology Mechanistic Model Script

## Core Equations 
update(G[]) <- (1 - delta) * G[i] + beta[i] * RB[i]
update(RB[]) <- (1 - beta[i]) * RB[i] + delta * G[i]

# Total pixels should add up to one
#N[] <- G[i] + RB[i]

# Assign dimensions
dim(G) = 365
dim(RB) = 365
#dim(N) = 365
dim(beta) = 365

# Initial Conditions
initial(G[]) <- G_init  # user-defined
initial(RB[]) <- 1 - G_init

# Parameters
G_init <- 0.2
beta[] <- .05
delta <- .1

