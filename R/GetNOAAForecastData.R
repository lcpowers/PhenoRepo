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
noaa_df <- noaa_gefs_read(base_dir, date, cycle, unlist(site_list))
summary(noaa_df)
write_csv(noaa_df,paste0("data/drivers/noaa/",as.character(date),".csv"))
