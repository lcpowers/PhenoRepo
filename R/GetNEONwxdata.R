# Getting historical weather data from NEON

library(neonstore)
library(tidyverse)
library(neonUtilities)
#Sys.setenv("NEONSTORE_HOME" = "data/drivers/neon/")
#Sys.setenv("NEONSTORE_DB" = "data/drivers/neon/")

targets <- read_csv("data/pheno/phenology-targets.csv.gz")
sites <- unique(targets$siteID)
dir.create("data/drivers/neon/")

for(site in sites){
  
  # Read in temperature data from NEON
  Temp <- loadByProduct(dpID="DP1.00002.001",
                        site=site,
                        package="basic",
                        check.size=F)

  # Get the 
  temp_df <- Temp$SAAT_30min
  dir.create(paste0("data/drivers/neon/",site))
  write_csv(temp_df,paste0("data/drivers/neon/",site,"/temp.csv"))
  write_csv(as.data.frame(Temp$variables_00002),
            paste0("data/drivers/neon/",site,"/temp_vars.csv"))
  
  rm(Temp,temp_df)
}

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
    filter(time>="09:00:00"&time<="15:00:00") %>% 
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
  rm(tmp_temp,tmp_temp2,midday_temp,daily_temp,output_temp,site,sites)
  
}

write_csv(all_temp,"data/drivers/neon/temps_allsites.csv")
rm(all_temp)
#### Extra Precip code incase we bring that in

# Precip <- loadByProduct(dpID="DP1.00006.001",
#                         site=site,
#                         package="basic",
#                         check.size=F)
# primary_precip <- Precip$PRIPRE_30min
# if(!is.null(primary_precip)) {
#   write_csv(primary_precip,paste0("data/drivers/neon/",site,"/precip_prim.csv"))
# } else {
#     print(paste0("No primary precip: ",site))
#   }
# 
# secondary_precip <- Precip$SECPRE_30min
# if(!is.null(secondary_precip)) {
#   write_csv(secondary_precip,paste0("data/drivers/neon/",site,"/precip_sec.csv"))
# } else {
#   print(paste0("No secondary precip: ",site))
# }
# 
# tf_precip <- Precip$THRPRE_30min
# if(!is.null(tf_precip)) {
#   write_csv(tf_precip,paste0("data/drivers/neon/",site,"/precip_tf.csv"))
# } else {
#   print(paste0("No tf precip: ",site))
# }
# 
# write_csv(as.data.frame(Precip$variables_00006),
#           paste0("data/drivers/neon/",site,"/precip_vars.csv"))

