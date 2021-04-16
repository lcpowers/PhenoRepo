# Phenology Mechanistic Model Script

## Core Equations 
update(G) <- (1 - delta) * G + beta * RB
update(RB) <- (1 - beta) * RB + delta * G

# Total pixels should add up to one
N <- G + RB

# Initial Conditions
initial(G) <- G_init  # user-defined
initial(RB) <- 1 - G_init

# Parameters
G_init <- 0.2
beta <- 0.05
delta <- .01

