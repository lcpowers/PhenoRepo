# # This script takes NEON temperature data
# # Uses it to calculate cummulative growing degree days
# # Uses that GDD value to find the add GDD value per day
# # Finds the logical value (above base temp or no)
# # And finally finds the number of GDD days for the year to date
# 
# library(tidyverse)
# library(lubridate)
# library(zoo)
# rm(list=ls())
# 
# # sites <- "GRSM"
# sites = c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")
# 
# temp_df <- read_csv("data/drivers/neon/temps_allsites.csv") %>% 
#   filter(!is.na(daily_min)&!is.na(daily_max)) %>% 
#   mutate(year=substr(date,1,4),
#          doy=yday(date))
# 
# basetemps <- read_csv("data/site_basetemps.csv")
# 
# # Histogram of temperature values
# # ggplot(temp_df) + 
# #   geom_histogram(aes(x=daily_max),color='white',bins=50)+
# #   facet_wrap(~siteID,scales='free')+
# #   theme_classic()
# 
# # # xy plot of temperature values
# # ggplot(temp_df,aes(x=date,y=midday_mean))+
# #   geom_point(size=0.4)+
# #   facet_wrap(~siteID)+
# #   theme_classic()
# # 
# # # xy plot of temp on DOYs
# # ggplot(temp_df,aes(x=date,y=daily_mean))+
# #   geom_point(size=0.4)+
# #   facet_wrap(~siteID)+
# #   theme_classic()
# 
# gdd_fun <- function(tmin,tmax,tbase){
#   
#   gdd <- (tmin+tmax)/2-tbase
#   gdd <- ifelse(gdd<0,0,gdd)
#   return(gdd)
#   
# }
# 
# window_size = 7
# gdd_df <- NULL

for(site in sites){
  output_df <- NULL
  
  site_df <- temp_df %>% 
    filter(siteID==site)
  base_temp <- basetemps$Btemp[basetemps$siteID==site]
  
  years <- unique(substr(site_df$year, 1,4))
  for(yeari in years){
    
    year_df <- site_df %>% 
      dplyr::filter(year==yeari)
  
    year_df$GDDdaily <- gdd_fun(tmin=year_df$daily_min,
                           tmax=year_df$daily_max,
                           tbase = base_temp)

    GDDtotal <- diffinv(year_df$GDDdaily,lag = 1)
    year_df <- year_df %>% 
      dplyr::mutate(GDDtotal = GDDtotal[2:length(GDDtotal)],
                    GDDyesno = ifelse(year_df$GDDdaily>0,1,0),
                    GDDdays = rep(NA,nrow(.)),
                    base_temp = rep(base_temp,nrow(year_df)))

    for(rowi in 1:nrow(year_df)){
      year_df$GDDdays[rowi]<-sum(year_df$GDDyesno[1:rowi])
    }

    
    output_df <- rbind(output_df,year_df)
    #rm(year_df)
    
  }
  
  output_df <- output_df %>% 
    mutate(MovAvg_GDDdaily = c(rep(NA,window_size-1),round(rollmean(GDDdaily,k=window_size),6)),
           MovAvg_GDDyesno = c(rep(NA,window_size-1),round(rollmean(GDDyesno,k=window_size),6)))
  gdd_df <- rbind(gdd_df,output_df)
 # rm(site_df,year,site,GDDtotal)
}

write_csv(gdd_df,"data/drivers/neon/GDDandtemp_allsites.csv")

targets_df <- read_csv("phenology-targets.csv.gz")
all_df <- merge(gdd_df,targets_df ,all.x=T, by.x = c("date","siteID"), by.y = c("time","siteID"))



# df_len <- length(sites)*length(base_temps)

# rsquares <- NULL
# 
# for(site in 1:length(sites)){
#   site_df <- all_df %>% filter(siteID==sites[site])
#   tmp_df <- data.frame(siteID=rep(NA,length(base_temps)),
#                        Btemp=rep(NA,length(base_temps)),
#                        rsquare=rep(NA,length(base_temps)))
#   for(base_temp in 1:length(base_temps)){
#     
#     temp <- as.numeric(base_temps[base_temp])
#     df <- site_df %>% filter(base_temp==temp)
#     lm <- summary(lm(gcc_90~GDDdaily,data=df))
#     
#     tmp_df$siteID[base_temp] = sites[site]
#     tmp_df$Btemp[base_temp] = base_temps[base_temp]
#     tmp_df$rsquare[base_temp] = lm$r.squared
#   }
#   
#   rsquares <- rbind(rsquares,tmp_df)
#   rm(tmp_df)
# }
# 
# 
# site_basetemps <- rsquares %>% 
#   group_by(siteID) %>% 
#   summarise(best_r = max(rsquare))
# 
# vec = NULL
# for(rowi in 1:nrow(site_basetemps)){
#   
#   idx = which(rsquares$rsquare==site_basetemps$best_r[rowi])
#   vec = append(x = vec,idx)
#   
# }
# 
# site_basetemps <- rsquares[vec,]
# write_csv(site_basetemps,"data/site_basetemps.csv")
# 
# ggplot(rsquares,aes(x=Btemp,y=rsquare))+
#   geom_point(aes(color=siteID))+
#   geom_line(aes(color=siteID))+
#   theme_classic()






