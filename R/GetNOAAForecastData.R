#'
#'
#'
#'
rm(list=ls())

library(tidyverse)
library(ncdf4)
library(neonstore)
library(neon4cast)
source("R/NEONscripts/noaa_gefs_read.R")

site_list <- list("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")
date <- Sys.Date()
interval = "6hr"
cycle <- "18"
# Get current NOAA forecast data
lapply(site_list, download_noaa, cycle=cycle, dir = "data/drivers/",date=date,interval=interval)

# Extract forecast data and write to csv
base_dir <- "data/drivers/noaa/noaa/NOAAGEFS_6hr"

# DF here is the NOAA forecast data
noaa_raw_df <- noaa_gefs_read(base_dir, date, cycle="06", unlist(site_list))
write_csv(noaa_raw_df,paste0("data/drivers/noaa/noaa_raw_",as.character(date),".csv"))

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
  filter(time=="12:00:00") %>% 
  group_by(siteID,date) %>% 
  summarise(midday_mean=mean(air_temp_C,na.rm=T),
            midday_var=var(air_temp_C,na.rm=T),
            midday_sd=sd(air_temp_C,na.rm=T))
setdiff(unique(daily_temps$date),unique(midday_temps$date))

all_data <- merge(daily_temps,midday_temps,all=T)

write_csv(all_data,paste0("data/drivers/noaa/noaa_temp_4cast_",as.character(date),".csv"))
