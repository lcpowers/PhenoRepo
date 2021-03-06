# # Fitting data for spring and summer model 
# 
# library(here) #for easy management of file paths within the repository
# library(tidyverse)
# library(lubridate)
# library(growthcurver)
# 
# rm(list=ls())
# 
# load("~/Desktop/CurrentProjects/TeamRotation/PhenoRepo/R/optimized_WarmModel_2021-04-28.RData")
# source(here("R/gridsearch_Casey.R")) #for gridsearch() function
# source("R/WarmModel.R")
# 
# # NOTICE: Need datasets to start on same first day!!! 
# # Change this between sites
# dayOne = as.Date("01-01-18","%m-%d-%y")  # First day with both data sets
# 
# # Read and format target data  -------------------------------------------------
# targets <- read.csv(file = 'data/pheno/GRSM/GRSM_gccTargets.csv') %>% 
#   select(1,3) %>%  # Only keep GCC and date
#   filter(!is.na(gcc_90)) %>%  # Remove NA's
#   mutate(time = as.Date(time),
#          day = yday(time)) %>% # Convert to date format
#   filter(time >= dayOne) 
# 
# # Read in GDD data  ------------------------------------------------------------
# GDD <- read.csv(file = 'data/drivers/neon/GDDandtemp_allsites.csv') %>%
#   filter(siteID == 'GRSM') %>%  # Only consider GRSM site
#   filter(date >= dayOne) %>% 
#   mutate(day = yday(date),
#          date = as.Date(date))
# 
# # Create temperature data.frame 
# temp <- GDD[,1:14]
# lagn = 1
# temp$daily_diff <- c(rep(NA,lagn),diff(temp$daily_mean,lag = lagn))
# 
# 
# # Consider only data in spring to fall date range
# spring_date = "01-31-2018"
# fall_date = "09-15-18"
# minDay <- yday(as.Date(spring_date,"%m-%d-%y"))
# maxDay <- yday(as.Date(fall_date,"%m-%d-%y"))
# 
# targets <- targets %>% filter(day >= minDay & day <= maxDay)
# 
# samedates <- intersect(as.character(targets$time),as.character(GDD$date)) %>% as.Date()
# 
# # Make sure dates in GDD are also in targets
# GDD <- GDD %>% filter(date %in% samedates)
# temp <- temp %>% filter(date %in% samedates)
# 
# # Now make sure that dates in Targets are also in GDD. 
# targets <- targets %>% filter(time %in% as.Date(samedates))
# df <- merge(temp,targets,by.x='date',by.y='time')
# ggplot(df,aes(x=midday_max,y=gcc_90,color=midday_max))+
#   geom_point()
# 
# plot(df)

## Data fitting process --------------------------------------------------------

# Sum of Squares Function - used to measure error
ssq_phenmod <- function(p,y,temp_df) {
  #In the next line we refer to the parameters in p by name so that the code
  #is self documenting
  y_pred <- WarmModel_CP(temp_df=temp,
                         G_init=p[1],
                         a=p[2],b=p[3],
                         t1=p[5],t2=p[6],
                         spring_date,fall_date) #predicted y
  e <- y - y_pred$G #observed minus predicted y
  ssq <- sum(e^2)
  return(ssq)
}

# Grid Search
# used to find general parameter area
# very slow for multiple parameters - scales exponentially 

# # list of parameter ranges
pvecs <- list(G_init=seq(0,0.4,length.out=10), # initial GCC
              a=seq(0,0.01,length.out=10),   # green-up: fast growth
              b=seq(0,0.001,length.out=10),  # maturation
              # b=seq(0,0.01,length.out=10),   # fall + winter decline
              t1=seq(30,70,length.out=10),   # Spring transition
              t2=seq(50,100,length.out=10))  # Summer transition

# # Feed in parameter list, ssq function, target data, input data
fit <- gridsearch(pvecs = pvecs, 
                  func = ssq_phenmod,
                  y=targets$gcc_90,
                  temp,spring_date,fall_date)
# 
# # Grid Search Results
# fit$par    # best parameter value found by fit function
# fit$value  # lowest SSQ found by fit function
# 
# 
# ## Finish data fitting using optim function ------------------------------------
# # Nelder - Mead Algorithm
# # Initialize guesses with Grid Search Results
#   starts <- c(fit$par["G_init"],fit$par["a"],fit$par["b"],fit$par["t1"],fit$par["t2"])
# 
# fit <- optim( starts, ssq_phenmod, y=targets$gcc_90, GDD = GDD)
# 
# fit
# save.image(paste0("R/optimized_WarmModel_",Sys.Date(),".RData")) # Save data frame 
# 

# Plot model results against data to test accuracy  -----------------------------

# GDD Warm Model Results
G_init = fit$par["Ginit"]
a = fit$par["a"]
b = fit$par["b"]
t1 = fit$par["t1"]
t2 = fit$par["t2"]

model_results <-  WarmModel_CP(temp_df = temp,
                               G_init = G_init,
                               a = a,b = b,
                               t1 = t1,t2 = t2,
                               spring_date = "01-31-2018",
                               fall_date="09-15-2018")
colnames(model_results)[2] <- "gcc_90"
model_results$day <- yday(model_results$date)

ggplot() +
  geom_line(aes(x = as.Date(GDD$date), y = model_results$gcc_90)) +
  geom_point(data = targets, aes(x = as.Date(time), y = gcc_90), color = "springgreen4") +
  labs(x="Day of year",y="GCC 90") +
  theme_classic(base_size = 15)



# Write model results to file --------------------------------------------------
model_data = cbind(targets, model_results)
write.csv(model_data,'model_data.csv')

