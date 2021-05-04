library(here) #for easy management of file paths within the repository
library(tidyverse)
library(lubridate)

rm(list=ls())

source(here("R/gridsearch.R")) #for gridsearch() function
source("R/PhenoModel.R")
source("R/LinPhenoMod.R")

# Read and format target data  -------------------------------------------------
targets <- read.csv(file = 'data/pheno/GRSM/GRSM_gccTargets.csv') %>% 
  select(1,3) %>%  # Only keep GCC and date
  filter(!is.na(gcc_90))  # Remove NA's
targets$time <- as.Date(targets$time)  # Convert to date format
targets$day <- yday(targets$time)

# Read in GDD data  ------------------------------------------------------------
GDD <- read.csv(file = 'data/drivers/neon/GDDandtemp_allsites.csv') %>%
  filter(siteID == 'GRSM') %>% 
  mutate(date = as.Date(date)) %>% 
  filter(date %in% targets$time)

targets <- filter(targets,time%in%GDD$date)
## Data fitting process --------------------------------------------------------

# Sum of Squares Function - used to measure error
ssq_phenmod <- function(p,y,GDD,G_init) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- PhenoModel(GDD,G_init,a=p[1],b=p[2],c=p[3],d=p[4],
                       t1=p[5],t2=p[6],t3=p[7],t4=p[8]) #predicted y
  e <- y - y_pred #observed minus predicted y
  ssq <- sum(e^2)
  return(ssq)
}

# Grid Search
# used to find general parameter area
# very slow for multiple parameters - scales exponentially 

# list of parameter ranges
# pvecs <- list(a=seq(0,0.01,length.out=10),   # green-up: fast growth
#               b=seq(0,0.001,length.out=10),  # maturation
#               c=seq(0,0.01,length.out=10),   # senescence: fast growth
#               d=seq(0,0.001,length.out=10),  # dormancy
#               t1=seq(30,70,length.out=10),   # GDDdays fit
#               t2=seq(50,100,length.out=10),  # GDDdays fit
#               t3=seq(240,270,length.out=10), # GDDdays fit
#               t4=seq(0,10,length.out=10))    # GDDrollingAvg fit
# 
# # Feed in parameter list, ssq function, target data, input data
# fit <- gridsearch(pvecs, ssq_phenmod, y=targets$gcc_90, GDD = GDD, 
#                   G_init = targets$gcc_90[1])

# fit <- load("R/optimized_2021-04-25.RData")

# Grid Search Results
fit$par    # best parameter value found by fit function
fit$value  # lowest SSQ found by fit function


## Finish data fitting using optim function ------------------------------------
# Nelder - Mead Algorithm
# Initialize guesses with Grid Search Results
starts <- c(fit$par["a"],fit$par["b"],fit$par["c"],fit$par["d"],
            fit$par["t1"],fit$par["t2"],fit$par["t3"],fit$par["t4"])

fit_new <- optim(starts, ssq_phenmod, y=targets$gcc_90, GDD = GDD, 
              G_init = targets$gcc_90[1])
fit_new
# save.image(paste0("R/optimized_",Sys.Date(),".RData")) # Save data frame 


## Add uncertainty -------------------------------------------------------------
# Calculating standard deviation to exp model at each day using 2018-2019 data
# GDD model results
G_init = targets$gcc_90[1]
a = fit$par["a"]
b = fit$par["b"]
c = fit$par["c"]
d = fit$par["d"]
t1 = fit$par["t1"]
t2 = fit$par["t2"]
t3 = fit$par["t3"]
t4 = fit$par["t4"]

# G_init = targets$gcc_90[1]
# a = fit_new$par["a"]
# b = fit_new$par["b"]
# c = fit_new$par["c"]
# d = fit_new$par["d"]
# t1 = fit_new$par["t1"]
# t2 = fit_new$par["t2"]
# t3 = fit_new$par["t3"]
# t4 = fit_new$par["t4"]

nll_phenmod <- function(p,y,GDD,G_init) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- PhenoModel(GDD=GDD,G_init=G_init,a=p[1],b=p[2],c=p[3],d=p[4],
                       t1=p[5],t2=p[6],t3=p[7],t4=p[8]) #predicted gcc
  nll <- -sum(dnorm(targets$gcc_90,mean=y_pred,sd=p[9],log=TRUE))
  return(nll)
}

sd_start <- mean(targets$gcc_90)
starts <- c(G_init=G_init,a,b,c,d,t1,t2,t3,t4,sd=sd_start)

fit_phenomod <- optim(par=starts,nll_phenmod,GDD=GDD,G_init=G_init)
fit_phenomod

######





