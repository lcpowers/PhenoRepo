library(here) #for easy management of file paths within the repository
library(tidyverse)
library(lubridate)

rm(list=ls())

source(here("R/gridsearch_Casey.R")) #for gridsearch() function
source("R/PhenoModel.R")
source("R/LinPhenoMod.R")

# NOTICE: Need datasets to start on same first day!!! 
# Change this between sites
dayOne = as.Date("01-01-18","%m-%d-%y")  # First day with both data sets


# Read and format target data  -------------------------------------------------
targets <- read.csv(file = 'data/pheno/GRSM/GRSM_gccTargets.csv') %>% 
  select(1,3) %>%  # Only keep GCC and date
  filter(!is.na(gcc_90))  # Remove NA's
targets$time <- as.Date(targets$time)  # Convert to date format

targets <- targets %>% filter(time >= dayOne)  # Remove prior dates
targets$day <- as.numeric(targets$time - dayOne) %% 365 + 1  # Day of the year


# Read in GDD data  ------------------------------------------------------------
GDD <- read.csv(file = 'data/drivers/neon/GDDandtemp_allsites.csv') %>%
  filter(siteID == 'GRSM') %>%  # Only consider GRSM site
  filter(date >= dayOne)


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
pvecs <- list(a=seq(0,0.01,length.out=10),   # green-up: fast growth
              b=seq(0,0.001,length.out=10),  # maturation
              c=seq(0,0.01,length.out=10),   # senescence: fast growth
              d=seq(0,0.001,length.out=10),  # dormancy
              t1=seq(30,70,length.out=10),   # GDDdays fit
              t2=seq(50,100,length.out=10),  # GDDdays fit
              t3=seq(240,270,length.out=10), # GDDdays fit
              t4=seq(0,10,length.out=10))    # GDDrollingAvg fit

# Feed in parameter list, ssq function, target data, input data
fit <- gridsearch(pvecs, ssq_phenmod, y=targets$gcc_90, GDD = GDD, 
                  G_init = targets$gcc_90[1])

# Grid Search Results
fit$par    # best parameter value found by fit function
fit$value  # lowest SSQ found by fit function


## Finish data fitting using optim function ------------------------------------
# Nelder - Mead Algorithm
# Initialize guesses with Grid Search Results
starts <- c(fit$par["a"],fit$par["b"],fit$par["c"],fit$par["d"],
            fit$par["t1"],fit$par["t2"],fit$par["t3"],fit$par["t4"])

fit <- optim( starts, ssq_phenmod, y=targets$gcc_90, GDD = GDD, 
              G_init = targets$gcc_90[1])
fit
save.image(paste0("R/optimized_",Sys.Date(),".RData")) # Save data frame 





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

model_results <-  PhenoModel(GDD,G_init,a,b,c,d,t1,t2,t3,t4)
#colnames(model_results)[1] <- "gcc_90"

# Add day of the year to model results
#dayOfYear <- (1:nrow(model_results)) %% 365 + 1
#model_results <- cbind(day=dayOfYear,model_results)

# Consider two years of data (prior to 2020)
unc_targets <- targets %>% filter(time < as.Date("01-01-20","%m-%d-%y"))
targets$sq_dif <- NA

# Calculate daily StDev from observed data and model prediction
for (d in 1:365){
  target <- targets %>% filter(day == d & time < as.Date("01-01-20","%m-%d-%y") )
  model <- model_results %>% filter(day == d & time < as.Date("01-01-20","%m-%d-%y") )
  ssq = 0
  for (i in target){
    ssq = ssq + (target[i]$gcc_90 - model[i]$G)^2
  }
  error = sqrt(ssq/nrow(target))
}
  
  




# Plot model results against data to test accuracy  -----------------------------

# Exponential model results
G_init <- 3.494092e-01 # fit$par["G_init"]
a <-  4.275827e-05 
b <- 5.005463e-04 
c <- 2.806884e-05
d <- 1.750219e-04

model_results <-  as.data.frame(LinPhenoMod(targets$day,G_init,a,b,c,d))
colnames(model_results)[1] <- "gcc_90"

ggplot() +
  geom_point(data = targets, aes(x = time, y = gcc_90), color = "springgreen4") +
  geom_line(aes(x = targets$time, y = model_results$gcc_90)) +
  labs(x="Day of year",y="GCC 90") +
  theme_classic(base_size = 15)

# GDD Model Results
G_init = targets$gcc_90[1]
a = fit$par["a"]
b = fit$par["b"]
c = fit$par["c"]
d = fit$par["d"]
t1 = fit$par["t1"]
t2 = fit$par["t2"]
t3 = fit$par["t3"]
t4 = fit$par["t4"]

model_results <-  PhenoModel(GDD,G_init,a,b,c,d,t1,t2,t3,t4)
colnames(model_results)[2] <- "gcc_90"
model_results$day <- yday(model_results$date)

ggplot() +
  geom_point(data = targets, aes(x = time, y = gcc_90), color = "springgreen4") +
  geom_line(aes(x = as.Date(GDD$date), y = model_results$gcc_90)) +
  labs(x="Day of year",y="GCC 90") +
  theme_classic(base_size = 15)



# Write model results to file --------------------------------------------------
model_data = cbind(targets, model_results)
write.csv(model_data,'model_data.csv')

