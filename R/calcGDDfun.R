#' Function to calculate GDD values for input temperature data
#' 
#' @param temp_df
#' @param targets_df 
#' @param minT_colnum
#' @param maxT_colnum
#' @param window_size default = 7
#' @param int_method Interpolation method used to fill in missing temp data. See function na_interpolation function for options
#' 


calcGDDfun <- function(temp_df,targets_df=targets,minT_colnum=4,maxT_colnum=5,window_size=7,int_method="spline"){

  sites <- c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")
  basetemps <- read_csv("data/site_basetemps.csv")

  # all_temps <- NULL
  output_df <- NULL
  for(site in sites){
    
    # Pull in target data to check for missing dates
    site_targs <- filter(targets_df,siteID==site) %>% arrange(time)
    min_date <- min(site_targs$time) %>% as.Date()
    max_date <- max(site_targs$time) %>% as.Date()
    targ_date_vec <- seq(from = min_date,to = max_date,by='day')
    
    # Filter weather data for current sites
    site_wx <- temp_df %>% 
      filter(siteID==site) %>% 
      filter(date>=min_date)
      
    wx_date_vec <- site_wx$date
    
    # Find dates missing from weather data
    missingdates <- targ_date_vec[!(targ_date_vec%in%wx_date_vec)]
    
    # If the weather data is missing dates, fill them in 
    if(length(missingdates>0)){
      fill_dates <- data.frame(siteID=rep(site,length(missingdates)),
                             date=missingdates,
                             daily_mean=rep(NA,length(missingdates)),
                             daily_min=rep(NA,length(missingdates)),
                             daily_max=rep(NA,length(missingdates)),
                             source = rep('interp',length(missingdates)))
      site_wx <- rbind(site_wx,fill_dates) %>% arrange(date)
      
      # Fill in mean daily
      daily_mean <- zoo(site_wx$daily_mean,site_wx$date)
      daily_mean <- na_interpolation(daily_mean, option = "spline") %>% as.data.frame() %>% rownames_to_column()
      site_wx$daily_mean <- daily_mean$.
      
      # Fill in daily min
      daily_min <- zoo(site_wx$daily_min,site_wx$date)
      daily_min <- na_interpolation(daily_min, option = int_method) %>% as.data.frame() %>% rownames_to_column()
      site_wx$daily_min <- daily_min$.
      
      # Fill in daily_max
      daily_max <- zoo(site_wx$daily_max,site_wx$date)
      daily_max <- na_interpolation(daily_max, option = "spline") %>% as.data.frame() %>% rownames_to_column()
      site_wx$daily_max <- daily_max$.
      rm(daily_mean,daily_min,daily_max,fill_dates,missingdates)
      }
    
    
    ####### Calc GDD #######
    base_temp <- basetemps$Btemp[basetemps$siteID==site]
    
    site_wx$year <- substr(site_wx$date,1,4)
    years <- unique(site_wx$year)
    gdd_df <- NULL
    
    for(yeari in years){
      
      year_df <- site_wx %>% 
        dplyr::filter(year==yeari)
      
      year_df$GDDdaily <- gdd_fun(tmin=year_df$daily_min,
                                  tmax=year_df$daily_max,
                                  tbase = base_temp)
      
      GDDlag <- diffinv(year_df$GDDdaily,lag = 1)
      year_df <- year_df %>% 
        dplyr::mutate(GDDtotal = GDDlag[2:length(GDDlag)],
                      GDDyesno = ifelse(year_df$GDDdaily>0,1,0),
                      GDDdays = rep(NA,nrow(.)),
                      base_temp = rep(base_temp,nrow(year_df)))
      
      for(rowi in 1:nrow(year_df)){
        year_df$GDDdays[rowi]<-sum(year_df$GDDyesno[1:rowi])
      }
      gdd_df <- rbind(gdd_df,year_df)
    }
    gdd_df <- gdd_df %>% 
      mutate(MovAvg_GDDdaily = c(rep(NA,window_size-1),round(rollmean(GDDdaily,k=window_size),6)),
             MovAvg_GDDyesno = c(rep(NA,window_size-1),round(rollmean(GDDyesno,k=window_size),6)))
    
    gdd_df$daily_diff <- c(0,diff(gdd_df$GDDdaily))
    
    output_df <- rbind(output_df,gdd_df)
  }
  output_df$day <- yday(output_df$date)
  return(output_df)
}

gdd_fun <- function(tmin,tmax,tbase){
  
  gdd <- (tmin+tmax)/2-tbase
  gdd <- ifelse(gdd<0,0,gdd)
  return(gdd)
  
}

