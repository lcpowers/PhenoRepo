#'
#'
#'
#' NOAA forecast data

library(tidyverse)
library(ncdf4)
library(neonstore)
library(neon4cast)
source("R/NEONscripts/noaa_gefs_read.R")

site_list <- list("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")
date <- Sys.Date()
interval = "6hr"
cycle <- "00" # These are the forecasts that run 35 days into the future
# Get current NOAA forecast data
lapply(site_list, download_noaa, dir = "data/drivers/")

# Extract forecast data and write to csv
base_dir <- "data/drivers/noaa/noaa/NOAAGEFS_6hr"

# DF here is the NOAA forecast data
noaa_raw_df <- noaa_gefs_read(base_dir = base_dir, 
                              cycle="00", # Cycle with 35 day forecasts
                              date = Sys.Date()-2, # Date what should be the first data in forecast data
                              sites = unlist(site_list)) # Sites to loop over
# Optionally write out raw data file
# write_csv(noaa_raw_df,paste0("data/drivers/noaa/noaa_raw_",as.character(date),".csv"))

noaa_df <- separate(data = noaa_raw_df,col = time,into = c("date","time"),sep = " ") %>% 
  mutate(air_temp_C = as.numeric(air_temperature-273.15)) 

daily_temps <- noaa_df %>%
  group_by(siteID,date,time) %>% 
  summarise(ens_mean = mean(air_temp_C,na.rm=T),
            temp_var = var(air_temp_C,na.rm=T),
            temp_sd = sd(air_temp_C,na.rm=T)) %>% 
  ungroup() %>% 
  group_by(siteID,date) %>% 
  summarise(n_obs = n(),
            daily_max = max(ens_mean,na.rm=T),
            daily_min = min(ens_mean,na.rm=T),
            daily_mean = mean(ens_mean,na.rm=T),
            daily_var = max(temp_var),
            daily_sd = max(temp_sd))
  
midday_temps <- noaa_df %>% 
  filter(time%in%c("06:00:00","12:00:00","18:00:00")) %>% 
  group_by(siteID,date) %>% 
  summarise(midday_mean=mean(air_temp_C,na.rm=T),
            midday_var=var(air_temp_C,na.rm=T),
            midday_sd=sd(air_temp_C,na.rm=T))
setdiff(unique(daily_temps$date),unique(midday_temps$date))

all_data <- merge(daily_temps,midday_temps,all=T)
write_csv(all_data,paste0("data/drivers/noaa/noaa_temp_4cast_",as.character(date),".csv"))
noaa_wx <- all_data

rm(all_data,daily_temps,midday_temps,noaa_df,noaa_raw_df,site_list,base_dir,cycle,date,interval)
