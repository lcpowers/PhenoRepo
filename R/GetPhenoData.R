# Get pheno data

library(tidyverse)
library(corrplot)
library(RColorBrewer)
rm(list=ls())

source("R/NEON/downloadPhenoCam.R")
source("R/NEON/calculatePhenoCamUncertainty.R")

##Selected Sites for Challenge
siteIDs <- c("NEON.D01.HARV.DP1.00033","NEON.D01.BART.DP1.00033","NEON.D02.SCBI.DP1.00033",
             "NEON.D05.STEI.DP1.00033","NEON.D06.UKFS.DP1.00033","NEON.D07.GRSM.DP1.00033",
             "NEON.D08.DELA.DP1.00033","NEON.D11.CLBJ.DP1.00033")

site_names <- c("HARV", "BART", "SCBI", "STEI", "UKFS", "GRSM", "DELA", "CLBJ")

message(paste0("Downloading and generating phenology targets ", Sys.time()))

# Initialize alldata df
allData <- data.frame(matrix(nrow = 0, ncol = 5))

for(i in 1:length(siteIDs)){
  # Create a subdirectory for site
  dir.create(paste0("data/",site_names[i]))
  
  # Print site name
  siteName <- siteIDs[i]
  message(siteName)
  
  # Get data URL
  if(siteName != "NEON.D11.CLBJ.DP1.00033"){
    URL_gcc90 <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_1000_1day.csv",sep="") ##URL for daily summary statistics
    URL_individual <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_1000_roistats.csv",sep="") ##URL for individual image metrics
  }else{
    URL_gcc90 <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_2000_1day.csv",sep="") ##URL for daily summary statistics
    URL_individual <- paste('https://phenocam.sr.unh.edu/data/archive/',siteName,"/ROI/",siteName,"_DB_2000_roistats.csv",sep="") ##URL for individual image metrics
  }
  
  # Get data aggregated by day and write to site subdirectory
  phenoData <- download.phenocam(URL = URL_gcc90)
  write.csv(phenoData,paste0("data/",site_names[i],"/",site_names[i],"_daily.csv"))
  
  dates <- unique(phenoData$date)
  
  # Get unaggregated data and write to site subdirectory
  phenoData_individual <- download.phenocam(URL=URL_individual,skipNum = 17)
  write.csv(phenoData,paste0("data/",site_names[i],"/",site_names[i],"_individual.csv"))
  
  # Calculate gcc SD
  gcc_sd <- calculate.phenocam.uncertainty(dat=phenoData_individual,dates=dates) ##Calculates standard deviations on daily gcc90 values
  
  # Get GCC data and write to site subdirectory
  subPhenoData <- phenoData %>% 
    mutate(siteID = stringr::str_sub(siteName, 10, 13), 
           time = date) %>% 
    select(time, siteID, gcc_90)
  subPhenoData <- cbind(subPhenoData,gcc_sd)
  write.csv(phenoData,paste0("data/",site_names[i],"/",site_names[i],"_gccTargets.csv"))
  
  allData <- rbind(allData,subPhenoData)
  
  ggplot(allData,aes(x=time,y=gcc_90))+
    # geom_ribbon(aes(ymin=gcc_90-gcc_sd,ymax=gcc_90+gcc_sd))+
    geom_line(aes(color=gcc_90))+
    scale_color_gradient(low="white",high="darkgreen")+
    theme_classic()
  
  ggsave(paste0("DataExplorationPlots/time_vs_gcc90_",site_names[i],".png"))
  
}

full_time <- seq(min(allData$time),max(allData$time), by = "1 day")

full_time <- tibble(time = rep(full_time, 8),
                    siteID = c(rep("HARV", length(full_time)),
                               rep("BART", length(full_time)),
                               rep("SCBI", length(full_time)),
                               rep("STEI", length(full_time)),
                               rep("UKFS", length(full_time)),
                               rep("GRSM", length(full_time)),
                               rep("DELA", length(full_time)),
                               rep("CLBJ", length(full_time))))


allData <- left_join(full_time, allData, by = c("time", "siteID"))
readr::write_csv(allData, "data/allsites_gccTargets.csv")
