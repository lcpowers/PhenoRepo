library(here) #for easy management of file paths within the repository
library(tidyverse)

rm(list=ls())

source(here("R/gridsearch_Casey.R")) #for gridsearch() function
source("R/PhenoModel.R")
source("R/LinPhenoMod.R")

# Read and format target data
targets <- read.csv(file = 'data/pheno/GRSM/GRSM_gccTargets.csv') %>% 
  select(1,3) %>% 
  filter(!is.na(gcc_90))
targets$time <- as.Date(targets$time)

dayOne = as.Date("01-01-17","%m-%d-%y")
targets$day <- as.numeric(targets$time - dayOne) %% 365 + 1


# Sum of Squares Function
ssq_phenmod <- function(p,y,x) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- PhenoModel(x,G_init=p[1],a=p[2],b=p[3],c=p[4],d=p[5]) #predicted y
  e <- y - y_pred #observed minus predicted y
  ssq <- sum(e^2)
  return(ssq)
}


# Grid Search

# list of parameter ranges
pvecs <- list(G_init=seq(0,1,length.out=10),
              a=seq(0,0.1,length.out=10),
              b=seq(0,0.1,length.out=10),
              c=seq(0,0.1,length.out=10),
              d=seq(0,0.1,length.out=10))

fit <- gridsearch(pvecs, ssq_phenmod, y=targets$gcc_90, x=targets$day)

fit$par    # best parameter value found by fit function
fit$value  # lowest SSQ found by fit function

par(mfrow=c(1,2))
plot(funcvals~G_init,data=fit$profile)
plot(funcvals~a,data=fit$profile)


# Nelder - Mead Algorithm
starts <- c(fit$par["G_init"],fit$par["a"],fit$par["b"],fit$par["c"],fit$par["d"])

fit <- optim( starts, ssq_phenmod, y=targets$gcc_90, x=targets$day)
fit


# Plot model results against data to test accuracy

# Model results - with linear growth and no d parameter
G_init <- 0.3490258844
a <- 0.0054031551
b <- 0.0005266447
c <- 0.0069854384

model_results <-  as.data.frame(LinPhenoMod(targets$day,G_init,a,b,c))
ggplot() +
  geom_point(data = targets, aes(x = time, y = gcc_90), color = "green") +
  geom_line(data = model_results, aes(x = targets$time, y = model_results))


# Model results - with exponential growth and medium gridsearch fit
G_init <- fit$par["G_init"]
a <- fit$par["a"] 
b <- fit$par["b"]
c <- fit$par["c"]
d <- fit$par["d"]
model_results <-  as.data.frame(PhenoModel(targets$day,G_init,a,b,c,d))

ggplot() +
  geom_point(data = targets, aes(x = time, y = gcc_90), color = "green") +
  geom_line(data = model_results, aes(x = targets$time, y = model_results))









