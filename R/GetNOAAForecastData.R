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
date <- "2021-04-15"
interval = "6hr"
cycle <- "12"
# Get current NOAA forecast data
lapply(site_list, download_noaa, cycle=cycle, dir = "data/drivers/",date=date,interval=interval)

# Extract forecast data and write to csv
base_dir <- "data/drivers/noaa/noaa/NOAAGEFS_6hr"

# DF here is the NOAA forecast data
noaa_raw_df <- noaa_gefs_read(base_dir, date, cycle, unlist(site_list))
write_csv(noaa_raw_df,paste0("data/drivers/noaa/noaa_raw_",as.character(date),".csv"))

noaa_df <- separate(data = noaa_raw_df,col = time,into = c("date","time"),sep = " ") %>% 
  filter(time=="12:00:00") %>%
  mutate(air_temp_C = as.numeric(air_temperature-273.15)) %>% 
  group_by(siteID,date) %>% 
  summarise(temp = mean(air_temp_C,na.rm=T),
            temp_sd = sd(air_temp_C,na.rm=T),
            temp_var = var(air_temp_C,na.rm=T))

write_csv(noaa_df,paste0("data/drivers/noaa/noaa_temp_4cast_",as.character(date),".csv"))
