# Fitting data for spring and summer model 

library(here) #for easy management of file paths within the repository
library(tidyverse)
library(lubridate)
library(imputeTS)
library(zoo)

rm(list=ls())

source(here("R/gridsearch_Casey.R")) #for gridsearch() function
source("R/WarmModel.R")

# NOTICE: Need datasets to start on same first day!!! 
# Change this between sites
dayOne = as.Date("01-01-18","%m-%d-%y")  # First day with both data sets


# Read and format target data  -------------------------------------------------
targets <- read.csv(file = 'data/pheno/GRSM/GRSM_gccTargets.csv') %>% 
  select(1,3)  # Only keep GCC and date
targets$time <- as.Date(targets$time)  # Convert to date format

x <- zoo(targets$gcc_90,targets$time)
x <- na_interpolation(x, option = "linear") %>% as.data.frame() %>% rownames_to_column()
colnames(x) <- c("time","gcc_90")
x$time <- as.Date(x$time)
targets$gcc_90 <- x$gcc_90

targets <- targets %>% filter(time >= dayOne)  # Remove prior dates
targets$day <- yday(targets$time)  # Day of the year


# Read in GDD data  ------------------------------------------------------------
GDD <- read.csv(file = 'data/drivers/neon/GDDandtemp_allsites.csv') %>%
  filter(siteID == 'GRSM') %>%  # Only consider GRSM site
  filter(date >= dayOne)
GDD$day <- yday(GDD$date)


# Consider only data in [2/14 - 8/30]
minDay <- yday(as.Date("02-14-18","%m-%d-%y"))
maxDay <- yday(as.Date("08-31-18","%m-%d-%y"))
targets <- targets %>% filter(day >= minDay & day <= maxDay)

samedates <- intersect(targets$time,as.Date(GDD$date))

# Make sure dates in GDD are also in targets
GDD <- GDD %>% filter(day >= minDay & day <= maxDay) %>% 
  filter(as.Date(date) %in% samedates)

# Now make sure that dates in Targets are also in GDD. 
targets <- targets %>% filter(time %in% samedates)
targets$year <- str_sub(targets$time,1,4) %>% as.factor()


## Data fitting process --------------------------------------------------------

# Sum of Squares Function - used to measure error
ssq_phenmod <- function(p,y,GDD) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- WarmModel(GDD,G_init=p[1],a=p[2],b=p[3],t1=p[4],t2=p[5]) #predicted y
  e <- y - y_pred$G #observed minus predicted y
  ssq <- sum(e^2)
  return(ssq)
}


# Grid Search
# used to find general parameter area
# very slow for multiple parameters - scales exponentially 

# Seed G_init and t2 using average values
# G_init: avg of first 7 days of data
avg_G_init = mean(targets$gcc_90[1:7]);
# t2: Average GDDdays around peak time 
avg_t2 = targets %>% 
  group_by(year) %>% 
  filter(year != 2021) %>%
  summarise(maxGCCday=day[gcc_90==max(gcc_90)]) 
avg_t2 <- floor(mean(avg_t2$maxGCCday))          # approximate peak time
avg_t2 <- GDD %>% filter(day == avg_t2)
avg_t2 <- mean(avg_t2$GDDdays)            # avg GDD days passed at peak

# list of parameter ranges                             
pvecs <- list(G_init = avg_G_init,  # GCC guess = avg first 7 days of targets
              a=seq(0,0.001,length.out=10),   # green-up: fast growth
              b=seq(0,0.0005,length.out=10),  # maturation
              t1=seq(30,70,length.out=10),   # Spring transition
              t2 = avg_t2  # Summer transition = avg date of peak GCC
              )

# Feed in parameter list, ssq function, target data, input data
fit <- gridsearch(pvecs, ssq_phenmod, y=targets$gcc_90, GDD = GDD)

# Grid Search Results
fit$par    # best parameter value found by fit function
fit$value  # lowest SSQ found by fit function


## Finish data fitting using optim function ------------------------------------
# Nelder - Mead Algorithm
# Initialize guesses with Grid Search Results
starts <- c(fit$par["G_init"],
            fit$par["a"],fit$par["b"],
            fit$par["t1"],fit$par["t2"])

fit_fin <- optim( starts, ssq_phenmod, y=targets$gcc_90, GDD = GDD)

fit_fin
save.image(paste0("R/optimized_WarmModel_",Sys.Date(),".RData")) # Save data frame 





# Plot model results against data to test accuracy  -----------------------------

# GDD Warm Model Results
G_init = fit_fin$par["G_init"]
a = fit_fin$par["a"]
b = fit_fin$par["b"]
t1 = fit_fin$par["t1"]
t2 = fit_fin$par["t2"]

model_results <-  WarmModel(GDD,G_init,a,b,t1,t2)
colnames(model_results)[2] <- "gcc_90"
model_results$day <- yday(model_results$date)

ggplot() +
  geom_point(data = targets, aes(x = as.Date(time), y = gcc_90), color = "springgreen4") +
  geom_point(aes(x = as.Date(GDD$date), y = model_results$gcc_90), color = "red") +
  labs(x="Day of year",y="GCC 90", title="Exp decay by normalized number of GDDdays") +
  theme_classic(base_size = 15)



# Write model results to file --------------------------------------------------
model_data = cbind(targets, model_results)
write.csv(model_data,'model_data.csv')

