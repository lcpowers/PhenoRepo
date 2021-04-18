# Getting historical weather data from Neon
# PAY ATTENTION TO THE DATES IN DOWNLOADS!!
# PLEASE UPDATE THIS LINE IF USED: Last download was for period from 2016-12-13 to 2021-04-17. Additional downloads for the products in this file should start at 2021-04-17

library(neonstore)
library(tidyverse)
library(neonUtilities)
rm(list=ls())
Sys.setenv("NEONSTORE_HOME" = "data/drivers/neon/")
Sys.setenv("NEONSTORE_DB" = "data/drivers/neon/")
sites <- c('STEI', 'UKFS', 'DELA')
#sites <- c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")

# This is the earliest date in targets. Use this date if acquiring a new date product, otherwise see the date immediately above the date products below
start_date <- "2016-12-13"
# Last date downloaded was 2021-04-17
# start_date <- "2021-04-17" ## UPDATE IF DOWNLOADING NEW DATA -- Ideally append new data to existing files

for(site in sites){
  site = sites[1]
  dir.create(paste0("data/drivers/neon/",site))
  # RH <- loadByProduct(dpID="DP1.00098.001", 
  #                     site=site, 
  #                     startdate=start_date,
  #                     package="basic",
  #                     check.size=F)
  # rh_df <- RH$RH_30min
  # write_csv(rh_df,paste0("data/drivers/neon/",site,"/relhum.csv"))
  # rh_vars <- RH$variables_00098
  # write_csv(rh_vars,paste0("data/drivers/neon/",site,"/relhum_vars.csv"))
  #  
  # Wind <- loadByProduct(dpID="DP1.00001.001", 
  #                       site=site, 
  #                       startdate=start_date,
  #                       package="basic",
  #                       check.size=F)
  # wind_df<- Wind$`2DWSD_30min`
  # write_csv(wind_df,paste0("data/drivers/neon/",site,"/wind.csv"))
  # write_csv(as.data.frame(Wind$variables_00001),
  #           paste0("data/drivers/neon/",site,"/wind_vars.csv"))
  # 
  # Precip <- loadByProduct(dpID="DP1.00006.001", 
  #                         site=site, 
  #                         startdate=start_date,
  #                         package="basic",
  #                         check.size=F)
  # # primary_precip <- Precip
  # write_csv(primary_precip,paste0("data/drivers/neon/",site,"/prim_precip.csv"))
  # secondary_precip <- Precip$SECPRE_30min
  # write_csv(secondary_precip,paste0("data/drivers/neon/",site,"/sec_precip.csv"))
  # tf_precip <- Precip$THRPRE_30min
  # write_csv(tf_precip,paste0("data/drivers/neon/",site,"/tf_precip.csv"))
  # write_csv(as.data.frame(Precip$variables_00006),
  #           paste0("data/drivers/neon/",site,"/precip_vars.csv"))
  
  Temp <- loadByProduct(dpID="DP1.00002.001", 
                        site=site, 
                        startdate=start_date,
                        package="basic",
                        check.size=F)

  temp_df <- Temp$SAAT_30min
  write_csv(temp_df,paste0("data/drivers/neon/",site,"/temp.csv"))
  write_csv(as.data.frame(Temp$variables_00002),
            paste0("data/drivers/neon/",site,"/temp_vars.csv"))
  
  rm(Temp,temp_df,Precip,primary_precip,Wind,wind_df,RH,rh_df,rh_vars)
}

# Process weather data
# Temp
# STEI, UKFS, DELA
sites <- c("HARV", "BART", "SCBI", "GRSM", "CLBJ",'STEI', 'UKFS', 'DELA')

all_temp <- NULL
for(site in sites){

  tmp_temp <- read.csv(paste0("data/drivers/neon/",site,"/temp.csv")) 
  tmp_temp$date <- str_sub(tmp_temp$startDateTime,1,10)
  tmp_temp$time <- str_sub(tmp_temp$startDateTime,12,19)
  
  output_temp <- tmp_temp %>% 
    filter(time%in%c('11:00:00','11:30:00','12:00:00','12:30:00')) %>% 
    group_by(date,siteID) %>% 
    summarize(mean = mean(tempSingleMean,na.rm=T),
              min = min(tempSingleMinimum,na.rm=T),
              max = max(tempSingleMaximum,na.rm=T),
              var = max(tempSingleVariance,na.rm=T),
              expuncert = max(tempSingleExpUncert,na.rm=T),
              meanstderr = max(tempSingleStdErMean,na.rm=T)) 
  
  output_temp$mean[is.nan(output_temp$mean)]<-NA
  output_temp$min[is.na(output_temp$mean)]<-NA
  output_temp$max[is.na(output_temp$mean)]<-NA
  output_temp$var[is.na(output_temp$mean)]<-NA
  output_temp$expuncert[is.na(output_temp$mean)]<-NA
  output_temp$meanstderr[is.na(output_temp$mean)]<-NA
  
  all_temp <- rbind(all_temp,output_temp)
  rm(tmp_temp,tmp_temp2,output_temp)
  
}

write_csv(all_temp,"data/drivers/neon/temperature.csv")
