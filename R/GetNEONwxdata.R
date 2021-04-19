# Getting historical weather data from Neon
# PAY ATTENTION TO THE DATES IN DOWNLOADS!!
# PLEASE UPDATE THIS LINE IF USED: Last download was for period from 2016-12-13 to 2021-04-17. Additional downloads for the products in this file should start at 2021-04-17

library(neonstore)
library(tidyverse)
library(neonUtilities)
rm(list=ls())
#Sys.setenv("NEONSTORE_HOME" = "data/drivers/neon/")
#Sys.setenv("NEONSTORE_DB" = "data/drivers/neon/")

targets <- read_csv("data/pheno/allsites_gccTargets.csv")
sites <- c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")

# This is the earliest date in targets. Use this date if acquiring a new date product, otherwise see the date immediately above the date products below
start_date <- "2016-12-13"

# Last date downloaded was 2021-04-17
# start_date <- "2021-04-17" ## UPDATE IF DOWNLOADING NEW DATA -- Ideally append new data to existing files

for(site in sites){

  #dir.create(paste0("data/drivers/neon/",site))
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
  Precip <- loadByProduct(dpID="DP1.00006.001",
                          site=site,
                          startdate=start_date,
                          package="basic",
                          check.size=F)
  primary_precip <- Precip$PRIPRE_30min
  if(!is.null(primary_precip)) {
    write_csv(primary_precip,paste0("data/drivers/neon/",site,"/precip_prim.csv"))
  } else {
      print(paste0("No primary precip: ",site))
    }
  
  secondary_precip <- Precip$SECPRE_30min
  if(!is.null(secondary_precip)) {
    write_csv(secondary_precip,paste0("data/drivers/neon/",site,"/precip_sec.csv"))
  } else {
    print(paste0("No secondary precip: ",site))
  }
  
  tf_precip <- Precip$THRPRE_30min
  if(!is.null(tf_precip)) {
    write_csv(tf_precip,paste0("data/drivers/neon/",site,"/precip_tf.csv"))
  } else {
    print(paste0("No tf precip: ",site))
  }
  
  write_csv(as.data.frame(Precip$variables_00006),
            paste0("data/drivers/neon/",site,"/precip_vars.csv"))
  
  # Temp <- loadByProduct(dpID="DP1.00002.001",
  #                       site=site,
  #                       startdate=start_date,
  #                       package="basic",
  #                       check.size=F)
  # 
  # temp_df <- Temp$SAAT_30min
  # write_csv(temp_df,paste0("data/drivers/neon/",site,"/temp.csv"))
  # write_csv(as.data.frame(Temp$variables_00002),
  #           paste0("data/drivers/neon/",site,"/temp_vars.csv"))
  
  rm(Temp,temp_df,Precip,primary_precip,Wind,wind_df,RH,rh_df,rh_vars)
}

# Process weather data

sites <- c("HARV", "BART", "SCBI", "GRSM", "CLBJ",'STEI', 'UKFS', 'DELA')

# Temp
all_temp <- NULL
for(site in sites){

  tmp_temp <- read.csv(paste0("data/drivers/neon/",site,"/temp.csv")) 
  tmp_temp$date <- as.Date(str_sub(tmp_temp$startDateTime,1,10))
  tmp_temp$time <- str_sub(tmp_temp$startDateTime,12,19)
  
  daily_temp <- tmp_temp %>% 
    group_by(date,siteID) %>% 
    summarize(daily_mean=mean(tempSingleMean,na.rm=T),
              daily_min=min(tempSingleMinimum,na.rm=T),
              daily_max=max(tempSingleMaximum,na.rm=T),
              daily_var=var(tempSingleVariance,na.rm=T))
    
    
  daily_temp$daily_mean[is.nan(daily_temp$daily_mean)]<-NA
  daily_temp$daily_min[is.na(daily_temp$daily_mean)]<-NA
  daily_temp$daily_max[is.na(daily_temp$daily_mean)]<-NA
  
  midday_temp <- tmp_temp %>% 
    filter(time%in%c('11:00:00','11:30:00','12:00:00','12:30:00')) %>% 
    group_by(date,siteID) %>% 
    summarize(midday_mean = mean(tempSingleMean,na.rm=T),
              midday_min = min(tempSingleMinimum,na.rm=T),
              midday_max = max(tempSingleMaximum,na.rm=T),
              midday_var = max(tempSingleVariance,na.rm=T),
              midday_expuncert = max(tempSingleExpUncert,na.rm=T),
              midday_meanstderr = max(tempSingleStdErMean,na.rm=T)) 
  
  midday_temp$midday_mean[is.nan(midday_temp$midday_mean)]<-NA
  midday_temp$midday_min[is.na(midday_temp$midday_mean)]<-NA
  midday_temp$midday_max[is.na(midday_temp$midday_mean)]<-NA
  midday_temp$midday_var[is.na(midday_temp$midday_mean)]<-NA
  midday_temp$midday_expuncert[is.na(midday_temp$midday_mean)]<-NA
  midday_temp$midday_meanstderr[is.na(midday_temp$midday_mean)]<-NA
  
  output_temp <- merge(daily_temp,midday_temp)
  
  all_temp <- rbind(all_temp,output_temp)
  rm(tmp_temp,tmp_temp2,midday_temp)
  
}

write_csv(all_temp,"data/drivers/neon/temps_allsites.csv")
ggplot(all_temp,aes(x=date,y=daily_mean))+
  geom_point(aes(color=siteID))+
  facet_wrap(~siteID)

# Precip

