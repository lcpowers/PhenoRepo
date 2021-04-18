# Getting historical weather data from Neon
# PAY ATTENTION TO THE DATES IN DOWNLOADS!!
# PLEASE UPDATE THIS LINE IF USED: Last download was for period from 2016-12-13 to 2021-04-17. Additional downloads for the products in this file should start at 2021-04-17

library(neonstore)
library(tidyverse)
library(neonUtilities)
rm(list=ls())
Sys.setenv("NEONSTORE_HOME" = "data/drivers/neon/")
Sys.setenv("NEONSTORE_DB" = "data/drivers/neon/")

sites <- c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")

# CP: Remember to delete this line
sites <- c("BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")
# This is the earliest date in targets. Use this date if acquiring a new date product, otherwise see the date immediately above the date products below
start_date <- "2016-12-13"
# Last date downloaded was 2021-04-17
# start_date <- "2021-04-17" ## UPDATE IF DOWNLOADING NEW DATA -- Ideally append new data to existing files

for(site in sites){
  
  dir.create(paste0("data/drivers/neon/",site))
  RH <- loadByProduct(dpID="DP1.00098.001", 
                      site=site, 
                      startdate=start_date,
                      package="basic",
                      check.size=F)
  rh_df <- RH$RH_30min
  write_csv(rh_df,paste0("data/drivers/neon/",site,"/relhum.csv"))
  rh_vars <- RH$variables_00098
  write_csv(rh_vars,paste0("data/drivers/neon/",site,"/relhum_vars.csv"))
  
  Wind <- loadByProduct(dpID="DP1.00001.001", 
                        site=site, 
                        startdate=start_date,
                        package="basic",
                        check.size=F)
  wind_df<- Wind$`2DWSD_30min`
  write_csv(wind_df,paste0("data/drivers/neon/",site,"/wind.csv"))
  write_csv(as.data.frame(Wind$variables_00001),
            paste0("data/drivers/neon/",site,"/wind_vars.csv"))
  
  Precip <- loadByProduct(dpID="DP1.00006.001", 
                          site=site, 
                          startdate=start_date,
                          package="basic",
                          check.size=F)
  primary_precip <- Precip$PRIPRE_30min
  write_csv(primary_precip,paste0("data/drivers/neon/",site,"/prim_precip.csv"))
  secondary_precip <- Precip$SECPRE_30min
  write_csv(secondary_precip,paste0("data/drivers/neon/",site,"/sec_precip.csv"))
  tf_precip <- Precip$THRPRE_30min
  write_csv(tf_precip,paste0("data/drivers/neon/",site,"/tf_precip.csv"))
  write_csv(as.data.frame(Precip$variables_00006),
            paste0("data/drivers/neon/",site,"/precip_vars.csv"))
  
  Temp <- loadByProduct(dpID="DP1.00002.001", 
                        site=site, 
                        startdate=start_date,
                        package="basic",
                        check.size=F)

  temp_df <- Temp$SAAT_30min
  write_csv(temp_df,paste0("data/drivers/neon/",site,"/temp.csv"))
  write_csv(as.data.frame(Temp$variables_00002),
            paste0("data/drivers/neon/",site,"/temp_vars.csv"))
}

