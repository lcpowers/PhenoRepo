# This script takes NEON temperature data
# Uses it to calculate cummulative growing degree days
# Uses that GDD value to find the add GDD value per day
# Finds the logical value (above base temp or no)
# And finally finds the number of GDD days for the year to date

library(tidyverse)
library(pollen)
rm(list=ls())

# sites <- "GRSM"
sites = c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")

temp_df <- read_csv("data/drivers/neon/temperature.csv") %>% 
  filter(!is.na(mean))

gdd_df <- NULL

for(site in sites){
  
  site_df <- temp_df %>% 
    filter(siteID==site)
  
  years <- unique(substr(site_df$date, 1,4))
  
  for(year in years){
    
    year_df <- site_df %>% 
      filter(str_detect(date,year))
  
    year_df$GDD <- gdd(tmax=year_df$max,
                       tmin=year_df$min,
                       tbase=10,
                       tbase_max=20)
    gdd_df <- rbind(gdd_df,year_df)
    rm(year_df)
    
  }
   
  rm(site_df,year,site)
}

gdd_df$GDDdiff <- c(0,diff(gdd_df$GDD,lag=1))
gdd_df$GDDlogic <- ifelse(gdd_df$GDDdiff>0,1,0)

final_temp_df <- NULL
years <- unique(substr(gdd_df$date,1,4))

for(site in sites){
  
  site_df <- filter(gdd_df, siteID == site)
  years <- unique(substr(site_df$date, 1,4))
  
  years_df <- NULL
  for(year in years){
    
    year_df <- site_df %>% 
      filter(str_detect(date,year))
    
    year_df$GDDdays <- NA
    year_df$GDDdays[1] <- year_df$GDDlogic[1] 
    
    for(rowi in 2:nrow(year_df)){
      year_df$GDDdays[rowi] <- sum(year_df$GDDlogic[rowi-1:rowi])
      
    }
    years_df <- rbind(years_df,year_df)
    
  }
  final_temp_df <- rbind(final_temp_df,years_df)
}



