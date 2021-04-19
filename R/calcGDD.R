# This script takes NEON temperature data
# Uses it to calculate cummulative growing degree days
# Uses that GDD value to find the add GDD value per day
# Finds the logical value (above base temp or no)
# And finally finds the number of GDD days for the year to date

library(tidyverse)
rm(list=ls())

# sites <- "GRSM"
sites = c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")

temp_df <- read_csv("data/drivers/neon/temps_allsites.csv") %>% 
  filter(!is.na(daily_min)&!is.na(daily_max))

gdd_fun <- function(tmin,tmax,tbase){
  
  gdd <- (tmin+tmax)/2-tbase
  gdd <- ifelse(gdd<0,0,gdd)
  return(gdd)
  
}

gdd_df <- NULL

for(site in sites){
  
  site_df <- temp_df %>% 
    filter(siteID==site)
  
  years <- unique(substr(site_df$date, 1,4))
  
  for(year in years){
    
    year_df <- site_df %>% 
      filter(str_detect(date,year))
  
    year_df$GDDdaily <- gdd_fun(tmin=year_df$daily_min,
                           tmax=year_df$daily_max,
                           tbase = 10)
      
    
    GDDtotal <- diffinv(year_df$GDDdaily,lag = 1)
    year_df$GDDtotal <- GDDtotal[2:length(GDDtotal)]
    year_df$GDDlogic <- ifelse(year_df$GDDdaily>0,1,0)
    year_df$GDDdays <- NA
    for(rowi in 1:nrow(year_df)){
      year_df$GDDdays[rowi]<-sum(year_df$GDDlogic[1:rowi])
    }

    gdd_df <- rbind(gdd_df,year_df)
    rm(year_df)
    
  }
   
  rm(site_df,year,site,GDDtotal)
}

gdd_df$GDDlogic <- ifelse(gdd_df$GDDdaily>0,1,0)

write_csv(gdd_df,"data/drivers/neon/GDDandtemp_allsites.csv")

