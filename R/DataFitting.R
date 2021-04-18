library(here) #for easy management of file paths within the repository
library(tidyverse)

source(here("R/gridsearch.R")) #for gridsearch() function

# Read and format target data
targets <- read.csv(file = 'data/pheno/GRSM/GRSM_gccTargets.csv')
targets <- targets %>% select(1,3)
targets$time <- as.Date(targets$time)

dayOne = as.Date("01-01-17","%m-%d-%y")
targets$time <- as.numeric(targets$time - dayOne) %% 365 + 1


# Sum of Squares Function
ssq_phenmod <- function(p,y,x) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- PhenoModel(x,G_init=p[1],a=p[2],b=p[3],c=p[4]) #predicted y
  e <- y - y_pred #observed minus predicted y
  ssq <- sum(e^2)
  return(ssq)
}


# Grid Search

# list of parameter ranges
pvecs <- list(G_init=seq(0,1,length.out=50),
              a=seq(0,0.1,length.out=50),
              b=seq(0,0.1,length.out=50),
              c=seq(0,0.1,length.out=50))

fit <- gridsearch(pvecs, ssq_phenmod, y=targets$gcc_90, x=targets$time)











